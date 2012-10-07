//
//  RefreshViewController.m
//  milan
//
//  Created by Wu Chang on 11-9-15.
//  Copyright 2011年 Unique. All rights reserved.
//

#import "RefreshViewController.h"
#define REFRESH_HEADER_HEIGHT 51.0f
#define REFRESH_FOOTER_HEIGHT 51.0f
//#define FOOTER_HEIGHT 49.0f
#define FOOTER_HEIGHT 0
#define HEADER_HEIGHT 20.0f

@implementation RefreshViewController
@synthesize _scrollView, textPull, textRelease, textLoading, textPullFooter, textReleaseFooter, textLoadingFooter, refreshHeaderView, refreshFooterView, refreshLabel, refreshArrow, refreshSpinner, refreshFooterLabel, refreshFooterArrow, refreshFooterSpinner, showHeader, showFooter, pageUp, pageDown;

#pragma mark - View lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.showHeader = NO;
        self.showFooter = YES;
        self.pageUp = 0;
        self.pageDown = 0;
//        [self initRefreshView];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.showHeader = NO;
        self.showFooter = YES;
        self.pageUp = 0;
        self.pageDown = 0;
        [self initRefreshView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)initRefreshView {
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 480 - HEADER_HEIGHT);
    CGRect scrollFrame = CGRectMake(0,  0,  _scrollView.frame.size.width,  480 - FOOTER_HEIGHT - HEADER_HEIGHT);
    _scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    _scrollView.directionalLockEnabled = YES;
    _scrollView.scrollEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.showsHorizontalScrollIndicator = YES;
    _scrollView.contentMode = UIViewContentModeScaleToFill;
    _scrollView.userInteractionEnabled = YES;
    _scrollView.autoresizesSubviews = YES;
    _scrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    //_scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //_scrollView.backgroundColor = [UIColor underPageBackgroundColor];
    //_scrollView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    [_scrollView setDelegate:self];
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, scrollFrame.size.height + FOOTER_HEIGHT)];
    [self setupStrings];
    if (showHeader) {
        [self addPullToRefreshHeader];
    }
    if (showFooter) {
        [self addPullToRefreshFooter];
    }
    [self.view addSubview:_scrollView];
    [self.view sendSubviewToBack:_scrollView];
}

- (void)initRefreshView:(UIScrollView *)baseScrollView {
    _scrollView = baseScrollView;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.scrollEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.showsHorizontalScrollIndicator = YES;
    _scrollView.contentMode = UIViewContentModeScaleToFill;
    _scrollView.userInteractionEnabled = YES;
    _scrollView.autoresizesSubviews = YES;
    [_scrollView setDelegate:self];
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height + FOOTER_HEIGHT)];
    [self setupStrings];
    if (showHeader) {
        [self addPullToRefreshHeader];
    }
    if (showFooter) {
        [self addPullToRefreshFooter];
    }
    [self.view addSubview:_scrollView];
    [self.view sendSubviewToBack:_scrollView];
}


- (void)setupStrings{
    textPull =@"Pull down to update...";
    textRelease = @"Release to update...";
    textLoading = @"Updating...";
    textPullFooter = @"Pull up to load more...";
    textReleaseFooter = @"Release to load more...";
    textLoadingFooter = @"Loading...";
}

- (void)relocateFooter{
    if (self._scrollView.contentSize.height > self._scrollView.frame.size.height) {
        self.refreshFooterView.frame = CGRectMake(self.refreshFooterView.frame.origin.x, self._scrollView.contentSize.height,  self.refreshFooterView.frame.size.width, REFRESH_HEADER_HEIGHT);
    }else {
        self.refreshFooterView.frame = CGRectMake(self.refreshFooterView.frame.origin.x, self._scrollView.frame.size.height,  self.refreshFooterView.frame.size.width, REFRESH_HEADER_HEIGHT);
    }
}

- (void)addPullToRefreshHeader {
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT,  self._scrollView.frame.size.width, REFRESH_HEADER_HEIGHT)];
//    refreshHeaderView.backgroundColor = [UIColor underPageBackgroundColor];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = UITextAlignmentCenter;
    
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refreshArrowDown"]];
    refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                    (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                    27, 44);
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];

    [self._scrollView addSubview:refreshHeaderView];
}

- (void)addPullToRefreshFooter {
    refreshFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 52 + self._scrollView.contentSize.height,  self._scrollView.frame.size.width, REFRESH_HEADER_HEIGHT)];
    //    refreshFooterView.backgroundColor = [UIColor underPageBackgroundColor];
    refreshFooterView.autoresizesSubviews = YES;
    refreshFooterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,  self._scrollView.frame.size.width, REFRESH_HEADER_HEIGHT)];
    refreshFooterLabel.backgroundColor = [UIColor clearColor];
    refreshFooterLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshFooterLabel.textAlignment = UITextAlignmentCenter;
    refreshFooterArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refreshArrowUp"]];
    refreshFooterArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                          (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                          27, 44);
    refreshFooterSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshFooterSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshFooterSpinner.hidesWhenStopped = YES;
    
    [refreshFooterView addSubview:refreshFooterLabel];
    [refreshFooterView addSubview:refreshFooterArrow];
    [refreshFooterView addSubview:refreshFooterSpinner];
    
    [self._scrollView addSubview:refreshFooterView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger bottomOffset = scrollView.contentOffset.y + scrollView.frame.size.height;
//    NSLog(@"%i, %f",bottomOffset, scrollView.contentSize.height);
    if (showHeader && isUpdating && bottomOffset < scrollView.contentSize.height) {
        if (scrollView.contentOffset.y >0)
            self._scrollView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self._scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, self._scrollView.contentInset.bottom, 0);
    } else if (showFooter && isLoading && bottomOffset > scrollView.contentSize.height){
        if (bottomOffset < scrollView.contentSize.height){
            self._scrollView.contentInset = UIEdgeInsetsZero;
        }else if (bottomOffset <= scrollView.contentSize.height + REFRESH_HEADER_HEIGHT){
            float inset = bottomOffset - scrollView.contentSize.height;
            //NSLog(@"%f",inset);
            self._scrollView.contentInset = UIEdgeInsetsMake(0, 0, inset, 0);
        }
    } else if (isDragging) {
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if (showHeader && scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
            // User is scrolling above the header
            refreshLabel.text = self.textRelease;
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else if (showFooter && bottomOffset > scrollView.contentSize.height + REFRESH_HEADER_HEIGHT) {
            //NSLog(@"%i,%f",bottomOffset, scrollView.contentSize.height + REFRESH_HEADER_HEIGHT);
            // User is scrolling below the footer
            refreshFooterLabel.text = self.textReleaseFooter;
            [refreshFooterArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        }
        else { // User is scrolling somewhere between the two headers
            refreshLabel.text = self.textPull;
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            refreshFooterLabel.text = self.textPullFooter;
            [refreshFooterArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
        [UIView commitAnimations];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (showHeader && scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startHeaderAction];
    }else if (showFooter && scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height + REFRESH_HEADER_HEIGHT) {
        // Released below the footer
        [self startFooterAction];
    }
}

- (void)startHeaderAction {
    isUpdating = YES;
    
    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self._scrollView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, self._scrollView.contentInset.bottom, 0);
    refreshLabel.text = self.textLoading;
    refreshArrow.hidden = YES;
    [refreshSpinner startAnimating];
    [UIView commitAnimations];
    
    // Refresh action!
    [self refreshHeaderTriggered];
}

- (void)startFooterAction {
    isLoading = YES;
    
    // Show the footer
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self._scrollView.contentInset = UIEdgeInsetsMake(self._scrollView.contentInset.top, 0, REFRESH_HEADER_HEIGHT, 0);
    refreshFooterLabel.text = self.textLoadingFooter;
    refreshFooterArrow.hidden = YES;
    [refreshFooterSpinner startAnimating];
    [UIView commitAnimations];
    
    // Refresh action!
    [self refreshFooterTriggered];
}

- (void)stopAction {
    if (isUpdating) {
        [self stopHeaderAction];
    }
    if (isLoading) {
        [self stopFooterAction];
    }
}

- (void)stopHeaderAction {
    isUpdating = NO;
    self.pageUp += 1;
    [self relocateFooter];
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopUpdatingComplete:finished:context:)];
    self._scrollView.contentInset = UIEdgeInsetsZero;
    [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    [UIView commitAnimations];
}

- (void)stopFooterAction {
    isLoading = NO;
    self.pageDown += 1;
    // Hide the Footer
    [self relocateFooter];
//    self.refreshFooterView.frame = CGRectMake(0, self._scrollView.contentSize.height,  self._scrollView.frame.size.width, REFRESH_HEADER_HEIGHT);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    self._scrollView.contentInset = UIEdgeInsetsZero;
    [refreshFooterArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    [UIView commitAnimations];
}

- (void)stopUpdatingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    refreshLabel.text = self.textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the footer
    refreshFooterLabel.text = self.textPullFooter;
    refreshFooterArrow.hidden = NO;
    [refreshFooterSpinner stopAnimating];
}

- (void) refreshHeaderTriggered {
    [self performSelector:@selector(stopHeaderAction) withObject:nil afterDelay:1.0];
}
- (void)refreshFooterTriggered {
    [self performSelector:@selector(stopFooterAction) withObject:nil afterDelay:1.0];
}


@end
