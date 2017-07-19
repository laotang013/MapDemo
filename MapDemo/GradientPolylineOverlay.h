//
//  GradientPolylineOverlay.h
//  MapDemo
//
//  Created by Start on 2017/7/19.
//  Copyright © 2017年 het. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
//但这个MKPolyline的构造方法中只接受和坐标相关的值，而轨迹渐变自然要通过速度控制，但传不进去，所以只能重写一个实现<MKOverlay>协议的类
@interface GradientPolylineOverlay : NSObject<MKOverlay>
{
    MKMapPoint *points;
    NSUInteger pointCount;
    NSUInteger pointSpace;
    MKMapRect boundingMapRect;
    pthread_rwlock_t rwLock;
}
//Initialize the overlay with the starting coordinate.
//The overlay's boundingMapRect will be set to a sufficiently large square
//centered on the starting coordinate.
-(id) initWithCenterCoordinate:(CLLocationCoordinate2D)coord;
-(id) initWithPoints:(CLLocationCoordinate2D*)_points velocity:(float*)_velocity count:(NSUInteger)_count;
//Add a location observation. A MKMapRect containing the newly added point
//and the previously added point is returned so that the view can be updated
//int that rectangle. If the added coordinate has not moved far enough from
//the previously added coordinate it will not be added to the list and
//MKMapRectNULL will be returned.
//
-(MKMapRect)addCoordinate:(CLLocationCoordinate2D)coord;
-(void) lockForReading;
//The following properties must only be accessed when holding the read lock
// via lockForReading. Once you're done accessing the points, release the
// read lock with unlockForReading.
//
@property (assign) MKMapPoint *points;
@property (readonly) NSUInteger pointCount;
@property (assign) float *velocity;
-(void) unlockForReading;
@end
