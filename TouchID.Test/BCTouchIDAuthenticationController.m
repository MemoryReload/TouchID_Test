//
//  ViewController.m
//  TouchID.Test
//
//  Created by Heping on 2017/1/17.
//  Copyright © 2017年 BONC. All rights reserved.
//

#import "BCTouchIDAuthenticationController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface BCTouchIDAuthenticationController ()
@property (nonatomic,strong,readwrite) UIButton* authenticationBtn;
@property (nonatomic,strong) LAContext* authContext;
- (void)authenticateWithBiometrics;
- (void)authenticatePassCode;
- (void)goBack;
@end

@implementation BCTouchIDAuthenticationController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setFallBackButtonTitle:(NSString *)fallBackButtonTitle
{
    if (fallBackButtonTitle==nil) {
        _fallBackButtonTitle=@"";
    }else{
        _fallBackButtonTitle=fallBackButtonTitle;
    }
    self.authContext.localizedFallbackTitle=_fallBackButtonTitle;
}

-(void)setCancleButtonTitle:(NSString *)cancleButtonTitle
{
    _cancleButtonTitle=cancleButtonTitle;
    self.authContext.localizedCancelTitle=_cancleButtonTitle;
}

-(instancetype)init
{
    self=[super init];
    if (self) {
        _authContext=[[LAContext alloc]init];
        _fallBackButtonTitle=@"";
        _reason=@"需要验证您的指纹来确认您的身份信息";
        _authContext.localizedFallbackTitle=_fallBackButtonTitle;
        self.hidesBottomBarWhenPushed=YES;
    }
    return self;
}

- (UIButton *)authenticationBtn
{
    if (_authenticationBtn==nil) {
        _authenticationBtn=[[UIButton alloc]init];
        [self.authenticationBtn addTarget:self action:@selector(doTouchIDAuthentication) forControlEvents:UIControlEventTouchUpInside];
    }
    return _authenticationBtn;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.authenticationBtn];
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didUserAttempsReachLimits:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.authenticationBtn.hidden=YES;
        });
    }
    
    self.authenticationBtn.translatesAutoresizingMaskIntoConstraints=NO;
    NSLayoutConstraint* verticalCenterConstraint=[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.authenticationBtn attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint* horizontalCenterConstraint=[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.authenticationBtn attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self.view addConstraints:@[verticalCenterConstraint,horizontalCenterConstraint]];
    
    [self doTouchIDAuthentication];
}

- (BOOL)canTouchIDAuthenticationWithError:(NSError * __autoreleasing *)error
{
    NSAssert([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0,@"TouchID is not supported" );
    
    NSError * err;
    [self.authContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&err];
    if (err.code==LAErrorTouchIDNotAvailable||err.code==LAErrorTouchIDNotEnrolled) {
        if (error) {
            *error=err;
        }
        return NO;
    }
    return YES;
}

- (void)doTouchIDAuthentication{
    NSAssert([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0,@"TouchID is not supported" );
    NSError* error;
    if ([self.authContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [self authenticateWithBiometrics];
    }else{
        //不支持指纹识别
        NSString* message;
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled:
            {
                message = @"您还没有设置TouchID验证,请设置后重试！";
                break;
            }
            case LAErrorPasscodeNotSet:
            {
                message = @"您还没有设置密码验证，请设置后重试！";
                break;
            }
            case LAErrorTouchIDLockout:
            {
                if ([[[UIDevice currentDevice] systemVersion] floatValue]<10.0) {
                    [self authenticateWithBiometrics];
                }else{
                    [self authenticatePassCode];
                }
                return;
            }
                break;
            default:
            {
                message = @"您的设备不支持TouchID验证！";
                break;
            }
        }
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提 示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)authenticateWithBiometrics
{
    __weak typeof(self) weakSelf= self;
    [self.authContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:self.reason reply:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(didFinishAuthenticationWithController:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf goBack];
                    [weakSelf.delegate didFinishAuthenticationWithController:self];
                });
            }
        }else{
            switch (error.code) {
                case LAErrorUserFallback:
                {
                    if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(didUserFallBackWithController:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.delegate didUserFallBackWithController:self];
                        });
                    }
                }
                    break;
                    
                case LAErrorUserCancel:
                {
                    if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(didUserCancleWithController:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.delegate didUserCancleWithController:self];
                        });
                    }
                }
                    break;
                    
                case -1:
                case LAErrorTouchIDLockout:
                {
                    if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(didUserAttempsReachLimits:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf goBack];
                            [weakSelf.delegate didUserAttempsReachLimits:self];
                        });
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
    }];
}

- (void)authenticatePassCode
{
    __weak typeof(self) weakSelf= self;
    [self.authContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:self.reason reply:^(BOOL success, NSError * _Nullable error) {
        if (success&&weakSelf.authContext.evaluatedPolicyDomainState==nil) {
            //密码验证已经通过，会导致下次逻辑错误，所以，更新context
            [weakSelf.authContext invalidate];
            weakSelf.authContext=[[LAContext alloc]init];
            weakSelf.authContext.localizedFallbackTitle=weakSelf.fallBackButtonTitle;
            if (weakSelf.cancleButtonTitle.length>0) {
                weakSelf.authContext.localizedCancelTitle=weakSelf.cancleButtonTitle;
            }
            //重新开始指纹验证
            [weakSelf authenticateWithBiometrics];
        }else{
            switch (error.code) {
                case LAErrorUserCancel:
                {
                    if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(didUserCancleWithController:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.delegate didUserCancleWithController:self];
                        });
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
    }];
}

- (void)goBack
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
