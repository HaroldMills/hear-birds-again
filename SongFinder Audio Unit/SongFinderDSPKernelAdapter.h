//
//  SongFinderDSPKernelAdapter.h
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//

#import <AudioToolbox/AudioToolbox.h>

// @class AttenuatorViewController;

NS_ASSUME_NONNULL_BEGIN

@interface SongFinderDSPKernelAdapter : NSObject

@property (nonatomic) AUAudioFrameCount maximumFramesToRender;
@property (nonatomic, readonly) AUAudioUnitBus *inputBus;
@property (nonatomic, readonly) AUAudioUnitBus *outputBus;

- (void)setParameter:(AUParameter *)parameter value:(AUValue)value;
- (AUValue)valueForParameter:(AUParameter *)parameter;

- (void)allocateRenderResources;
- (void)deallocateRenderResources;
- (AUInternalRenderBlock)internalRenderBlock;

@end

NS_ASSUME_NONNULL_END
