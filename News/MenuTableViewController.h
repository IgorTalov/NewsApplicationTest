//
//  MenuTableViewController.h
//  News
//
//  Created by Игорь Талов on 29.06.16.
//  Copyright © 2016 Игорь Талов. All rights reserved.


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"

@interface MenuTableViewController : UITableViewController


@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end
