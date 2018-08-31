//
//  JSLimitTextField.m
//  DemoTextField
//
//  Created by 曾家诗 on 2018/8/30.
//  Copyright © 2018年 jiashi.com. All rights reserved.
//

#import "JSLimitTextField.h"
#import "NSString+Shove.h"
#import "NSString+encryptDES.h"

@interface JSLimitTextField()

@property(nonatomic,copy) NSString *previousTextFieldContent;
@property(nonatomic,strong) UITextRange *previousSelection;
@property(nonatomic,copy) NSString *phoneNum;

@end

@implementation JSLimitTextField


- (instancetype)initWithFrame:(CGRect)frame AndPlaceholder:(NSString *)placeholder AndTextFieldType:(TextFieldType)textType
{
    self = [super initWithFrame:frame];
    if (self) {
       
        self.delegate = self;
        self.font = [UIFont systemFontOfSize:16];
        self.backgroundColor = [UIColor yellowColor];
        self.placeholder = placeholder;
        self.textfieldType = textType;
        [self initTextFieldView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame AndPlaceholder:(NSString *)placeholder AndTextFieldType:(TextFieldType)textType AndCertificateBlock:(CertificateBlock)block{
    
    self.certifiBlock = block;
    return [self initWithFrame:frame AndPlaceholder:placeholder AndTextFieldType:textType];
    
}

/**
 * 初始化textField,设置常用属性
 */
- (void)initTextFieldView{
    self.clearButtonMode = UITextFieldViewModeWhileEditing;  //编辑时出现删除按钮
    self.textAlignment = NSTextAlignmentLeft;  //左对齐
    self.borderStyle = UITextBorderStyleRoundedRect;
    
}

/**
 * setter方法
 */
- (void)setTextfieldType:(TextFieldType)textfieldType{
    
    _textfieldType = textfieldType;
    if (textfieldType==TextFieldTypePhoneNum) {
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.secureTextEntry = NO;
        //再次编辑就清空
        self.clearsOnBeginEditing = NO;
        [self addTarget:self action:@selector(reformatAsPhoneNumber:) forControlEvents:UIControlEventEditingChanged];
        
    }else if(textfieldType==TextFieldTypePassword){
        self.keyboardType = UIKeyboardTypeASCIICapable;
        self.secureTextEntry = YES;
        //再次编辑就清空
        self.clearsOnBeginEditing = YES;
        
    }else if(textfieldType==TextFieldTypeEmail){
        
        self.keyboardType = UIKeyboardTypeASCIICapable;
        self.LimitLength = 99;
        //再次编辑就清空
        self.clearsOnBeginEditing = NO; 
    }else if (textfieldType==TextFieldTypeCardID) {
        self.keyboardType = UIKeyboardTypeASCIICapable;
        self.secureTextEntry = NO;
        //再次编辑就清空
        self.clearsOnBeginEditing = NO;
        [self addTarget:self action:@selector(reformatAsPhoneNumber:) forControlEvents:UIControlEventEditingChanged];
    }else if (textfieldType==TextFieldTypeBankCard){
        
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.secureTextEntry = NO;
        //再次编辑就清空
        self.clearsOnBeginEditing = NO;
        [self addTarget:self action:@selector(reformatAsPhoneNumber:) forControlEvents:UIControlEventEditingChanged];
        
    }

}

- (void)setLimitLength:(NSUInteger)LimitLength{
    
    _LimitLength = LimitLength;
    
}

#pragma mark - 手机号码分隔
/**
 *  3-3-4手机号码分隔
 */
-(void)reformatAsPhoneNumber:(UITextField *)textField {
    //判断正确的光标位置
    NSUInteger targetCursorPostion = [textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.selectedTextRange.start];
    
    NSString *phoneNumberWithoutSpaces;
    if(self.textfieldType==TextFieldTypePhoneNum){
        phoneNumberWithoutSpaces = [NSString removePhoneNumNonDigits:textField.text andPreserveCursorPosition:&targetCursorPostion];
        self.LimitLength = 11;
        
    }else if(self.textfieldType==TextFieldTypeCardID){

        phoneNumberWithoutSpaces = [NSString removeIDCardNumNonDigits:textField.text andPreserveCursorPosition:&targetCursorPostion];
        self.LimitLength = 18;
    }else if(self.textfieldType==TextFieldTypeBankCard){
        
        phoneNumberWithoutSpaces = [NSString removePhoneNumNonDigits:textField.text andPreserveCursorPosition:&targetCursorPostion];
        self.LimitLength = 19;
    }
    if([phoneNumberWithoutSpaces length] > self.LimitLength) {
        //避免超过限制位数的输入
        [textField setText:self.previousTextFieldContent];
        textField.selectedTextRange = self.previousSelection;
        return;
    }
    
    //制定格式
    NSString *phoneNumberWithSpaces;
    if(self.textfieldType==TextFieldTypePhoneNum){
       phoneNumberWithSpaces = [NSString phoneNumInsertSpacesEveryFourDigitsIntoString:phoneNumberWithoutSpaces andPreserveCursorPosition:&targetCursorPostion];
    }else if(self.textfieldType==TextFieldTypeCardID||self.textfieldType==TextFieldTypeBankCard){
        phoneNumberWithSpaces = [NSString cardIDInsertSpacesEveryFourDigitsIntoString:phoneNumberWithoutSpaces andPreserveCursorPosition:&targetCursorPostion];
    }
    
    textField.text = phoneNumberWithSpaces;
    UITextPosition *targetPostion = [textField positionFromPosition:textField.beginningOfDocument offset:targetCursorPostion];
    [textField setSelectedTextRange:[textField textRangeFromPosition:targetPostion toPosition:targetPostion]];
}


#pragma mark - UITextFieldDelegate
/**
 * 限制长度
 */
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    if (self.textfieldType==TextFieldTypePhoneNum) {
        //手机限制
        self.previousSelection = textField.selectedTextRange;
        self.previousTextFieldContent = textField.text;
        if(range.location==0) {
            //限制手机号码只能以1开头
            if(string.integerValue >1){
                return NO;
            }
        }
        return YES;
    }else if(self.textfieldType==TextFieldTypePassword){
        //密码限制
        if (range.length+range.location>textField.text.length) {

            return NO;
        }
        NSUInteger newLength = textField.text.length + string.length - range.length;
        return newLength <= self.LimitLength;
        
    }else if (self.textfieldType==TextFieldTypeCardID||self.textfieldType==TextFieldTypeBankCard){
        //身份证限制
        self.previousSelection = textField.selectedTextRange;
        self.previousTextFieldContent = textField.text;
        return YES;
    }else{
        return YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"结束编辑");
    
    //验证格式
    [self verificationFormatWith:textField AndBlock:self.certifiBlock];
    
}


/**
 * 验证格式
 */
- (void)verificationFormatWith:(UITextField *)textField AndBlock:(CertificateBlock)block{
    if (!block) {
        return;
    }
    NSString *textStr = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    //验证要求格式
    if (self.textfieldType==TextFieldTypePhoneNum) {
        //手机格式验证
        self.certifiBlock(self,textStr,[textStr isPhone]);
        
    }else if (self.textfieldType==TextFieldTypeEmail){
        //邮箱验证
        self.certifiBlock(self,textStr,[textField.text isEmail]);
        
    }else if (self.textfieldType==TextFieldTypeCardID){
        //身份证验证
        self.certifiBlock(self,textStr,[NSString accurateVerifyIDCardNumber:textStr]);
    }else if(self.textfieldType==TextFieldTypeBankCard){
        //银行卡验证
        self.certifiBlock(self,textStr,[textStr wl_bankCardluhmCheck]);
        
    }else{
        //密码验证
        self.certifiBlock(self,textStr,(textField.text.length>=6&&textField.text.length<=16));
    }
}







@end
