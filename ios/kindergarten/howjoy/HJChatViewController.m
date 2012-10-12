//
//  HJChatViewController.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

// 
// Images used in this example by Petr Kratochvil released into public domain
// http://www.publicdomainpictures.net/view-image.php?image=9806
// http://www.publicdomainpictures.net/view-image.php?image=1358
//

#import "HJChatViewController.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "MIRequestManager+API.h"
#import "MBProgressHUD.h"

@implementation HJChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];

        self.title = NSLocalizedString(@"私信", @"Message");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        self.dataSource = [NSMutableArray array];
        bubbleData = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadInputView];
//    NSBubbleData *heyBubble = [NSBubbleData dataWithText:@"Hey, halloween is soon" date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeSomeoneElse];
//    heyBubble.avatar = [UIImage imageNamed:@"avatar1.png"];
//
//    NSBubbleData *photoBubble = [NSBubbleData dataWithImage:[UIImage imageNamed:@"halloween.jpg"] date:[NSDate dateWithTimeIntervalSinceNow:-290] type:BubbleTypeSomeoneElse];
//    photoBubble.avatar = [UIImage imageNamed:@"avatar1.png"];
//    
//    NSBubbleData *replyBubble = [NSBubbleData dataWithText:@"Wow.. Really cool picture out there. iPhone 5 has really nice camera, yeah?" date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
//    replyBubble.avatar = nil;
//    
//    bubbleData = [[NSMutableArray alloc] initWithObjects:heyBubble, photoBubble, replyBubble, nil];
    bubbleTable.bubbleDataSource = self;
    
    // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
    // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
    // Groups are delimited with header which contains date and time for the first message in the group.
    
    bubbleTable.snapInterval = 120;
    
    // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
    // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
    
    bubbleTable.showAvatars = NO;
    
    // Uncomment the line below to add "Now typing" bubble
    // Possible values are
    //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
    //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
    //    - NSBubbleTypingTypeNone - no "now typing" bubble
    
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    [bubbleTable reloadData];
    [self queryChatLogs];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

- (void)queryChatLogs {
    if (!self.withId) {
        return;
    }
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.withId, @"with", nil];
    
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiMessageCenter:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         if ([rData length] > 0 && error == nil){
             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
             NSInteger c = [[resp objectForKey:@"c"] intValue];
             if (c == 200) {
                 NSArray *d = [resp objectForKey:@"d"];
                 [self.dataSource addObjectsFromArray:d];
                 bubbleData = [NSMutableArray array];
                 Log(@"%@", self.dataSource);

                 NSString *my_id = [[MIStorage sharedManager] currentUserId];

                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSString *avatar;

                     for (NSDictionary *cellData in self.dataSource) {
                         NSString *fid = [cellData objectForKey:@"from_id"];
                         NSString *tid = [cellData objectForKey:@"to_id"];
                         NSBubbleType tp = BubbleTypeSomeoneElse;
                         
                         if ([my_id isEqualToString:fid]) {
                             tp = BubbleTypeMine;
                             avatar = [[cellData objectForKey:@"to"] objectForKey:@"avatar"];
                         }else if ([my_id isEqualToString:tid]){
                             avatar = [[cellData objectForKey:@"from"] objectForKey:@"avatar"];
                         }else{
                             avatar = @"/default.jpg";
                         }
                         
                         NSString *content = [cellData objectForKey:@"content"];
                         NSBubbleData *bubble = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:-300] type:tp];
                         avatar = @"http://www.google.com/images/google_favicon_128.png";
                         if (avatar.length > 0) {
                             bubble.avatar = [UIImage imageNamed:@"avatar1.png"];
                         }else{
                             bubble.avatar = [UIImage imageNamed:@"avatar1.png"];
                         }
                         [bubbleData addObject:bubble];
                     }
                     
                     [bubbleTable reloadData];
                     NSIndexPath* ipath = [NSIndexPath indexPathForRow: bubbleData.count - 1 inSection: 0];
                     [bubbleTable scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated:YES];
                 });
                 
                 @try {
                 }
                 @catch (NSException *exception) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误"
                                                                     message:@"服务器返回数据错误"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil, nil];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [alert show];
                     });
                 }
                 @finally {
                     
                 }
             }else {
                 NSString *msg;
                 if ([resp objectForKey:@"d"]) {
                     if ([[resp objectForKey:@"d"] isKindOfClass:[NSString class]]) {
                         msg = [resp objectForKey:@"d"];
                     }else if ([[resp objectForKey:@"d"] isKindOfClass:[NSDictionary class]]) {
                         msg = [[resp objectForKey:@"d"] objectForKey:@"message"];
                     }
                 }else if ([resp objectForKey:@"error"]) {
                     msg = [resp objectForKey:@"error"];
                 }else if ([resp objectForKey:@"message"]) {
                     msg = [resp objectForKey:@"message"];
                 }else{
                     msg = @"服务器未返回可读的错误信息";
                 }
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误"
                                                                 message:msg
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [alert show];
                 });
             }
         }
     } withErrorHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self performSelectorOnMainThread:@selector(stopAction) withObject:nil waitUntilDone:[NSThread isMainThread]];
         });
     }];
}









- (void)loadInputView {	
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, 320, 40)];
    
	textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 6;
	textView.returnKeyType = UIReturnKeyDefault;
	textView.font = [UIFont systemFontOfSize:15.0f];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    
    // textView.text = @"test\n\ntest";
	// textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:containerView];
	
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [containerView addSubview:imageView];
    [containerView addSubview:textView];
    [containerView addSubview:entryImageView];
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	doneBtn.frame = CGRectMake(containerView.frame.size.width - 69, 8, 63, 27);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[doneBtn setTitle:@"发送" forState:UIControlStateNormal];
    
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[containerView addSubview:doneBtn];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

-(void)resignTextView
{
	[textView resignFirstResponder];
    if (textView.text.length > 0) {
        [self sendMessage:textView.text];
    }
}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    CGRect bubbleFrame = bubbleTable.frame;
    bubbleFrame.size.height = containerFrame.origin.y;

	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	containerView.frame = containerFrame;
	bubbleTable.frame = bubbleFrame;
	
	// commit animations
	[UIView commitAnimations];
    [bubbleTable reloadData];
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: bubbleData.count - 1 inSection: 0];
    [bubbleTable scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated:YES];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    CGRect bubbleFrame = bubbleTable.frame;
    bubbleFrame.size.height = containerFrame.origin.y;

	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	containerView.frame = containerFrame;
    bubbleTable.frame = bubbleFrame;

	// commit animations
	[UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerView.frame = r;
    
    CGRect bubbleFrame = bubbleTable.frame;
    bubbleFrame.size.height += diff;
//    bubbleFrame.origin.y += diff;
	bubbleTable.frame = bubbleFrame;
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: bubbleData.count - 1 inSection: 0];
    [bubbleTable scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated:YES];
}

- (void) sendMessage:(NSString *)txt{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:txt?txt:@"", @"msg", self.withId, @"to", nil];
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiSendMessage:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         if ([rData length] > 0 && error == nil){
             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
             NSInteger c = [[resp objectForKey:@"c"] intValue];
             if (c == 200) {
                 NSString *d = [resp objectForKey:@"d"];
                 Log(@"%@", d);
                 MBProgressHUD *alert = [[MBProgressHUD alloc] initWithView:self.view];
                 alert.customView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"Icon"]];
                 alert.mode = MBProgressHUDModeCustomView;
                 alert.labelText = @"发送成功";
                 
                 dispatch_async(dispatch_get_main_queue(), ^{                     
                     [self.view addSubview:alert];
                     [alert show:YES];
                     [alert hide:YES afterDelay:2.0];
                     
                     NSString *content = textView.text;
                     NSBubbleData *bubble = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeMine];
                     NSString *avatar = @"http://www.google.com/images/google_favicon_128.png";
                     if (avatar.length > 0) {
                         bubble.avatar = [UIImage imageNamed:@"avatar1.png"];
                     }else{
                         bubble.avatar = [UIImage imageNamed:@"avatar1.png"];
                     }
                     [bubbleData addObject:bubble];
                     [bubbleTable reloadData];
                     NSIndexPath* ipath = [NSIndexPath indexPathForRow: bubbleData.count - 1 inSection: 0];
                     [bubbleTable scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated:YES];
                     textView.text = nil;
                 });
                 @try {
                 }
                 @catch (NSException *exception) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误"
                                                                     message:@"服务器返回数据错误"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil, nil];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [alert show];
                     });
                 }
                 @finally {
                     
                 }
             }else {
                 NSString *msg;
                 if ([resp objectForKey:@"d"]) {
                     if ([[resp objectForKey:@"d"] isKindOfClass:[NSString class]]) {
                         msg = [resp objectForKey:@"d"];
                     }else if ([[resp objectForKey:@"d"] isKindOfClass:[NSDictionary class]]) {
                         msg = [[resp objectForKey:@"d"] objectForKey:@"message"];
                     }
                 }else if ([resp objectForKey:@"error"]) {
                     msg = [resp objectForKey:@"error"];
                 }else if ([resp objectForKey:@"message"]) {
                     msg = [resp objectForKey:@"message"];
                 }else{
                     msg = @"服务器未返回可读的错误信息";
                 }
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误"
                                                                 message:msg
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [alert show];
                 });
             }
         }
     } withErrorHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             MBProgressHUD *alert = [[MBProgressHUD alloc] initWithView:self.view];
             alert.customView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"Icon"]];
             alert.mode = MBProgressHUDModeCustomView;
             alert.labelText = @"发送失败";
             
             dispatch_async(dispatch_get_main_queue(), ^{                 
                 [self.view addSubview:alert];
                 [alert show:YES];
                 [alert hide:YES afterDelay:2.0];
             });
         });
     }];
}

@end
