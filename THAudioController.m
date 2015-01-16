//
//  THAudioController.m
//
//  Created by Daniel GARCÍA on 23/08/2014.
//  Copyright (c) 2014 Daniel GARCÍA. All rights reserved.
//

#import "THAudioController.h"

@import AVFoundation;

@interface THAudioController() <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioSession *audioSession;
@property (strong, nonatomic) AVAudioPlayer *backgroundMusicPlayer;
@property (assign) BOOL backgroundMusicPlaying;
@property (assign) BOOL backgroundMusicInterrupted;
@property (weak, nonatomic) NSString *fileName;
@property (weak, nonatomic) NSString *fileType;

@end

@implementation THAudioController

//----------------------------------------------------------------------------------------------------//
#pragma mark - Initialization
//----------------------------------------------------------------------------------------------------//
-(id)initWithMusicName: (NSString *)fileName andFileType: (NSString *)fileType
{
    self = [super init];
    if (self)
    {
        self.fileName = fileName;
        self.fileType = fileType;
        [self configureAudioSession];
        BOOL success = [self configureAudioPlayer];
		
		if( !success )
			return nil;
    }
    return self;
}

+(THAudioController *)sharedInstanceWithMusicName: (NSString *)fileName andFileType: (NSString *)fileType
{
    //Declare a static variable to hold the instance of the class, ensuring it’s available globally inside the class.
    static THAudioController *_sharedInstance = nil;
    
    //Declare the static variable dispatch_once_t which ensures that the initialization code executes only once.
    static dispatch_once_t oncePredicate;
    
    //Use Grand Central Dispatch (GCD) to execute a block which initializes an instance of THAudioController.
    //This is the essence of the Singleton design pattern: the initializer is never called again once the class has been instantiated.
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[THAudioController alloc] initWithMusicName: (NSString *)fileName andFileType: (NSString *)fileType ];
    });
    
    return _sharedInstance;
}
//----------------------------------------------------------------------------------------------------//



//----------------------------------------------------------------------------------------------------//
#pragma mark - Actions
//----------------------------------------------------------------------------------------------------//
-(void)tryPlayMusic
{
    // If background music or other music is already playing, nothing more to do here
    if ( self.backgroundMusicPlaying || [self.audioSession isOtherAudioPlaying] )
        return;
    
    // Play background music if no other music is playing and we aren't playing already
    //Note: prepareToPlay preloads the music file and can help avoid latency. If you don't
    //call it, then it is called anyway implicitly as a result of [self.backgroundMusicPlayer play];
    //It can be worthwhile to call prepareToPlay as soon as possible so as to avoid needless
    //delay when playing a sound later on.
    [self.backgroundMusicPlayer prepareToPlay];
    [self.backgroundMusicPlayer play];
    self.backgroundMusicPlaying = YES;
}

-(void)tryStopMusic
{
    [self.backgroundMusicPlayer stop];
    self.backgroundMusicPlaying = NO;
}

-(void)tryPauseMusic
{
    [self.backgroundMusicPlayer pause];
    self.backgroundMusicPlaying = NO;
}
//----------------------------------------------------------------------------------------------------//



//----------------------------------------------------------------------------------------------------//
#pragma mark - Helper methods
//----------------------------------------------------------------------------------------------------//
- (void) configureAudioSession
{
    self.audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    if ([self.audioSession isOtherAudioPlaying])
    {
        [self.audioSession setCategory: AVAudioSessionCategorySoloAmbient error: &setCategoryError];
        self.backgroundMusicPlaying = NO;
    }
    else
    {
        [self.audioSession setCategory:AVAudioSessionCategoryAmbient error: &setCategoryError];
    }
    
    if ( setCategoryError )
        NSLog(@"<THAudioController | ERROR> - Error while setting category! %ld", (long)[setCategoryError code]);
}

- (BOOL)configureAudioPlayer
{
    if ( [self.fileName length] == 0 || [self.fileType length] == 0 )
    {
		NSLog(@"<THAudioController | ERROR> - File name or file type are null");
        return NO;
    }
    
    NSString *backgroundMusicPath = [ [NSBundle mainBundle] pathForResource: self.fileName ofType: self.fileType ];
    if ( [backgroundMusicPath length] == 0 )
    {
		NSLog(@"<THAudioController | ERROR> - File not found!");
        return NO;
    }
    
    NSURL *backgroundMusicURL = [NSURL fileURLWithPath: backgroundMusicPath];
    self.backgroundMusicPlayer = [ [AVAudioPlayer alloc] initWithContentsOfURL: backgroundMusicURL error: nil ];
    self.backgroundMusicPlayer.delegate = self; //This allows to restart after interrumptions
    self.backgroundMusicPlayer.numberOfLoops = -1; //-1 means forever
	
	return YES;
}
//----------------------------------------------------------------------------------------------------//


//----------------------------------------------------------------------------------------------------//
#pragma mark - AVAudioPlayerDelegate methods
//----------------------------------------------------------------------------------------------------//
- (void) audioPlayerBeginInterruption: (AVAudioPlayer *) player
{
    //It is often not necessary to implement this method since by the time
    //this method is called, the sound has already stopped. You don't need to
    //stop it yourself.
    //In this case the backgroundMusicPlaying flag could be used in any
    //other portion of the code that needs to know if your music is playing.
    
	self.backgroundMusicInterrupted = YES;
	self.backgroundMusicPlaying = NO;
}

- (void) audioPlayerEndInterruption: (AVAudioPlayer *) player withOptions:(NSUInteger) flags
{
    //Since this method is only called if music was previously interrupted
    //you know that the music has stopped playing and can now be resumed.
    [self tryPlayMusic];
    self.backgroundMusicInterrupted = NO;
}
//----------------------------------------------------------------------------------------------------//

@end
