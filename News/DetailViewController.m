//
//  DetailViewController.m
//  News
//
//  Created by Игорь Талов on 29.06.16.
//  Copyright © 2016 Игорь Талов. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <UIWebViewDelegate>

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.webView loadHTMLString:self.htmlString baseURL:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}


-(void)dealloc{
    self.webView.delegate = nil;
}

#pragma UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSLog(@"shouldStartLoadWithRequest %@", [request debugDescription]);
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]show];
    
    NSLog(@"Fail");
}
@end
