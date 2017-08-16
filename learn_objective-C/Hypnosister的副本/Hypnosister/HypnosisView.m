//
//  HypnosisView.m
//  Hypnosister
//
//  Created by NM on 2017/7/6.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import "HypnosisView.h"

@interface HypnosisView ()

@property (strong, nonatomic) UIColor * circleColor;

@end

@implementation HypnosisView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    NSLog(@"drawRect");
    CGRect bounds = self.bounds;
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    
    float maxradius = (hypot(bounds.size.width, bounds.size.height) / 2.0);
    
    UIBezierPath * path = [[UIBezierPath alloc] init];
    
    // draw shadow
//    CGContextRef currentContext = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(currentContext);
//    CGContextSetShadow(currentContext, CGSizeMake(0, 2), 3);
    
    // draw circles
    for (float currentRadius = maxradius; currentRadius > 0; currentRadius -= 20) {
        [path moveToPoint:CGPointMake(center.x + currentRadius, center.y)];
        [path addArcWithCenter:center
                        radius:currentRadius
                    startAngle:0
                      endAngle:2.0 * M_PI
                     clockwise:YES];
    }
    
    path.lineWidth = 10;
    [self.circleColor setStroke];
    [path stroke];
    
    //draw image
    UIImage * image = [UIImage imageNamed:@"1.png"];
    [image drawInRect:CGRectMake(50, 200, 300, 300)];
    
    
    //stop shadow drawing
    //CGContextRestoreGState(currentContext);
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"initWithFrame");
        self.backgroundColor = [UIColor whiteColor];
        self.circleColor = [UIColor lightGrayColor];
        
        //set segmentControl
        self.segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Red", @"Green", @"Blue"]];
        self.segmentControl.frame = CGRectMake(20, 20, 150, 30);
        [self.segmentControl addTarget:self action:@selector(onSegmentClick:)
                      forControlEvents:UIControlEventValueChanged];
        [self.segmentControl setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.segmentControl];
        
    }
    return self;
}


- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"%@ was touched", self);
    
    float red = (arc4random() % 100) / 100.0;
    float green = (arc4random() % 100) / 100.0;
    float blue = (arc4random() % 100) / 100.0;
    
    UIColor * randomColor = [UIColor colorWithRed:red
                                            green:green
                                             blue:blue
                                            alpha:1.0];
    self.circleColor = randomColor;
}

- (IBAction)onSegmentClick:(id)sender {
    NSLog(@"Segment being clicked");
    switch ([sender selectedSegmentIndex]) {
        case 0:
            self.circleColor = [UIColor redColor];
            break;
        case 1:
            self.circleColor = [UIColor greenColor];
            break;
        case 2:
            self.circleColor = [UIColor blueColor];
            break;
        default:
            break;
    }
}



- (void)setCircleColor:(UIColor *)circleColor {
    _circleColor = circleColor;
    [self setNeedsDisplay];
}


@end
