//
//  EditPhoneNumberViewController.m
//  PersonJSONMigration
//
//  Created by Alex Tataurov on 17/02/14.
//  Copyright (c) 2014 Alex Tataurov. All rights reserved.
//

#import "EditPhoneNumberViewController.h"
#import "PhoneNumber.h"
#import "UIColor+MoreColors.h"

static const NSUInteger kPhoneNumberInfoSection = 0;
static const NSUInteger kPhoneRow = 0;
static const NSUInteger kPhoneTypeRow = 1;

static const NSUInteger kPhoneNumberDeleteSection = 1;

@interface EditPhoneNumberViewController ()

@property (nonatomic) BOOL isNew;

@property (nonatomic, strong) UITextField *numberTextField;
@property (nonatomic, strong) UISegmentedControl *typeSegementedControl;

@end

@implementation EditPhoneNumberViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isNew = (self.phoneNumber.number == nil || self.phoneNumber.number.length == 0);
    self.title = self.isNew ? NSLocalizedString(@"Add Phone Number", @"Add Phone Number") : NSLocalizedString(@"Edit Phone Number", @"Edit Phone Number");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event handlers

- (IBAction)saveButtonPressed:(id)sender
{
    if (![self isValidNumber:self.numberTextField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message:NSLocalizedString(@"Invalid Phone Number", @"Invalid Phone Number")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.delegate && self.phoneNumber) {
        self.phoneNumber.number = self.numberTextField.text;
        self.phoneNumber.type = @(self.typeSegementedControl.selectedSegmentIndex);
        [self.delegate finishedEditingPhoneNumber:self.phoneNumber];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Validation

- (BOOL)isValidNumber:(NSString *)theNumber
{
    if (theNumber == nil || theNumber.length == 0) {
        return NO;
    }
    
    NSString *trimmedNumber = [theNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedNumber.length == 0) {
        return NO;
    }
    
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:&error];
    NSArray *matches = [detector matchesInString:trimmedNumber options:0 range:NSMakeRange(0, trimmedNumber.length)];
    if (matches != nil) {
        for (NSTextCheckingResult *match in matches) {
            if ([match resultType] == NSTextCheckingTypePhoneNumber) {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kPhoneNumberInfoSection) {
        return 2;
    }
    else {
        return (self.isNew ? 0 : 1);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == kPhoneNumberInfoSection) {
        if (indexPath.row == kPhoneRow) {
            cell.textLabel.text = NSLocalizedString(@"Phone", @"Phone");
            
            if (self.numberTextField == nil) {
                self.numberTextField = [[UITextField alloc] initWithFrame:CGRectMake(120.0, 7.0, 180.0, 30.0)];
                self.numberTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                self.numberTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                self.numberTextField.textColor = [UIColor blueTextColor];
                self.numberTextField.text = self.phoneNumber.number;
                [cell addSubview:self.numberTextField];
            }
        }
        
        if (indexPath.row == kPhoneTypeRow) {
            cell.textLabel.text = NSLocalizedString(@"Type", @"Type");
            
            if (self.typeSegementedControl == nil) {
                self.typeSegementedControl = [[UISegmentedControl alloc] initWithItems:@[@"Home", @"Work"]];
                self.typeSegementedControl.frame = CGRectMake(120.0, 7.0, 180.0, 30.0);
                self.typeSegementedControl.selectedSegmentIndex = [self.phoneNumber.type integerValue];
                [cell addSubview:self.typeSegementedControl];
            }
        }
    }
    
    if (indexPath.section == kPhoneNumberDeleteSection) {
        cell.textLabel.text = NSLocalizedString(@"Delete", @"Delete");
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kPhoneNumberDeleteSection) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirmation", @"Confirmation")
                                                        message:NSLocalizedString(@"Are you sure to delete this Phone Number?", @"Are you sure to delete this Phone Number?")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                              otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];
        [alert show];
    }
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) { // "Yes"
        if (self.delegate && self.phoneNumber) {
            [self.delegate deletePhoneNumber:self.phoneNumber];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end