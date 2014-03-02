//
//  EditAddressViewController.h
//  PersonJSONMigration
//
//  Created by Alex Tataurov on 22/02/14.
//  Copyright (c) 2014 Alex Tataurov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Email;

@protocol EditEmailViewControllerDelegate

- (void)finishedEditingEmail:(Email *)email;
- (void)deleteEmail:(Email *)email;

@end

@interface EditEmailViewController : UITableViewController

@property (nonatomic, strong) Email *email;
@property (nonatomic, weak) id<EditEmailViewControllerDelegate> delegate;

- (IBAction)saveButtonPressed:(id)sender;

@end