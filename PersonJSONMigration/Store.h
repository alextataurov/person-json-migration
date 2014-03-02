//
//  Store.h
//  PersonJSONMigration
//
//  Created by Alex Tataurov on 09/02/14.
//  Copyright (c) 2014 Alex Tataurov. All rights reserved.
//

// Inspired by https://github.com/objcio/issue-2-background-core-data

#import <Foundation/Foundation.h>

@interface Store : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainManagedObjectContext;

+ (Store *)sharedStore;

- (void)saveContext;
- (NSManagedObjectContext *)newPrivateContext;

@end