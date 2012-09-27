//
//  SNWeiboSendWeiboViewController.m
//  SinaWeiboClient
//
//  Created by Lion User on 20/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNWeiboSendWeiboViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SNWeiboEngine.h"


#define ADD_IMAGE_FROM_ALBUM @"从图片库添加"
#define ADD_IMAGE_FROM_CAMERA @"拍照"
#define POST_SUCCEED_SURE @"确定"
#define MAX_IMAGE_WIDTH 90.0f
#define MAX_CHARACTERS_COUNT 140


@interface SNWeiboSendWeiboViewController () <UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,UITextViewDelegate>
@property (nonatomic,weak) IBOutlet UIView *textViewContainer;
@property (nonatomic,weak) IBOutlet UITextView *textView;
@property (nonatomic,weak) IBOutlet UIButton *cancelButton;
@property (nonatomic,weak) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (nonatomic,strong) UIActionSheet *actionSheet;
@property (nonatomic,strong) UIAlertView *alertView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *limitCount;
@property (nonatomic) BOOL hasImage;
@property (nonatomic,strong) UIImage *postImage;
@property (nonatomic) UIStatusBarStyle previouSstatusBarStyle;
@end

@implementation SNWeiboSendWeiboViewController
@synthesize  textView  = _textView;
@synthesize textViewContainer = _textViewContainer;
@synthesize viewController = _viewController;
@synthesize cancelButton = _cancelButton;
@synthesize sendButton = _sendButton;
@synthesize actionSheet = _actionSheet;
@synthesize alertView = _alertView;
@synthesize imageView = _imageView;
@synthesize limitCount = _limitCount;
@synthesize addImageButton = _addImageButton;
@synthesize hasImage = _hasImage;
@synthesize postImage = _postImage;
@synthesize previouSstatusBarStyle = _previousStatusBarStyle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textViewContainer.backgroundColor = [UIColor clearColor];
    self.textView.backgroundColor = [UIColor clearColor];
    self.hasImage=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSucceedPostStatus) name:SINA_DIDSUCCEEDPOSTUPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSucceedPostStatus) name:SINA_DIDSUCCEEDPOSTUPLOAD object:nil];
    self.textView.delegate=self;
    self.textView.keyboardType=UIKeyboardTypeTwitter;
    [self.textView becomeFirstResponder];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.previouSstatusBarStyle=[UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    UIImage *image=[[UIImage imageNamed:@"DETweetCancelButtonPortrait.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];

    [self.cancelButton setBackgroundImage:image forState:UIControlStateNormal];

        

    UIImage *image2=[[UIImage imageNamed:@"DETweetSendButtonPortrait.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    [self.sendButton setBackgroundImage:image2 forState:UIControlStateNormal];
    [self.addImageButton setBackgroundImage:image2 forState:UIControlStateNormal];

}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_DIDSUCCEEDPOSTUPDATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_DIDSUCCEEDPOSTUPLOAD object:nil];
    [self setAddImageButton:nil];
    [self setImageView:nil];
    [self setLimitCount:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:self.previouSstatusBarStyle animated:YES];
    [super viewDidDisappear:animated];
}


-(void)didSucceedPostStatus
{
    UIAlertView *succeedAlertView=[[UIAlertView alloc] initWithTitle:nil message:@"Send Succeed" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    
    [succeedAlertView show];
    
}

- (IBAction)didClickCancelButton:(id)sender {
    NSLog(@"cancel clicked");
    [self.viewController dismissModalViewControllerAnimated:YES];
}
- (IBAction)didClickSendButton:(id)sender {
    NSString *text=self.textView.text;
    if (text.length<=0) {
        UIAlertView *textAlertView=[[UIAlertView alloc] initWithTitle:nil message:@"输入不能为空！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [textAlertView show];
        return;
    }
    if ([self countTextLength:text]>MAX_CHARACTERS_COUNT) {
        UIAlertView *textAlertView=[[UIAlertView alloc] initWithTitle:nil message:@"输入字数不能超过限定长度！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [textAlertView show];
        return;

    }
    
    if (self.hasImage) {
        [[SNWeiboEngine getInstance] postStatus:text withImage:self.postImage];
    }else {
        [[SNWeiboEngine getInstance] postStatus:text withImage:nil];
    }
    
    
}

- (IBAction)didClickAddImageButton:(id)sender {

    if (self.alertView) {
        if (!self.alertView.visible) {
            [self.alertView show];
        }
        
    }else {
        self.alertView=[[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:ADD_IMAGE_FROM_ALBUM,ADD_IMAGE_FROM_CAMERA, nil];
        [self.alertView show];
    }

    
}

-(void)addImageFromAlbum
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSArray *mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        if ([mediaTypes containsObject:(NSString *)kUTTypeImage]) {
            UIImagePickerController *picker=[[UIImagePickerController alloc] init];
            picker.delegate=self;
            picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            picker.mediaTypes=[NSArray arrayWithObject:(NSString *)kUTTypeImage];
            picker.allowsEditing=YES;
            [self presentModalViewController:picker animated:YES];
        }
    }
}

-(void)addImageFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([mediaTypes containsObject:(NSString *)kUTTypeImage]) {
            UIImagePickerController *picker=[[UIImagePickerController alloc]   init];
            picker.delegate=self;
            picker.sourceType=UIImagePickerControllerSourceTypeCamera;
            picker.mediaTypes=[NSArray arrayWithObject:(NSString *)kUTTypeImage];
            picker.allowsEditing=YES;
            [self presentModalViewController:picker animated:YES];
        }
    }else {
        UIAlertView *cameraAlertView=[[UIAlertView alloc] initWithTitle:nil message:@"本设备不支持拍照" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [cameraAlertView show];
    }
}

-(NSInteger)countTextLength:(NSString *)text
{
    if (text==nil||([text length]==0)) {
        return 0;
    }
    double sum=0;
    NSInteger textLength=0;
    NSString *temp;
    textLength=text.length;
    for (NSInteger i=0; i<textLength; i++) {
        temp=[text substringWithRange:NSMakeRange(i, 1)];
        if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding]==3) {
            sum++;
        }else {
            sum+=0.5;
        }
    }
    return ceil(sum);
}

-(void)textViewDidChange:(UITextView *)textView
{
    NSInteger textLength=[self countTextLength:textView.text];
    NSInteger availableCharactersCount=MAX_CHARACTERS_COUNT-textLength;
    NSString *availCharactersString=[NSString stringWithFormat:@"%d字",availableCharactersCount];
    self.limitCount.text=availCharactersString;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice=[alertView buttonTitleAtIndex:buttonIndex];
    if ([choice isEqualToString:ADD_IMAGE_FROM_ALBUM]) {
        [self addImageFromAlbum];
        
    }else if ([choice isEqualToString:ADD_IMAGE_FROM_CAMERA]) {
        [self addImageFromCamera];
        
    }else if ([choice isEqualToString:POST_SUCCEED_SURE]) {
        [self.viewController dismissModalViewControllerAnimated:YES];
    }
}



-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) {
        image=[info objectForKey:UIImagePickerControllerOriginalImage];
    }
    if (image) {
        self.imageView.image=image;
        CGRect frame=self.imageView.frame;
        while (frame.size.width>MAX_IMAGE_WIDTH) {
            frame.size.width/=2;
            frame.size.height/=2;
        }
        self.imageView.frame=frame;
        self.postImage=image;
        self.hasImage=YES;
    }
    [self dismissModalViewControllerAnimated:YES];
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
