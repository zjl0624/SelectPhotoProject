//
//  SelectPhoto.h
//  SelectPhotoProject
//
//  Created by zjl on 2021/11/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@protocol SelectPhotoDelegate<NSObject>
@optional
- (void)selectPhoto:(UIImage *)image;//选择照片回调
- (void)savePhoto:(BOOL)isSuccess;//保存照片回调
@end
NS_ASSUME_NONNULL_BEGIN

@interface SelectPhoto : NSObject
@property (nonatomic,weak) id<SelectPhotoDelegate> delegate;
+ (instancetype)sharedInstance;
- (void)openCamera:(id<SelectPhotoDelegate>)delegate;//打开相机拍照
- (void)openPhotoLibary:(id<SelectPhotoDelegate>)delegate;//打开相册选择图片
- (void)savePhotoToSystemLibary:(UIImage *)image delegate:(id<SelectPhotoDelegate>)delegate;//保存图片到系统相册
- (void)savePhotoToCustomLibary:(UIImage *)image libaryName:(NSString *)libary delegate:(nonnull id<SelectPhotoDelegate>)delegate;//保存图片到自定义相册
@end

NS_ASSUME_NONNULL_END
