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

- (id)initSystemShake;//系统 震动

@end

@implementation ViewController
{
    AVAudioPlayer *player;
    SystemSoundID sound;//系统声音的id 取值范围为：1000-2000  
}

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
        _brain.isEnteringBuff_A = YES;
    }
    return _brain;
}

//初始化震动
- (id)initSystemShake
{
    self = [super init];
    if (self) {
        sound = kSystemSoundID_Vibrate;//震动
    }
    return self;
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
    //播放声音
    if (player)
    {
        if (![player isPlaying])
        {
            [player play];
//            NSLog(@"播放开始");
        }
    }
    
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
    //播放声音
    if (player)
    {
        if (![player isPlaying])
        {
            [player play];
//            NSLog(@"播放开始");
        }
    }

//    //取消所有运算键高亮显示
//    [self cancelAllDigitButtonsHighlighted];
//    //运算符号键半透明标记
//    [sender setAlpha:0.3];
//
//    //如果上次运算出错，自动回复初始态
//    if( [self.brain.Result isEqualToString:@"ERRO"])
//    {
//        [self.brain clearAllBuff];
//    }
//
//    //如果brain当前为初始态，只需要更进行后台处理
//    if (self.brain.CurrentNum == nil) {
//        [self.brain operatorPressed:self.display.text Operator:[sender currentTitle]];
//    }
//    else
//    {
//        [self.brain operatorPressed:self.display.text Operator:[sender currentTitle]];
//        //如果当前状态为运算未结束，依据brain运算结果刷新屏幕
//        self.display.text = self.brain.Result;
//    }
//
//    //标记需要重新输入数字
//    self.cursorIsInTheMiddleOfEnteringANumber = NO;
//    //恢复符号标记 
//    self.IsTheFirstOperatorNegative = NO;
//    //标记重新进入边录入边记录缓存C的状态
//    self.brain.isEnteringBuff_A = NO;
    
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
    //播放声音
    if (player)
    {
        if (![player isPlaying])
        {
            [player play];
//            NSLog(@"播放开始");
        }
    }
 
    //标记需要重新输入数字
    self.cursorIsInTheMiddleOfEnteringANumber = NO;
//    //标记重新进入边录入边记录缓存A的状态
//    self.brain.isEnteringBuff_A = YES;
    
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
- (IBAction)clearPressed:(UIButton *)sender {
    
    //播放声音
    if (player)
    {
        if (![player isPlaying])
        {
            [player play];
//            NSLog(@"播放开始");
        }
    }

//    //清除两个缓存内容
//    self.brain.Result = nil;
//    self.brain.CurrentNum = nil;
    //清除缓存的operator
//    self.brain.operantor = nil;
//    //清除当前显示数据
    self.display.text = @"0";
    //标记需要重新输入数字
    self.cursorIsInTheMiddleOfEnteringANumber = NO;
//    //初始态符号为负标记
//    self.IsTheFirstOperatorNegative = NO;
//    //标记运算未以“=”结束
//    self.brain.isEnteringBuff_A = YES;
    
    //取消所有运算键高亮显示
    [self cancelAllDigitButtonsHighlighted];
    
    //把“C”按钮设置成“AC”
    if ([[self.clearButton currentTitle] isEqualToString:@"C"]) {
        [self.clearButton setTitle:@"AC" forState:UIControlStateNormal];
    }
}

//触摸“DEL”按键
- (IBAction)DelPressed:(UIButton *)sender{
    
    //播放声音
    if (player)
    {
        if (![player isPlaying])
        {
            [player play];
//            NSLog(@"播放开始");
        }
    }

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
- (IBAction)minusPressed:(id)sender {
    
    //播放声音
    if (player)
    {
        if (![player isPlaying])
        {
            [player play];
//            NSLog(@"播放开始");
        }
    }

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
    
    //在通知中心设置applicationWillResignActive对UIApplicationWillResignActiveNotification的响应
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillResignActive:)
     name:UIApplicationWillResignActiveNotification
     object:app];
    
    //找到mp3在资源库中的路径 文件名称为sound 类型为mp3
    NSString *path = [[NSBundle mainBundle] pathForResource:@"btw" ofType:@"wav"];
    //在这里判断以下是否能找到这个音乐文件
    if (path) {
        //从path路径中 加载播放器
        player = [[AVAudioPlayer alloc]initWithContentsOfURL:[[NSURL alloc]initFileURLWithPath:path]error:nil];
        //初始化播放器
        [player prepareToPlay];
        
        //设置播放循环次数，如果numberOfLoops为负数 音频文件就会一直循环播放下去
        player.numberOfLoops = 1;
        
        //设置音频音量 volume的取值范围在 0.0为最小 0.1为最大 可以根据自己的情况而设置
        player.volume = 0.5f;
        
        NSLog(@"播放加载");
    }
    
//    int j = Cformula::mergerMinusAndAdd("-++-");
//    printf("%d\n",j);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (int i=0; i<3; i++) {
        UITextField *theField = self.recordsTextFields[i];
        [theField resignFirstResponder];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSString *filePath = [self dataFilePath];
    
    //这个方法可以把OutLet Collections中的成员某个属性转换为数组
    NSArray *array = [self.recordsTextFields valueForKey:@"text"];
    //通过NSArray的类方法可以直接把数据写入指定路径
    [array writeToFile:filePath atomically:YES];
}

//查找Documents目录并在其后附加数据文件
- (NSString *)dataFilePath
{
    //查找Documents路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"data.plist"];
}

//将对应记录返回display
- (IBAction)recordEntered:(UIButton *)sender
{
    //播放声音
    if (player)
    {
        if (![player isPlaying])
        {
            [player play];
            NSLog(@"播放开始");
        }
    }
    
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
- (IBAction)clearTheRecord:(UIButton *)sender {
    //播放声音
    if (player)
    {
        if (![player isPlaying])
        {
            [player play];
            NSLog(@"播放开始");
        }
    }
    
    UIButton *theButton = sender;
    long num = theButton.tag;
    UITextField* thefield = recordsTextFields[num];
    thefield.text = @"";

}

//保存当前display数据，并自动清除最后一组数据
- (IBAction)saveCurrentData:(UIButton *)sender
{
    //播放声音
    if (player)
    {
        if (![player isPlaying])
        {
            [player play];
            NSLog(@"播放开始");
        }
    }
    
    for (int i=1; i>=0; i--) {
        ((UITextField*)recordsTextFields[i+1]).text = ((UITextField*)recordsTextFields[i]).text;
    }
    ((UITextField*)recordsTextFields[0]).text = self.display.text;
}

@end
