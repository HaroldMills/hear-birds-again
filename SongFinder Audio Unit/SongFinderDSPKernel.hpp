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

#import <string>
#import "DSPKernel.hpp"
#import "SongFinderProcessor.hpp"


using std::string;


enum {
    Attenuation = 0,
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
        
        SongFinderProcessor *p = new SongFinderProcessor(
            _maxInputSize, _pitchShiftFactor, _windowType, _windowSize);
        
        const size_t zero_count =
            static_cast<size_t>(round(_windowSize * p->sample_rate));

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
            case Attenuation:
                _attenuation = value;
                break;
        }
    }

    
    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case Attenuation:
                // Return the goal. It is not thread safe to return the ramping value.
                return _attenuation;

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
            
            // const float scaleFactor = pow(10, -_attenuation / 20);
            
            // std::cout << "process " << _attenuation << " " << scaleFactor << std::endl;
            // std::cout << "frameCount " << frameCount << std::endl;
            
            for (int i = 0; i != _channelCount; ++i) {
            
                const float *inputs = (float *) _inputBuffers->mBuffers[i].mData + bufferOffset;
                float *outputs = (float *) _outputBuffers->mBuffers[i].mData + bufferOffset;
                
                _processors[i]->process(inputs, frameCount, outputs);
                
//                for (int j = 0; j != frameCount; ++j)
//                    outputs[j] = scaleFactor * inputs[j];
                
            }
            
        }

    }

    
private:
    
    // MARK: Member Variables

    int _channelCount = 2;
    float _sampleRate = 48000;
    
    unsigned _maxInputSize = 128;
    unsigned _pitchShiftFactor = 2;
    string _windowType = "Hann";
    double _windowSize = .020;
    SongFinderProcessor **_processors = nullptr;
    
    bool _bypassed = false;
    AudioBufferList* _inputBuffers = nullptr;
    AudioBufferList* _outputBuffers = nullptr;
    AUValue _attenuation;
    
    
};


#endif
