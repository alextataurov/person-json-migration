//
//  EditPersonViewController.m
//  PersonJSONMigration
//
//  Created by Alex Tataurov on 08/02/14.
//  Copyright (c) 2014 Alex Tataurov. All rights reserved.
//

#import "EditPersonViewController.h"
#import "Store.h"
#import "Person.h"
#import "PhoneNumber.h"
#import "Email.h"
#import "EditPhoneNumberViewController.h"
#import "EditEmailViewController.h"
#import "UIColor+MoreColors.h"
#import <QuartzCore/QuartzCore.h>

static const NSUInteger kBasicInfoSection = 0;
static const NSUInteger  kPhoneNumbersSection = 1;
static const NSUInteger kEmailsSection = 2;

static const NSUInteger kBasicInfoNameRow = 0;
static const NSUInteger kBasicInfoCompanyRow = 1;
static const NSUInteger kBasicInfoAgeRow = 2;
static const NSUInteger kBasicInfoActiveRow = 3;
static const NSUInteger kBasicInfoRegisteredRow = 4;

static const NSUInteger kPhoneNumbersLimit = 2;
static const NSUInteger kEmailsLimit = 2;

@interface EditPersonViewController () <EditPhoneNumberViewControllerDelegate, EditEmailViewControllerDelegate>

@property (nonatomic) BOOL isNew;

@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *companyTextField;
@property (nonatomic, strong) UITextField *ageTextField;
@property (nonatomic, strong) UISwitch *activeSwitch;

@end

@implementation EditPersonViewController {
    UIGestureRecognizer *_tapper;
}

- (void)awakeFromNib
{
    self.isNew = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.person == nil) {
        self.isNew = YES;
        self.title = NSLocalizedString(@"Add Person", @"Add Person");
        self.person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:[Store sharedStore].mainManagedObjectContext];
    }
    else {
        self.title = NSLocalizedString(@"Edit Person", @"Edit Person");
        self.isNew = NO;
    }
    
    _tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    _tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tapper];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event handlers

- (IBAction)cancelButtonPressed:(id)sender
{
    if (self.isNew) {
        [[Store sharedStore].mainManagedObjectContext deleteObject:self.person];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButtonPressed:(id)sender
{
    if ([self isStringEmpty:self.nameTextField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message:NSLocalizedString(@"Please specify name", @"Please specify name")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (![self isStringEmpty:self.ageTextField.text]) {
        if (![self ageIsCorrect:self.ageTextField.text]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                            message:NSLocalizedString(@"Age must be numeric value between 18 and 99", @"Age must be numeric value between 18 and 99")
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    self.person.name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.person.company = [self.companyTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *trimmedAgeString = [self.ageTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.person.age = @([trimmedAgeString integerValue]);
    self.person.active = @(self.activeSwitch.isOn);
    if (self.isNew) {
        self.person.registered = [NSDate date];
    }
    
    // Saving
    [[Store sharedStore] saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleSingleTap:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - Validation

- (BOOL)isStringEmpty:(NSString *)string
{
    if (string == nil || string.length == 0) {
        return YES;
    }
    
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedString.length == 0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)ageIsCorrect:(NSString *)ageString
{
    NSCharacterSet *numericCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *ageStringSuperSet = [NSCharacterSet characterSetWithCharactersInString:ageString];
    
    if (![numericCharacterSet isSupersetOfSet: ageStringSuperSet]) {
        return NO;
    }
    
    NSUInteger age = [ageString integerValue];
    if (age < 18 || age > 99) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kBasicInfoSection) {
        return 5;
    }
    if (section == kPhoneNumbersSection) {
        if (self.person.phoneNumbers.count == 0) {
            return 1;
        }
        return (self.person.phoneNumbers.count + 1);
    }
    if (section == kEmailsSection) {
        if (self.person.emails.count == 0) {
            return 1;
        }
        return (self.person.emails.count + 1);
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == kBasicInfoSection) {
        return NSLocalizedString(@"Basic info", @"Basic info");
    }
    if (section == kPhoneNumbersSection) {
        return NSLocalizedString(@"Phone numbers", @"Phone numbers");
    }
    if (section == kEmailsSection) {
        return NSLocalizedString(@"Emails", @"Emails");
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *PhoneNumberOrEmailCellIdentifier = @"PhoneNumberOrEmailCell";
    
    UITableViewCell *cell;
    if (indexPath.section == kPhoneNumbersSection || indexPath.section == kEmailsSection) {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PhoneNumberOrEmailCellIdentifier];
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:PhoneNumberOrEmailCellIdentifier];
        }
    }
    else {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
    }
    
    if (indexPath.section == kBasicInfoSection && indexPath.row == kBasicInfoNameRow) {
        cell.textLabel.text = NSLocalizedString(@"Name", @"Name");
        
        if (self.nameTextField == nil) {
            self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(120.0, 7.0, 180.0, 30.0)];
            self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            self.nameTextField.textColor = [UIColor blueTextColor];
            self.nameTextField.textAlignment = NSTextAlignmentRight;
            self.nameTextField.text = self.person.name;
            [cell addSubview:self.nameTextField];
        }
    }
    
    if (indexPath.section == kBasicInfoSection && indexPath.row == kBasicInfoCompanyRow) {
        cell.textLabel.text = NSLocalizedString(@"Company", @"Company");
        
        if (self.companyTextField == nil) {
            self.companyTextField = [[UITextField alloc] initWithFrame:CGRectMake(120.0, 7.0, 180.0, 30.0)];
            self.companyTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.companyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            self.companyTextField.textColor = [UIColor blueTextColor];
            self.companyTextField.textAlignment = NSTextAlignmentRight;
            self.companyTextField.text = self.person.company;
            [cell addSubview:self.companyTextField];
        }
    }
    
    if (indexPath.section == kBasicInfoSection && indexPath.row == kBasicInfoAgeRow) {
        cell.textLabel.text = NSLocalizedString(@"Age", @"Age");
        
        if (self.ageTextField == nil) {
            self.ageTextField = [[UITextField alloc] initWithFrame:CGRectMake(200.0, 7.0, 100.0, 30.0)];
            self.ageTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.ageTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            self.ageTextField.textColor = [UIColor blueTextColor];
            self.ageTextField.textAlignment = NSTextAlignmentRight;
            self.ageTextField.keyboardType = UIKeyboardTypeNumberPad;
            self.ageTextField.text = (self.isNew) ? @"" : [NSString stringWithFormat:@"%d", [self.person.age integerValue]];
            [cell addSubview:self.ageTextField];
        }
    }
    
    if (indexPath.section == kBasicInfoSection && indexPath.row == kBasicInfoActiveRow) {
        cell.textLabel.text = NSLocalizedString(@"Active", @"Active");
        
        if (self.activeSwitch == nil) {
            self.activeSwitch = [[UISwitch alloc] init];
            CGSize activeSwitchSize = [self.activeSwitch sizeThatFits:CGSizeZero];
            self.activeSwitch.frame = CGRectMake(cell.contentView.bounds.size.width - activeSwitchSize.width - 10.0,
                                            (cell.contentView.bounds.size.height - activeSwitchSize.height) / 2.0,
                                            activeSwitchSize.width,
                                            activeSwitchSize.height);
            self.activeSwitch.on = [self.person.active boolValue];
            [cell addSubview:self.activeSwitch];
        }
    }
    
    if (indexPath.section == kBasicInfoSection && indexPath.row == kBasicInfoRegisteredRow) {
        cell.textLabel.text = NSLocalizedString(@"Registered", @"Registered");
        
        NSDate *personRegisteredDate = (self.isNew) ? [NSDate date] : self.person.registered;

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterLongStyle;
        
        cell.detailTextLabel.text = [dateFormatter stringFromDate:personRegisteredDate];
    }
    
    if (indexPath.section == kPhoneNumbersSection) {
        if (self.person.phoneNumbers.count == 0 || indexPath.row == self.person.phoneNumbers.count) {
            cell.textLabel.text = NSLocalizedString(@"Add Phone Number", @"Add Phone Number");
            cell.textLabel.textColor = [UIColor blueTextColor];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else {
            PhoneNumber *phoneNumber = [self.person.phoneNumbers allObjects][indexPath.row];
            cell.textLabel.text = phoneNumber.number;
            cell.detailTextLabel.text = ([phoneNumber.type integerValue] == 0) ? @"Home" : @"Work";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    if (indexPath.section == kEmailsSection) {
        if (self.person.emails.count == 0 || indexPath.row == self.person.emails.count) {
            cell.textLabel.text = NSLocalizedString(@"Add Email", @"Add Email");
            cell.textLabel.textColor = [UIColor blueTextColor];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else {
            Email *email = [self.person.emails allObjects][indexPath.row];
            cell.textLabel.text = email.email;
            cell.detailTextLabel.text = ([email.type integerValue] == 0) ? @"Business" : @"Personal";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kPhoneNumbersSection) {
        if (indexPath.row == self.person.phoneNumbers.count && self.person.phoneNumbers.count == kPhoneNumbersLimit) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                            message:[NSString stringWithFormat:@"You can add more than %i phone number(s)", kPhoneNumbersLimit]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        [self performSegueWithIdentifier:@"EditPhoneNumberSegue" sender:indexPath];
    }
    
    if (indexPath.section == kEmailsSection) {
        if (indexPath.row == self.person.emails.count && self.person.emails.count == kEmailsLimit) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                            message:[NSString stringWithFormat:@"You can add more than %i email(s)", kPhoneNumbersLimit]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        [self performSegueWithIdentifier:@"EditEmailSegue" sender:indexPath];
    }
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditPhoneNumberSegue"]) {
        EditPhoneNumberViewController *editPhoneNumberViewController = segue.destinationViewController;
        editPhoneNumberViewController.delegate = self;
        
        NSInteger selectedPhoneNumberIndex = ((NSIndexPath *)sender).row;
        if (self.person.phoneNumbers.count == 0 || self.person.phoneNumbers.count == selectedPhoneNumberIndex) {
            // Selected "Add new Phone Number"
            PhoneNumber *newPhoneNumber = [NSEntityDescription insertNewObjectForEntityForName:@"PhoneNumber"
                                                                        inManagedObjectContext:[Store sharedStore].mainManagedObjectContext];
            editPhoneNumberViewController.phoneNumber = newPhoneNumber;
        }
        else {
            PhoneNumber *selectedPhoneNumber = [self.person.phoneNumbers allObjects][selectedPhoneNumberIndex];
            editPhoneNumberViewController.phoneNumber = selectedPhoneNumber;
        }
    }
    
    if ([segue.identifier isEqualToString:@"EditEmailSegue"]) {
        EditEmailViewController *editEmailViewController = segue.destinationViewController;
        editEmailViewController.delegate = self;
        
        NSInteger selectedEmailIndex = ((NSIndexPath *)sender).row;
        if (self.person.emails.count == 0 || self.person.emails.count == selectedEmailIndex) {
            // Selected "Add new Email"
            Email *newEmail = [NSEntityDescription insertNewObjectForEntityForName:@"Email"
                                                                        inManagedObjectContext:[Store sharedStore].mainManagedObjectContext];
            editEmailViewController.email = newEmail;
        }
        else {
            Email *selectedEmail = [self.person.emails allObjects][selectedEmailIndex];
            editEmailViewController.email = selectedEmail;
        }
    }
}

#pragma mark EditPhoneNumberViewControllerDelegate

- (void)finishedEditingPhoneNumber:(PhoneNumber *)phoneNumber
{
    if (phoneNumber && ![self.person.phoneNumbers containsObject:phoneNumber]) {
        [self.person addPhoneNumbersObject:phoneNumber];
    }
    
    NSIndexSet *phoneNumberSection = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(kPhoneNumbersSection, 1)];
    [self.tableView reloadSections:phoneNumberSection withRowAnimation:UITableViewRowAnimationNone];
}

- (void)deletePhoneNumber:(PhoneNumber *)phoneNumber
{
    if (phoneNumber && [self.person.phoneNumbers containsObject:phoneNumber]) {
        [self.person removePhoneNumbersObject:phoneNumber];
        [[Store sharedStore].mainManagedObjectContext deleteObject:phoneNumber];
        
        NSIndexSet *phoneNumberSection = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(kPhoneNumbersSection, 1)];
        [self.tableView reloadSections:phoneNumberSection withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark EditEmailViewControllerDelegate

- (void)finishedEditingEmail:(Email *)email
{
    if (email && ![self.person.emails containsObject:email]) {
        [self.person addEmailsObject:email];
    }
    
    NSIndexSet *emailSection = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(kEmailsSection, 1)];
    [self.tableView reloadSections:emailSection withRowAnimation:UITableViewRowAnimationNone];
}

- (void)deleteEmail:(Email *)email
{
    if (email && [self.person.emails containsObject:email]) {
        [self.person removeEmailsObject:email];
        [[Store sharedStore].mainManagedObjectContext deleteObject:email];
        
        NSIndexSet *emailSection = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(kEmailsSection, 1)];
        [self.tableView reloadSections:emailSection withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end