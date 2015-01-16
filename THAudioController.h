//
//  THAudioController.h
//
//  Created by Daniel GARCÍA on 23/08/2014.
//  Copyright (c) 2014 Daniel GARCÍA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface THAudioController : NSObject

/// \brief Creates singleton object for audio
/// \param fileName Music file name in project
/// \param fileType File type 
/// \return THAudioController returns current singlenton instance 
+(THAudioController *)sharedInstanceWithMusicName: (NSString *)fileName andFileType: (NSString *)fileType;
/// \brief Attempts to pause music 
-(void)tryPauseMusic;
/// \brief Attempts to play music
-(void)tryPlayMusic;
/// \brief Attempts to stop music
-(void)tryStopMusic;

@end
