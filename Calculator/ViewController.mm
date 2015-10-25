//
//  ViewController.m
//  Calculator
//
//  Created by WilliamChang on 3/15/15.
//  Copyright (c) 2015 WilliamChang. All rights reserved.
//

#import "ViewController.h"
#import "CalculatorBrain.h"
#include "resolveFormula.h"

@interface ViewController ()

@property (nonatomic) BOOL cursorIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL IsTheFirstOperatorNegative;
@property (nonatomic,strong) CalculatorBrain *brain;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *operatorButtons;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

//系统声音
@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	soundFileObject;
@property (assign)      BOOL            isSilent;

@end

@implementation ViewController
{
}

@synthesize display;
@synthesize cursorIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize recordsTextFields;
@synthesize operatorButtons;
@synthesize clearButton;

#pragma mark -- View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initRecordableTextField];
    
    [self initSystemSound];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSString *filePath = [self dataFilePath];
    
    //这个方法可以把OutLet Collections中的成员某个属性转换为数组
    NSArray *array = [self.recordsTextFields valueForKey:@"text"];
    //通过NSArray的类方法可以直接把数据写入指定路径
    [array writeToFile:filePath atomically:YES];
}

//初始化可记录TextField
- (void)initRecordableTextField
{
    NSString *filePath = [self dataFilePath];
    
    ///通过[NSFileManager defaultManager] fileExistsAtPaht:(NSString *)来判断当前路径下文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
        //恢复从文件读取数据到各个TextField
        for (int i = 0; i < 3; i++) {
            UITextField *theField = self.recordsTextFields[i];
            theField.text = array[i];
        }
    }
    
    //在通知中心设置applicationWillResignActive对UIApplicationWillResignActiveNotification的响应
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillResignActive:)
     name:UIApplicationWillResignActiveNotification
     object:app];
}

//查找Documents目录并在其后附加数据文件
- (NSString *)dataFilePath
{
    //查找Documents路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"data.plist"];
}

//初始化系统按钮声音
- (void)initSystemSound
{
    //通过mainBundle资源束的名称和拓展名找到sound的URL
    NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"btw"
                                                withExtension: @"wav"];
    
    self.soundFileURLRef = (__bridge CFURLRef)tapSound;
    
    AudioServicesCreateSystemSoundID (_soundFileURLRef,&_soundFileObject);
    
    //默认不禁音按钮声
    self.isSilent = NO;
}

//播放按键声音
- (void)playBtnSound
{
    if (!self.isSilent) {
        AudioServicesPlaySystemSound (_soundFileObject);
    }
}

#pragma mark -- Property Lazy Load

//类实例的构造方法
-(CalculatorBrain *)brain
{
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
        _brain.isEnteringBuff_A = YES;
    }
    return _brain;
}

#pragma mark -- Button Pressed Event

//触摸数字键
- (IBAction)digitPressed:(UIButton *)sender
{
    [self playBtnSound];
    
    //把“AC”按钮设置成“C”
    if (![[self.clearButton currentTitle] isEqualToString:@"C"]) {
        [self.clearButton setTitle:@"C" forState:UIControlStateNormal];
    }

    //如果上次运算出错，自动回复初始态
    if( [self.display.text isEqualToString:@"ERRO"])
    {
        [self clearPressed:nil];
    }
    
    NSString *digit = [sender currentTitle];
    
    //判断是否为@"0"的显示状态
    if ([self.display.text isEqualToString:@"0"] || [self.display.text isEqualToString:@"-0"])
    {
        //单独处理数字键“.”
        if ([digit isEqualToString:@"."])
        {
            if ([self.display.text isEqualToString:@"0"] ) {
                self.display.text = @"0." ;
            }
            else
            {
                self.display.text = @"-0." ;
            }
            cursorIsInTheMiddleOfEnteringANumber = YES;
            
            //向brain实例发送刷新当前屏幕缓存的消息，具体处理由brain内部完成，对于ViewController是透明的
            [self.brain updateBuff:self.display.text];
            
            return;
        }

        //单独处理数字键"0"
        if([digit isEqualToString:@"0"])
        {
            //无效返回
            return;
        }
    }

    if (!self.cursorIsInTheMiddleOfEnteringANumber)
    {
        self.display.text = [NSString stringWithFormat:@"%g", [digit doubleValue]] ;
        cursorIsInTheMiddleOfEnteringANumber = YES;
    }
    else
    {
        self.display.text = [self.display.text stringByAppendingString:digit];
    }

}


//触摸运算符号健
- (IBAction)operatorPressed:(UIButton *)sender
{
    [self playBtnSound];
    
    NSString *op = [sender currentTitle];
    if([op isEqualToString:@"×"])
    {
         self.display.text = [self.display.text stringByAppendingString:@"*"];
    }
    else if([op isEqualToString:@"÷"])
    {
        self.display.text = [self.display.text stringByAppendingString:@"/"];
    }
    else
    {
        if(!self.cursorIsInTheMiddleOfEnteringANumber)
        {
            self.display.text = op;
            cursorIsInTheMiddleOfEnteringANumber = YES;
        }
        else
        {
            self.display.text = [self.display.text stringByAppendingString:op];
        }
    }
}

//触摸输入健
- (IBAction)enterPressed
{
    [self playBtnSound];
 
    //标记需要重新输入数字
    self.cursorIsInTheMiddleOfEnteringANumber = NO;
    
    Cformula formulaManager = *new Cformula();
    double result;
    
    if(formulaManager.resolveFormula([self.display.text UTF8String], &result))
    {
        self.display.text = [NSString stringWithFormat:@"%g", result];
    }
    else
    {
        self.display.text = @"ERRO";
    }
    
}

//触摸清除键
- (IBAction)clearPressed:(UIButton *)sender
{
    [self playBtnSound];

    self.display.text = @"0";
    
    //标记需要重新输入数字
    self.cursorIsInTheMiddleOfEnteringANumber = NO;
    
    //把“C”按钮设置成“AC”
    if ([[self.clearButton currentTitle] isEqualToString:@"C"]) {
        [self.clearButton setTitle:@"AC" forState:UIControlStateNormal];
    }
}

//触摸“DEL”按键
- (IBAction)DelPressed:(UIButton *)sender
{
    [self playBtnSound];

    if ([self.display.text isEqualToString:@"ERRO"]) {
        self.display.text = @"0";
        return;
    }
    
    if (![self.display.text isEqualToString:@"0"])
    {
        unsigned long length = [self.display.text length];
        if (length == 1) {
            self.display.text = @"0";
            self.cursorIsInTheMiddleOfEnteringANumber = NO;
        }
        else
        {
            self.display.text = [self.display.text substringToIndex:length-1];
        }

        //向brain实例发送刷新当前屏幕缓存的消息，具体处理由brain内部完成，对于ViewController是透明的
        [self.brain updateBuff:self.display.text];
    }
}


//触摸“+/-”按键
- (IBAction)minusPressed:(id)sender
{
    [self playBtnSound];

    if (self.cursorIsInTheMiddleOfEnteringANumber) {
        self.display.text = [NSString stringWithFormat:@"%g", -[self.display.text doubleValue]] ;
    }
    else
    {
        if (![self.display.text isEqualToString:@"-0"])
        {
            self.display.text = @"-0";
            self.IsTheFirstOperatorNegative = YES;
        }
        else
        {
            self.display.text = @"0";
            self.IsTheFirstOperatorNegative = NO;
        }
    }
    
    //向brain实例发送刷新当前屏幕缓存的消息，具体处理由brain内部完成，对于ViewController是透明的
    [self.brain updateBuff:self.display.text];
}

//将对应记录返回display
- (IBAction)recordEntered:(UIButton *)sender
{
    [self playBtnSound];
    
    UIButton *theButton = sender;
    long num = theButton.tag;
    UITextField* thefield = recordsTextFields[num];
    
    if (thefield.text == nil || [thefield.text  isEqual: @""]) {
        return;
    }
    
    self.display.text = [NSString stringWithFormat:@"%g", [thefield.text doubleValue]];
    [self.brain updateBuff:self.display.text];
    self.cursorIsInTheMiddleOfEnteringANumber = NO;
}

//清除对应的记录
- (IBAction)clearTheRecord:(UIButton *)sender
{
    [self playBtnSound];
    
    UIButton *theButton = sender;
    long num = theButton.tag;
    UITextField* thefield = recordsTextFields[num];
    thefield.text = @"";

}

//保存当前display数据，并自动清除最后一组数据
- (IBAction)saveCurrentData:(UIButton *)sender
{
    [self playBtnSound];
    
    for (int i=1; i>=0; i--) {
        ((UITextField*)recordsTextFields[i+1]).text = ((UITextField*)recordsTextFields[i]).text;
    }
    ((UITextField*)recordsTextFields[0]).text = self.display.text;
}

#pragma Mark -- Touch Event

//处理编辑TextField点击别处取消
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (int i=0; i<3; i++) {
        UITextField *theField = self.recordsTextFields[i];
        [theField resignFirstResponder];
    }
}

@end
