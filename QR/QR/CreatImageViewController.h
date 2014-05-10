//
//  CreatImageViewController.h
//  QR
//
//  Created by star on 14-4-25.
//  Copyright (c) 2014年 GraduationDesign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreatImageViewController : UIViewController<UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

//从编辑页面传来的数据
@property (strong, nonatomic) NSString *receiveString;
@property (strong, nonatomic) NSString *receiveMode;



@end
