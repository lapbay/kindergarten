//
//  HJChatViewController.h
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"
#import "HPGrowingTextView.h"

@class UIBubbleTableView;

@interface HJChatViewController : UIViewController <UIBubbleTableViewDataSource, HPGrowingTextViewDelegate>
{
    IBOutlet UIBubbleTableView *bubbleTable;
    NSMutableArray *bubbleData;
    
    UIView *containerView;
    HPGrowingTextView *textView;
}

@property (retain, nonatomic) NSMutableArray *dataSource;
@property (retain, nonatomic) NSString *withId;

-(void)resignTextView;

@end
