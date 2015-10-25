//
//  CalculatorBrain.m
//  Calculator
//
//  Created by WilliamChang on 3/15/15.
//  Copyright (c) 2015 WilliamChang. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@end

@implementation CalculatorBrain

//运算结果缓存 A
@synthesize Result;
//运算符缓存 B
@synthesize Operantor;
//当前运算值缓存 C
@synthesize CurrentNum;

//在触摸数字键时，包括“+/-”、“%”，有两种状态：
//第一是边录入边记录缓存A的状态，否则是边录入边记录缓存C的状态
@synthesize isEnteringBuff_A;

-(void)clearAllBuff
{
    self.Result = nil;
    self.Operantor = nil;
    self.CurrentNum = nil;
    
    //更改为边录入边记录缓存A的状态
    self.isEnteringBuff_A = YES;
}

-(void)updateBuff:(NSString *)screenNum
{
    if (self.isEnteringBuff_A)
    {
        self.Result = screenNum;
    }
    else
    {
        self.CurrentNum = screenNum;
    }
}

-(void)enterPressed:(NSString *)screenNum
{
    ///----------------------------------------------------------------------------
    ////Fixed Mar24 取消在enterPressed以及operatorPressed中对A的更新处理
    //如果上次运算以“=”结束，且各个缓存非空（在ViewController.m中已有该条件下才进入该方法）
    //计算并更新A
    /*
    if(self.IsCalcuEnded)
    {
        [self performOperation];
    }
    //更新C，计算并更新A
    else
    {
        self.CurrentNum = screenNum;
        [self performOperation];
    }*/
    ///----------------------------------------------------------------------------
    
    //由于新方法采用在Viewcontroller.m中digitPressed边录入边跟新缓存A
    [self performOperation];
    
    //更改为边录入边记录缓存A的状态
    self.isEnteringBuff_A = YES;
}

-(void)operatorPressed:(NSString *)screenNum Operator:(NSString *)operat
{
    ///----------------------------------------------------------------------------
    ////Fixed Mar24 取消在enterPressed以及operatorPressed中对A的更新处理
    /*
    ///如果brain当前为初始态，只需要把屏幕值注入A与运算符注入B
    if (self.Result == nil || [self.Result isEqualToString:@"ERRO"])
    {
        self.Result = screenNum;
        self.Operantor = operat;
    }
    else
    {
        //如果当前状态为运算结束状态（由“=”触发），只需注入B
        if(self.IsCalcuEnded)
        {
            self.Operantor = operat;
        }
        //如果当前状态为运算未结束，需要和C，并进行计算跟新A，再注入B
        else
        {
            self.CurrentNum = screenNum;
            [self performOperation];
            self.Operantor = operat;
        }
    }
    */
    ///----------------------------------------------------------------------------
    
    ///如果brain当前为初始态(self.CurrentNum为空)或者以“=”结束,只需要把运算符注入B
    if (self.CurrentNum == nil || self.isEnteringBuff_A)
    {
        self.Operantor = operat;
    }
    ///非初始态（self.CurrentNum为空非空）否则需要计算并跟新A，再注入B
    else
    {
        [self performOperation];
        self.Operantor = operat;
    }
    
    ///更改为边录入边记录缓存C的状态
    self.isEnteringBuff_A = NO;
}

-(void)performOperation
{
    double result = 0;
    
    //具体运算细节
    if ([self.Operantor isEqualToString:@"+"])
    {
        result = [self.Result doubleValue] + [self.CurrentNum doubleValue];
        self.Result = [NSString stringWithFormat:@"%g", result];
    }
    else if([self.Operantor isEqualToString:@"×"])
    {
        result = [self.Result doubleValue] * [self.CurrentNum doubleValue];
        self.Result = [NSString stringWithFormat:@"%g", result];
    }
    else if([self.Operantor isEqualToString:@"-"])
    {
        result = [self.Result doubleValue] - [self.CurrentNum doubleValue];
        self.Result = [NSString stringWithFormat:@"%g", result];
    }
    else if([self.Operantor isEqualToString:@"÷"])
    {
        double divisor = [self.CurrentNum doubleValue];
        if (divisor) {
            result = [self.Result doubleValue] / divisor;
            self.Result = [NSString stringWithFormat:@"%g", result];
        }
        else
        {
            self.Result = @"ERRO";
        }
    }
}


@end
