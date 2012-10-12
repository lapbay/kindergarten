//
//  HJEditViewController.m
//  gdst
//
//  Created by Wu Chang on 7/22/12.
//  Copyright (c) 2012 unique. All rights reserved.
//

#import "HJEditViewController.h"
#import "MIRequestManager+API.h"

@interface HJEditViewController ()

@end

@implementation HJEditViewController
@synthesize delegate, editView, dateView, type;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.editType = HJEditTypeDefault;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"确定", @"Confirm")
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(confirm:)];
    self.navigationItem.rightBarButtonItem = NavButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setType:(NSInteger)t {
    type = t;
//    NSLog(@"%i", t);
    if (t == 2) {
        self.dateView.hidden = NO;
        self.editView.hidden = YES;
    }else{
        self.dateView.hidden = YES;
        self.editView.hidden = NO;
    }
}

- (IBAction)confirm: (id) sender {
    if (self.editView.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"内容不能为空"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    switch (self.type) {
        case 0:
        {
            break;
        }
        case 1:
        {
            if ([self isPureFloat:self.editView.text] || [self isPureInt:self.editView.text]) {
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"内容必须为数字"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            break;
        }
        case 2:
        {
            break;
        }
        default:
            break;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(textEditDidFinished:)]){
        [self.delegate performSelector:@selector(textEditDidFinished:) withObject:self.editView.text];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
    }else{
        
    }
}


- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (BOOL)isPureFloat:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

@end
