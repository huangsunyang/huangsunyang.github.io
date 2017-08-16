//
//  ItemViewController.m
//  Homepwner
//
//  Created by NM on 2017/7/7.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import "DetailViewController.h"
#import "ItemViewController.h"
#import "ItemStore.h"
#import "Item.h"

@interface ItemViewController ()
@property (nonatomic, strong) IBOutlet UIView * headerView;
@end

@implementation ItemViewController

- (IBAction)addNewItem:(id)sender {
    Item * newItem = [[ItemStore sharedStore] createItem];
    
    DetailViewController * detailViewController = [[DetailViewController alloc] initForNewItem:YES];
    detailViewController.item = newItem;
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    detailViewController.dismissBlock = ^ {
        [self.tableView reloadData];
    };
    
    [self presentViewController:navController animated:YES completion:nil];
    
}


- (instancetype) init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
//        for (int i = 0; i < 5; i++) {
//            [[ItemStore sharedStore] createItem];
//        }
        
        UINavigationItem * navItem = self.navigationItem;
        
        UIBarButtonItem * bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                              target:self
                                                                              action:@selector(addNewItem:)];
        navItem.rightBarButtonItem = bbi;
        navItem.title = @"HomePwner";
        navItem.leftBarButtonItem = self.editButtonItem;
    }
    return self;
}

- (instancetype) initWithStyle:(UITableViewStyle)style {
    return [self init];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
    
    UIView * header = self.headerView;
    if (!header) {
        NSLog(@"header is nil");
    }
    [self.tableView setTableHeaderView:header];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[ItemStore sharedStore] allItems] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                                   reuseIdentifier:@"UITableViewCell"];
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
                                                             forIndexPath:indexPath];
    
    NSArray * items = [[ItemStore sharedStore] allItems];
    Item * item = items[indexPath.row];
    
    cell.textLabel.text = [item description];
    
    // Configure the cell...
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray * items = [[ItemStore sharedStore] allItems];
        Item * item = [items objectAtIndex:indexPath.row];
        [[ItemStore sharedStore] removeItem:item];
        
        
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath {
    [[ItemStore sharedStore] moveItemAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
    NSLog(@"%@", [[ItemStore sharedStore] allItems]);
    [self.tableView reloadData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController * detailViewController  = [[DetailViewController alloc] initForNewItem:NO];
    
    NSArray * items = [[ItemStore sharedStore] allItems];
    Item * selectedItem = items[indexPath.row];
    detailViewController.item = selectedItem;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

@end
