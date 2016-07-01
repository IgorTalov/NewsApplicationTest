//
//  DetailViewController.h
//  News
//
//  Created by Игорь Талов on 29.06.16.
//  Copyright © 2016 Игорь Талов. All rights reserved.


#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property(weak, nonatomic) IBOutlet UIWebView* webView;

@property(strong, nonatomic) NSString* htmlString;
@property(strong, nonatomic) NSString* viewTitle;

@end
