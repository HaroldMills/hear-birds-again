#ifndef SONG_FINDER_PROCESSOR
#define SONG_FINDER_PROCESSOR


#include <iostream>
#include <map>
#include <string>
#include <vector>
#include "AdvancingBuffer.hpp"
#include "Interpolator.hpp"
#include "OverlapAdder.hpp"


using std::map;
using std::string;
using std::vector;


// forward function declarations
vector<float> _get_interpolator_filter(unsigned);


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
    // interpolator filters in advance.
    static constexpr double sample_rate = 48000;


    SongFinderProcessor(

        size_t max_input_size,
        unsigned pitch_shift_factor,
        string window_type,
        double window_size

	) :

        _max_input_size(max_input_size),
	    _pitch_shift_factor(pitch_shift_factor),
        _window_type(window_type),
        _window_size(window_size),

        _input_buffer(_buffer_size * _max_input_size),

        _ola_buffer(_buffer_size * _max_input_size / _pitch_shift_factor),

        _output_buffer(_buffer_size * _max_input_size),

        _overlap_adder(
            _pitch_shift_factor, _window_type, _window_size, sample_rate,
            _input_buffer, _ola_buffer),

        _interpolator(
            _pitch_shift_factor, _get_interpolator_filter(_pitch_shift_factor),
            _ola_buffer, _output_buffer),

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
            _interpolator.process();

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
    unsigned _pitch_shift_factor;
    string _window_type;
    double _window_size;

    AdvancingBuffer<float> _input_buffer;
    AdvancingBuffer<float> _ola_buffer;
    AdvancingBuffer<float> _output_buffer;
    OverlapAdder _overlap_adder;
    Interpolator _interpolator;

    unsigned _input_buffer_num;


};


/*

FIR filter designed with
http://t-filter.engineerjs.com/

sampling frequency: 48000 Hz

* 0 Hz - 9000 Hz
  gain = 1
  desired ripple = 1 dB
  actual ripple = 0.7450170347285441 dB

* 12000 Hz - 24000 Hz
  gain = 0
  desired attenuation = -80 dB
  actual attenuation = -80.08129806462802 dB

filter length: 45

*/

const vector<float> INTERPOLATOR_FILTER_2 {
    -0.00010675337693134514,
    -0.0017503768144127491,
    -0.006034506752219656,
    -0.010539251033025256,
    -0.009168708810412391,
    0.0003418387561544608,
    0.009392478181773365,
    0.005823624170020336,
    -0.008135564283652079,
    -0.013107266677063434,
    0.0023596816514399057,
    0.019485727427834804,
    0.009510880891362691,
    -0.020855188598996197,
    -0.026930399099730076,
    0.012143269190300288,
    0.04727298127931795,
    0.013230423529631984,
    -0.06648332625847726,
    -0.07150519391666825,
    0.08025723649881988,
    0.30599253836322954,
    0.4147513573395191,
    0.30599253836322954,
    0.08025723649881988,
    -0.07150519391666825,
    -0.06648332625847726,
    0.013230423529631984,
    0.04727298127931795,
    0.012143269190300288,
    -0.026930399099730076,
    -0.020855188598996197,
    0.009510880891362691,
    0.019485727427834804,
    0.0023596816514399057,
    -0.013107266677063434,
    -0.008135564283652079,
    0.005823624170020336,
    0.009392478181773365,
    0.0003418387561544608,
    -0.009168708810412391,
    -0.010539251033025256,
    -0.006034506752219656,
    -0.0017503768144127491,
    -0.00010675337693134514
};


/*

FIR filter designed with
http://t-filter.engineerjs.com/

sampling frequency: 48000 Hz

* 0 Hz - 6000 Hz
  gain = 1
  desired ripple = 1 dB
  actual ripple = 0.7432183517386264 dB

* 8000 Hz - 24000 Hz
  gain = 0
  desired attenuation = -80 dB
  actual attenuation = -80.10226796701247 dB

filter length: 67

*/

const vector<float> INTERPOLATOR_FILTER_3 {
    -0.000049988654409267935,
    -0.0006165089975126487,
    -0.0019181345419226814,
    -0.004008494583445973,
    -0.006232363315117716,
    -0.00734439391520328,
    -0.006113473685855542,
    -0.0022914409654582442,
    0.0027275972941193808,
    0.006258012373051146,
    0.005827308070912372,
    0.001062953583938441,
    -0.00541396789534455,
    -0.009126543011750768,
    -0.006639040471556047,
    0.0015589856160929097,
    0.010454796440236136,
    0.013281948759577956,
    0.006357920472797053,
    -0.007275601695949839,
    -0.018552867418217937,
    -0.017950730024110812,
    -0.0028046453844219033,
    0.018823483014060706,
    0.03151044034643775,
    0.02229997053847108,
    -0.008691562272690774,
    -0.044318938205442866,
    -0.05729279260907759,
    -0.025393730125465978,
    0.05348718950196699,
    0.15607131295739268,
    0.24267904068369706,
    0.27651151298582993,
    0.24267904068369706,
    0.15607131295739268,
    0.05348718950196699,
    -0.025393730125465978,
    -0.05729279260907759,
    -0.044318938205442866,
    -0.008691562272690774,
    0.02229997053847108,
    0.03151044034643775,
    0.018823483014060706,
    -0.0028046453844219033,
    -0.017950730024110812,
    -0.018552867418217937,
    -0.007275601695949839,
    0.006357920472797053,
    0.013281948759577956,
    0.010454796440236136,
    0.0015589856160929097,
    -0.006639040471556047,
    -0.009126543011750768,
    -0.00541396789534455,
    0.001062953583938441,
    0.005827308070912372,
    0.006258012373051146,
    0.0027275972941193808,
    -0.0022914409654582442,
    -0.006113473685855542,
    -0.00734439391520328,
    -0.006232363315117716,
    -0.004008494583445973,
    -0.0019181345419226814,
    -0.0006165089975126487,
    -0.000049988654409267935
};


/*

FIR filter designed with
http://http://t-filter.engineerjs.com/

sampling frequency: 48000 Hz

* 0 Hz - 4500 Hz
  gain = 1
  desired ripple = 1 dB
  actual ripple = 0.7424698964229353 dB

* 6000 Hz - 24000 Hz
  gain = 0
  desired attenuation = -80 dB
  actual attenuation = -80.11100880837203 dB

filter length: 89

*/

const vector<float> INTERPOLATOR_FILTER_4 {
    -0.00002023897307765986,
    -0.0003138507934412714,
    -0.0008557313474728114,
    -0.001775958050456147,
    -0.002997406562244653,
    -0.004287758813220976,
    -0.005259061543647789,
    -0.005469182678898593,
    -0.00459004559310957,
    -0.0025891812309488797,
    0.00015677886112203468,
    0.0028925865684858686,
    0.004689208039100991,
    0.004780746233718539,
    0.0029177177277080937,
    -0.00041716684376227886,
    -0.004059719225416874,
    -0.00652059039039525,
    -0.006556229355397888,
    -0.003747410036060987,
    0.0011691747460916152,
    0.00641108953773094,
    0.00973872118950459,
    0.009352996208600098,
    0.004763889727608247,
    -0.0027575724130677937,
    -0.010417223751363268,
    -0.01484485619498293,
    -0.013464463206237958,
    -0.005768875825578264,
    0.006066718933591363,
    0.017610034396243902,
    0.023637803832256804,
    0.020212495092855335,
    0.0066223819650311905,
    -0.013617053114587118,
    -0.033241720101120246,
    -0.04323027719277266,
    -0.0357651151139654,
    -0.007188252619850143,
    0.0401169225615354,
    0.09769402457784687,
    0.15299964654843987,
    0.1928708317111332,
    0.20738834763537364,
    0.1928708317111332,
    0.15299964654843987,
    0.09769402457784687,
    0.0401169225615354,
    -0.007188252619850143,
    -0.0357651151139654,
    -0.04323027719277266,
    -0.033241720101120246,
    -0.013617053114587118,
    0.0066223819650311905,
    0.020212495092855335,
    0.023637803832256804,
    0.017610034396243902,
    0.006066718933591363,
    -0.005768875825578264,
    -0.013464463206237958,
    -0.01484485619498293,
    -0.010417223751363268,
    -0.0027575724130677937,
    0.004763889727608247,
    0.009352996208600098,
    0.00973872118950459,
    0.00641108953773094,
    0.0011691747460916152,
    -0.003747410036060987,
    -0.006556229355397888,
    -0.00652059039039525,
    -0.004059719225416874,
    -0.00041716684376227886,
    0.0029177177277080937,
    0.004780746233718539,
    0.004689208039100991,
    0.0028925865684858686,
    0.00015677886112203468,
    -0.0025891812309488797,
    -0.00459004559310957,
    -0.005469182678898593,
    -0.005259061543647789,
    -0.004287758813220976,
    -0.002997406562244653,
    -0.001775958050456147,
    -0.0008557313474728114,
    -0.0003138507934412714,
    -0.00002023897307765986
};


const map<unsigned, vector<float>> INTERPOLATOR_FILTERS {
    {2, INTERPOLATOR_FILTER_2},
    {3, INTERPOLATOR_FILTER_3},
    {4, INTERPOLATOR_FILTER_4}
};


vector<float> _get_interpolator_filter(unsigned shift) {
    const vector<float> unscaled_filter = INTERPOLATOR_FILTERS.at(shift);
    const size_t filter_length = unscaled_filter.size();
    vector<float> scaled_filter(filter_length);
    for (size_t i = 0; i != filter_length; ++i)
        scaled_filter[i] = shift * unscaled_filter[i];
    return scaled_filter;
}


#endif
