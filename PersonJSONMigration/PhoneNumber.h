//
//  PhoneNumber.h
//  PersonJSONMigration
//
//  Created by Alex Tataurov on 08/02/14.
//  Copyright (c) 2014 Alex Tataurov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PhoneNumber : NSManagedObject

@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSManagedObject *person;

@end
