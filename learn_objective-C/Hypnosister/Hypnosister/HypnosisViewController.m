//
//  HypnosisViewController.m
//  Hypnosister
//
//  Created by NM on 2017/7/6.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import "HypnosisViewController.h"
#import "HypnosisView.h"

@interface HypnosisViewController () <UITextFieldDelegate, UIScrollViewDelegate>

@end

@implementation HypnosisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"Hypnosis loaded");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect bigRect = screenRect;
    
    bigRect.size.height *= 2;
    bigRect.size.width *= 2;
    
    HypnosisView * backgroundView = [[HypnosisView alloc] initWithFrame:bigRect];
    backgroundView.tag = 10;

    NSLog(@"%lf %lf", bigRect.size.height, bigRect.size.width);
    
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = scrollView;
    [scrollView addSubview:backgroundView];
    NSLog(@"%lf %lf", scrollView.bounds.size.height, scrollView.bounds.size.width);
    scrollView.contentSize = bigRect.size;
    [scrollView setDelegate:self];
    scrollView.maximumZoomScale = 2.0;
    
    CGRect textFieldRect = CGRectMake(40, 70, 240, 30);
    UITextField * textField = [[UITextField alloc] initWithFrame:textFieldRect];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = @"Hypnotize me";
    textField.returnKeyType = UIReturnKeyDone;
    textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.secureTextEntry = YES;
    textField.delegate = self;
    [scrollView addSubview:textField];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Hypnotize";
        UIImage *i = [UIImage imageNamed:@"Hypno.png"];
        self.tabBarItem.image = i;
    }
    return self;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) drawHypnoticMessage: (NSString *) message {
    for (int i = 0; i < 20; i++) {
        UILabel * messageLabel = [[UILabel alloc] init];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.text = message;
        
        [messageLabel sizeToFit];
        
        int width = (int)(self.view.bounds.size.width - messageLabel.bounds.size.width);
        int x = arc4random() % width;
        
        int height = (int)(self.view.bounds.size.height - messageLabel.bounds.size.height);
        int y = arc4random() % height;
        
        CGRect frame = messageLabel.frame;
        frame.origin = CGPointMake(x, y);
        messageLabel.frame = frame;
        
        [self.view addSubview:messageLabel];
        
        UIInterpolatingMotionEffect * motionEffect;
        motionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                       type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        motionEffect.minimumRelativeValue = @(-25);
        motionEffect.maximumRelativeValue = @(25);
        [messageLabel addMotionEffect:motionEffect];
    }
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn: (UITextField *) textField {
    [self drawHypnoticMessage:textField.text];
    
    textField.text = @"";
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - scroll delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [self.view viewWithTag:10];
}

@end
