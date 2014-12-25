//
//  UVBaseViewController.m
//  UserVoice
//
//  Created by UserVoice on 10/19/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVBaseViewController.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVSuggestion.h"
#import "UVUser.h"
#import "UVStyleSheet.h"
#import "UVImageCache.h"
#import "UVAccessToken.h"
#import "UVSigninManager.h"
#import "UVKeyboardUtils.h"
#import "UVUtils.h"
#import "UVTruncatingLabel.h"

@implementation UVBaseViewController

- (id)init {
    self = [super init];
    if (self) {
        _signinManager = [UVSigninManager manager];
        _signinManager.delegate = self;
        _templateCells = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dismiss {
    if (_firstController) {
        [[UVImageCache sharedInstance] flush];
        [[UVSession currentSession] clear];
    }
    if (_firstController && [[UserVoice delegate] respondsToSelector:@selector(userVoiceRequestsDismissal)]) {
        [[UserVoice delegate] userVoiceRequestsDismissal];
    } else {
        __weak UVBaseViewController *_weakSelf = self;
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     if (_weakSelf.firstController && [[UserVoice delegate] respondsToSelector:@selector(userVoiceWasDismissed)]) {
                                         [[UserVoice delegate] userVoiceWasDismissed];
                                     }
                                 }];
    }
}

- (CGRect)contentFrame {
    CGRect barFrame = CGRectZero;
    barFrame = self.navigationController.navigationBar.frame;
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    CGFloat yStart = barFrame.origin.y + barFrame.size.height;

    return CGRectMake(0, yStart, appFrame.size.width, appFrame.size.height - barFrame.size.height);
}

- (void)showActivityIndicator {
    if (!_shade) {
        _shade = [[UIView alloc] initWithFrame:self.view.bounds];
        _shade.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _shade.backgroundColor = [UIColor blackColor];
        _shade.alpha = 0.5;
        [self.view addSubview:_shade];
    }
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4);
        _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        [self.view addSubview:_activityIndicatorView];
    }
    _shade.hidden = NO;
    _activityIndicatorView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/([UVKeyboardUtils visible] ? 4 : 2));
    _activityIndicatorView.hidden = NO;
    [_activityIndicatorView startAnimating];
}

- (void)hideActivityIndicator {
    [self enableSubmitButton];
    [_activityIndicatorView stopAnimating];
    _activityIndicatorView.hidden = YES;
    _shade.hidden = YES;
}

- (void)setSubmitButtonEnabled:(BOOL)enabled {
    if (!self.navigationItem) {
        return;
    }

    if (self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem.enabled = enabled;
    }
}

- (void)disableSubmitButton {
    [self setSubmitButtonEnabled:NO];
}

- (void)enableSubmitButton {
    [self enableSubmitButtonForce:NO];
}

- (void)enableSubmitButtonForce:(BOOL)force {
    BOOL shouldEnableButton = [self shouldEnableSubmitButton];

    if (shouldEnableButton || force) {
        [self setSubmitButtonEnabled:YES];
    }
}

- (BOOL)shouldEnableSubmitButton {
    return YES;
}

- (void)alertError:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Error", @"UserVoice", [UserVoice bundle], nil)
                                message:message
                               delegate:nil
                      cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"OK", @"UserVoice", [UserVoice bundle], nil)
                      otherButtonTitles:nil] show];
}

- (void)didReceiveError:(NSError *)error {
    NSString *msg = nil;
    [self hideActivityIndicator];
    if ([UVUtils isConnectionError:error]) {
        msg = NSLocalizedStringFromTableInBundle(@"There appears to be a problem with your network connection, please check your connectivity and try again.", @"UserVoice", [UserVoice bundle], nil);
    } else {
        NSDictionary *userInfo = [error userInfo];
        for (NSString *key in [userInfo allKeys]) {
            if ([key isEqualToString:@"message"] || [key isEqualToString:@"type"])
                continue;
            NSString *displayKey = nil;
            if ([key isEqualToString:@"display_name"])
                displayKey = NSLocalizedStringFromTableInBundle(@"User name", @"UserVoice", [UserVoice bundle], nil);
            else
                displayKey = [[key stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];

            // Suggestion title has custom messages
            if ([key isEqualToString:@"title"])
                msg = [userInfo valueForKey:key];
            else
                msg = [NSString stringWithFormat:@"%@ %@", displayKey, [userInfo valueForKey:key]];
        }
        if (!msg)
            msg = NSLocalizedStringFromTableInBundle(@"Sorry, there was an error in the application.", @"UserVoice", [UserVoice bundle], nil);
    }
    [self alertError:msg];
}

- (void)initNavigationItem {
    self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"Feedback", @"UserVoice", [UserVoice bundle], nil);

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Back", @"UserVoice", [UserVoice bundle], nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    _exitButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", @"UserVoice", [UserVoice bundle], nil)
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(dismiss)];
    if ([UVSession currentSession].isModal && _firstController) {
        self.navigationItem.leftBarButtonItem = _exitButton;
    }
}

- (UIView *)poweredByView {
    UIView *power = [UIView new];
    power.frame = CGRectMake(0, 0, 0, 80);
    UILabel *uv = [UILabel new];
    uv.text = NSLocalizedStringFromTableInBundle(@"Powered by UserVoice", @"UserVoice", [UserVoice bundle], nil);
    uv.font = [UIFont systemFontOfSize:13];
    uv.textColor = [UIColor grayColor];
    uv.backgroundColor = [UIColor clearColor];
    uv.textAlignment = NSTextAlignmentCenter;
    UILabel *version = [UILabel new];
    version.text = [NSString stringWithFormat:@"iOS SDK v%@", [UserVoice version]];
    version.font = [UIFont systemFontOfSize:13];
    version.textColor = [UIColor lightGrayColor];
    version.textAlignment = NSTextAlignmentCenter;
    version.backgroundColor = [UIColor clearColor];
    [self configureView:power
               subviews:NSDictionaryOfVariableBindings(uv, version)
            constraints:@[@"V:|-[uv]-[version]", @"|[uv]|", @"|[version]|"]];
    return power;
}

- (BOOL)needNestedModalHack {
    return [UIDevice currentDevice].systemVersion.floatValue >= 6;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {

    // We are the top modal, make to sure that parent modals use our size
    if (self.needNestedModalHack && self.presentedViewController == nil && self.presentingViewController) {
        for (UIViewController* parent = self.presentingViewController;
             parent.presentingViewController;
             parent = parent.presentingViewController) {
            parent.view.superview.frame = parent.presentedViewController.view.superview.frame;
        }
    }

    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    // We are the top modal, make to sure that parent modals are hidden during transition
    if (self.needNestedModalHack && self.presentedViewController == nil && self.presentingViewController) {
        for (UIViewController* parent = self.presentingViewController;
             parent.presentingViewController;
             parent = parent.presentingViewController) {
            parent.view.superview.hidden = YES;
        }
    }

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // We are the top modal, make to sure that parent modals are shown after animation
    if (self.needNestedModalHack && self.presentedViewController == nil && self.presentingViewController) {
        for (UIViewController* parent = self.presentingViewController;
             parent.presentingViewController;
             parent = parent.presentingViewController) {
            parent.view.superview.hidden = NO;
        }
    }

    if (!IOS7 && _tableView) {
        [_tableView reloadData];
    }

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark ===== helper methods for table views =====

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (UITableViewCell *)createCellForIdentifier:(NSString *)identifier
                                   tableView:(UITableView *)theTableView
                                   indexPath:(NSIndexPath *)indexPath
                                       style:(UITableViewCellStyle)style
                                  selectable:(BOOL)selectable {
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier];
        cell.selectionStyle = selectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;

        SEL initCellSelector = NSSelectorFromString([NSString stringWithFormat:@"initCellFor%@:indexPath:", identifier]);
        if ([self respondsToSelector:initCellSelector]) {
            [self performSelector:initCellSelector withObject:cell withObject:indexPath];
        }
    }

    SEL customizeCellSelector = NSSelectorFromString([NSString stringWithFormat:@"customizeCellFor%@:indexPath:", identifier]);
    if ([self respondsToSelector:customizeCellSelector]) {
        [self performSelector:customizeCellSelector withObject:cell withObject:indexPath];
    }
    if (!IOS7) {
        cell.contentView.frame = CGRectMake(0, 0, [self cellWidthForStyle:_tableView.style accessoryType:cell.accessoryType], 0);
        [cell.contentView setNeedsLayout];
        [cell.contentView layoutIfNeeded];
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                if (label.numberOfLines != 1) {
                    [label setPreferredMaxLayoutWidth:label.frame.size.width];
                }
                [label setBackgroundColor:[UIColor clearColor]];
            } else if ([view isKindOfClass:[UVTruncatingLabel class]]) {
                UVTruncatingLabel *label = (UVTruncatingLabel *)view;
                [label setPreferredMaxLayoutWidth:label.frame.size.width];
            }
        }
    }
    return cell;
}
#pragma clang diagnostic pop

#pragma mark ===== Keyboard Notifications =====

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];

}

- (void)keyboardWillShow:(NSNotification*)notification {
    if (IPAD) {
        NSInteger formSheetHeight = 576;
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            _kbHeight = formSheetHeight - 352;
        } else {
            _kbHeight = formSheetHeight - 504;
        }
    } else {
        NSDictionary* info = [notification userInfo];
        CGRect rect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        // Convert from window space to view space to account for orientation
        _kbHeight = (NSInteger)[self.view convertRect:rect fromView:nil].size.height;
    }
}

- (UIScrollView *)scrollView {
    return _tableView;
}

- (void)keyboardDidShow:(NSNotification*)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake([self scrollView].contentInset.top, 0.0, _kbHeight, 0.0);
    [self scrollView].contentInset = contentInsets;
    [self scrollView].scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)notification {
}

- (void)keyboardDidHide:(NSNotification*)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake([self scrollView].contentInset.top, 0.0, 0.0, 0.0);
    [self scrollView].contentInset = contentInsets;
    [self scrollView].scrollIndicatorInsets = contentInsets;
}

- (void)presentModalViewController:(UIViewController *)viewController {
    UINavigationController *navigationController = [UINavigationController new];
    [UVUtils applyStylesheetToNavigationController:navigationController];
    navigationController.viewControllers = @[viewController];
    if (FORMSHEET)
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)setupGroupedTableView {
    _tableView = [[UITableView alloc] initWithFrame:[self contentFrame] style:UITableViewStyleGrouped];
    _tableView.delegate = (id<UITableViewDelegate>)self;
    _tableView.dataSource = (id<UITableViewDataSource>)self;
    if ([UVStyleSheet instance].tableViewBackgroundColor) {
        if (!IOS7) {
            UIView *bg = [UIView new];
            bg.backgroundColor = [UVStyleSheet instance].tableViewBackgroundColor;
            _tableView.backgroundView = bg;
        }
        _tableView.backgroundColor = [UVStyleSheet instance].tableViewBackgroundColor;
    }
    self.view = _tableView;
}

- (void)setView:(UIView *)view {
    [super setView:view];
    if (IOS7) {
        view.tintColor = [UVStyleSheet instance].tintColor;
    }
}

- (void)requireUserSignedIn:(UVCallback *)callback {
    [_signinManager signInWithCallback:callback];
}

- (void)requireUserAuthenticated:(NSString *)email name:(NSString *)name callback:(UVCallback *)callback {
    [_signinManager signInWithEmail:email name:name callback:callback];
}

- (void)setUserName:(NSString *)theName {
    _userName = theName;

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:_userName forKey:@"uv-user-name"];
    [prefs synchronize];
}

- (NSString *)userName {
    if ([UVSession currentSession].user)
        return [UVSession currentSession].user.name;
    if (_userName)
        return _userName;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _userName = [prefs stringForKey:@"uv-user-name"];
    return _userName;
}

- (void)setUserEmail:(NSString *)theEmail {
    _userEmail = theEmail;

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:_userEmail forKey:@"uv-user-email"];
    [prefs synchronize];
}

- (NSString *)userEmail {
    if ([UVSession currentSession].user)
        return [UVSession currentSession].user.email;
    if (_userEmail)
        return _userEmail;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _userEmail = [prefs stringForKey:@"uv-user-email"];
    return _userEmail;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (CGFloat)heightForDynamicRowWithReuseIdentifier:(NSString *)reuseIdentifier indexPath:(NSIndexPath *)indexPath {
    NSString *cacheKey = [NSString stringWithFormat:@"%@-%d", reuseIdentifier, (int)self.view.frame.size.width];
    UITableViewCell *cell = [_templateCells objectForKey:cacheKey];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:reuseIdentifier];
        SEL initCellSelector = NSSelectorFromString([NSString stringWithFormat:@"initCellFor%@:indexPath:", reuseIdentifier]);
        if ([self respondsToSelector:initCellSelector]) {
            [self performSelector:initCellSelector withObject:cell withObject:nil];
        }
        [_templateCells setObject:cell forKey:cacheKey];
    }
    SEL customizeCellSelector = NSSelectorFromString([NSString stringWithFormat:@"customizeCellFor%@:indexPath:", reuseIdentifier]);
    if ([self respondsToSelector:customizeCellSelector]) {
        [self performSelector:customizeCellSelector withObject:cell withObject:indexPath];
    }
    cell.contentView.frame = CGRectMake(0, 0, [self cellWidthForStyle:_tableView.style accessoryType:cell.accessoryType], 10000);
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];

    // cells are usually flat so I don't bother to iterate recursively
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            if (label.numberOfLines != 1) {
                [label setPreferredMaxLayoutWidth:label.frame.size.width];
            }
        }
    }
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];

    return [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
}
#pragma clang diagnostic pop

- (CGFloat)cellWidthForStyle:(UITableViewStyle)style accessoryType:(UITableViewCellAccessoryType)accessoryType {
    CGFloat width = self.view.frame.size.width;
    CGFloat accessoryWidth = 0;
    CGFloat margin = 0;
    if (IOS7) {
        if (accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
            accessoryWidth = 33;
        } else if (accessoryType == UITableViewCellAccessoryCheckmark) {
            accessoryWidth = 38.5;
        }
    } else {
        if (accessoryType == UITableViewCellAccessoryDisclosureIndicator || accessoryType == UITableViewCellAccessoryCheckmark) {
            accessoryWidth = 20;
        }
        if (width > 20) {
            if (width < 400) {
                margin = 10;
            } else {
                margin = MAX(31, MIN(45, width*0.06f));
            }
        } else {
            margin = width - 10;
        }
    }
    return width - (style == UITableViewStyleGrouped ? margin * 2 : 0) - accessoryWidth;
}

- (void)configureView:(UIView *)superview subviews:(NSDictionary *)viewsDict constraints:(NSArray *)constraintStrings {
    [self configureView:superview subviews:viewsDict constraints:constraintStrings finalCondition:NO finalConstraint:nil];
}

- (void)configureView:(UIView *)superview subviews:(NSDictionary *)viewsDict constraints:(NSArray *)constraintStrings finalCondition:(BOOL)includeFinalConstraint finalConstraint:(NSString *)finalConstraint {
    [UVUtils configureView:superview subviews:viewsDict constraints:constraintStrings finalCondition:includeFinalConstraint finalConstraint:finalConstraint];
}

- (UITextField *)configureView:(UIView *)view label:(NSString *)labelText placeholder:(NSString *)placeholderText {
    UITextField *field = [UITextField new];
    field.placeholder = placeholderText;
    [field setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    UILabel *label = [UILabel new];
    label.text = [NSString stringWithFormat:@"%@:", labelText];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    [label setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self configureView:view
               subviews:NSDictionaryOfVariableBindings(field, label)
            constraints:@[@"|-16-[label]-[field]-|", @"V:|-12-[label]", @"V:|-12-[field]"]];
    return field;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UVStyleSheet instance].preferredStatusBarStyle;
}

#pragma mark - UVSigninManagerDelegate

- (void)signinManagerDidSignIn:(UVUser *)user {
    [self hideActivityIndicator];
}

- (void)signinManagerDidFail {
    [self hideActivityIndicator];
}


#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [self initNavigationItem];
    [self registerForKeyboardNotifications];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
