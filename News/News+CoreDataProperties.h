//
//  News+CoreDataProperties.h
//  News
//
//  Created by Игорь Талов on 01.07.16.
//  Copyright © 2016 Игорь Талов. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "News.h"

NS_ASSUME_NONNULL_BEGIN

@interface News (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *newsdescription;
@property (nullable, nonatomic, retain) NSString *newstitle;
@property (nullable, nonatomic, retain) NSString *url;

@end

NS_ASSUME_NONNULL_END
