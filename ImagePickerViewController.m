//
//  ImagePickerViewController.m
//  Pixel Styles
//
//  Created by William Markezana on 09/03/14.
//  Copyright (c) 2014 RGB Styles. All rights reserved.
//

#import "ImagePickerViewController.h"

#import "GCDAsyncUdpSocket.h"
#import "LiveViewController.h"
#import "UIImage+ScaledToSize.h"


@interface ImagePickerViewController ()
{
    LiveViewController *liveViewController;
    GCDAsyncUdpSocket *udpSocket;
}


@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ImagePickerViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.livePreviewAlpha = 0.0;
    liveViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"liveView"];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImage:)];
    tapRecognizer.numberOfTouchesRequired = 1;
    [_imageView addGestureRecognizer:tapRecognizer];
    
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [udpSocket setPreferIPv4];
    
    _imageView.layer.shadowRadius = 4.0;
    _imageView.layer.masksToBounds = NO;
    _imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _imageView.clipsToBounds = NO;
    _imageView.layer.shadowOpacity = 0.6;
    _imageView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = _mode.name;
}

- (void)didUpdateLivePreview:(NSNotification *)notification
{
    [super didUpdateLivePreview:notification];
    
    [liveViewController updateWithImage:self.livePreviewImage];
    _imageView.image = liveViewController.image;
}

- (void)didTapImage:(UITapGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        [picker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
        [self presentViewController:picker animated:YES completion:Nil];
    }
}

- (NSData *)dataOfCGImage:(CGImageRef)image
{
    NSInteger width = CGImageGetWidth(image);
    NSInteger height = CGImageGetHeight(image);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    uint8_t *rawData = malloc(height * width * 4);
    NSInteger bytesPerPixel = 4;
    NSInteger bytesPerRow = bytesPerPixel * width;
    NSInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGContextRelease(context);
    
    uint8_t *data = malloc(height * width * 3);
    int dataPtr = 0;
    for (int i = 0; i < height * width * 4; i+= 4) {
        data[dataPtr++] = rawData[i];
        data[dataPtr++] = rawData[i+1];
        data[dataPtr++] = rawData[i+2];
    }
    return [NSData dataWithBytes:data length:height * width * 3];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    if(!img) img = [info objectForKey:UIImagePickerControllerOriginalImage];

    NSData *data = [self dataOfCGImage:[img resizedImage:CGSizeMake(_service.width, _service.height) interpolationQuality:kCGInterpolationNone].CGImage];
    [udpSocket sendData:data toHost:_service.ip port:_mode.port withTimeout:0 tag:0];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
