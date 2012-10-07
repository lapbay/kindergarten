//
//  RefreshViewController.h
//  milan
//
//  Created by Wu Chang on 11-9-15.
//  Copyright 2011年 Unique. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface RefreshViewController : UIViewController <UIScrollViewDelegate>{
    UIScrollView *_scrollView;
    UIView *refreshHeaderView;
    UIView *refreshFooterView;
    UILabel *refreshLabel;
    UIImageView *refreshArrow;
    UIActivityIndicatorView *refreshSpinner;
    UILabel *refreshFooterLabel;
    UIImageView *refreshFooterArrow;
    UIActivityIndicatorView *refreshFooterSpinner;
    BOOL isDragging;
    BOOL isLoading;
    BOOL isUpdating;
    NSString *textPull;
    NSString *textRelease;
    NSString *textLoading;
    NSString *textPullFooter;
    NSString *textReleaseFooter;
    NSString *textLoadingFooter;
}

@property (nonatomic, retain) UIScrollView *_scrollView;
@property (nonatomic, retain) UIView *refreshHeaderView;
@property (nonatomic, retain) UIView *refreshFooterView;
@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, retain) UIImageView *refreshArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, retain) UILabel *refreshFooterLabel;
@property (nonatomic, retain) UIImageView *refreshFooterArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshFooterSpinner;
@property (nonatomic, retain) NSString *textPull;
@property (nonatomic, retain) NSString *textRelease;
@property (nonatomic, retain) NSString *textLoading;
@property (nonatomic, retain) NSString *textPullFooter;
@property (nonatomic, retain) NSString *textReleaseFooter;
@property (nonatomic, retain) NSString *textLoadingFooter;
@property (nonatomic, assign) BOOL showHeader;
@property (nonatomic, assign) BOOL showFooter;
@property (nonatomic, assign) NSInteger pageUp;
@property (nonatomic, assign) NSInteger pageDown;

- (void)initRefreshView;
- (void)initRefreshView:(UIScrollView *)baseScrollView;
- (void)setupStrings;
- (void)relocateFooter;
- (void)addPullToRefreshHeader;
- (void)startHeaderAction;
- (void)startFooterAction;
- (void)stopHeaderAction;
- (void)stopFooterAction;
- (void)stopAction;
- (void)refreshHeaderTriggered;
- (void)refreshFooterTriggered;

@end
