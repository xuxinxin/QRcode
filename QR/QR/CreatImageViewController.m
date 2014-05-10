//
//  CreatImageViewController.m
//  QR
//
//  Created by star on 14-4-25.
//  Copyright (c) 2014年 GraduationDesign. All rights reserved.
//
typedef enum {
    GREEN=0,
    BLUE,
    BROWN,
    BLACK,
    RED
}ColorSet;



#import "CreatImageViewController.h"
#import "QRCodeGenerator.h"
#import "CommonFunc.h"
#import "FMTImageSet.h"

@interface CreatImageViewController ()
{
    ColorSet currentColor;
    BOOL IsBackgroundWhite;
    BOOL IsEncryed;
    NSString *encryKey;
    BOOL HaveLogo;
    UIColor *buttonColor;
}
@property (weak, nonatomic) IBOutlet UIImageView *QRImage;
@property (strong, nonatomic) NSString *codeString;

@property (strong, nonatomic) NSString *correctLevelString;


@property (weak, nonatomic) IBOutlet UIView *encryptView;
@property (weak, nonatomic) IBOutlet UITextField *encryKeyTextField;

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIButton *choseGreen;
@property (weak, nonatomic) IBOutlet UIButton *choseBlue;
@property (weak, nonatomic) IBOutlet UIButton *choseBrown;
@property (weak, nonatomic) IBOutlet UIButton *chosePurple;
@property (weak, nonatomic) IBOutlet UIButton *choseRed;
@property (weak, nonatomic) IBOutlet UIButton *colorChoseButton;
@property (weak, nonatomic) IBOutlet UIButton *encryButton;
@property (nonatomic) BOOL IsColorChose;

@end

@implementation CreatImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"reiceive:%@",self.receiveString);
    NSLog(@"mode:%@",self.receiveMode);
    self.encryKeyTextField.delegate=self;
    self.correctLevelString=@"L";//default ECLevel is L
    
    
    IsBackgroundWhite=YES;
    IsEncryed=NO;
    HaveLogo=NO;
    buttonColor=self.encryButton.titleLabel.textColor;
    self.encryptView.layer.cornerRadius=6;
    [self receiveStringTocodeString];
    [self labelInit];
    //[self.colorView setBackgroundColor:[UIColor grayColor]];
    [self encryViewClear];
    [self colorChoseClear];
    currentColor=BLACK;
    [self viewUpdate];
}


-(void)labelInit{
    NSString* labelStr=self.receiveString;
    labelStr=[labelStr stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    if ([labelStr length]) {
        CGPoint labelOrigin={20.0,450.0};
        CGFloat width=280;
        UIFont *font = [UIFont fontWithName:@"Arial" size:15];
        NSAttributedString *attributedText=[[NSAttributedString alloc] initWithString:labelStr attributes:@{NSFontAttributeName: font}];
        CGRect rect=[attributedText boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        CGFloat height=ceilf(rect.size.height) ;
        width=ceilf(rect.size.width);
        UILabel *QRstringLabel=[[UILabel alloc] init];
        [QRstringLabel setNumberOfLines:0];
        
        [QRstringLabel setFont:font];
        [QRstringLabel setFrame:CGRectMake(labelOrigin.x, labelOrigin.y, width, height)];
        
        QRstringLabel.text=labelStr;
       // QRstringLabel.layer.cornerRadius=5;
        QRstringLabel.layer.borderColor=[UIColor grayColor].CGColor;
        QRstringLabel.layer.borderWidth=1;
        
        [self.view addSubview:QRstringLabel];
    }

                                       
}
-(void)encryViewClear{
    [self.encryKeyTextField resignFirstResponder];
    self.encryptView.hidden=YES;
}



-(void)receiveStringTocodeString{
    if ([self.receiveString length]==0) {
        self.receiveString=@"NO DATA!NO HAPPY!";
        NSLog(@"you shuju le a ");
    }
    self.codeString=[[NSString alloc]initWithString:self.receiveString];
    NSLog(@"code:%@",self.codeString);
    
}


#pragma -mark error correct level
- (IBAction)errorCollectChoose:(id)sender {
    UIActionSheet *ECLsheet=[[UIActionSheet alloc]initWithTitle:@"纠错级别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"低（7%）",@"中低（15%）",@"中高（25%）",@"高（30%）", nil];
    ECLsheet.tag=1;
    [ECLsheet showInView:[UIApplication sharedApplication].keyWindow];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    BOOL change=NO;
    NSString *cls=self.correctLevelString;
    if (actionSheet.tag==1) {
        switch (buttonIndex) {
            case 0:
                if (![cls isEqualToString:@"L"]) {
                    self.correctLevelString=@"L";
                    change=YES;
                }
                break;
            case 1:
                if (![cls isEqualToString:@"M"]) {
                    self.correctLevelString=@"M";
                    change=YES;
                }
                break;
            case 2:
                if (![cls isEqualToString:@"Q"]) {
                    self.correctLevelString=@"Q";
                    change=YES;
                }
                break;
            case 3:
                if (![cls isEqualToString:@"H"]) {
                    self.correctLevelString=@"H";
                    change=YES;
                }
                break;
            default:
                if (![cls isEqualToString:@"L"]) {
                    self.correctLevelString=@"L";
                    change=YES;
                }
                break;
        }
    }
    if (change) {
        [self viewUpdate];
    }
}



#pragma -mark encry
//----------encry part-----------------
//encry :[CommonFunc base64StringFromText: withKey:(NSString *)]
//decry : [CommonFunc textFromBase64String:<#(NSString *)#> withKey:<#(NSString *)#>]
//-------------------------------------
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)encryButtonClick:(id)sender {
    if (IsEncryed) {
        //dont encry
        self.codeString=self.receiveString;
        [self viewUpdate];
        IsEncryed=NO;
        [self.encryButton setTitleColor:buttonColor forState:UIControlStateNormal];
        //[self.encryButton setBackgroundColor:[UIColor whiteColor]];
    }else {
        self.encryptView.hidden=NO;
        [self.encryKeyTextField becomeFirstResponder];
        [self colorChoseClear];
    }
    
}
- (IBAction)encrySureButtonClick:(id)sender {
    if ([self.encryKeyTextField.text length]){
        NSLog(@"%@",self.encryKeyTextField.text);
       // [self codeStringEncryUpdate];
        self.codeString=[CommonFunc base64StringFromText:self.codeString
                                                 withKey:self.encryKeyTextField.text];
        NSLog(@"decry...");
        NSLog(@"origindata:%@",[CommonFunc textFromBase64String:self.codeString withKey:self.encryKeyTextField.text]);
        
        self.codeString=[@"ENC:" stringByAppendingString:self.codeString];
        NSLog(@"codestring update:%@",self.codeString);
        [self viewUpdate];
        IsEncryed=YES;
        [self.encryButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        // [self.encryButton setBackgroundColor:[UIColor lightGrayColor]];
    }
    self.encryptView.hidden=YES;
    self.encryKeyTextField.text=nil;
    [self.encryKeyTextField resignFirstResponder];
}
- (IBAction)encryCanclButtonClick:(id)sender {
    self.encryptView.hidden=YES;
    [self.encryKeyTextField resignFirstResponder];
    self.encryKeyTextField.text=nil;
}

#pragma -mark change color
-(void)colorChoseClear{
    self.colorView.hidden=YES;
    self.IsColorChose=NO;
}

- (IBAction)choseColor:(id)sender {
    [self encryViewClear];
    if (self.IsColorChose) {
        [self colorChoseClear];
    }else{
        self.colorView.hidden=NO;
        self.IsColorChose=YES;
    }
}
- (IBAction)choseGreen:(id)sender {
    if (HaveLogo) {
       self.QRImage.image=[QRCodeGenerator qrImageForString:self.codeString
                                                imageSize:self.QRImage.bounds.size.width
                                                  ECLevel:self.correctLevelString];
        HaveLogo=NO;
    }
    
    [self setColorGreen:self.QRImage.image];
}
-(void)setColorGreen:(UIImage*)img{
    UIColor *acolor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1.0];
    UIImage *bImage = [FMTImageSet colorizeImage:img withColor:acolor];
    [self.QRImage setImage:bImage];
    currentColor=GREEN;
}

- (IBAction)choseBlue:(id)sender {
    if (HaveLogo) {
        self.QRImage.image=[QRCodeGenerator qrImageForString:self.codeString
                                                   imageSize:self.QRImage.bounds.size.width
                                                     ECLevel:self.correctLevelString];
        HaveLogo=NO;
    }
    [self setColorBlue:self.QRImage.image];
}
-(void)setColorBlue:(UIImage*)img{
    UIColor *acolor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1.0];
    UIImage *bImage = [FMTImageSet colorizeImage:img withColor:acolor];
    [self.QRImage setImage:bImage];
    currentColor=BLUE;
}

- (IBAction)shoseBrown:(id)sender {
    if (HaveLogo) {
        self.QRImage.image=[QRCodeGenerator qrImageForString:self.codeString
                                                   imageSize:self.QRImage.bounds.size.width
                                                     ECLevel:self.correctLevelString];
        HaveLogo=NO;
    }
    [self setColorBrown:self.QRImage.image];
}
-(void)setColorBrown:(UIImage*)img{
    UIColor *acolor = [UIColor colorWithRed:0.5 green:0.25 blue:0 alpha:1.0];
    UIImage *bImage = [FMTImageSet colorizeImage:img withColor:acolor];
    [self.QRImage setImage:bImage];
    currentColor=BROWN;
}

- (IBAction)choseBlack:(id)sender {
    if (HaveLogo) {
        self.QRImage.image=[QRCodeGenerator qrImageForString:self.codeString
                                                   imageSize:self.QRImage.bounds.size.width
                                                     ECLevel:self.correctLevelString];
        HaveLogo=NO;
    }
    [self setColorBlack:self.QRImage.image];
}
-(void)setColorBlack:(UIImage*)img{
    UIColor *acolor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    UIImage *bImage = [FMTImageSet colorizeImage:img withColor:acolor];
    [self.QRImage setImage:bImage];
    currentColor=BLACK;
}

- (IBAction)choseRed:(id)sender {
    if (HaveLogo) {
        self.QRImage.image=[QRCodeGenerator qrImageForString:self.codeString
                                                   imageSize:self.QRImage.bounds.size.width
                                                     ECLevel:self.correctLevelString];
        HaveLogo=NO;
    }
    [self setColorRed:self.QRImage.image];
}
-(void)setColorRed:(UIImage*)img{
    UIColor *acolor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1.0];
    UIImage *bImage = [FMTImageSet colorizeImage:img withColor:acolor];
    [self.QRImage setImage:bImage];
    currentColor=RED;
}

- (IBAction)setBackgroundColor:(id)sender {
    if (IsBackgroundWhite) {
        [self.QRImage setBackgroundColor:[UIColor lightGrayColor]];
    }else{
        [self.QRImage setBackgroundColor:[UIColor whiteColor]];
    }
    IsBackgroundWhite=!IsBackgroundWhite;
}
#pragma -mark LOGO
- (IBAction)setLOGO:(id)sender {
    if (HaveLogo) {
        [self viewUpdate];
        HaveLogo=NO;
    }
    //open photo album
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self dismissViewControllerAnimated:NO completion:^{}];
        [self presentViewController:imagePicker animated:YES completion:^{}];
    }
}
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self dismissViewControllerAnimated:YES
                             completion:^{
                             }];
    image=[FMTImageSet addImageLogo:self.QRImage.image logo:image];
    [self.QRImage setImage:image];
    NSLog(@"logo");
    HaveLogo=YES;
}

#pragma -mark save to photo album
- (IBAction)saveToAlbum:(id)sender {
    UIImageWriteToSavedPhotosAlbum(self.QRImage.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *) contextInfo {
    NSString *message;
    NSString *title;
    if (!error) {
        title = @"Success";
        message = @"成功保存到相册。";
    } else {
        title = @"Failure";
#if DEBUG_MODE
        message = [error description];
#else
        message = @"保存到相册失败。";
#endif
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


#pragma -mark information update
-(void)viewUpdate{
    NSLog(@"view update...");
    //[self.QRImage setImage:nil];
    if (HaveLogo) {
        HaveLogo=NO;
    }
    UIImage *newimg=[QRCodeGenerator qrImageForString:self.codeString
                                            imageSize:self.QRImage.bounds.size.width
                                              ECLevel:self.correctLevelString];
    NSLog(@"%@,%@",self.codeString,self.correctLevelString);
    switch (currentColor) {
        case BLACK:
            [self.QRImage setImage:newimg];
            break;
        case BLUE:
            [self setColorBlue:newimg];
            break;
        case BROWN:
            [self setColorBrown:newimg];
            break;
        case GREEN:
            [self setColorGreen:newimg];
            break;
        default:
            [self setColorRed:newimg];
            break;
    }
}



@end


