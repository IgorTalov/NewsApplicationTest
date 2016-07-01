//
//  DataManager.m
//  News
//
//  Created by Игорь Талов on 01.07.16.
//  Copyright © 2016 Игорь Талов. All rights reserved.
//

#import "DataManager.h"
#import "News.h"

@interface DataManager () <NSXMLParserDelegate>

@property(strong, nonatomic) NSMutableArray* array;
@property(strong, nonatomic) NSURL* rssURL;
@property(strong, nonatomic) NSXMLParser* parser;
@property(strong, nonatomic) NSMutableDictionary* item;
@property(strong, nonatomic) NSMutableString* newsTitle;
@property(strong, nonatomic) NSMutableString* newsDescription;
@property(strong, nonatomic) NSMutableString* newsLink;
@property(strong, nonatomic) NSString* element;

@end

@implementation DataManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
+(DataManager* )sharedManager {
    
    static DataManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataManager alloc]init];
    });
    
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.rssURL = [NSURL URLWithString:@"http://static.feed.rbc.ru/rbc/internal/rss.rbc.ru/rbc.ru/mainnews.rss"];

    }
    return self;
}

#pragma mark - XMLParse

- (void) startParseXML {
    
    self.array = [NSMutableArray array];
    self.parser = [[NSXMLParser alloc]initWithContentsOfURL:self.rssURL];
    self.parser.delegate = self;
    [self.parser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    self.element = elementName;
    
    if ([self.element isEqualToString:@"item"]) {
        self.item    = [[NSMutableDictionary alloc] init];
        self.newsTitle   = [[NSMutableString alloc] init];
        self.newsLink    = [[NSMutableString alloc] init];
        self.newsDescription = [[NSMutableString alloc]init];
    }

    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([self.element isEqualToString:@"title"]) {
        [self.newsTitle appendString:string];
    } else if ([self.element isEqualToString:@"link"]) {
        [self.newsLink appendString:string];
    } else if ([self.element isEqualToString:@"description"]){
        [self.newsDescription appendString:string];
    }

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        
        [self.item setObject:self.newsTitle forKey:@"title"];
        [self.item setObject:self.newsLink forKey:@"link"];
        [self.item setObject:self.newsDescription forKey:@"description"];
        [self.array addObject:self.item];
        
        NSError* error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    for (NSDictionary* item in self.array) {
        News* news = [NSEntityDescription insertNewObjectForEntityForName:@"News" inManagedObjectContext:self.managedObjectContext];
        news.newstitle = [item objectForKey:@"title"];
        news.newsdescription = [item objectForKey:@"description"];
        news.url = [item objectForKey:@"link"];
        NSLog(@"%@", news);
        
    }
}
#pragma mark - Core Data Stack


- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.SealDeveloper.CoreDataAPP" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"News" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"News.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma  mark - Help Methods

- (void) deleteAllObjects {
    
    NSArray* allObjects = [self allObjects];
    
    for (News* object in allObjects) {
        [self.managedObjectContext deleteObject:object];
    }
    [self.managedObjectContext save:nil];
}

- (NSArray*) allObjects {
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"News"
                inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    return resultArray;
}

- (void) printAllObjects {
    NSArray* allObjects = [self allObjects];
    [self printArray:allObjects];
}

- (void) printArray:(NSArray*) array {
    for (id object in array) {
        if ([object isKindOfClass:[News class]]) {
            News* news = (News*)object;
            NSLog(@"News Title %@", news.newstitle);
        }
    }
    NSLog(@"COUNT = %d", [array count]);
}

-(void) reloadDataBase {
    [self deleteAllObjects];
    [self startParseXML];
    [self printAllObjects];
}
@end
