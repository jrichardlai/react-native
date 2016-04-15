/**
 * The examples provided by Facebook are for non-commercial testing and
 * evaluation purposes only.
 *
 * Facebook reserves all rights not expressly granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL
 * FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <XCTest/XCTest.h>

#import <CoreLocation/CLLocationManager.h>
#import "RCTLocationObserver.h"

@interface RCTLocationObserverTests : XCTestCase

@property (nonatomic, readwrite, strong) RCTLocationObserver *locationObserver;

@end

typedef struct {
  double timeout;
  double maximumAge;
  double accuracy;
  double distanceFilter;
} RCTLocationOptions;

@implementation RCTLocationObserverTests

- (void)setUp
{
  [super setUp];

  self.locationObserver = [RCTLocationObserver new];
}

#pragma GCC diagnostic ignored "-Wundeclared-selector"

- (void)callStartObservingWithOptions:(RCTLocationOptions)options {
  SEL startObservingSel = @selector(startObserving:);
  NSMethodSignature *methodSignature = [self.locationObserver methodSignatureForSelector:startObservingSel];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
  [invocation setTarget:self.locationObserver];
  [invocation setSelector:startObservingSel];
  [invocation setArgument:&options atIndex:2];
  [invocation invoke];
}

- (void)callGetCurrentPositionWithOptions:(RCTLocationOptions)options {
  SEL getCurrentPositionSel = @selector(getCurrentPosition:withSuccessCallback:errorCallback:);
  NSMethodSignature *methodSignature = [self.locationObserver methodSignatureForSelector:getCurrentPositionSel];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];

  void (^noOpBlock)() = ^void() {};

  [invocation setTarget:self.locationObserver];
  [invocation setSelector:getCurrentPositionSel];
  [invocation setArgument:&options atIndex:2];
  [invocation setArgument:(__bridge void * _Nonnull)(noOpBlock) atIndex:3];
  [invocation setArgument:(__bridge void * _Nonnull)(noOpBlock) atIndex:4];
  [invocation invoke];
}

- (void)testLocationMangerSettingsCanBeChanged
{
  CLLocationManager *locationManager;
  locationManager = [self.locationObserver valueForKey:@"locationManager"];
  // make sure it is not initialized when nothing happened
  XCTAssertNil(locationManager);

  [self callStartObservingWithOptions:(RCTLocationOptions){
    .accuracy = 10,
    .distanceFilter = 20
  }];
  locationManager = [self.locationObserver valueForKey:@"locationManager"];
  XCTAssertEqual(locationManager.desiredAccuracy, 10);
  XCTAssertEqual(locationManager.distanceFilter, 20);

  [self callStartObservingWithOptions:(RCTLocationOptions){
    .accuracy = 30,
    .distanceFilter = 40
  }];
  locationManager = [self.locationObserver valueForKey:@"locationManager"];
  XCTAssertEqual(locationManager.desiredAccuracy, 30);
  XCTAssertEqual(locationManager.distanceFilter, 40);
}

- (void)testGetCurrentPositionRunsProperly
{
  CLLocationManager *locationManager;
  locationManager = [self.locationObserver valueForKey:@"locationManager"];
  // make sure it is not initialized when nothing happened
  XCTAssertNil(locationManager);

  [self callGetCurrentPositionWithOptions:(RCTLocationOptions){
    .accuracy = 10,
    .distanceFilter = 20
  }];

  locationManager = [self.locationObserver valueForKey:@"locationManager"];
  XCTAssertEqual(locationManager.desiredAccuracy, 10);
  XCTAssertEqual(locationManager.distanceFilter, 20);
}

@end
