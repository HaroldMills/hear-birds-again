//
//  SongFinderDSPKernelAdapter.mm
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreAudioKit/AUViewController.h>
#import "DSPKernel.hpp"
#import "BufferedAudioBus.hpp"
#import "SongFinderDSPKernel.hpp"
#import "SongFinderDSPKernelAdapter.h"

@implementation SongFinderDSPKernelAdapter {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    SongFinderDSPKernel  _kernel;
    BufferedInputBus _inputBus;
}

- (instancetype)init {

    if (self = [super init]) {
        
        int sampleRate = 48000;
        int maxChannelCount = 2;
        
        AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:sampleRate channels:maxChannelCount];
        
        // Configure input bus.
        _inputBus.init(defaultFormat, maxChannelCount);
        
        // Create output bus.
        _outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];
        _outputBus.maximumChannelCount = maxChannelCount;
        
    }
    
    return self;
    
}

- (AUAudioUnitBus *)inputBus {
    return _inputBus.bus;
}

- (void)setParameter:(AUParameter *)parameter value:(AUValue)value {
    _kernel.setParameter(parameter.address, value);
}

- (AUValue)valueForParameter:(AUParameter *)parameter {
    return _kernel.getParameter(parameter.address);
}

- (AUAudioFrameCount)maximumFramesToRender {
    return _kernel.maximumFramesToRender();
}

- (void)setMaximumFramesToRender:(AUAudioFrameCount)maximumFramesToRender {
    _kernel.setMaximumFramesToRender(maximumFramesToRender);
}

- (BOOL)shouldBypassEffect {
    return _kernel.isBypassed();
}

- (void)setShouldBypassEffect:(BOOL)bypass {
    _kernel.setBypassed(bypass);
}

- (void)allocateRenderResources {
    _inputBus.allocateRenderResources(self.maximumFramesToRender);
    _kernel.allocateRenderResources(self.inputBus.format.channelCount, self.outputBus.format.channelCount);
}

- (void)deallocateRenderResources {
    _inputBus.deallocateRenderResources();
    _kernel.deallocateRenderResources();
}

// MARK: -  AUAudioUnit (AUAudioUnitImplementation)

// Subclassers must provide a AUInternalRenderBlock (via a getter) to implement rendering.
- (AUInternalRenderBlock)internalRenderBlock {
    /*
     Capture in locals to avoid ObjC member lookups. If "self" is captured in
     render, we're doing it wrong.
     */
    // Specify captured objects are mutable.
    __block SongFinderDSPKernel *state = &_kernel;
    __block BufferedInputBus *input = &_inputBus;

    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags                 *actionFlags,
                              const AudioTimeStamp                       *timestamp,
                              AVAudioFrameCount                           frameCount,
                              NSInteger                                   outputBusNumber,
                              AudioBufferList                            *outputData,
                              const AURenderEvent                        *realtimeEventListHead,
                              AURenderPullInputBlock __unsafe_unretained pullInputBlock) {

        AudioUnitRenderActionFlags pullFlags = 0;

        if (frameCount > state->maximumFramesToRender()) {
            return kAudioUnitErr_TooManyFramesToProcess;
        }

        AUAudioUnitStatus err = input->pullInput(&pullFlags, timestamp, frameCount, 0, pullInputBlock);

        if (err != noErr) { return err; }

        AudioBufferList *inAudioBufferList = input->mutableAudioBufferList;

        /*
         Important:
         If the caller passed non-null output pointers (outputData->mBuffers[x].mData), use those.

         If the caller passed null output buffer pointers, process in memory owned by the Audio Unit
         and modify the (outputData->mBuffers[x].mData) pointers to point to this owned memory.
         The Audio Unit is responsible for preserving the validity of this memory until the next call to render,
         or deallocateRenderResources is called.

         If your algorithm cannot process in-place, you will need to preallocate an output buffer
         and use it here.

         See the description of the canProcessInPlace property.
         */

        // If passed null output buffer pointers, process in-place in the input buffer.
        AudioBufferList *outAudioBufferList = outputData;
        if (outAudioBufferList->mBuffers[0].mData == nullptr) {
            for (UInt32 i = 0; i < outAudioBufferList->mNumberBuffers; ++i) {
                outAudioBufferList->mBuffers[i].mData = inAudioBufferList->mBuffers[i].mData;
            }
        }

        state->setBuffers(inAudioBufferList, outAudioBufferList);
        state->processWithEvents(timestamp, frameCount, realtimeEventListHead, nil /* MIDIOutEventBlock */);

        return noErr;
    };
}

@end
