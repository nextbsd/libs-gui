#import <AppKit/AppKit.h>
#include <stdio.h>
#include <unistd.h>
#include <getopt.h>

static BOOL finished = NO;
static BOOL spoke = NO;

@interface SpeechDelegate : NSObject
@end

@implementation SpeechDelegate
/* Called over Distributed Objects from inside the run loop: just note it.
   Calling exit() here unwound the run loop's autorelease pools out of
   order ("NSAutoreleasePool -dealloc of deallocated pool"). */
- (void)speechSynthesizer: (NSSpeechSynthesizer*)sender 
        didFinishSpeaking: (BOOL)success
{
  spoke = success;
  finished = YES;
}
@end

int main(int argc, char **argv)
{
  NSAutoreleasePool * p = [NSAutoreleasePool new];
  NSMutableString *words = nil;
  NSString *outFile = nil;
  NSString *voice = nil;
  NSString *inFile = nil;
  NSSpeechSynthesizer *say;
  SpeechDelegate *delegate;
  int ch;
  int i;

  while ((ch = getopt(argc, argv, "o:v:f:")) != -1)
    {
      switch (ch)
        {
        case 'o':
          outFile = [NSString stringWithUTF8String: optarg];
          break;
        case 'f':
          inFile = [NSString stringWithUTF8String: optarg];
          break;
        case 'v':
          voice = [NSString stringWithUTF8String: optarg];
          break;
        }
    }
  
  if (nil != inFile)
    {
      NSData *file = [NSData dataWithContentsOfFile: inFile];

      if (nil == file)
        {
          fprintf(stderr, "say: can't read %s\n", [inFile UTF8String]);
          RELEASE(p);
          return 1;
        }
      /* The file's bytes aren't NUL-terminated. */
      words = AUTORELEASE([[NSMutableString alloc] initWithData: file
        encoding: NSUTF8StringEncoding]);
    }
  else
    {
      words = [NSMutableString string];
      for (i = optind ; i < argc ; i++)
        {
          [words appendString: [NSString stringWithUTF8String: argv[i]]];
          [words appendString: @" "];
        }
    }

  // Don't interrupt other apps.
  while ([NSSpeechSynthesizer isAnyApplicationSpeaking])
    {
      [NSThread sleepForTimeInterval: 0.1];
    }

  say = [[NSSpeechSynthesizer alloc] initWithVoice: voice];
  if (nil == say)
    {
      fprintf(stderr, "say: the speech server isn't running and "
        "couldn't be started\n");
      RELEASE(p);
      return 1;
    }
  /* Kept until the end: the synthesizer is a proxy for the speech
     server's object and doesn't keep its delegate alive here. */
  delegate = [SpeechDelegate new];
  [say setDelegate: delegate];
  if (nil != outFile)
    {
      [say startSpeakingString: words toURL: [NSURL fileURLWithPath: outFile]];
    }
  else
    {
      [say startSpeakingString: words];
    }
  /* The server says it's done from its speaking thread over Distributed
     Objects, and that message can get lost, so also stop once the server
     no longer says anything is speaking. Its speaking flag is set before
     startSpeakingString: returns and cleared when the speech is over. */
  while (!finished && [NSSpeechSynthesizer isAnyApplicationSpeaking])
    {
      CREATE_AUTORELEASE_POOL(loop);
      [[NSRunLoop currentRunLoop]
        runMode: NSDefaultRunLoopMode
        beforeDate: [NSDate dateWithTimeIntervalSinceNow: 0.1]];
      RELEASE(loop);
    }
  if (!finished)
    {
      spoke = YES;
    }
  RELEASE(say);
  RELEASE(delegate);
  RELEASE(p);
  return spoke ? 0 : 1;
}
