//
//  SongFinderDSPKernel.hpp
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//
// The class defined in this file is a C++ class rather than
// an Objective-C or Swift class to make it safe to use on
// the audio render thread.
//


#ifndef SongFinderDSPKernel_hpp
#define SongFinderDSPKernel_hpp


#import <cmath>
#import <string>
#import "DSPKernel.hpp"
#import "SongFinderProcessor.hpp"


using std::string;


enum {
    Cutoff, PitchShift, WindowType, WindowSize, Gain, Balance, OutputLevel
};


const AUValue _MIN_POWER = 1e-20;


class SongFinderDSPKernel : public DSPKernel {
    
    
public:
    
    
    // MARK: Member Functions

    
    SongFinderDSPKernel() {}

    
    void allocateRenderResources(int inputChannelCount, int outputChannelCount) {
        
        _inputChannelCount = inputChannelCount;
        _outputChannelCount = outputChannelCount;
        
        _processors = new SongFinderProcessor*[_outputChannelCount];
        for (int i = 0; i != _outputChannelCount; ++i)
            _processors[i] = _createProcessor();
            
        _channelMap = _createChannelMap();
        
        _gainFactors = new float[_outputChannelCount];
        
        _renderResourcesAllocated = true;
        
        _updateGainFactors();
        
    }
    
    
    SongFinderProcessor *_createProcessor() {
        
        const string windowType = _windowType == 0 ? "Hann" : "SongFinder";
        const double windowSize = _windowSize / 1000;
        
        SongFinderProcessor *p = new SongFinderProcessor(
            _maxInputSize, _cutoff, _pitchShift, windowType, windowSize);
        
        const size_t zero_count =
            static_cast<size_t>(round(windowSize * p->sample_rate));

        p->prime_input(zero_count);
        
        return p;
        
    }
    
    
    int *_createChannelMap() {
        
        int *channelMap = new int[_outputChannelCount];
        int maxInputChannelNum = _inputChannelCount - 1;
        
        for (int i = 0; i != _outputChannelCount; ++i)
            channelMap[i] = i < maxInputChannelNum ? i : maxInputChannelNum;
        
        return channelMap;
        
    }
    
    
    void _updateGainFactors() {
        
        if (_renderResourcesAllocated) {
            
            // Set the gain factors of all channels according to `_gain`.
            float gainFactor = _dbToFactor(_gain);
            for (int i = 0; i != _outputChannelCount; ++i)
                _gainFactors[i] = gainFactor;
            
            // If stereo, adjust gain factor of left or right channel if indicated by `_balance`.
            if (_outputChannelCount == 2) {
                if (_balance > 0) {
                    _gainFactors[0] *= _dbToFactor(-_balance);
                } else if (_balance < 0) {
                    _gainFactors[1] *= _dbToFactor(_balance);
                }
            }
            
        }
        
    }
    
    
    float _dbToFactor(float x) {
        return std::pow(10, x / 20);
    }
    
    
    void deallocateRenderResources() {
        
        for (int i = 0; i != _inputChannelCount; ++i)
            delete _processors[i];
        delete[] _processors;
        _processors = nullptr;
        
        delete[] _channelMap;
        _channelMap = nullptr;
        
        delete[] _gainFactors;
        _gainFactors = nullptr;
        
        _renderResourcesAllocated = false;
        
    }
    
    
    bool isBypassed() {
        return _bypassed;
    }

    
    void setBypassed(bool bypassed) {
        bypassed = bypassed;
    }

    
    void setParameter(AUParameterAddress address, AUValue value) {
        
        switch (address) {
                
            case Cutoff:
                _cutoff = value;
                std::cout << "DSP Kernel: set cutoff to " << _cutoff << std::endl;
                break;
                
            case PitchShift:
                _pitchShift = value;
                std::cout << "DSP Kernel: set pitch shift to " << _pitchShift << std::endl;
                break;
                
            case WindowType:
                _windowType = value;
                std::cout << "DSP Kernel: set window type to " << _windowType << std::endl;
                break;
                
            case WindowSize:
                _windowSize = value;
                std::cout << "DSP Kernel: set window size to " << _windowSize << std::endl;
                break;
                
            case Gain:
                _gain = value;
                std::cout << "DSP Kernel: set gain to " << _gain << std::endl;
                _updateGainFactors();
                break;
                
            case Balance:
                _balance = value;
                std::cout << "DSP Kernel: set balance to " << _balance << std::endl;
                _updateGainFactors();
                break;

        }
        
        
    }

    
    
    AUValue getParameter(AUParameterAddress address) {
        
        switch (address) {
                
            case Cutoff:
                return _cutoff;
                
            case PitchShift:
                return _pitchShift;
                
            case WindowType:
                return _windowType;
                
            case WindowSize:
                return _windowSize;
                
            case Gain:
                return _gain;
                
            case Balance:
                return _balance;
                
            case OutputLevel:
                return _outputLevel;

            default: return 0;
                
        }
        
    }

    
    void setBuffers(AudioBufferList* inputBuffers, AudioBufferList* outputBuffers) {
        _inputBuffers = inputBuffers;
        _outputBuffers = outputBuffers;
    }

    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        
        // std::cout << "SongFinderDSPKernel.process " << frameCount << std::endl;

        
        for (int j = 0; j != _outputChannelCount; ++j) {

            int i = _channelMap[j];
            
            const float *inputs = (float *) _inputBuffers->mBuffers[i].mData + bufferOffset;
            float *outputs = (float *) _outputBuffers->mBuffers[j].mData + bufferOffset;

            if (_bypassed) {
                // this audio unit bypassed
                    
                if (outputs == inputs) {
                    // input and output buffers are the same

                    continue;

                } else {
                    // input and output buffers are not the same

                    for (int k = 0; k != frameCount; ++k)
                        outputs[k] = inputs[k];

                }

            } else {
                // this audio unit not bypassed

                _processors[j]->process(inputs, frameCount, outputs);

                float gainFactor = _gainFactors[j];
                for (int k = 0; k != frameCount; ++k)
                    outputs[k] *= gainFactor;

            }
            
        }


        // compute max channel RMS output power in dBFS, where full scale is 1.
        
        // TODO: Measure separate level for each output channel.

        float maxPower = _MIN_POWER;

        for (int i = 0; i != _outputChannelCount; ++i) {

            float power = 0;
            float *outputs = (float *) _outputBuffers->mBuffers[0].mData + bufferOffset;

            for (int j = 0; j != frameCount; ++j) {
                const float sample = outputs[j];
                power += sample * sample;
            }

            power /= frameCount;

            if (power > maxPower)
                maxPower = power;

        }

        _outputLevel = 10 * std::log10(maxPower);
        

    }
    
    
private:
    
    // MARK: Member Variables

    bool _renderResourcesAllocated = false;
    
    int _inputChannelCount;
    int _outputChannelCount;
    int *_channelMap = nullptr;
    
    unsigned _maxInputSize = 128;
    AUValue _cutoff = 0;            // Hz
    AUValue _pitchShift = 2;
    AUValue _windowType = 0;
    AUValue _windowSize = 20;       // ms
    AUValue _gain = 0;              // dB
    AUValue _balance = 0;           // dB
    AUValue _outputLevel = -200;    // dB
    AUValue *_gainFactors = nullptr;
    SongFinderProcessor **_processors = nullptr;
    
    bool _bypassed = false;
    AudioBufferList* _inputBuffers = nullptr;
    AudioBufferList* _outputBuffers = nullptr;
    
    
};


#endif
