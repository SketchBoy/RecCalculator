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

@synthesize IsCalcuEnded;
//运算结果缓存 A
@synthesize Result;
//运算符缓存 B
@synthesize Operantor;
//当前运算值缓存 C
@synthesize CurrentNum;

-(void)clearAllBuff
{
    self.Result = nil;
    self.Operantor = nil;
    self.CurrentNum = nil;
}

-(void)enterPressed:(NSString *)screenNum
{
    //如果上次运算以“=”结束，且各个缓存非空
    //计算并更新A
    if(self.IsCalcuEnded)
    {
        [self performOperation];
    }
    //更新C，计算并更新A
    else
    {
        self.CurrentNum = screenNum;
        [self performOperation];
    }
}

-(void)operatorPressed:(NSString *)screenNum Operator:(NSString *)operat
{
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
