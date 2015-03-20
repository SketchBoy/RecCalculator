//
//  ViewController.m
//  Calculator
//
//  Created by WilliamChang on 3/15/15.
//  Copyright (c) 2015 WilliamChang. All rights reserved.
//

#import "ViewController.h"
#import "CalculatorBrain.h"

@interface ViewController ()

@property (nonatomic) BOOL cursorIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL IsTheFirstOperatorNegative;
@property (nonatomic,strong) CalculatorBrain *brain;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *operatorButtons;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@end

@implementation ViewController

@synthesize display;
@synthesize cursorIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize recordsTextFields;
@synthesize operatorButtons;
@synthesize clearButton;

//类实例的构造方法
-(CalculatorBrain *)brain
{
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

//取消所有运算键高亮显示方法
- (void)cancelAllDigitButtonsHighlighted
{
    for (UIButton *button in operatorButtons) {
        if (button.alpha != 1.0) {
            [button setAlpha:1.0];
        }
    }
}


//触摸数字键
- (IBAction)digitPressed:(UIButton *)sender
{
    //把“AC”按钮设置成“C”
    if (![[self.clearButton currentTitle] isEqualToString:@"C"]) {
        [self.clearButton setTitle:@"C" forState:UIControlStateNormal];
    }
    
    //取消所有运算键高亮显示
    [self cancelAllDigitButtonsHighlighted];
    
    self.brain.IsCalcuEnded = NO;
    
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
            return;
        }

        //单独处理数字键"0"
        if([digit isEqualToString:@"0"])
        {
            return;
        }
    }
    
    if (!self.cursorIsInTheMiddleOfEnteringANumber)
    {
        //判断第一个符号是否为负号
        if(!self.IsTheFirstOperatorNegative)
        {
            self.display.text = digit;
        }
        else
        {
            self.display.text = [NSString stringWithFormat:@"%g", -[digit doubleValue]] ;
        }
        
        cursorIsInTheMiddleOfEnteringANumber = YES;
    }
    else
    {
        //判断是否是@“.”
        if([digit isEqualToString:@"."])
        {
            //显示字符中不能包含"."
            if ([self.display.text containsString:@"."])
            {
                return;
            }
        }
        self.display.text = [self.display.text stringByAppendingString:digit];
    }
}


//触摸运算符号健
- (IBAction)operatorPressed:(UIButton *)sender
{
    //取消所有运算键高亮显示
    [self cancelAllDigitButtonsHighlighted];
    //运算符号键半透明标记
    [sender setAlpha:0.3];

    //如果上次运算出错，自动回复初始态
    if( [self.brain.Result isEqualToString:@"ERRO"])
    {
        [self.brain clearAllBuff];
    }
    
    //如果brain当前为初始态，只需要更进行后台处理
    if (self.brain.Result == nil) {
        [self.brain operatorPressed:self.display.text Operator:[sender currentTitle]];
    }
    else
    {
        [self.brain operatorPressed:self.display.text Operator:[sender currentTitle]];
        //如果当前状态为运算未结束，依据brain运算结果刷新屏幕
        if(!self.brain.IsCalcuEnded)
        {
            self.display.text = self.brain.Result;
        }
    }

    //标记需要重新输入数字
    self.cursorIsInTheMiddleOfEnteringANumber = NO;
}

//触摸输入健
- (IBAction)enterPressed
{
    //取消所有运算键高亮显示
    [self cancelAllDigitButtonsHighlighted];
    
    //如果上次运算出错，无效返回
    if( [self.brain.Result isEqualToString:@"ERRO"])
    {
        //标记当前运算由“=”结束
        self.brain.isCalcuEnded = YES;
        return;
    }
    //如果当前为brain初始态，无效返回
    if (self.brain.Result == nil && self.brain.Operantor == nil) {
        return;
    }
    
    [self.brain enterPressed:self.display.text];
    
    self.display.text = self.brain.Result;
    
    //标记需要重新输入数字
    self.cursorIsInTheMiddleOfEnteringANumber = NO;
    //标记当前运算由“=”结束
    self.brain.isCalcuEnded = YES;
}

//触摸清除键
- (IBAction)clearPressed:(UIButton *)sender {
    //清除两个缓存内容
    self.brain.Result = nil;
    self.brain.CurrentNum = nil;
    //清除缓存的operator
    self.brain.operantor = nil;
    //清除当前显示数据
    self.display.text = @"0";
    //标记需要重新输入数字
    self.cursorIsInTheMiddleOfEnteringANumber = NO;
    //初始态符号为负标记
    self.IsTheFirstOperatorNegative = NO;
    //标记运算未以“=”结束
    self.brain.isCalcuEnded = NO;
    
    //把“C”按钮设置成“AC”
    if ([[self.clearButton currentTitle] isEqualToString:@"C"]) {
        [self.clearButton setTitle:@"AC" forState:UIControlStateNormal];
    }
}

//触摸“%”按键
- (IBAction)percentPressed:(UIButton *)sender {
    self.display.text = [NSString stringWithFormat:@"%g", [self.display.text doubleValue] / 100] ;
}

//触摸“+/-”按键
- (IBAction)minusPressed:(id)sender {
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
    
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillResignActive:)
     name:UIApplicationWillResignActiveNotification
     object:app];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSString *filePath = [self dataFilePath];
    
    //这个方法可以把OutLet Collections中的成员某个属性转换为数组
    NSArray *array = [self.recordsTextFields valueForKey:@"text"];
    //通过NSArray的类方法可以直接把数据写入指定路径
    [array writeToFile:filePath atomically:YES];
}

///查找Documents目录并在其后附加数据文件
- (NSString *)dataFilePath
{
    //查找Documents路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"data.plist"];
}

///将对应记录返回display
- (IBAction)recordEntered:(UIButton *)sender
{
    UIButton *theButton = sender;
    long num = theButton.tag;
    UITextField* thefield = recordsTextFields[num];
    self.display.text = [NSString stringWithFormat:@"%g", [thefield.text doubleValue]];
    self.cursorIsInTheMiddleOfEnteringANumber = NO;
}

//保存当前display数据，并自动清除最后一组数据
- (IBAction)saveCurrentData:(UIButton *)sender
{
    for (int i=1; i>=0; i--) {
        ((UITextField*)recordsTextFields[i+1]).text = ((UITextField*)recordsTextFields[i]).text;
    }
    ((UITextField*)recordsTextFields[0]).text = self.display.text;
    
}

@end
