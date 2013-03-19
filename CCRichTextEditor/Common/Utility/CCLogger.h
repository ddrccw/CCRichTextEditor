//
//  Logger.h
//  eoimsIOS
//
//  Created by ddrccw on 12-6-8.
//  Copyright (c) 2012年 ewellsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Debugging severity levels
 * - info: Informational messages.
 * - warning: Warn of a possible problem.
 * - error: A definite error has occured.
 */
enum level {_INFO_, _WARNING_, _ERROR_};

#define LOGLEVEL _ERROR_

// 开启debug模式，注释掉该行就不会在 All Output里输出log信息
//#define _LOGDEBUG_

//MCS_LOG(_INFO_, @"AD at %s", "adf")
//MCS_LOG(_INFO_, @"AD at ad")
#define CC_LOG(LEVEL, xx, ...)                           \
    do{                                                     \
        if(LEVEL <= LOGLEVEL){                                                                        \
            NSLog(@"%s(%d)[level(%d):" xx "]", __PRETTY_FUNCTION__, __LINE__, LEVEL, ##__VA_ARGS__);    \
        }                                                                                             \
    }while(0)


#define CC_INFOLOG(xx, ...)  CC_LOG(_INFO_, xx, ##__VA_ARGS__)
//MCS_WARNNINGLOG(@"AD at %s", "adf")  ##remove comma
#define CC_WARNNINGLOG(xx, ...)  CC_LOG(_WARNING_, xx, ##__VA_ARGS__)
//MCS_ERRORLOG(@"AD at %s", "adf")
#define CC_ERRORLOG(xx, ...) CC_LOG(_ERROR_, xx, ##__VA_ARGS__)


static void redirectNSLogToDocuments() {
  NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDIR = [allPaths objectAtIndex:0];
  NSString *pathForLog = [documentsDIR stringByAppendingPathComponent:@"CCLog.txt"];
  freopen([pathForLog cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}
