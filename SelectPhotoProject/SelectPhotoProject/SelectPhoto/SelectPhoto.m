//
//  SelectPhoto.m
//  SelectPhotoProject
//
//  Created by zjl on 2021/11/17.
//

#import "SelectPhoto.h"

#import <UIKit/UIKit.h>
static id _instance;

@interface SelectPhoto()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong,nonatomic) UIImagePickerController *imagePicker;
@property (assign,nonatomic) BOOL isSaving;//是否正在进行保存
@end
@implementation SelectPhoto
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}


- (void)openCamera:(id<SelectPhotoDelegate>)delegate {
    self.delegate = delegate;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [[self topController] presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)openPhotoLibary:(id<SelectPhotoDelegate>)delegate {
    self.delegate = delegate;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.allowsEditing = YES;
    [[self topController] presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
            UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
            if ([self.delegate respondsToSelector:@selector(selectPhoto:)]) {
                [self.delegate selectPhoto:originalImage];
            }
        }
    }else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
        if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
            UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
            if ([self.delegate respondsToSelector:@selector(selectPhoto:)]) {
                [self.delegate selectPhoto:originalImage];
            }
        }
    }
    
    [_imagePicker dismissViewControllerAnimated:YES completion:nil];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [_imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)savePhotoToSystemLibary:(UIImage *)image delegate:(nonnull id<SelectPhotoDelegate>)delegate {
    self.delegate = delegate;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(!error){
        if ([self.delegate respondsToSelector:@selector(savePhoto:)]) {
            [self.delegate savePhoto:YES];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(savePhoto:)]) {
            [self.delegate savePhoto:NO];
        }
    }
}

- (void)savePhotoToCustomLibary:(UIImage *)image libaryName:(NSString *)libary delegate:(nonnull id<SelectPhotoDelegate>)delegate{
    self.delegate = delegate;
    if (_isSaving) {
        return;
    }
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            
            _isSaving = YES;
            NSError *error = nil;
            __block PHObjectPlaceholder *placeholder = nil;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
               placeholder =  [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset;
            } error:&error];
            if (error) {
                _isSaving = NO;
                NSLog(@"保存失败");
                if ([self.delegate respondsToSelector:@selector(savePhoto:)]) {
                    [self.delegate savePhoto:NO];
                }
                return;
            }
            NSString *title = libary;
            PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            PHAssetCollection *createCollection = nil;
            for (PHAssetCollection *collection in collections) {
                if ([collection.localizedTitle isEqualToString:title]) {
                    createCollection = collection;
                    break;
                }
            }
            if (createCollection == nil) {
                __block NSString *createCollectionID = nil;
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    createCollectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
                } error:&error];
                if (error) {
                    _isSaving = NO;
                    if ([self.delegate respondsToSelector:@selector(savePhoto:)]) {
                        [self.delegate savePhoto:NO];
                    }
                    NSLog(@"创建相册失败");
                    return;;
                }else {
                    createCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createCollectionID] options:nil].firstObject;
                }
            }
            PHAssetCollection * assetCollection = createCollection;
            if (assetCollection == nil) {
                
            }
            [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
                PHAssetCollectionChangeRequest *requtes = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                [requtes insertAssets:@[placeholder] atIndexes:[NSIndexSet indexSetWithIndex:0]];
            } error:&error];
            if (error) {
                _isSaving = NO;
                if ([self.delegate respondsToSelector:@selector(savePhoto:)]) {
                    [self.delegate savePhoto:NO];
                }
                NSLog(@"保存图片失败");
                return;
            } else {
                _isSaving = NO;
                if ([self.delegate respondsToSelector:@selector(savePhoto:)]) {
                    [self.delegate savePhoto:YES];
                }
                NSLog(@"保存图片成功");
            }

        } else {
            if ([self.delegate respondsToSelector:@selector(savePhoto:)]) {
                [self.delegate savePhoto:NO];
                NSLog(@"没权限");
            }
        }
    }];
}


- (UIViewController *)topController {
    
    UIViewController *topC = [self topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (topC.presentedViewController) {
        topC = [self topViewController:topC.presentedViewController];
    }
    return topC;
}

- (UIViewController *)topViewController:(UIViewController *)controller {
    if ([controller isKindOfClass:[UINavigationController class]]) {
        return [self topViewController:[(UINavigationController *)controller topViewController]];
    } else if ([controller isKindOfClass:[UITabBarController class]]) {
        return [self topViewController:[(UITabBarController *)controller selectedViewController]];
    } else {
        return controller;
    }
}
@end
