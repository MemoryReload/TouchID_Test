//
//  AppDelegate.m
//  TouchID.Test
//
//  Created by Heping on 2017/1/17.
//  Copyright © 2017年 BONC. All rights reserved.
//

#import "AppDelegate.h"
#import "BCTouchIDAuthenticationController.h"

@interface AppDelegate () <BCTouchIDAuthenticationControllerDelegate>

@end

@implementation AppDelegate

-(void)didFinishAuthenticationWithController:(BCTouchIDAuthenticationController*)controller
{
    NSLog(@"Touch Authentication OK!");
}

-(void)didUserFallBackWithController:(BCTouchIDAuthenticationController*)controller
{
    NSLog(@"User fall back ~");
}

-(void)didUserCancleWithController:(BCTouchIDAuthenticationController*)controller
{
    NSLog(@"User cancel Authentication.");
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    BCTouchIDAuthenticationController* vc=[[BCTouchIDAuthenticationController alloc]init];
    [vc.authenticationBtn setTitle:@"TouchID" forState:UIControlStateNormal];
    [vc.authenticationBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    vc.delegate=self;
    vc.view.backgroundColor=[UIColor whiteColor];
    
    UIViewController* blueVC=[[UIViewController alloc]init];
    blueVC.view.backgroundColor = [UIColor blueColor];
    //模态
    self.window.rootViewController=blueVC;
    [self.window.rootViewController presentViewController:vc animated:YES completion:nil];
    //导航
//    self.window.rootViewController=[[UINavigationController alloc]initWithRootViewController:blueVC];
//    [((UINavigationController*)self.window.rootViewController) pushViewController:vc animated:YES];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
