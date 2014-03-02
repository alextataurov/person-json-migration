//
//  Address.h
//  PersonJSONMigration
//
//  Created by Alex Tataurov on 08/02/14.
//  Copyright (c) 2014 Alex Tataurov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface Address : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * zipcode;
@property (nonatomic, retain) Person *person;

@end
