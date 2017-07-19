//
//  ViewController.m
//  MapDemo
//
//  Created by Start on 2017/7/18.
//  Copyright © 2017年 het. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
@interface ViewController ()<CLLocationManagerDelegate>
/**定位时间管理类*/
@property(nonatomic,strong)CLLocationManager *locationManager;
/**CLGeocoder*/
@property(nonatomic,strong)CLGeocoder *geocoder;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self location];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - **************** 定位
-(void)location
{
    //1.初始化定位管理
    self.locationManager = [[CLLocationManager alloc]init];
    //1.1 判断是否启用定位服务了
    if (![self.locationManager locationServicesEnabled]) {
        NSLog(@"定位服务没有打开,请打开定位服务");
        return ;
    }
    //1.2 判断用户有没有授权 kCLAuthorizationStatusNotDetermined 用户已经明确禁止使用定位服务
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
        //使用此应用时允许访问用户定位
    }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        //1.3设置代理 设置精度 设置定位频率 启动跟踪定位
        self.locationManager.delegate = self;
        //精确定位
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        CLLocationDistance distance = 10.0;//位置更新的最小距离 只有移动大于这个距离才更新位置信息,默认为kCLDistanceFilterNone：不进行距离限制
        self.locationManager.distanceFilter = distance;
        //开始定位追踪,开始定位后按照用户设置的更新频率执行
        [self.locationManager startUpdatingLocation];
        
    }
    
    
    //2.0 CGGeocoder
    self.geocoder = [[CLGeocoder alloc]init];
    [self getCoordinateByAddress:@"北京"];

}



#pragma mark - **************** 代理方法
//反馈定位信息
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations firstObject];
    //返回当前坐标的位置
    CLLocationCoordinate2D coordinate = location.coordinate;
    NSLog(@"经度 %f 纬度 %f",coordinate.longitude,coordinate.latitude);
    //如果不需要实时定位，使用完毕则可以关闭定位服务
   // [_locationManager stopUpdatingLocation];
    [self getAddressFromLocation:location];
    
}

#pragma mark - **************** 地理方法

//地理编码 根据地名获取地理坐标
-(void)getCoordinateByAddress:(NSString *)addressStr
{
    [self.geocoder geocodeAddressString:addressStr completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placeMark = [placemarks firstObject];
        CLLocation *location = placeMark.location;
        CLLocationCoordinate2D coordinate = location.coordinate;
        NSLog(@"经度 %f 纬度 %f",coordinate.longitude,coordinate.latitude);
    }];
}



//反地理编码
-(void)getAddressFromLocation:(CLLocation *)location
{
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        NSLog(@"%@",placemarks);
        CLPlacemark *placeMark  = [placemarks firstObject];
        NSLog(@"详细信息: %@",placeMark.addressDictionary);
    }];
    
}


#pragma mark - **************** 注释
/*
 http://www.cnblogs.com/kenshincui/p/4125570.html
  1.定位
     CoreLocation进行定位，Colocation可以单独进行使用,和MapKit完全是独立的。
     其中主要包括了定位、地理编码(包括反编码)
   1.1 实现定位的变化使用CLLocationManager类
      首先需要在info.plist配置中进行配置
         requestAlwaysAuthorization 请求获得应用一直使用定位服务授权，
         requestWhenInUseAuthorization 请求获得应用使用时的定位服务授权。
         如果不进行配置则默认情况下应用无法使用定位服务。
   1.2 定位成功后会根据情况频繁调用-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations方法,这个方法返回一组地理位置对象数组每个元素一个CLLocation代表地址位置之所以返回数组是因为有些时候一个位置点可能包含多个位置
  2. 地理编码 CLGeocoder
       2.1 定位服务还包含CLGeocoder类用于处理地理编码和逆地理编码(反地理编码)
           地理编码:根据给定的位置(通常是地名)确定地理坐标(经纬度)
           逆地理编码:可以根据地理坐标(经纬度)确定位置信息
 */

















@end
