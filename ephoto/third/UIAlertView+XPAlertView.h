//
//  UIAlertView+XPAlertView.h
//  
//
//  Created by
//  Copyright (c) 2014  All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (XPAlertView)

-(void)showWithCompletion:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completion;

@end
