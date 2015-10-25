//
//  ViewController.h
//  Calculator
//
//  Created by WilliamChang on 3/15/15.
//  Copyright (c) 2015 WilliamChang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h> 

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *display;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *recordsTextFields;


@end

