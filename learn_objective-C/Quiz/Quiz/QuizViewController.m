//
//  QuizViewController.m
//  Quiz
//
//  Created by NM on 2017/7/5.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import "QuizViewController.h"

@interface QuizViewController ()
@property (nonatomic) int currentQuestionIndex;
@property (nonatomic, copy) NSArray * questions;
@property (nonatomic, copy) NSArray * answers;
@property (nonatomic, weak) IBOutlet UILabel * questionLabel;
@property (nonatomic, weak) IBOutlet UILabel * answerLabel;

@end

@implementation QuizViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.questions = @[@"From who is congnac made?",
                           @"What is 7 + 7",
                           @"asdfasd"];
        self.answers = @[@"Grapes",
                         @"14",
                         @"asdf"];
    }
    return self;
}


- (IBAction)showQuestion:(id)sender {
    self.currentQuestionIndex++;
    if (self.currentQuestionIndex == [self.questions count]) {
        self.currentQuestionIndex = 0;
    }
    
    NSString * question = self.questions[_currentQuestionIndex];
    self.questionLabel.text = question;
    self.answerLabel.text = @"???";
}

- (IBAction)showAnswer:(id)sender {
    NSString * answer = self.answers[self.currentQuestionIndex];
    self.answerLabel.text = answer;
}

@end
