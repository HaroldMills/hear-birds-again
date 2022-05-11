#ifndef INTERPOLATOR
#define INTERPOLATOR


#include <cmath>
#include "AdvancingBuffer.hpp"


using std::size_t;
using std::vector;


class Interpolator {


public:


    Interpolator(

        unsigned interpolation_factor,
		const vector<float> &filter,
		AdvancingBuffer<float> &input_buffer,
		AdvancingBuffer<float> &output_buffer

	) :

	    _interpolation_factor(interpolation_factor),
		_filter(filter),
		_input_buffer(input_buffer),
		_output_buffer(output_buffer)
	
	{

    	_filter_length = _filter.size();

    	const float n = static_cast<float>(_filter_length);
    	_input_record_size =
		    static_cast<size_t>(ceil(n / _interpolation_factor));

    	_reversed_filter = _reverse(_filter);

    	// Prime input buffer with zeros so interpolator can compute
    	// `interpolation_factor` output samples for each subsequent
    	// input sample.
    	_input_buffer.append_zeros(_input_record_size - 1);

    }


    unsigned interpolation_factor() {
    	return _interpolation_factor;
    }


    vector<float> filter() {
        return vector<float>(_filter);
    }


    void process() {

    	// Get the number of output records that we will produce.
    	const size_t output_record_count =
    		_input_buffer.size() - _input_record_size + 1;

    	// Get pointer to last sample of first input record.
    	const float *x = _input_buffer.data() + _input_record_size - 1;

    	// Extend output buffer and get pointer to first output sample.
    	float *y = _output_buffer.extend(
    		output_record_count * _interpolation_factor);

    	const unsigned interpolation_factor = _interpolation_factor;
    	const float *reversed_filter = _reversed_filter;
    	const float *reversed_filter_end = reversed_filter + _filter_length;

    	for (size_t i = 0; i != output_record_count; ++i) {

    		// For each input record we compute an output record
    		// comprising `interpolation_factor` samples. Each sample
    		// of the output record is the inner product of the filter
    		// coefficient vector with a vector of consecutive samples
    		// from an upsampled version of the input, i.e. the input
    		// with `interpolation_factor - 1` zero samples inserted
    		// between each pair of consecutive input samples. The
    		// upsampled input vector used to compute the first sample
    		// of the output record ends at the last sample of the input
    		// record, the upsampled input vector used compute the
    		// second sample of the output record ends at the first
    		// zero inserted after the last sample of the input record,
    		// and so on.
    		//
    		// For example, suppose that the interpolation factor is
    		// three and the filter length is eight. In the following
    		// diagram, the first line represents an upsampled input
    		// sequence, with each "|" representing an input sample and
    		// each "." representing an inserted zero sample. The
    		// remaining lines indicate which filter coefficients are
    		// multiplied by which upsampled input samples to produce
    		// the three samples of the output record produced from
    		// the fourth input sample and the two input samples that
    		// precede it. In the filter coefficient lines, each "+"
    		// indicates a filter coefficient that is multiplied by
    		// an input sample, and each "-" indicates a filter
    		// coefficient that is multiplied by an inserted zero.
    		// For efficiency's sake, we do not actually insert zero
    		// samples and multiply by them in the code below. To make
    		// the code a little simpler to think about and write, we
    		// also store the filter coefficients in reversed order
    		// and compute our inner products backward in time rather
    		// than forward, i.e. from right to left in the diagram
    		// rather than from left to right.
    		//
    		//     |..|..|..|..|..|
    		//       -+--+--+
    		//        +--+--+-
    		//         --+--+--

    		for (unsigned j = 0; j != interpolation_factor; ++j) {

        		const float *z = x;

				// Get pointer to filter coefficient that will multiply
				// last sample of input record.
    		    const float *f = reversed_filter + j;

    		    *y = 0;

    		    // Compute inner product of filter coefficients with
    		    // input samples, moving backward in time.
				while (f < reversed_filter_end) {
						*y += *z-- * *f;
						f += interpolation_factor;
				}

				++y;

    		}

		    ++x;

    	}

    	_input_buffer.discard(output_record_count);

    }


private:


    unsigned _interpolation_factor;
	vector<float> _filter;
    size_t _filter_length;
    float *_reversed_filter;
	AdvancingBuffer<float> &_input_buffer;
    AdvancingBuffer<float> &_output_buffer;

    // The number of input samples required to produce each record
	// of _interpolation_factor consecutive output samples.
    size_t _input_record_size;

    static float *_reverse(vector<float> &v) {
    	float *result = new float[v.size()];
		float *q = result;
		for (auto p = v.rbegin(); p != v.rend(); )
		    *q++ = *p++;
    	return result;
    }


};


#endif
