//
//  OverlapAdder.hpp
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


#ifndef OVERLAP_ADDER
#define OVERLAP_ADDER


#include <cmath>
#include <cstring>
#include <numbers>
#include "AdvancingBuffer.hpp"


using std::size_t;
using std::string;


class OverlapAdder {


public:


    OverlapAdder(

        unsigned decimation_factor,
        string window_type,
        double window_duration,
        double sample_rate,
        AdvancingBuffer<float> &input_buffer,
        AdvancingBuffer<float> &output_buffer

    ) :

        _decimation_factor(decimation_factor),
        _window_type(window_type),
        _window_duration(window_duration),
        _sample_rate(sample_rate),
        _input_buffer(input_buffer),
        _output_buffer(output_buffer)
    
    {

        const double segment_duration = _window_duration / _decimation_factor;
        _segment_size =
            static_cast<size_t>(round(segment_duration * _sample_rate));
        _window_size = _decimation_factor * _segment_size;
        _window = _create_window(_window_type);

        const size_t accumulator_size =
            (_decimation_factor - 1) * _segment_size;
        _accumulator = new float[accumulator_size]();
        _accumulator_end = _accumulator + accumulator_size;
        _accumulator_ptr = _accumulator;

    }


    string window_type() {
        return _window_type;
    }


    vector<float> window() {
        const vector<float> window(_window, _window + _window_size);
        return window;
    }


    void process() {

        const size_t window_count = _input_buffer.size() / _window_size;
        const size_t internal_segment_count = _decimation_factor - 2;

        const float *x = _input_buffer.data();
        float *a = _accumulator_ptr;

        float *y = _output_buffer.extend(window_count * _segment_size);

        for (size_t i = 0; i != window_count; ++i) {

            const float *w = _window;

            // Process initial window segment, generating output.
            for (size_t j = 0; j != _segment_size; ++j)
                *y++ = *a++ + *w++ * *x++;

            // Wrap around to beginning of accumulator if needed.
            if (a == _accumulator_end)
                a = _accumulator;

            // Process internal (i.e. neither initial nor final) window
            // segment(s), accumulating results but generating no output.
            for (size_t k = 0; k != internal_segment_count; ++k) {

                // Apply internal window segment to next input segment
                // and accumulate.
                for (size_t j = 0; j != _segment_size; ++j)
                    *a++ += *w++ * *x++;

                // Wrap around to beginning of accumulator if needed.
                if (a == _accumulator_end)
                    a = _accumulator;

            }

            // Process final window segment, writing results to accumulator.
            for (size_t j = 0; j != _segment_size; ++j)
                *a++ = *w++ * *x++;

            // Wrap around to beginning of accumulator if needed.
            if (a == _accumulator_end)
                a = _accumulator;

        }

        // Remember accumulator pointer for next time.
        _accumulator_ptr = a;
        
        // Discard processed inputs.
        _input_buffer.discard(window_count * _window_size);

    }


private:


    unsigned _decimation_factor;
    string _window_type;
    double _window_duration;
    double _sample_rate;
    AdvancingBuffer<float> &_input_buffer;
    AdvancingBuffer<float> &_output_buffer;

    size_t _window_size;
    size_t _segment_size;    // window segment size
    float *_window;
    float *_accumulator;
    float *_accumulator_end;
    float *_accumulator_ptr;


    float *_create_window(string window_type) {

        if (window_type == "SongFinder")
            return _create_song_finder_window();

        else
            return _create_hann_window();

    }


    float *_create_hann_window() {

        // Note that this function returns a symmetric window whose first
        // coefficient is not zero. We omit the leading zero of the
        // asymmetric Hann window of length _window_size + 1, or
        // equivalently the leading and trailing zeros of the symmetric
        // Hann window of length _window_size + 2.

        float *window = new float[_window_size];
        const float scale_factor = 1. / _decimation_factor;
        const float phase_factor = 2. * std::numbers::pi / (_window_size + 1);

        for (size_t i = 0; i != _window_size; ++i)
            window[i] = scale_factor * (1 - cos(phase_factor * (i + 1)));

        return window;

    }


    float *_create_song_finder_window() {

        // This method creates a window that is applied (i.e. multipled
        // sample by sample) to successive, non-overlapping input
        // segments as part of the overlap-add process. The window is
        // the concatenation of `_decimation_factor` segments of length
        // `_window_size / _decimation_factor`, and the segments sum to
        // a segment of ones.
        //
        // When the decimation factor is 2 or 4, the window is triangular.
        //
        // When the decimation factor is 3, the window ramps up in its
        // first segment, is constant in its middle segment, and ramps
        // down in its final segment.
        //
        // The windows created by this method are those that were used
        // in the SongFinder product.

        float *window = new float[_window_size];

        if (_decimation_factor % 2 == 0) {
            // decimation factor is 2 or 4

            size_t half_window_size = _window_size / 2;

            const float f =
                1.0f / (half_window_size + 1) / (_decimation_factor / 2);

            for (size_t i = 0; i != half_window_size; ++i) {
                const float x = (i + 1) * f;
                window[i] = x;
                window[_window_size - 1 - i] = x;
            }

        } else {
            // decimation factor is 3

            const float f = .5f / (_segment_size + 1);

            for (size_t i = 0; i != _segment_size; ++i) {
                const float x = (i + 1) * f;
                window[i] = x;
                window[_window_size - 1 - i] = x;
                window[i + _segment_size] = .5f;
            }

        }

        return window;

    }


};


#endif
