//
//  Person+Import.m
//  PersonJSONMigration
//
//  Created by Alex Tataurov on 09/02/14.
//  Copyright (c) 2014 Alex Tataurov. All rights reserved.
//

#import "Person+Import.h"
#import "PhoneNumber.h"
#import "Email.h"

@implementation Person (Import)

+ (void)importFromJSON:(NSDictionary *)data intoContext:(NSManagedObjectContext *)context
{
    NSString *entityName = NSStringFromClass(self);
    Person *person = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    
    if ([data objectForKey:@"name"]) {
        person.name = [data objectForKey:@"name"];
    }
    
    if ([data objectForKey:@"company"]) {
        person.company = [data objectForKey:@"company"];
    }
    
    if ([data objectForKey:@"age"]) {
        person.age = [data objectForKey:@"age"];
    }
    
    if ([data objectForKey:@"isActive"]) {
        person.active = [data objectForKey:@"isActive"];
    }
    
    if ([data objectForKey:@"registered"]) {
        NSString *registeredString = [data objectForKey:@"registered"];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        person.registered = [dateFormat dateFromString:registeredString];
    }
    
    if ([data objectForKey:@"phoneNumbers"]) {
        NSArray *phoneNumbers = [data objectForKey:@"phoneNumbers"];
        for (NSDictionary *phoneNumberData in phoneNumbers) {
            if ([phoneNumberData objectForKey:@"number"]) {
                PhoneNumber *phoneNumber = [NSEntityDescription insertNewObjectForEntityForName:@"PhoneNumber" inManagedObjectContext:context];
                phoneNumber.number = [phoneNumberData objectForKey:@"number"];
                
                if ([phoneNumberData objectForKey:@"type"]) {
                    NSString *type = [phoneNumberData objectForKey:@"type"];
                    phoneNumber.type = @([type isEqualToString:@"home"] ? 0 : 1);
                }
                [person addPhoneNumbersObject:phoneNumber];
            }
        }
    }
    
    if ([data objectForKey:@"emailAddresses"]) {
        NSArray *emails = [data objectForKey:@"emailAddresses"];
        for (NSDictionary *emailData in emails) {
            if ([emailData objectForKey:@"emailAddress"]) {
                Email *email = [NSEntityDescription insertNewObjectForEntityForName:@"Email" inManagedObjectContext:context];
                email.email = [emailData objectForKey:@"emailAddress"];
                
                if ([emailData objectForKey:@"type"]) {
                    NSString *type = [emailData objectForKey:@"type"];
                    email.type = @([type isEqualToString:@"business"] ? 0 : 1);
                }
                [person addEmailsObject:email];
            }
        }
    }
}

@end