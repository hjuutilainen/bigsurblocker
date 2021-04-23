//
//  main.m
//  bigsurblocker
//
//  Created by Hannes Juutilainen on 18.10.2020.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSAlertDelegate>
@property BOOL alertTriggered;
- (BOOL)alertShowHelp:(NSAlert *)alert;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    self.alertTriggered = NO;

    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSNotificationCenter *nc = [workspace notificationCenter];

    NSOperationQueue *notificationQueue = [NSOperationQueue new];

    // Subscribe for notifications when apps are launched
    [nc addObserverForName:NSWorkspaceDidLaunchApplicationNotification
                    object:nil
                     queue:notificationQueue
                usingBlock:^(NSNotification * _Nonnull note) {

        // Get information about the launched app
        NSDictionary *userInfo = [note userInfo];
        NSRunningApplication *runningApp = [userInfo objectForKey:NSWorkspaceApplicationKey];
        NSString *bundleID = runningApp.bundleIdentifier;

        // Load our user defaults suite. This will allow the alert text
        // to be specified with a configuration profile
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.hjuutilainen.bigsurblocker"];

        NSArray *bundleIDsToBlock = [userDefaults arrayForKey:@"bundleIDsToBlock"];
        if (!bundleIDsToBlock) {
            bundleIDsToBlock = @[
                @"com.apple.InstallAssistant.BigSur",
                @"com.apple.InstallAssistant.macOSBigSur",
                @"com.apple.InstallAssistant.Seed.macOS1016Seed1",
            ];
        }
        if ([bundleIDsToBlock containsObject:bundleID]) {
            NSLog(@"Detected macOS installer app launch");

            // Get the localized app name
            NSString *appName = runningApp.localizedName;

            // Terminate the app
            NSLog(@"Terminating \"%@\", \"%@\"", appName, bundleID);

            // We could be polite but...
            [runningApp forceTerminate];

            // Check if we are already displaying an alert
            if (self.alertTriggered) {
                NSLog(@"Skipping alert. Previous alert still running");
            } else {
                self.alertTriggered = YES;

                // GUI must be run from main thread
                dispatch_async(dispatch_get_main_queue(), ^{


                    NSString *messageText = [userDefaults stringForKey:@"AlertTitle"];
                    if (!messageText) {
                        messageText = NSLocalizedString(@"The application \"%@\" has been blocked", @"");
                    }

                    NSString *informativeText = [userDefaults stringForKey:@"AlertText"];
                    if (!informativeText) {
                        informativeText = NSLocalizedString(@"Contact your administrator for more information", @"");
                    }

                    // Configure the alert
                    NSAlert *alert = [[NSAlert alloc] init];

                    [alert setMessageText:[NSString stringWithFormat:messageText, appName]];
                    [alert setInformativeText:informativeText];

                    NSString *buttonTitle = [userDefaults stringForKey:@"ButtonTitle"];
                    if (!buttonTitle) {
                        buttonTitle = NSLocalizedString(@"OK", @"");
                    }
                    [alert addButtonWithTitle:buttonTitle];
                    [alert setAlertStyle:NSAlertStyleWarning];
                    [alert setIcon:[NSImage imageNamed:NSImageNameCaution]];
                    
                    // If a custom help URL is defined in defaults, enable the help button
                    NSString *helpURLString = [userDefaults stringForKey:@"HelpURL"];
                    if (helpURLString) {
                        [alert setDelegate:self];
                        [alert setShowsHelp:YES];
                    }
                    

                    // Show the alert above all other apps and windows
                    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
                    [[alert window] setLevel:NSStatusWindowLevel];

                    // Show the alert
                    //
                    // Note that the [alert runModal] will not return until the user dismisses the popup window
                    [alert runModal];

                    // User dismissed the alert, change status to allow new ones to be displayed
                    self.alertTriggered = NO;
                });
            }
        }
    }];
}

- (BOOL)alertShowHelp:(NSAlert *)alert
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.hjuutilainen.bigsurblocker"];
    NSString *helpURLString = [userDefaults stringForKey:@"HelpURL"];
    if (helpURLString) {
        NSURL *helpURL = [NSURL URLWithString:helpURLString];
        [[NSWorkspace sharedWorkspace] openURL:helpURL];
    }
    
    return YES;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *application = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [application setDelegate:delegate];
        [application run];
    }
    return 0;
}
