//
//  EditPhoneNumberViewController.h
//  PersonJSONMigration
//
//  Created by Alex Tataurov on 17/02/14.
//  Copyright (c) 2014 Alex Tataurov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhoneNumber;

@protocol EditPhoneNumberViewControllerDelegate

- (void)finishedEditingPhoneNumber:(PhoneNumber *)phoneNumber;
- (void)deletePhoneNumber:(PhoneNumber *)phoneNumber;

@end

@interface EditPhoneNumberViewController : UITableViewController

@property (nonatomic, strong) PhoneNumber *phoneNumber;
@property (nonatomic, weak) id<EditPhoneNumberViewControllerDelegate> delegate;

- (IBAction)saveButtonPressed:(id)sender;

@end