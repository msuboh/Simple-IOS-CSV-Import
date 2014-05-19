//
//  MHSMasterViewController.m
//  SimpleCSVImport
//
//  Created by Maher Suboh on 5/17/14.
//  Copyright (c) 2014 Maher Suboh. All rights reserved.
//

#import "MHSMasterViewController.h"
#import "MHSDetailViewController.h"

#import "NSString+ParsingExtensions.h"



@interface MHSMasterViewController ()
{
    NSString *fileString;
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

typedef void(^myCompletion)(BOOL);

//typedef void (^completion_t)(id result);
typedef void (^completion_t)(id result, NSError* error);
- (void) taskWithCompletion:(completion_t)completionHandler;



@end

@implementation MHSMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
  
    
    
    
    //////////////////////////////////////////////
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    _spinner.transform = CGAffineTransformMakeScale(1.5, 1.5);
    _spinner.center = self.view.center;
    [_spinner setColor:[UIColor blueColor]];
    [self.view addSubview:_spinner];
    [self.view bringSubviewToFront:_spinner];
    /////////////////////////////////////////////
    
    [self.spinner startAnimating];
    NSLog(@"Start Point ...");
    [self deleteAllObjects]; // I am just doing this deleting the core data entity just to make sure that if there happen an error there won't be any data from the prevouse runs and think that this runs ok.


    
    
//    1. if you want to read it from a server and load it right away:
//    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://localhost/Kababish/KababishServerMenu.csv"]];
//    NSString *fileString = [[NSString alloc] initWithData:responseData   encoding:NSUTF8StringEncoding];
//   [self importCSVFile:[fileString csvRows]];
//    NSLog(@"responseString--->%@",fileString);
    
//    2. If you want to read it Localy shipped with your App:
//    NSError *outError = nil;    
//    NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"KababishMenu"  ofType:@"csv"];
//    NSString *fileString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&outError];
//    [self importCSVFile:[fileString csvRows]];
    
    
//    3. Custom Block
//    [self myBlockMethod:^(BOOL finished) {
//        if(finished)
//        {
////            NSLog(@"%@", [fileString csvRows]);
//            [self importCSVFile:[fileString csvRows]];
//            NSLog(@"success");
//
//        }
//         NSLog(@"Are we there yet?!");
//        [self.spinner stopAnimating];
//    }];
    

    
//   4. Grand Central Dispatch (GCD)
    
    // Now, there is one really big benefit to using blocks and that is Grand Central Dispatch (GCD).

    /*
     Today, I’ll use wikipedia as my crutch:
     
     Grand Central Dispatch (GCD) is a technology developed by Apple Inc. to optimize application support for systems with multi-core processors and other symmetric multiprocessing systems.
     */

     /*
     A Note on Concurrency
     Now for the sake of simplicity we opted to use a serial task to run our block on another thread. This was denoted by NULL in our dispatch_Queue_create() method. Serial just means that the processes are first in first out or FIFO. In other words, the second block doesn’t start on any thread until the first block is done.
     
     Conversely, we could do this concurrently (replace NULL with DISPATCH_QUEUE_CONCURRENT). For this example it doesn’t make much sense since we only have one block. Suppose we had two blocks however, then they would start in order (dequeue) but they wouldn’t necessarily finish in order. This property makes them useful for handling a lot of data such as three seperate calls to a server that each load information that is independent of each other.
     */
    
//    dispatch_queue_t countQueue = dispatch_queue_create("counter", NULL);
//    OR the following .... read the above note.
//    dispatch_queue_t countQueue = dispatch_queue_create("counter", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(countQueue, ^{
//        
//
////        int x = 1;
////        while (x < 10001) {
////            
////            NSLog(@"%i", x);
////            x++;
////        }
//        
//        NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://localhost/Kababish/KababishServerMenu.csv"]];
//        fileString = [[NSString alloc] initWithData:responseData   encoding:NSUTF8StringEncoding];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            
//            [self importCSVFile:[fileString csvRows]];
//
//            NSLog(@"Are we there yet?!");
//            
//            [self.tableView reloadData];
//            
//            [self.spinner stopAnimating];
//        });
//    });

    
    
// 5. My Custom Block method and GCD Way
    // Why I am Using Both togther. Though my Custom completion Block is enough to handle the completion when loading the cvs file from the sever and handle the erro.
    // Becuase, without the GCD way, when you run the App, the ViewControl view is Black, and can't do other things beside it like displaying the Activity View and/or scroll the Table view, ... etc..
    dispatch_queue_t countQueue = dispatch_queue_create("counter", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(countQueue, ^{

        __block bool finishedOK = YES;
        
        // Here I am using my completion Custom Block
        [self myBlockMethod:^(BOOL finished) {
            // myBlockMethod method just download or load the CSV file from the server to a NSString String variable and check if it is there and no error, before we Parse it into an array.
            if(finished)
            {
                NSLog(@"Success!");
            }
            else
            {
                finishedOK = NO;
            }
        }];

        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (finishedOK)
            {
                // [self importCSVFile:[fileString csvRows]] method Parse the NSString Variable into an Array and Update the Core Data, and make sure there was no error in either the CSV file nor in Updating the Core Data.
                if ([self importCSVFile:[fileString csvRows]])
                {
                    NSLog(@"Are we there yet?!");
                
                    [self.tableView reloadData];
                    NSLog(@"Yes, we are reloading TableView ....");
                }
                else
                {
                    NSLog(@"Display a message error 1");
                    [[[UIAlertView alloc] initWithTitle:@"Action Status" message:@"An Error Occurs!\nPlease Check you CSV File ..." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
                }
            }
            else
            {
                NSLog(@"Display a message error 2");
                [[[UIAlertView alloc] initWithTitle:@"Action Status" message:@"An Error Occurs!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
            }

            [self.spinner stopAnimating];
        });

        
        NSLog(@"And out of the GCD Queue Block");

    });

    
    
    NSLog(@"End Point.");

    
    
    //As an example, here‘s a piece of code that uses separate success/failure blocks:
    //    [object doSomethingWithSuccess:^(NSData *data) {
    //        [self.activityIndicator stopAnimating];
    //        // Do something with the data
    //    } failure:^(NSError *error) {
    //        [self.activityIndicator stopAnimating];
    //        // Do something with the error
    //    }];
    // And here’s how I’d write it:
    //    [object doSomethingWithCompletion:^(NSData *data, NSError *error) {
    //        [self.activityIndicator stopAnimating];
    //        if (data != nil) {
    //            // Do something with the data
    //        } else {
    //            // Do something with the error
    //        }
    //    }];
    /*
      If you go and look at any Apple API that uses a completion handler, you’ll see they follow the second pattern. 
        Using separate success/failure blocks forces you to repeat code, because cleanup code is usually independent of success or failure. Don’t do that.
    */
    
    
}

/*
Schedule Blocks on Dispatch Queues with Grand Central Dispatch
If you need to schedule an arbitrary block of code for execution, you can work directly with dispatch queues controlled by Grand Central Dispatch (GCD). Dispatch queues make it easy to perform tasks either synchronously or asynchronously with respect to the caller, and execute their tasks in a first-in, first-out order.

You can either create your own dispatch queue or use one of the queues provided automatically by GCD. If you need to schedule a task for concurrent execution, for example, you can get a reference to an existing queue by using the dispatch_get_global_queue() function and specifying a queue priority, like this:

dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
To dispatch the block to the queue, you use either the dispatch_async() or dispatch_sync() functions. The dispatch_async() function returns immediately, without waiting for the block to be invoked:

dispatch_async(queue, ^{
    NSLog(@"Block for asynchronous execution");
});
The dispatch_sync() function doesn’t return until the block has completed execution; you might use it in a situation where a concurrent block needs to wait for another task to complete on the main thread before continuing, for example.

*/


- (void) taskWithCompletion:(completion_t)completionHandler
{
    
}


//-(void)oneBlock {
//    [self startWithCompletionBlock:^(id obj, NSError* error) {
//        if (error) {
//            NSLog(@"error: %@", error);
//        } else {
//            NSLog(@"success: %@", obj);
//        }
//        self.connection = nil;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self updateUI];
//        });
//    }];
//}

-(void) myBlockMethod:(myCompletion) completionBlockStatus
{
    //do stuff
    NSLog(@"Start Processing myBlockMethod ...");
    
    // Let's assume the download takes long time by running this loop.
    // You can Comment the following loop after testing ...
    int x = 1;
    while (x < 10001) {
        
        NSLog(@"%i", x);
        x++;
    }

    
    // in Those two lines, we are just reading the csv file in a NSString variable either from a sever file or locally from mainBundle:
    
    // 1.  use the following if you are reading the csv file from mainBundle:
    //    NSError *outError = nil;
    //    NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"KababishMenu"  ofType:@"csv"];
    //    fileString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&outError];

    // 2. use the following if you are reading the csv file from the Sever Site:
    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://localhost/Kababish/KababishServerMenu.csv"]];
    fileString = [[NSString alloc] initWithData:responseData   encoding:NSUTF8StringEncoding];
    
    
    //NSLog(@"responseString--->%@",fileString);
    
    
    if ([fileString isEqualToString:@""])
        completionBlockStatus(NO);
    else
        completionBlockStatus(YES);
    // Note: Completion callback (opposed to success/failure pair) is more generic.
    
    NSLog(@"End and out of Processing myBlockMethod.");

}



- (IBAction)deleteRecordAction:(id)sender
{
    
    
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Deletion Configuration"
                                                     message:@"Are you sure you want delete you record!"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles: nil];
    [alert addButtonWithTitle:@"Delete"];
    [alert show];
    
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    NSLog(@"Button Index =%ld",(long)buttonIndex);
    
    if (buttonIndex == 0)
    {
        NSLog(@"You have clicked Cancel");
    }
    else if(buttonIndex == 1)
    {
//        _welcomeMessage.hidden = NO;
//        _welcomeMessage.text = @"";
//        if([ _userRecordID isEqualToString:@"0"]  )
//        {
//            _welcomeMessage.text = @"Deletion Failed!\nUser Record Id does not Exist!";
//        }
//        else
//        {
//            [self loginWithCustomNSURLSessionDelegate:true withLoginCommand:@"delete"];
//        }
//        
//        NSLog(@"You have clicked Delete ...");
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)insertNewObject:(id)sender
//{
//    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
//    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
//    
//    // If appropriate, configure the new managed object.
//    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
//    
//    // Save the context.
//    NSError *error = nil;
//    if (![context save:&error]) {
//         // Replace this implementation with code to handle the error appropriately.
//         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//}

- (void) deleteAllObjects
{
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:context]];
    
    //    NSSortDescriptor *sortDescriptorByAge = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
    //    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorByAge, nil];
    //
    //
    //    [request setSortDescriptors:sortDescriptors];
    //
    //
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"appDefault = 1"   ];
    //    [request setPredicate:predicate];
    
    
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if (objects == nil)
    {
        // handle error
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Save Error!"
                                  message:[NSString stringWithFormat:@"Unresolved error %@, %@", error, [error userInfo] ]
                                  delegate:self
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil, nil];
        [alertView show];
        
    }
    else
    {
        for (NSManagedObject *object in objects)
        {
            [context deleteObject:object];
        }
        [context save:&error];
    }
    
}

- (bool) importCSVFile:(NSArray *)csvArray {
    
    
    

    NSLog(@"Updating the Core Data Entity...");

    int i = 0;
    
    
    [self deleteAllObjects];
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    

    
    for (NSArray *row in csvArray) {
        
        //1st row is a header - skip
        if (i > 0)
        {
            /*
             menuItemSideOrder
             menuItemBriefDescription
             menuItemCategory
             menuItemCategoryOrderIncludes
             menuItemDescription
             menuItemName
             menuItemNumber
             menuItemPrice
             timeStamp
             */
            
            NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
            
            @try
            {
                [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
                [newManagedObject setValue:[row objectAtIndex:0] forKey:@"menuItemNumber"];
                [newManagedObject setValue:[row objectAtIndex:1] forKey:@"menuItemCategory"];
                [newManagedObject setValue:[row objectAtIndex:2] forKey:@"menuItemName"];
                [newManagedObject setValue:[row objectAtIndex:3] forKey:@"menuItemBriefDescription"];
                [newManagedObject setValue:[row objectAtIndex:4] forKey:@"menuItemDescription"];
                [newManagedObject setValue:[row objectAtIndex:5] forKey:@"menuItemPrice"];
                [newManagedObject setValue:[row objectAtIndex:6] forKey:@"menuItemCategoryOrderIncludes"];
                [newManagedObject setValue:[row objectAtIndex:7] forKey:@"menuItemSideOrder"];
            }
            @catch (NSException * e)
            {
                NSLog(@"Exception----------: %@", e);
                return false;

            }
            @finally
            {
                
//                NSLog(@"finally");
                
                // Save the context.
                NSError *error = nil;
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }

            }
            
            
            
        }
        i++;
    }
    
    

    NSLog(@"End and going out for Updating the Core Data Entity.");
    return true;
}



#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    return  [[[self.fetchedResultsController sections] objectAtIndex:section] name];;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"menuItemNumber" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"menuItemCategory" cacheName:@"Master"];
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

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"menuItemName"] description];
}

@end
