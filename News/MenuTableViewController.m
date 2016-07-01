//
//  MenuTableViewController.m
//  News
//
//  Created by Игорь Талов on 29.06.16.
//  Copyright © 2016 Игорь Талов. All rights reserved.
//

#import "MenuTableViewController.h"
#import "NewsCell.h"
#import "DetailViewController.h"
#import "DataManager.h"
#import "News.h"
#import "AppDelegate.h"

@interface MenuTableViewController () <NSXMLParserDelegate, UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) NSMutableArray* array;
@property(strong, nonatomic) NSURL* rssURL;
@property(strong, nonatomic) NSXMLParser* parser;
@property(strong, nonatomic) NSMutableDictionary* item;
@property(strong, nonatomic) NSMutableString* newsTitle;
@property(strong, nonatomic) NSMutableString* newsDescription;
@property(strong, nonatomic) NSMutableString* newsLink;
@property(strong, nonatomic) NSString* element;

@end

@implementation MenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Новости";
    
    self.splitViewController.delegate = self;

    if ([self isConnected]) {
        
        [[DataManager sharedManager]reloadDataBase];
        
        UIRefreshControl* refresh = [[UIRefreshControl alloc]init];
        [refresh addTarget:self action:@selector(refreshNews) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refresh;
    }

}
- (NSManagedObjectContext*) managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [[DataManager sharedManager] managedObjectContext];
    }
    return _managedObjectContext;
}

- (void)dealloc {

}

-(BOOL) isConnected
{
    NSURL* scriptUrl = [NSURL URLWithString:@"http://www.google.com/m"];
    NSData* data = [NSData dataWithContentsOfURL:scriptUrl];
    if (data)
        return YES;
    else
        return NO;
}

-(void)refreshNews {

    if ([self isConnected]) {
        [[DataManager sharedManager]reloadDataBase];
        [self.refreshControl endRefreshing];
    } else {
        [self.refreshControl endRefreshing];
    }
}

-(NSString* )createHTMLString:(NSString* )string withURL:(NSString* )url{
    
    NSString* HTMLString = nil;
    
    if ([string isEqualToString:@""]) {
        NSString* description = @"Мы не нашли описание данной новости";
        HTMLString = [NSString stringWithFormat:@"<html>"
                                "<body>"
                                "<p style=\"font-size: 100%%; text-align: left;\">%@</p>"
                                "<a href=\%@><b>Перейти на сайт</b></a>"
                                "</body>"
                                "</html>",description,url];
    } else {
    
        HTMLString = [NSString stringWithFormat:@"<html>"
                            "<body>"
                            "<p style=\"font-size: 100%%; text-align: left;\">%@</p>"
                            "<a href=\%@><b>Перейти на сайт</b></a>"
                            "</body>"
                            "</html>",string,url];
    }
    
    return HTMLString;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //return [self.array count];
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    
    NSLog(@"%d", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* identifier = @"Cell";
    
    NewsCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[NewsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(NewsCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    News* news = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.label.text = news.newstitle;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.f;
}

#pragma mark - Segue

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showWeb"]) {
        
        UINavigationController* nc = [segue destinationViewController];
        DetailViewController* vc = (DetailViewController* )[nc topViewController];
        NSIndexPath* index = [self.tableView indexPathForSelectedRow];
        
        News* news = [self.fetchedResultsController objectAtIndexPath:index];
        
        NSString* titleString = news.newstitle;

        NSString* htmlString = [self createHTMLString:news.newsdescription withURL:news.url];

        NSLog(@"%@", htmlString);
        vc.navigationItem.title = titleString;
        vc.htmlString = htmlString;
    }
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    return YES;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"News"
                inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:description];
    
    NSSortDescriptor* nameDescription =
    [[NSSortDescriptor alloc] initWithKey:@"newstitle" ascending:NO];
    
    [fetchRequest setSortDescriptors:@[nameDescription]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
