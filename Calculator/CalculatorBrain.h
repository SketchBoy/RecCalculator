//
//  CalculatorBrain.h
//  Calculator
//
//  Created by WilliamChang on 3/15/15.
//  Copyright (c) 2015 WilliamChang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)clearAllBuff;

- (void)operatorPressed:(NSString *)screenNum
             Operator:(NSString *)operat;
- (void)enterPressed:(NSString *)screenNum;
- (void)updateBuff:(NSString *)screenNum;

@property (nonatomic, strong) NSString *Operantor;
@property (nonatomic, strong) NSString *Result;
@property (nonatomic, strong) NSString *CurrentNum;

@property BOOL isEnteringBuff_A;

@end
