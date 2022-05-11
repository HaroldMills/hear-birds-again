#ifndef FIR_FILTER
#define FIR_FILTER


#include <vector>
#include "AdvancingBuffer.hpp"


using std::size_t;
using std::vector;


class FirFilter {


public:


    FirFilter(

		const vector<float> &coeffs,
		AdvancingBuffer<float> &input_buffer,
		AdvancingBuffer<float> &output_buffer

	) :

		_coeffs(coeffs),
		_input_buffer(input_buffer),
		_output_buffer(output_buffer)
	
	{

    	_length = _coeffs.size();

    	_reversed_coeffs = _reverse(_coeffs);

    	// Prime input buffer with zeros so filter can compute
    	// one output sample for each subsequent input sample.
    	_input_buffer.append_zeros(_length - 1);

    }


    vector<float> coeffs() {
        return vector<float>(_coeffs);
    }


    void process() {

    	// Get the number of output samples that we will produce.
    	const size_t output_count = _input_buffer.size() - _length + 1;

    	// Get pointer to first input sample.
    	const float *x = _input_buffer.data();

    	// Extend output buffer and get pointer to first output sample.
    	float *y = _output_buffer.extend(output_count);

    	const float *reversed_coeffs = _reversed_coeffs;
    	const float *reversed_coeffs_end = reversed_coeffs + _length;

    	for (size_t i = 0; i != output_count; ++i) {

            const float *z = x;

            // Get pointer to filter coefficient that will multiply
            // first sample of input record.
            const float *c = reversed_coeffs;

            *y = 0;

            // Compute inner product of input samples and filter coefficients.
            while (c != reversed_coeffs_end) {
                *y += *z++ * *c;
                ++c;
            }

            ++y;
		    ++x;

    	}

    	_input_buffer.discard(output_count);

    }


private:


	vector<float> _coeffs;
    size_t _length;
    float *_reversed_coeffs;
	AdvancingBuffer<float> &_input_buffer;
    AdvancingBuffer<float> &_output_buffer;

    static float *_reverse(vector<float> &v) {
    	float *result = new float[v.size()];
		float *q = result;
		for (auto p = v.rbegin(); p != v.rend(); )
		    *q++ = *p++;
    	return result;
    }


};


#endif
