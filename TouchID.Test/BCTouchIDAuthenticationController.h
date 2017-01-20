//
//  ViewController.h
//  TouchID.Test
//
//  Created by Heping on 2017/1/17.
//  Copyright © 2017年 BONC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCTouchIDAuthenticationController;

@protocol BCTouchIDAuthenticationControllerDelegate <NSObject>
@optional
-(void)didFinishAuthenticationWithController:(BCTouchIDAuthenticationController*)controller;
-(void)didUserFallBackWithController:(BCTouchIDAuthenticationController*)controller;
-(void)didUserCancleWithController:(BCTouchIDAuthenticationController*)controller;
@end

NS_CLASS_AVAILABLE(10_10, 8_0)
@interface BCTouchIDAuthenticationController : UIViewController
@property (nonatomic,strong) NSString* reason;
@property (nonatomic,strong) NSString* fallBackButtonTitle;
@property (nonatomic,strong) NSString* cancleButtonTitle NS_AVAILABLE(10_12, 10_0);
@property (nonatomic,strong,readonly) UIButton* authenticationBtn;
@property (nonatomic,weak) id<BCTouchIDAuthenticationControllerDelegate> delegate;
- (instancetype)init;
- (BOOL)canTouchIDAuthentication;
- (void)doTouchIDAuthentication;
@end

