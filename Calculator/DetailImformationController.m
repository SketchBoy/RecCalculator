//
//  DetailImformationController.m
//  Calculator
//
//  Created by WilliamChang on 3/31/15.
//  Copyright (c) 2015 WilliamChang. All rights reserved.
//

#import "DetailImformationController.h"

@interface DetailImformationController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigator;
@end

@implementation DetailImformationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //webview适应屏幕尺寸
    self.webview.scalesPageToFit = YES;
    
    //创建网络请求
    NSURL *url= [NSURL URLWithString:@"http://walliamsblog.blog.ustc.edu.cn/?p=64"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //加载网络请求
    [self.webview loadRequest:request];
                 
    //设置webview的代理到controller
    self.webview.delegate = self;
}

- (IBAction)closeCurrentView:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)webgoBack:(UIBarButtonItem *)sender {
    [self.webview goBack];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webviewDidStartLoad...");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webviewDidFinishLoad...");
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webviewDidFailLoadWithError!");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
