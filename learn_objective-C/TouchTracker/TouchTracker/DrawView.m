//
//  DrawView.m
//  TouchTracker
//
//  Created by NM on 2017/7/10.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import "DrawView.h"
#import "Line.h"

@interface DrawView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableDictionary * lineInProgress;
@property (nonatomic, strong) NSMutableArray * finishedLines;
@property (nonatomic, weak) Line * selectedLine;
@property (nonatomic, strong) UIPanGestureRecognizer * moveRecognizer;

@end


@implementation DrawView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.lineInProgress = [[NSMutableDictionary alloc] init];
        self.finishedLines = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor grayColor];
        self.multipleTouchEnabled = YES;
        
        UITapGestureRecognizer * doubleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                        initWithTarget:self
                                                                action:@selector(doubleTap:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.delaysTouchesBegan = YES;
        [self addGestureRecognizer:doubleTapRecognizer];
        
        UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tapRecognizer.delaysTouchesBegan = YES;
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        
        [self addGestureRecognizer:tapRecognizer];
        
        UILongPressGestureRecognizer * pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                       action:@selector(longPress:)];
        [self addGestureRecognizer:pressRecognizer];
        
        self.moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(moveLine:)];
        self.moveRecognizer.delegate = self;
        self.moveRecognizer.cancelsTouchesInView = NO;
        self.moveRecognizer.delaysTouchesBegan = YES;
        
        [self addGestureRecognizer:self.moveRecognizer];
        
    }
    return self;
}

- (void) strokeLine: (Line *) line {
    UIBezierPath * bp = [UIBezierPath bezierPath];
    bp.lineWidth = 10;
    bp.lineCapStyle = kCGLineCapRound;
    
    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    [bp stroke];
}

- (void) drawRect:(CGRect)rect {
    [[UIColor blackColor] set];
    for (Line * line in self.finishedLines) {
        [self strokeLine:line];
    }
    
    [[UIColor redColor] set];
    for (NSValue * key in self.lineInProgress) {
        [self strokeLine:self.lineInProgress[key]];
    }
    
    if (self.selectedLine) {
        [[UIColor greenColor] set];
        [self strokeLine:self.selectedLine];
    }
    
    float f = 0.0;
    for (int i = 0; i < 1000000; i++) {
        f += sin(sin(sin(time(NULL))) + i);
    }
    NSLog(@"%f", f);
}

- (Line *) lineAtPoint:(CGPoint) p {
    for (Line * l in self.finishedLines) {
        CGPoint start = l.begin;
        CGPoint end = l.end;
        
        for (float t = 0.0; t < 1.0; t += 0.05) {
            float x = start.x + t * (end.x - start.x);
            float y = start.y + t * (end.y - start.y);
            
            if (hypot(x - p.x, y - p.y) < 20.0) {
                return l;
            }
        }
    }
    return nil;
}

# pragma mark - Touch events

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for (UITouch * t in touches) {
        CGPoint location = [t locationInView:self];
        
        Line * line = [[Line alloc] init];
        line.begin = location;
        line.end = location;
        NSValue * key = [NSValue valueWithNonretainedObject:t];
        self.lineInProgress[key] = line;
    }
    
    [self setNeedsDisplay];
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for (UITouch * t in touches) {
        NSValue * key = [NSValue valueWithNonretainedObject:t];
        Line * line = self.lineInProgress[key];
        
        line.end = [t locationInView:self];
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for (UITouch * t in touches) {
        NSValue * key = [NSValue valueWithNonretainedObject:t];
        Line * line = self.lineInProgress[key];
        
        [self.finishedLines addObject:line];
        [self.lineInProgress removeObjectForKey:key];
    }
    
    [self setNeedsDisplay];
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for (UITouch * t in touches) {
        NSValue * key = [NSValue valueWithNonretainedObject:t];
        [self.lineInProgress removeObjectForKey:key];
    }
    
    [self setNeedsDisplay];
}


# pragma mark - Gesture Event
- (void)doubleTap: (UIGestureRecognizer *)gr {
    NSLog(@"Recognized Double Tap");
    
    [self.lineInProgress removeAllObjects];
    [self.finishedLines removeAllObjects];
    [self setNeedsDisplay];
}

- (void)tap: (UIGestureRecognizer *) gr {
    NSLog(@"Recognized tap");
    
    CGPoint point = [gr locationInView:self];
    self.selectedLine = [self lineAtPoint:point];
    
    if (self.selectedLine) {
        [self becomeFirstResponder];
        
        UIMenuController * menu = [UIMenuController sharedMenuController];
        
        UIMenuItem * deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteLine:)];
        
        menu.menuItems = @[deleteItem];
        
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2)
                     inView:self];
        [menu setMenuVisible:YES animated:YES];
    } else {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
    
    [self setNeedsDisplay];
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (void) deleteLine:(id)sender {
    [self.finishedLines removeObject:self.selectedLine];
    self.selectedLine = nil;
    
    [self setNeedsDisplay];
}

- (void) longPress:(UILongPressGestureRecognizer *)gr {
    if (gr.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gr locationInView:self];
        self.selectedLine = [self lineAtPoint:point];
        
        if (self.selectedLine) {
            [self.lineInProgress removeAllObjects];
        }
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        self.selectedLine = nil;
    }
    [self setNeedsDisplay];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.moveRecognizer) {
        return YES;
    } return NO;
}

- (void) moveLine: (UIPanGestureRecognizer *) gr {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (!self.selectedLine) {
        return;
    }
    
    if (gr.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gr translationInView:self];
        CGPoint begin = self.selectedLine.begin;
        CGPoint end = self.selectedLine.end;
        begin.x += translation.x;
        end.x += translation.x;
        begin.y += translation.y;
        end.y += translation.y;
        
        self.selectedLine.begin = begin;
        self.selectedLine.end = end;
    } else if (gr.state == UIGestureRecognizerStateBegan) {
        gr.cancelsTouchesInView = YES;
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        gr.cancelsTouchesInView = NO;
    }
    
    [self setNeedsDisplay];
    [gr setTranslation:CGPointZero inView:self];
}
@end
