//
//  MessageEditViewController.m
//  QR
//
//  Created by star on 14-4-30.
//  Copyright (c) 2014年 GraduationDesign. All rights reserved.
//

#import "MessageEditViewController.h"

@interface MessageEditViewController ()
@property (weak, nonatomic) IBOutlet UITextField *NOUSETextField;
@property (weak, nonatomic) IBOutlet UITextView *phoneTextView;

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createImageButtonItem;

@end

@implementation MessageEditViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.NOUSETextField.enabled=YES;
    [self.phoneTextView becomeFirstResponder];
    //self.createImageButtonItem.enabled=NO;
    self.phoneTextView.text=@"13114362288";
    self.messageTextView.text=@"hello,world";
    
}
-(void)textViewDidChange:(UITextView *)textView
{
    if ([self.phoneTextView.text length]) {
        self.createImageButtonItem.enabled=YES;
    }else{
        self.createImageButtonItem.enabled=NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"messageToImageSegue"]) {
        NSString *message=self.messageTextView.text;
        NSString *phone=self.phoneTextView.text;
        NSString *send=[[[@"SMSTO:" stringByAppendingString:phone]  stringByAppendingString:@":"] stringByAppendingString:message];
        NSLog(@"Message To Segue");
        [segue.destinationViewController setValue:send forKey:@"receiveString"];
        
    }
   
}


@end
