//
//  EditEmailViewController.m
//  PersonJSONMigration
//
//  Created by Alex Tataurov on 22/02/14.
//  Copyright (c) 2014 Alex Tataurov. All rights reserved.
//

#import "EditEmailViewController.h"
#import "Email.h"
#import "UIColor+MoreColors.h"

static const NSUInteger kEmailInfoSection = 0;
static const NSUInteger kEmailRow = 0;
static const NSUInteger kEmailTypeRow = 1;

static const NSUInteger kEmailDeleteSection = 1;

@interface EditEmailViewController ()

@property (nonatomic) BOOL isNew;

@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UISegmentedControl *typeSegementedControl;

@end

@implementation EditEmailViewController

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

    self.isNew = (self.email.email == nil || self.email.email.length == 0);
    self.title = self.isNew ? NSLocalizedString(@"Add Email", @"Add Email") : NSLocalizedString(@"Edit Email", @"Edit Email");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event handlers

- (IBAction)saveButtonPressed:(id)sender
{
    if (![self isValidEmail:self.emailTextField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message:NSLocalizedString(@"Invalid Email", @"Invalid Email")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.delegate && self.email) {
        self.email.email = self.emailTextField.text;
        self.email.type = @(self.typeSegementedControl.selectedSegmentIndex);
        [self.delegate finishedEditingEmail:self.email];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Validation

- (BOOL)isValidEmail:(NSString *)theEmail
{
    if (theEmail == nil || theEmail.length == 0) {
        return NO;
    }
    
    NSString *trimmedEmail = [theEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedEmail.length == 0) {
        return NO;
    }
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:trimmedEmail];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kEmailInfoSection) {
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
    
    if (indexPath.section == kEmailInfoSection) {
        if (indexPath.row == kEmailRow) {
            cell.textLabel.text = NSLocalizedString(@"Email", @"Email");
            
            if (self.emailTextField == nil) {
                self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(120.0, 7.0, 180.0, 30.0)];
                self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                self.emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                self.emailTextField.textColor = [UIColor blueTextColor];
                self.emailTextField.text = self.email.email;
                [cell addSubview:self.emailTextField];
            }
        }
        
        if (indexPath.row == kEmailTypeRow) {
            cell.textLabel.text = NSLocalizedString(@"Type", @"Type");;
            
            if (self.typeSegementedControl == nil) {
                self.typeSegementedControl = [[UISegmentedControl alloc] initWithItems:@[@"Business", @"Personal"]];
                self.typeSegementedControl.frame = CGRectMake(120.0, 7.0, 180.0, 30.0);
                self.typeSegementedControl.selectedSegmentIndex = [self.email.type integerValue];
                [cell addSubview:self.typeSegementedControl];
            }
        }
    }
    
    if (indexPath.section == kEmailDeleteSection) {
        cell.textLabel.text = NSLocalizedString(@"Delete", @"Delete");
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kEmailDeleteSection) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirmation", @"Confirmation")
                                                        message:NSLocalizedString(@"Are you sure to delete this Email?", @"Are you sure to delete this Email?")
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
        if (self.delegate && self.email) {
            [self.delegate deleteEmail:self.email];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end