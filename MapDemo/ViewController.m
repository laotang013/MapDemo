//
//  ViewController.m
//  MapDemo
//
//  Created by Start on 2017/7/18.
//  Copyright © 2017年 het. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "KCAnnotation.h"
@interface ViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>
/**定位时间管理类*/
@property(nonatomic,strong)CLLocationManager *locationManager;
/**CLGeocoder*/
@property(nonatomic,strong)CLGeocoder *geocoder;
/**地图控件*/
@property(nonatomic,strong)MKMapView *mapView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //案例1
    //[self location];
    //案例2
    //初始化UI
    [self setupSubViews];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - **************** 初始化控件
-(void)setupSubViews
{
    CGRect rect = [UIScreen mainScreen].bounds;
    self.mapView = [[MKMapView alloc]initWithFrame:rect];
    [self.view addSubview:self.mapView];
    //设置代理
    self.mapView.delegate = self;
    //请求定位服务
    self.locationManager = [[CLLocationManager alloc]init];
    if (![CLLocationManager locationServicesEnabled]||[CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    //设置用户追踪
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    //设置地图类型
    self.mapView.mapType = MKMapTypeStandard;
    self.geocoder = [[CLGeocoder alloc]init];
    
    //添加大头针
    [self addKCAnnotation:CLLocationCoordinate2DMake(39.95, 116.35) title:@"中国" subTitle:@"北京" image:@"dingweidian_map"];
    [self addKCAnnotation:CLLocationCoordinate2DMake(39.35, 116.35) title:@"美国" subTitle:@"自由女神" image:@"icon_warnning"];
}

-(void)addKCAnnotation:(CLLocationCoordinate2D )location2D
                 title:(NSString *)title
              subTitle:(NSString *)subtitle
              image:(NSString *)imageStr
{
    KCAnnotation *annotion = [[KCAnnotation alloc]init];
    annotion.coordinate = location2D;
    annotion.title = title;
    annotion.subtitle = subtitle;
    annotion.image = [UIImage imageNamed:imageStr];
    [self.mapView addAnnotation:annotion];
    
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



//反地理编码 根据经纬度获取位置信息
-(void)getAddressFromLocation:(CLLocation *)location
{
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        //NSLog(@"%@",placemarks);
        CLPlacemark *placeMark  = [placemarks firstObject];
        NSLog(@"详细信息: %@",placeMark.addressDictionary);
    }];
}

#pragma mark - **************** mapKit
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(nonnull MKUserLocation *)userLocation
{
    // 设置地图显示范围(如果不进行区域设置会自动显示区域范围并指定当前用户位置为地图中心点)
    //MKCoordinateSpan span=MKCoordinateSpanMake(0.01, 0.01);
   //MKCoordinateRegion region=MKCoordinateRegionMake(userLocation.location.coordinate, span);
    //[_mapView setRegion:region animated:true];
    
    NSLog(@"userLocation:%@",userLocation);
    [self getAddressFromLocation:userLocation.location];
}

//自定义大头针 显示大头针时触发，返回大头针视图
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //由于当前位置的标注也是一个大头针，所以此时需要判断,此代理方法返回nil返回默认的大头针
    if ([annotation isKindOfClass:[KCAnnotation class]]) {
        static NSString *key1 = @"AnnotationKey1";
        MKAnnotationView *annottationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:key1];
        if (!annottationView) {
            annottationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:key1];
            annottationView.canShowCallout = true;//允许交互点击
            //定义详情视图偏移量
            annottationView.calloutOffset = CGPointMake(0, 1);
            annottationView.leftCalloutAccessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"location_marker"]];//定义详情左视图
        }
        annottationView.annotation = annotation;
        //设置大头针的图片
        annottationView.image = ((KCAnnotation *)annotation).image;
        return annottationView;
    }else
    {
        return nil;
    }
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
           逆地理编码:可以根据地理坐标(经纬度)确定位置信息、
  3.地图
     两种方式：一种直接利用Mapkit框架进行地图开发，利用这种方式可以对地图进行精准的控制。另一种方式直接调用
             苹果官方自带的地图应用，主要用于一些简单的地图应用无法进行精确的控制。
       3.1 MapKit:
         地图展示控件MKMapView
         - (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation;用户位置发生改变时触发(第一次定位到用户位置时也触发该方法); 调用频率相当频繁
      3.2:大头针：只要一个NSObject类实现MKAnnotation协议就可以作为一个大头针，通过会重写协议
                 coordinate（标记位置）、title（标题）、subtitle（子标题）三个属性
        3.3 自定义大头针视图:
             - (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;方法可以返回一个大头针视图，只要实现这个方法并在这个方法中定义一个大头针视图MKAnnotationView对象并设置相关属性就可以改变默认大头针的样式。
 */

















@end
