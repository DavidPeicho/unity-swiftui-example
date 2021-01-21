#import <Foundation/Foundation.h>
#import "NativeCallProxy.h"

@implementation FrameworkLibAPI

id<NativeCallsProtocol> api = NULL;
+(void) registerAPIforNativeCalls:(id<NativeCallsProtocol>) aApi
{
    api = aApi;
}

@end

/**
 * The methods below bridge the calls from Unity into iOS. When Unity call any
 * of the methods below, the call is forwarded to the iOS bridge using the
 * `NativeCallsProtocol`.
 */
extern "C" {

  void
  sendUnityStateUpdate(const char* state)
  {
    [api onUnityStateChange: state];
  }

  void
  setTestDelegate(DelegateTest delegate)
  {
    [api onSetTestDelegate: delegate];
  }

}
