//
//  EditViewController.m
//  QR
//
//  Created by star on 14-4-25.
//  Copyright (c) 2014年 GraduationDesign. All rights reserved.
//

#import "EditViewController.h"
#import "CreatImageViewController.h"

@interface EditViewController ()
@property (weak, nonatomic) IBOutlet UITextView *TextTV;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *TextBI;

@property (weak, nonatomic) IBOutlet UITextField *WebTF;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *WebBI;


@end

@implementation EditViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.TextTV.delegate=self;
    self.WebTF.delegate=self;
    
    self.TextBI.enabled=NO;
    self.WebBI.enabled=YES;
    
    [self.TextTV becomeFirstResponder];
    
}

-(void)textViewDidChange:(UITextView *)textView
{
    if ([self.TextTV.text length]) {
        self.TextBI.enabled=YES;
    }else{
        self.TextBI.enabled=NO;
    }
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TextToImageSegue"]) {
        NSLog(@"Text to Segue");
        [segue.destinationViewController setValue:self.TextTV.text forKey:@"receiveString"];
        [segue.destinationViewController setValue:@"Text"
                                           forKey:@"receiveMode"];
    }else if ([segue.identifier isEqualToString:@"WebToImageSegue"]){
        NSLog(@"Web to Segue");
        [segue.destinationViewController setValue:self.WebTF.text forKey:@"receiveString"];
        [segue.destinationViewController setValue:@"Web"
                                           forKey:@"receiveMode"];

    }
    
}








@end
