//
//  DataManager.h
//  News
//
//  Created by Игорь Талов on 01.07.16.
//  Copyright © 2016 Игорь Талов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void) deleteAllObjects;
- (void) printAllObjects;
- (void) reloadDataBase;
- (void) startParseXML;
- (void) saveContext;
- (NSURL *)applicationDocumentsDirectory;
+(DataManager* )sharedManager;
@end