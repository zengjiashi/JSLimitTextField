//
//  JSLimitTextField.h
//  DemoTextField
//
//  Created by 曾家诗 on 2018/8/30.
//  Copyright © 2018年 jiashi.com. All rights reserved.
//
//自定义textField

#import <UIKit/UIKit.h>
@class JSLimitTextField;


typedef NS_ENUM(NSInteger,TextFieldType){
    
    TextFieldTypePhoneNum,  //手机号码
    TextFieldTypePassword,  //密码
    TextFieldTypeEmail,     //电子邮箱
    TextFieldTypeCardID,    //身份证
    TextFieldTypeBankCard,   //银行卡
    
    
};

typedef void(^CertificateBlock)(JSLimitTextField *textField,NSString *textString,BOOL isCorrect);

@interface JSLimitTextField : UITextField<UITextFieldDelegate>

//初始化
- (instancetype)initWithFrame:(CGRect)frame AndPlaceholder:(NSString *)placeholder AndTextFieldType:(TextFieldType)textType;
- (instancetype)initWithFrame:(CGRect)frame AndPlaceholder:(NSString *)placeholder AndTextFieldType:(TextFieldType)textType AndCertificateBlock:(CertificateBlock)block;

//输入框类型
@property(nonatomic,assign) TextFieldType textfieldType;
//限制长度
@property(nonatomic,assign) NSUInteger LimitLength;
//认证格式是否正确的block
@property(nonatomic,copy) CertificateBlock certifiBlock;


@end
