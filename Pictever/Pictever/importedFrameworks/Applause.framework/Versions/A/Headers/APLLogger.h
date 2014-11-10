//  Copyright 2014 Applause. All rights reserved.
//
//	This is the main logger file. Include it in your project
//  along with the Applause Framework. 

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "APLSettings.h"


/**
* Enum presenting possible logging level
*/
typedef enum {
    APLLogLevelFatal = 16,
    APLLogLevelError = 8,
    APLLogLevelWarning = 4,
    APLLogLevelInfo = 2,
    APLLogLevelVerbose = 0
} APLLogLevel;

/**
* Convinience method to log applications exceptions
*/

void APLUncaughtExceptionHandler(NSException *exception);

/** Applause enabled macro **/
#define APLEnabled 1

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu-zero-variadic-macro-arguments"

/** Logging macros **/

/*
 * Replace all occurences of NSLog with APLLog. 
 * Except for working like normal log it will also send message to Applause server.
 */
#define APLLog(nsstring_format, ...)    \
    do {                        \
        [APLLogger logWithLevel:APLLogLevelInfo \
        tag:nil \
        line:__LINE__ fileName:[NSString stringWithUTF8String:__FILE__] \
        method:[NSString stringWithUTF8String:__PRETTY_FUNCTION__] \
        stacktrace:[NSThread callStackReturnAddresses]\
        format:nsstring_format, \
        ##__VA_ARGS__];\
} while(0)

/*
 * Works as the one above, except it provides additional configuration options
 */
#define APLExtendedLog(APLLogLevel, nsstring_tag, nsstring_format, ...)    \
    do {                        \
        [APLLogger logWithLevel:(APLLogLevel) \
        tag:(nsstring_tag) \
        line:__LINE__ fileName:[NSString stringWithUTF8String:__FILE__] \
        method:[NSString stringWithUTF8String:__PRETTY_FUNCTION__] \
        stacktrace:[NSThread callStackReturnAddresses] \
        format:nsstring_format, \
        ##__VA_ARGS__];\
} while(0)


#pragma clang diagnostic pop

/**
* Main applause API class
* @see https://help.applause.com/library-installation/ios/tutorial
 */
@interface APLLogger : NSObject {

}

/**
* Default settings:
* - applicationVersionName is equal to CFBundleShortVersionString
* - applicationVersionCode is equal to CFBundleVersion
* - reportOnShakeEnabled is equal to YES
* - withUTest is equal to NO
* @return APLSettings object with default values. You can easily change applause behaviour by simply changing it's properties.
*/
+ (APLSettings *)settings;

/**
* ONLY FOR APPLAUSE-PRE-PRODUCTION
* Applause-Pre-Production is using CMMotionManager for shake gesture. Apple advices to use one CMMotionManager per application.
* If your application is using one, please register it to Applause-Pre-Production library via this method.
* If you won't do this Applause-Pre-Production will create it's own CMMotionManager.
*/
+ (void)registerMotionManager:(id)motionManager;

/**
* Starting Applause session. Should be called once per application run - doing otherwise will result in an undefined behavior.
* If you want to change default settings change properties for object [APLLogger settings].
* @param applicationID Application ID that you can get from Applause
 */
+ (void)startNewSessionWithApplicationKey:(NSString *)applicationId;

/**
* Logs exception. Screenshot will be included in the data sent to the server.
* You can use APLUncaughtExceptionHandler as a convenience accessor to this method.
* @param error Exception that will be passed to Applause
 */
+ (void)logApplicationException:(NSException *)error;

/**
* This method will register object for logging, meaning each and every method sent to it will be logged, including timestamp.
* @param object Object that will be registered for logging
 */
+ (id)registerObjectForLogging:(id)object;

/**
* Forces the contents of the session log buffer to be send.
 */
+ (void)flush;

/**
* ONLY FOR APPLAUSE-PRE-PRODUCTION
* This function manually shows report screen that is normally accessible by shaking device.
*/
+ (void)showReportScreen;

/**
* ONLY FOR APPLAUSE-PRODUCTION
* Function to show feedback modal where user can write and send feedback about application.
* You can theme this using Appearance protocol (above iOS 5.0).
* @param title Title of modal header
* @param placeholder Placeholder of text field
*/
+ (void)feedback:(NSString *)title placeholder:(NSString *)placeholder;

/**
* ONLY FOR APPLAUSE-PRODUCTION
* @see APLLogger#feedback:placeholder:
*/
+ (void)feedback:(NSString *)title;

/**
* ONLY FOR APPLAUSE-PRODUCTION
* Default title is "Feedback".
* @see APLLogger#feedback:placeholder:
*/
+ (void)feedback;

/**
* ONLY FOR APPLAUSE-PRODUCTION
* Function which sends feedback to Applause. It is used by feedback modal.
* @param feedback Text which you want send to Applause.
*/
+ (void)sendFeedback:(NSString *)feedback;

@end


/**
* Despite being called private, you can generally call these method, if you wish.
* However, this is strongly discouraged, since given macros and functions are more convenient way of using Applause.
 */
@interface APLLogger (PrivateAccessors)

+ (void)logWithLevel:(APLLogLevel)level tag:(NSString *)tag line:(NSInteger)line fileName:(NSString *)fileName method:(NSString *)method stacktrace:(NSArray *)stacktrace format:(NSString *)format, ...;
+ (void)logWithLevel:(APLLogLevel)level tag:(NSString *)tag line:(NSInteger)line fileName:(NSString *)fileName method:(NSString *)method stacktrace:(NSArray *)stacktrace writeToConsole:(BOOL)writeToConsole format:(NSString *)format, ...;

@end