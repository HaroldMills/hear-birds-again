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


// #include <iostream>

#import <cmath>
#import <string>
#import "DSPKernel.hpp"
#import "SongFinderProcessor.hpp"


using std::string;


enum {
    Cutoff, PitchShift, WindowType, WindowSize, Gain
};


class SongFinderDSPKernel : public DSPKernel {
    
    
public:
    
    
    // MARK: Member Functions

    
    SongFinderDSPKernel() {}

    
    void init(int channelCount, double sampleRate) {
        _channelCount = channelCount;
        _sampleRate = float(sampleRate);
    }

    
    void reset() { }

    
    void allocateRenderResources() {
        
        _processors = new SongFinderProcessor*[_channelCount];
        
        for (int i = 0; i != _channelCount; ++i)
            _processors[i] = _createProcessor();
            
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
    
    
    void deallocateRenderResources() {
        for (int i = 0; i != _channelCount; ++i)
            delete _processors[i];
        delete[] _processors;
        _processors = nullptr;
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
                _gainFactor = std::pow(10, (_gain / 20));
                std::cout << "DSP Kernel: set gain to " << _gain << " " << _gainFactor << std::endl;
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

            default: return 0;
                
        }
        
    }

    
    void setBuffers(AudioBufferList* inputBuffers, AudioBufferList* outputBuffers) {
        _inputBuffers = inputBuffers;
        _outputBuffers = outputBuffers;
    }

    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        if (_bypassed) {
            // this audio unit bypassed
            
            // Pass samples through.
            for (int i = 0; i != _channelCount; ++i) {
                
                const float *inputs = (float *) _inputBuffers->mBuffers[i].mData + bufferOffset;
                float *outputs = (float *) _outputBuffers->mBuffers[i].mData + bufferOffset;
                
                if (outputs == inputs) {
                    // input and output buffers are the same
                    
                    continue;
                    
                } else {
                    // input and output buffers are not the same
                    
                    for (int j = 0; j != frameCount; ++j)
                        outputs[j] = inputs[j];
                    
                }
                
            }

        } else {
            // this audio unit not bypassed
            
            // std::cout << "frameCount " << frameCount << std::endl;
            
            for (int i = 0; i != _channelCount; ++i) {
            
                const float *inputs = (float *) _inputBuffers->mBuffers[i].mData + bufferOffset;
                float *outputs = (float *) _outputBuffers->mBuffers[i].mData + bufferOffset;
                
                _processors[i]->process(inputs, frameCount, outputs);
                
                for (int j = 0; j != frameCount; ++j)
                    outputs[j] *= _gainFactor;
                
            }
            
        }

    }

    
private:
    
    // MARK: Member Variables

    int _channelCount = 2;
    float _sampleRate = 48000;
    
    unsigned _maxInputSize = 128;
    AUValue _cutoff = 0;            // Hz
    AUValue _pitchShift = 2;
    AUValue _windowType = 0;
    AUValue _windowSize = 20;       // ms
    AUValue _gain = 0;              // dB
    AUValue _gainFactor = 1;
    SongFinderProcessor **_processors = nullptr;
    
    bool _bypassed = false;
    AudioBufferList* _inputBuffers = nullptr;
    AudioBufferList* _outputBuffers = nullptr;
    
    
};


#endif
