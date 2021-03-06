/*
 * Copyright (c) 28/01/2013 Mario Negro (@emenegro)
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <objc/runtime.h>

#import "UIAlertView+Easy.h"
#import "LanguageManager.h"

/*
 * Runtime association key.
 */
void *kHandlerAssociatedKey = @"kHandlerAssociatedKey";

@implementation UIAlertView (Easy)

#pragma mark - Showing

/*
 * Shows the receiver alert with the given handler.
 */
- (void)showWithCompletionHandler:(UIAlertViewHandler)handler {
    
    objc_setAssociatedObject(self, kHandlerAssociatedKey, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setDelegate:self];
    [self show];
}

#pragma mark - UIAlertViewDelegate

/*
 * Sent to the delegate when the user clicks a button on an alert view.
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UIAlertViewHandler completionHandler = objc_getAssociatedObject(self, kHandlerAssociatedKey);
    
    if (completionHandler != nil) {
        
        completionHandler(alertView, buttonIndex);
    }
}

#pragma mark - Utility methods

/*
 * Utility selector to show an alert with a title, a message and a button to dimiss.
 */
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
              handler:(UIAlertViewHandler)handler {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:LocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    
    [alert showWithCompletionHandler:handler];
}

/*
 * Utility selector to show an alert with an "Error" title, a message and a button to dimiss.
 */
+ (void)showErrorWithMessage:(NSString *)message
                     handler:(UIAlertViewHandler)handler {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error", nil)
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:LocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    
    [alert showWithCompletionHandler:handler];
}

/*
 * Utility selector to show an alert with a "Warning" title, a message and a button to dimiss.
 */
+ (void)showWarningWithMessage:(NSString *)message
                       handler:(UIAlertViewHandler)handler {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Warning", nil)
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:LocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    
    [alert showWithCompletionHandler:handler];
}

/*
 * Utility selector to show a confirmation dialog with a title, a message and two buttons to accept or cancel.
 */
+ (void)showConfirmationDialogWithTitle:(NSString *)title
                                message:(NSString *)message
                                handler:(UIAlertViewHandler)handler {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:LocalizedString(@"No", nil)
                                          otherButtonTitles:LocalizedString(@"Yes", nil), nil];
    
    [alert showWithCompletionHandler:handler];
}

@end
