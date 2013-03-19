//
//  CCAudioViewController.m
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-14.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import "CCAudioViewController.h"
#import "AQLevelMeter.h"
#import "AQPlayer.h"
#import "AQRecorder.h"

static NSString * const kCCAuidoViewControllerplaybackQueueResumed = @"kCCAuidoViewControllerplaybackQueueResumed";

@interface CCAudioViewController ()
{
	CFStringRef recordFilePath_;
}
@property (atomic) AQPlayer *player;
@property (atomic) AQRecorder *recorder;
@property (assign, nonatomic) BOOL playbackWasInterrupted;
@property (assign, nonatomic) BOOL playbackWasPaused;
@property (nonatomic, retain) IBOutlet AQLevelMeter *lvlMeter_in;
@property (nonatomic, assign)	BOOL inBackground;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *tipLabel;

- (void)stopRecord;
- (void)pausePlayQueue;

@end

@implementation CCAudioViewController
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  delete _player;
  delete _recorder;
  CFRelease(recordFilePath_);
  [_timeLabel release];
  [_tipLabel release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
  [self setTimeLabel:nil];
  [self setTipLabel:nil];
  [super viewDidUnload];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
  [super willMoveToParentViewController:parent];
  self.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	// Allocate our singleton instance for the recorder & player object
	_recorder = new AQRecorder();
	_player = new AQPlayer();
  
	OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, self);
	if (error) CC_ERRORLOG("ERROR INITIALIZING AUDIO SESSION! %d", (int)error);
	else
	{
		UInt32 category = kAudioSessionCategory_PlayAndRecord;
		error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
		if (error) CC_ERRORLOG("couldn't set audio category!");
    
		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, self);
		if (error) CC_ERRORLOG("ERROR ADDING AUDIO SESSION PROP LISTENER! %d", (int)error);
		UInt32 inputAvailable = 0;
		UInt32 size = sizeof(inputAvailable);
		
		// we do not want to allow recording if input is not available
		error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
		if (error) CC_ERRORLOG("ERROR GETTING INPUT AVAILABILITY! %d", (int)error);
    //		btn_record.enabled = (inputAvailable) ? YES : NO;
		
		// we also need to listen to see if input availability changes
		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, self);
		if (error) CC_ERRORLOG("ERROR ADDING AUDIO SESSION PROP LISTENER! %d", (int)error);
    
		error = AudioSessionSetActive(true);
		if (error) CC_ERRORLOG("AudioSessionSetActive (true) failed");
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(playbackQueueStopped:)
                                               name:kAQPlayerPlaybackQueueStopped object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(playbackQueueResumed:)
                                               name:kCCAuidoViewControllerplaybackQueueResumed object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateRecordDuration:)
                                               name:kAQRecorderTimelineDidChange
                                             object:nil];
  
	UIColor *bgColor = [[UIColor alloc] initWithRed:.39 green:.44 blue:.57 alpha:.5];
  self.lvlMeter_in.vertical = YES;
	[self.lvlMeter_in setBackgroundColor:bgColor];  //default use opengl es
	[self.lvlMeter_in setBorderColor:bgColor];      //make a effect when not use gl
	[bgColor release];
	
  UIControl *stopControl = [[UIControl alloc] initWithFrame:self.view.bounds];
  [stopControl addTarget:self action:@selector(stopRecord) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:stopControl];
  [stopControl release];
	_playbackWasInterrupted = NO;
	_playbackWasPaused = NO;
  
  [self registerForBackgroundNotifications];
}

////////////////////////////////////////////////////////////////////////////////
# pragma mark - Notification routines
- (void)playbackQueueStopped:(NSNotification *)note
{
	[self.lvlMeter_in setAq: nil];
}

- (void)playbackQueueResumed:(NSNotification *)note
{
	[self.lvlMeter_in setAq:_player->Queue()];
}

- (void)updateRecordDuration:(NSNotification *)notification {
  UInt64 nanoDuration = [[notification object] unsignedLongLongValue];
  NSString *text = [NSString stringWithFormat:@"%.3fs", (nanoDuration * 1. / 1000000000)];
  self.timeLabel.text = text;
}
////////////////////////////////////////////////////////////////////////////////
#pragma mark - background notifications
- (void)registerForBackgroundNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(resignActive)
                                               name:UIApplicationWillResignActiveNotification
                                             object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(enterForeground)
                                               name:UIApplicationWillEnterForegroundNotification
                                             object:nil];
}

- (void)resignActive
{
  if (_recorder->IsRunning()) [self stopRecord];
  if (_player->IsRunning()) [self stopPlayQueue];
  _inBackground = true;
}

- (void)enterForeground
{
  OSStatus error = AudioSessionSetActive(true);
  if (error) CC_ERRORLOG("AudioSessionSetActive (true) failed");
	_inBackground = false;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Playback routines
-(void)stopPlayQueue
{
	_player->StopQueue();
	[self.lvlMeter_in setAq:nil];
}

-(void)pausePlayQueue
{
	_player->PauseQueue();
	_playbackWasPaused = YES;
}

- (void)stopRecord
{
	// Disconnect our level meter from the audio queue
	[self.lvlMeter_in setAq:nil];
	
	_recorder->StopRecord();
	
	// dispose the previous playback queue
	_player->DisposeQueue(true);
  
	// now create a new queue for the recorded file
	recordFilePath_ = (CFStringRef)[NSTemporaryDirectory() stringByAppendingPathComponent: @"recordedFile.caf"];
	_player->CreateQueueForFile(recordFilePath_);
 
  self.tipLabel.text = @"结束录音";
  if ([self.delegate respondsToSelector:@selector(audioViewControllerDidStopRecord)]) {
    [self.delegate audioViewControllerDidStopRecord];
  }
}

- (void)play:(id)sender
{
	if (_player->IsRunning())
	{
		if (_playbackWasPaused) {
			OSStatus result = _player->StartQueue(true);
      _playbackWasPaused = NO;
			if (result == noErr)
				[[NSNotificationCenter defaultCenter] postNotificationName:kCCAuidoViewControllerplaybackQueueResumed
                                                            object:self];
		}
		else
			[self stopPlayQueue];
	}
	else
	{
		OSStatus result = _player->StartQueue(false);
		if (result == noErr)
			[[NSNotificationCenter defaultCenter] postNotificationName:kCCAuidoViewControllerplaybackQueueResumed
                                                          object:self];
	}
}

- (void)record:(id)sender
{
	if (_recorder->IsRunning()) // If we are currently recording, stop and save the file.
	{
		[self stopRecord];
	}
	else // If we're not recording, start.
	{
		// Start the recorder
		_recorder->StartRecord(CFSTR("recordedFile.caf"));
		
		[self setFileDescriptionForFormat:_recorder->DataFormat() withName:@"Recorded File"];
		
		// Hook the level meter up to the Audio Queue for the recorder
		[self.lvlMeter_in setAq:_recorder->Queue()];
    
    self.tipLabel.text = @"开始录音...";
	}
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - AudioSession listeners
void interruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	CCAudioViewController *THIS = (CCAudioViewController *)inClientData;
	if (inInterruptionState == kAudioSessionBeginInterruption)
	{
		if (THIS.recorder->IsRunning()) {
			[THIS stopRecord];
		}
		else if (THIS.player->IsRunning()) {
			//the queue will stop itself on an interruption, we just need to update the UI
			[[NSNotificationCenter defaultCenter] postNotificationName:kAQPlayerPlaybackQueueStopped object:THIS];
			THIS.playbackWasInterrupted = YES;
		}
	}
	else if ((inInterruptionState == kAudioSessionEndInterruption) && THIS.playbackWasInterrupted)
	{
		// we were playing back when we were interrupted, so reset and resume now
		THIS.player->StartQueue(true);
		[[NSNotificationCenter defaultCenter] postNotificationName:kCCAuidoViewControllerplaybackQueueResumed object:THIS];
		THIS.playbackWasInterrupted = NO;
	}
}

void propListener(void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData)
{
	CCAudioViewController *THIS = (CCAudioViewController *)inClientData;
	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
		CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;
		//CFShow(routeDictionary);
		CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		SInt32 reasonVal;
		CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
		if (reasonVal != kAudioSessionRouteChangeReason_CategoryChange)
		{
			/*CFStringRef oldRoute = (CFStringRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_OldRoute));
       if (oldRoute)
       {
       printf("old route:\n");
       CFShow(oldRoute);
       }
       else
       printf("ERROR GETTING OLD AUDIO ROUTE!\n");
       
       CFStringRef newRoute;
       UInt32 size; size = sizeof(CFStringRef);
       OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
       if (error) printf("ERROR GETTING NEW AUDIO ROUTE! %d\n", error);
       else
       {
       printf("new route:\n");
       CFShow(newRoute);
       }*/
      
			if (reasonVal == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
			{
				if (THIS.player->IsRunning()) {
					[THIS pausePlayQueue];
					[[NSNotificationCenter defaultCenter] postNotificationName:kAQPlayerPlaybackQueueStopped object:THIS];
				}
			}
      
			// stop the queue if we had a non-policy route change
			if (THIS.recorder->IsRunning()) {
				[THIS stopRecord];
			}
		}
	}
	else if (inID == kAudioSessionProperty_AudioInputAvailable)
	{
		if (inDataSize == sizeof(UInt32)) {
      //			UInt32 isAvailable = *(UInt32*)inData;
			// disable recording if input is not available
      //			THIS->btn_record.enabled = (isAvailable > 0) ? YES : NO;
		}
	}
}

char *OSTypeToStr(char *buf, OSType t)
{
	char *p = buf;
	char str[4] = {0};
  char *q = str;
	*(UInt32 *)str = CFSwapInt32(t);
	for (int i = 0; i < 4; ++i) {
		if (isprint(*q) && *q != '\\')
			*p++ = *q++;
		else {
			sprintf(p, "\\x%02x", *q++);
			p += 4;
		}
	}
	*p = '\0';
	return buf;
}

- (void)setFileDescriptionForFormat:(CAStreamBasicDescription)format withName:(NSString*)name
{
	char buf[5];
	const char *dataFormat = OSTypeToStr(buf, format.mFormatID);
	NSString* description = [[NSString alloc] initWithFormat:@"(%ld ch. %s @ %g Hz)", format.NumberChannels(), dataFormat, format.mSampleRate, nil];
  //	fileDescription.text = description;
	[description release];
}


@end
