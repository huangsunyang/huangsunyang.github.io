//
//  DetailViewController.m
//  Homepwner
//
//  Created by NM on 2017/7/10.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import "DetailViewController.h"
#import "Item.h"
#import "ImageStore.h"
#import "ItemStore.h"

@interface DetailViewController ()
<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) UIPopoverController * imagePickerPopover;

@end

@implementation DetailViewController

- (instancetype) initForNewItem:(BOOL)isNew {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (isNew) {
            UIBarButtonItem * doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                       target:self
                                                                                       action:@selector(save:)];
            self.navigationItem.rightBarButtonItem = doneItem;
            
            UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancelItem;
        }
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    @throw [NSException exceptionWithName:@"Wrong initializer"
                                   reason:@"Use initForNewItem"
                                 userInfo:nil];
    return nil;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    UIImageView * iv = [[UIImageView alloc] initWithImage:nil];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    
    iv.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:iv];
    
    self.imageView = iv;
    
    NSDictionary * nameMap = @{@"imageView": self.imageView,
                               @"dateLabel": self.dateLabel,
                               @"toolbar": self.toolBar};
    
    NSArray * horizontalConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:
                                       @"H:|-0-[imageView]-0-|"
                                            options:0
                                            metrics:nil
                                              views:nameMap];
    
    NSArray * verticalConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:
                                            @"V:[dateLabel]-[imageView]-[toolbar]"
                                            options:0
                                            metrics:nil
                                              views:nameMap];
    [self.view addConstraints: horizontalConstraints];
    [self.view addConstraints:verticalConstraints];
    
    [self.imageView setContentHuggingPriority:200
                                      forAxis:UILayoutConstraintAxisVertical];
    [self.imageView setContentCompressionResistancePriority:700
                                                    forAxis:UILayoutConstraintAxisVertical];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    [self prepareViewsForOrientation:io];
    
    Item * item = self.item;
    self.nameField.text = item.itemName;
    self.serialField.text = item.serialNumber;
    self.valueField.text = [NSString stringWithFormat:@"%d", item.valueInDollars];
    
    static NSDateFormatter * dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    self.dateLabel.text = [dateFormatter stringFromDate:item.dateCreated];
    
    NSString * imageKey = self.item.imageKey;
    
    UIImage * imageToDisplay = [[ImageStore sharedStore] imageForKey:imageKey];
    
    self.imageView.image = imageToDisplay;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
    Item * item = self.item;
    item.itemName = self.nameField.text;
    item.serialNumber = self.serialField.text;
    item.valueInDollars = [self.valueField.text intValue];
}

- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
    for (UIView * view in self.view.subviews) {
        if ([view hasAmbiguousLayout]) {
            [view exerciseAmbiguityInLayout];
        }
    }
}

- (void) viewDidLayoutSubviews {
    for (UIView * subview in self.view.subviews) {
        if ([subview hasAmbiguousLayout]) {
            NSLog(@"AMBIGIOUS: %@", subview);
        }
    }
}

-(void) setItem:(Item *)item {
    _item = item;
    self.navigationItem.title = _item.itemName;
}

- (IBAction)onTouchesUp:(id)sender {
    [self.nameField resignFirstResponder];
    [self.serialField resignFirstResponder];
    [self.valueField resignFirstResponder];
    
}

- (IBAction)takePicture:(id)sender {
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        UIImageView * overLayImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
        overLayImg.image = [UIImage imageNamed:@"1.png"];
        imagePicker.cameraOverlayView = overLayImg;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        imagePicker.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:imagePicker animated:YES completion:nil];
        
        UIPopoverPresentationController * popOverController = [imagePicker popoverPresentationController];
        
        popOverController.permittedArrowDirections =UIPopoverArrowDirectionLeft|UIPopoverArrowDirectionRight;
        
        popOverController.sourceView = self.view;
        popOverController.barButtonItem = sender;
        
        
    } else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    //UIImage * image = info[UIImagePickerControllerOriginalImage];
    UIImage * image = info[UIImagePickerControllerEditedImage];
    
    [[ImageStore sharedStore] setImage:image
                                forKey:self.item.imageKey];
    
    self.imageView.image = image;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onPressReset:(id)sender {
    self.imageView.image = nil;
    [[ImageStore sharedStore] deleteImageForKey: self.item.imageKey];
}


- (void)prepareViewsForOrientation: (UIInterfaceOrientation) orientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return;
    }
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.imageView.hidden = YES;
        self.cameraButton.enabled = NO;
    } else {
        self.imageView.hidden = NO;
        self.cameraButton.enabled = YES;
    }
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self prepareViewsForOrientation:toInterfaceOrientation];
}

- (void) save: (id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (void) cancel: (id)sender {
    [[ItemStore sharedStore] removeItem:self.item];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

@end
