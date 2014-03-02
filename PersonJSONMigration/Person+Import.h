//
//  Person+Import.h
//  PersonJSONMigration
//
//  Created by Alex Tataurov on 09/02/14.
//  Copyright (c) 2014 Alex Tataurov. All rights reserved.
//

#import "Person.h"

@interface Person (Import)

+ (void)importFromJSON:(NSDictionary *)data intoContext:(NSManagedObjectContext *)context;

@end