//
//  personIDViewController.m
//  QR
//
//  Created by star on 14-5-2.
//  Copyright (c) 2014年 GraduationDesign. All rights reserved.
//

#import "personIDViewController.h"

@interface personIDViewController ()<UIActionSheetDelegate,ABPeoplePickerNavigationControllerDelegate,ABPersonViewControllerDelegate,ABNewPersonViewControllerDelegate>
{
    CGPoint textFieldOrigin;
    BOOL IsChoosePerson;
    NSMutableArray *textFileds;
    NSUInteger textFieldNumber;
}

@property  (nonatomic) ABAddressBookRef chosenPerson;
@property (strong,nonatomic)NSString * codeString;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createImageButtonItem;
//@property (strong, nonatomic) IBOutlet UIView *view;

@end

@implementation personIDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self chooseActionSheet];
    [self initial];
}
-(void)initial{
    textFieldOrigin=CGPointMake(0, 90);
    IsChoosePerson=NO;
    textFileds=[[NSMutableArray alloc]init];
    textFieldNumber=0;
    _codeString=[NSString stringWithFormat:@"BEGIN:VCARD\nVERSION:3.0\n"];
    _createImageButtonItem.enabled=NO;
    NSLog(@"%@",_codeString);
}
-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"view appear");
    if (IsChoosePerson) {
        [self viewUpdate];
    }
}
-(void)viewUpdate
{
    //name
    ABAddressBookRef person=self.chosenPerson;
    NSString *firstname=(__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    if ([firstname length]==0) {
        firstname=@"";
    }
    NSString *lastname=(__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
    if ([lastname length]==0) {
        lastname=@"";
    }
    _codeString=[NSString stringWithFormat:@"%@N:%@;%@;;;\n",_codeString,firstname,lastname];
    NSString *name=[NSString stringWithFormat:@"姓名:%@ %@",firstname,lastname];
    [self stringToTextField:name];
    
    textFieldNumber++;
    
    //organization
    NSString *organization=(__bridge NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
    if ([organization length]) {
        _codeString=[NSString stringWithFormat:@"%@ORG:%@\n",_codeString,organization];
        organization=[@"公司:" stringByAppendingString:organization];
        [self stringToTextField:organization];
        textFieldNumber++;
    }
    
    //phone
    ABMultiValueRef phone=ABRecordCopyValue(person, kABPersonPhoneProperty);
    if((phone!=nil)&&(ABMultiValueGetCount(phone)>0)){
        for (int m=0; m<ABMultiValueGetCount(phone); m++) {
            NSString *aphonevalue=(__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, m);
            NSString *aphonelabel=(__bridge NSString*)ABMultiValueCopyLabelAtIndex(phone, m);
            NSRange rang=NSMakeRange(4, [aphonelabel length]-8);
            aphonelabel=[aphonelabel substringWithRange:rang];
            NSString *aphone=[[aphonelabel stringByAppendingString:@":"]stringByAppendingString:aphonevalue];
            _codeString=[NSString stringWithFormat:@"%@TEL;%@:%@\n",_codeString,aphonelabel,aphonevalue];
            [self stringToTextField:aphone];
            textFieldNumber++;
        }
    }
    
    //email
    ABMultiValueRef email=ABRecordCopyValue(person, kABPersonEmailProperty);
    if ((email != nil)&&(ABMultiValueGetCount(email)>0)) {
        for (int k=0; k<ABMultiValueGetCount(email); k++) {
            NSString *aEmailvalue=(__bridge NSString *)ABMultiValueCopyValueAtIndex(email, k);
            NSString *aEmailLabel=(__bridge NSString *)ABMultiValueCopyLabelAtIndex(email, k);
            NSRange rang=NSMakeRange(4, [aEmailLabel length]-8);
            aEmailLabel=[aEmailLabel substringWithRange:rang];
            _codeString=[NSString stringWithFormat:@"%@EMAIL;%@:%@\n",_codeString,aEmailLabel,aEmailvalue];
            NSString *aEmail=[[aEmailLabel stringByAppendingString:@":"]stringByAppendingString:aEmailvalue];
            [self stringToTextField:aEmail];
            textFieldNumber++;
        }
    }
    
    for (int i=0;i<[textFileds count];i++)
    {
        UITextField *textfield=textFileds[i];
        if (i<textFieldNumber) {
            textfield.hidden=NO;
            NSLog(@"%@",textfield.text);
            [self.view addSubview:textfield];
        }else{
            textfield.hidden=YES;
        }
        
    }
    _codeString=[NSString stringWithFormat:@"%@END:VCARD",_codeString];
    _createImageButtonItem.enabled=YES;
    NSLog(@"%@",_codeString);
    textFieldNumber=0;
    IsChoosePerson=NO;
}
-(void)stringToTextField:(NSString *)string
{
    if (textFieldNumber>=[textFileds count]) {
        [self createTextField:string];
    }
    UITextField *textField=textFileds[textFieldNumber];
    textField.text=string;
}
-(void)createTextField:(NSString *)string{
    if ([string length])
    {
        CGFloat width=280;
        CGFloat height=30;
        UITextField *textField=[[UITextField alloc] initWithFrame:CGRectMake(textFieldOrigin.x, textFieldOrigin.y, width,height)];
        textFieldOrigin.y=textField.frame.origin.y+height;
        textField.borderStyle=UITextBorderStyleRoundedRect;
        textField.enabled=NO;
        [textFileds addObject:textField];
    }
}
#pragma -mark segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"VCardToQRImage"]) {
        [segue.destinationViewController setValue:_codeString forKey:@"receiveString"];
    }
}

#pragma -mark action sheet
- (void)chooseActionSheet
{
    UIActionSheet *PIDSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从通讯录中打开",@"新建联系人", nil];
    PIDSheet.tag=1;
    [PIDSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag==1) {
        switch (buttonIndex) {
            case 0:
                NSLog(@"打开通讯录");
                [self displayAddressBook];
                break;
                
            case 1:
                NSLog(@"新建联系人");
                [self createNewPerson];
                break;
            default:
                NSLog(@"quxiao");
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
                break;
        }
    }
}


#pragma -mark Address Book
-(void)displayAddressBook{
    ABPeoplePickerNavigationController *picker=[[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate=self;
    NSArray *displayedItems=[NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty],[NSNumber numberWithInt:kABPersonEmailProperty],[NSNumber numberWithInt:kABPersonBirthdayProperty],nil];
    picker.displayedProperties = displayedItems;
    
    [self presentViewController:picker animated:YES completion:nil];
}
-(void)createNewPerson{
    ABNewPersonViewController *picker=[[ABNewPersonViewController alloc]init];
    picker.newPersonViewDelegate=self;
    UINavigationController *navigation=[[UINavigationController alloc] initWithRootViewController:picker];
    [self presentViewController:navigation animated:YES completion:nil];
    NSLog(@"create press");
}
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
//after selecting dont display the information
    self.chosenPerson=person;
    IsChoosePerson=YES;
    [self dismissViewControllerAnimated:YES completion:NULL];
    return NO;
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    
    return NO;
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
    NSLog(@"cancl");
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}

-(BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

-(void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    if(person!=NULL){
        NSLog(@"new person");
        self.chosenPerson=person;
        IsChoosePerson=YES;
        [self dismissViewControllerAnimated:YES completion:NULL];
    }else {
        [self dismissViewControllerAnimated:YES completion:NULL];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    }

}


@end
