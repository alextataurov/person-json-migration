//
//  EditPersonViewController.h
//  PersonJSONMigration
//
//  Created by Alex Tataurov on 08/02/14.
//  Copyright (c) 2014 Alex Tataurov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Person;

@interface EditPersonViewController : UITableViewController

@property (nonatomic, strong) Person *person;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

@end