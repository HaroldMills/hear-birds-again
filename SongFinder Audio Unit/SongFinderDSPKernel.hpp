//
//  SongFinderDSPKernel.hpp
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//

#ifndef SongFinderDSPKernel_hpp
#define SongFinderDSPKernel_hpp

// #include <iostream>

#import "DSPKernel.hpp"

enum {
    Attenuation = 0,
};

/*
 SongFinderDSPKernel
 Performs simple copying of the input signal to the output.
 As a non-ObjC class, this is safe to use from render thread.
 */
class SongFinderDSPKernel : public DSPKernel {
public:
    
    // MARK: Member Functions

    SongFinderDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        chanCount = channelCount;
        sampleRate = float(inSampleRate);
    }

    void reset() {
    }

    bool isBypassed() {
        return bypassed;
    }

    void setBypass(bool shouldBypass) {
        bypassed = shouldBypass;
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case Attenuation:
                attenuation = value;
                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case Attenuation:
                // Return the goal. It is not thread safe to return the ramping value.
                return attenuation;

            default: return 0.f;
        }
    }

    void setBuffers(AudioBufferList* inBufferList, AudioBufferList* outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        if (bypassed) {
            // this audio unit bypassed
            
            // Pass samples through.
            for (int channel = 0; channel < chanCount; ++channel) {
                
                const float *inData = (float *) inBufferListPtr->mBuffers[channel].mData;
                float *outData = (float *) outBufferListPtr->mBuffers[channel].mData;
                
                if (outData == inData) {
                    // input and output buffers are the same
                    
                    continue;
                    
                } else {
                    // input and output buffers are not the same
                
                    const float *in = inData + bufferOffset;
                    float *out = outData + bufferOffset;
                    
                    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex)
                        out[frameIndex] = in[frameIndex];
                    
                }
                
            }

        } else {
            // this audio unit not bypassed
            
            const float scaleFactor = pow(10, -attenuation / 20.);
            
            // std::cout << "process " << attenuation << " " << scaleFactor << std::endl;
            // std::cout << "frameCount " << frameCount << std::endl;
            
            // Perform per sample dsp on the incoming float *in before assigning it to *out.
            for (int channel = 0; channel < chanCount; ++channel) {
            
                const float *in = ((float *) inBufferListPtr->mBuffers[channel].mData) + bufferOffset;
                float *out = ((float *) outBufferListPtr->mBuffers[channel].mData) + bufferOffset;
                
                for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex)
                    out[frameIndex] = scaleFactor * in[frameIndex];
                
            }
            
        }

    }

    // MARK: Member Variables

private:
    int chanCount = 2;
    float sampleRate = 48000.0;
    bool bypassed = false;
    AudioBufferList* inBufferListPtr = nullptr;
    AudioBufferList* outBufferListPtr = nullptr;
    AUValue attenuation;
};

#endif /* SongFinderDSPKernel_hpp */
