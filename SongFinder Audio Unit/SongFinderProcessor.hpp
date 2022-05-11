#ifndef SONG_FINDER_PROCESSOR
#define SONG_FINDER_PROCESSOR


#include <iostream>
#include <map>
#include <string>
#include <vector>
#include "AdvancingBuffer.hpp"
#include "FirFilter.hpp"
#include "HbaFilters.hpp"
#include "Interpolator.hpp"
#include "OverlapAdder.hpp"


using std::map;
using std::string;
using std::vector;


// forward function declarations
vector<float> _get_hp_filter_coeffs(unsigned);
vector<float> _get_interpolator_filter_coeffs(unsigned);


// TODO: Understand and document conditions under which subprocessors
// will always produce same number of outputs as inputs. I think this
// is if you prime the input with one window's worth of samples, but
// I'm not sure if that's true and why. If we can provide such a
// (conditional) guarantee, remove zero padding from `process` method.
// Also make `prime_input` argument optional, and have it default to
// the minimum number of priming samples needed for guarantee.


class SongFinderProcessor {


public:


    // The SongFinder sample rate is fixed so we can design its
    // filters in advance.
    static constexpr double sample_rate = 48000;


    SongFinderProcessor(

        size_t max_input_size,
        unsigned cutoff,
        unsigned pitch_shift_factor,
        string window_type,
        double window_size

	) :

        _max_input_size(max_input_size),
        _cutoff(cutoff),
	    _pitch_shift_factor(pitch_shift_factor),
        _window_type(window_type),
        _window_size(window_size),

        _input_buffer(_buffer_size * _max_input_size),
        _ola_buffer(_buffer_size * _max_input_size / _pitch_shift_factor),
        _hp_buffer(_buffer_size * _max_input_size / _pitch_shift_factor),
        _output_buffer(_buffer_size * _max_input_size),

        _overlap_adder(
            _pitch_shift_factor, _window_type, _window_size, sample_rate,
            _input_buffer, _ola_buffer),

        _hp_filter(_get_hp_filter_coeffs(_cutoff), _ola_buffer, _hp_buffer),

        _interpolator(
            _pitch_shift_factor,
            _get_interpolator_filter_coeffs(_pitch_shift_factor),
            _cutoff == 0 ? _ola_buffer : _hp_buffer,
            _output_buffer),

        _input_buffer_num(0)
	
	{

    }


    void prime_input(size_t input_count) {
        _input_buffer.append_zeros(input_count);
    }



    void process(const float *input, size_t input_count, float *output) {

        size_t output_count = 0;
        size_t zero_count = 0;

        if (input_count > _max_input_size) {
            // input count exceeds max configured size

            zero_count = input_count;

        } else {
            // input count does not exceed max configured size

            // Process input.
            _input_buffer.append(input, input_count);
            _overlap_adder.process();

            if (_cutoff == 0) {
                _interpolator.process();
            } else {
                _hp_filter.process();
                _interpolator.process();
            }

            // Update output and zero counts as needed.
            output_count = _output_buffer.size();
            if (output_count > input_count)
                output_count = input_count;
            else if (output_count < input_count)
                zero_count = input_count - output_count;

        }

        if (output_count != 0) {

            // Copy from processor output buffer to output array.
            const float *data = _output_buffer.data();
            const size_t size = output_count * sizeof(float);
            std::memcpy(output, data, size);

            // Discard copied samples from processor output buffer.
            _output_buffer.discard(output_count);

        }

        if (zero_count != 0) {

            for (size_t i = 0; i != zero_count; ++i)
                output[i] = 0;

            std::cout << "SongFinderProcessor: " << _input_buffer_num <<
                " " << input_count << " " << output_count << " " <<
                zero_count << std::endl;

        }

        _input_buffer_num += 1;

    }


private:

    static const size_t _buffer_size = 50;    // _max_input_size units

    size_t _max_input_size;
    unsigned _cutoff;
    unsigned _pitch_shift_factor;
    string _window_type;
    double _window_size;

    AdvancingBuffer<float> _input_buffer;
    AdvancingBuffer<float> _ola_buffer;
    AdvancingBuffer<float> _hp_buffer;
    AdvancingBuffer<float> _output_buffer;

    OverlapAdder _overlap_adder;
    FirFilter _hp_filter;
    Interpolator _interpolator;

    unsigned _input_buffer_num;


};


const vector<float> dummy_filter { 1 };


vector<float> _get_hp_filter_coeffs(unsigned cutoff) {
    if (cutoff == 0)
        return dummy_filter;
    else
        return highpass_filters.at(cutoff);
}


vector<float> _get_interpolator_filter_coeffs(unsigned shift) {
    const vector<float> unscaled_filter = lowpass_filters.at(shift);
    const size_t filter_length = unscaled_filter.size();
    vector<float> scaled_filter(filter_length);
    for (size_t i = 0; i != filter_length; ++i)
        scaled_filter[i] = shift * unscaled_filter[i];
    return scaled_filter;

}


#endif
