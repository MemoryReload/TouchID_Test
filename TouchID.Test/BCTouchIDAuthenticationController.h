//
//  ViewController.h
//  TouchID.Test
//
//  Created by Heping on 2017/1/17.
//  Copyright © 2017年 BONC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCTouchIDAuthenticationController;


/**
 实现BCTouchIDAuthenticationControllerTouchID验证事件回调处理的协议接口
 */
@protocol BCTouchIDAuthenticationControllerDelegate <NSObject>
@optional

/**
 指纹验证成功时被调用
 
 @param controller 执行验证的指纹验证控制器实例
 */
-(void)didFinishAuthenticationWithController:(BCTouchIDAuthenticationController*)controller;

/**
 当设置了fallBackButtonTitle之后，将会出现回退处理功能按钮，用户点击fallBack按钮后，将调用此方法进行回退处理
 
 @param controller 执行验证的指纹验证控制器实例
 */
-(void)didUserFallBackWithController:(BCTouchIDAuthenticationController*)controller;

/**
 当用户的尝试次数达到上限，TouchID锁定时调用；
 注意：如果代理没有实现此方法，验证将弹出密码激活TouchID的界面，激活后可以继续尝试。如果实现此方法，达到最大尝试次数之后，TouchID将锁定，验证将失败退出。
 
 @param controller 执行验证的指纹验证控制器实例
 */
-(void)didUserAttempsReachLimits:(BCTouchIDAuthenticationController*)controller;

/**
 当用户点击取消按钮时，此方被调用。
 
 @param controller 执行验证的指纹验证控制器实例
 */
-(void)didUserCancleWithController:(BCTouchIDAuthenticationController*)controller;
@end


NS_CLASS_AVAILABLE(10_10, 8_0)
/**
 调用TouchID实现验证的控制器
 */
@interface BCTouchIDAuthenticationController : UIViewController

/**
 TouchID验证弹出警视窗的提示文字，为请求验证的原因。
 */
@property (nonatomic,strong) NSString* reason;

/**
 回退处理按钮的标题，默认为空，按钮隐藏。当此属性的值不为空时，按钮将显示。
 */
@property (nonatomic,strong) NSString* fallBackButtonTitle;

/**
 取消验证的按钮标题。注意：此属性只在10及以上的iOS系统支持。
 */
@property (nonatomic,strong) NSString* cancleButtonTitle NS_AVAILABLE(10_12, 10_0);

/**
 需要循环验证时，如果验证失败，点击此按钮将会开启新的一轮验证。
 */
@property (nonatomic,strong,readonly) UIButton* authenticationBtn;

/**
 用来处理验证结果回调的代理对象
 */
@property (nonatomic,weak) id<BCTouchIDAuthenticationControllerDelegate> delegate;

/**
 默认的初始化函数
 
 @return 指纹验证控制器实例
 */
- (instancetype)init;


/**
 检查设备硬件是否支持TouchID(包括硬件支持，用户是否设置了TouchID)
 
 @param error 如果设备不支持，方法执行后error对象中包含无法支持IDTouch的错误原因。如果不需要错误信息，传入nil。
 @return  设备是否支持TouchID验证
 */
- (BOOL)canTouchIDAuthenticationWithError:(NSError * __autoreleasing *)error;

/**
 调用验证流程。
 注意：控制器加载视图之后会自动调用此方法，开始验证流程。点击authenticationBtn也会调用此方法，开始新的一轮验证。此方法用来供用自定义一轮验证的流程，如果你愿意的话。
 */
- (void)doTouchIDAuthentication;
@end
