//
//  ViewController.m
//  SelectPhotoProject
//
//  Created by zjl on 2021/11/17.
//

#import "ViewController.h"
#import "SelectPhoto.h"

@interface ViewController ()<SelectPhotoDelegate>
@property (nonatomic,strong) UIButton *photoLibaryBtn;
@property (nonatomic,strong) UIButton *cameraBtn;
@property (nonatomic,strong) UIButton *saveBtn;

@property (nonatomic,strong) UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    _photoLibaryBtn = [[UIButton alloc] initWithFrame:CGRectMake(width/2 - 120/2, 100, 120, 60)];
    [_photoLibaryBtn setTitle:@"相册" forState:UIControlStateNormal];
    [_photoLibaryBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:_photoLibaryBtn];
    [_photoLibaryBtn addTarget:self action:@selector(clickPhotoLibary) forControlEvents:UIControlEventTouchUpInside];
    
    _cameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(width/2 - 120/2, CGRectGetMaxY(_photoLibaryBtn.frame) + 20, 120, 60)];
    [_cameraBtn setTitle:@"相机" forState:UIControlStateNormal];
    [_cameraBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:_cameraBtn];
    [_cameraBtn addTarget:self action:@selector(clickCamera) forControlEvents:UIControlEventTouchUpInside];
    
    _saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(width/2 - 120/2, CGRectGetMaxY(_cameraBtn.frame) + 20, 120, 60)];
    [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:_saveBtn];
    [_saveBtn addTarget:self action:@selector(clickSave) forControlEvents:UIControlEventTouchUpInside];
    
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_saveBtn.frame) + 20, width, 200)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
}


- (void)clickPhotoLibary {
    [[SelectPhoto sharedInstance] openPhotoLibary:self];
}

- (void)clickCamera {
    [[SelectPhoto sharedInstance] openCamera:self];
}

- (void)clickSave {
//    [[SelectPhoto sharedInstance] savePhotoToSystemLibary:_imageView.image delegate:self];
    [[SelectPhoto sharedInstance] savePhotoToCustomLibary:_imageView.image libaryName:@"啦啦啦" delegate:self];
}


#pragma mark - SelectPhotoDelegate
- (void)selectPhoto:(UIImage *)image{
    _imageView.image = image;
}

- (void)savePhoto:(BOOL)isSuccess {
    if (isSuccess) {
        NSLog(@"保存成功");
    }else {
        NSLog(@"保存失败");
    }
}
@end
