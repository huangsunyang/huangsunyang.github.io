//
//  ItemViewController.m
//  Homepwner
//
//  Created by NM on 2017/7/7.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import "ItemViewController.h"
#import "ItemStore.h"
#import "Item.h"

@interface ItemViewController ()

@end

@implementation ItemViewController

- (instancetype) init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        int n = arc4random() % 13 + 80;
        for (int i = 0; i < n; i++) {
            [[ItemStore sharedStore] createItem];
        }
    }
    self.tableView.estimatedRowHeight = 3;
    
    return self;
}

- (instancetype) initWithStyle:(UITableViewStyle)style {
    return [self init];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
    
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray * array = [[ItemStore sharedStore] allItems];
    unsigned long n = [array count];
    int num = 0;
    for (int i = 0; i < n; i++) {
        if ([[array objectAtIndex:i] valueInDollars] < 50) {
            num ++;
        }
    }
    if (section == 0) {
        return num;
    } else if (section == 1) {
        return n - num;
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                                   reuseIdentifier:@"UITableViewCell"];
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
                                                             forIndexPath:indexPath];
    
    NSArray * items = [[ItemStore sharedStore] allItems];
    unsigned long sectionNum = indexPath.section;
    unsigned long indexNum = indexPath.row;
    
    NSMutableArray * small = [[NSMutableArray alloc] init];
    NSMutableArray * large = [[NSMutableArray alloc] init];
    
    NSSortDescriptor * sort = [[NSSortDescriptor alloc]             initWithKey:@"valueInDollars"
                                                          ascending:YES];
    

    for (int i = 0; i < [items count]; i++) {
        if ([[items objectAtIndex:i] valueInDollars] < 50) {
            [small addObject:[items objectAtIndex:i]];
        } else {
            [large addObject:[items objectAtIndex:i]];
        }
    }
    
    [small sortUsingDescriptors:@[sort]];
    [large sortUsingDescriptors:@[sort]];
    
    Item * item;
    
    if (sectionNum == 0) {
        item = small[indexNum];
    } else if (sectionNum == 1) {
        item = large[indexNum];
    } else {
        cell.textLabel.text = @"No more Items";
        return cell;
    }
    
    cell.textLabel.text = [item description];
    
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

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

@end
