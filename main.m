#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <QuartzCore/CAMetalLayer.h>
#import <objc/runtime.h>


// import mtlcommandqueue

@interface MainViewController : NSViewController <MTKViewDelegate>
- (void)viewDidLoad;
@end

@implementation MainViewController
{
  MTKView *_metalView;
  id<MTLDevice> _device;
  id<MTLCommandQueue> _commandQueue;
  float _redLevel;
}

- (void)drawInMTKView:(MTKView *)view
{
  _redLevel += 0.01;
  if (_redLevel > 1.0) {
    _redLevel = 0.0;
  }
  [_metalView setClearColor:(MTLClearColor){ _redLevel, 0.0, 0.0, 1.0 }];
  id descriptor = view.currentRenderPassDescriptor;
  id drawable = view.currentDrawable;
  id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];

  id<MTLCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
  [commandEncoder endEncoding];
  [commandBuffer presentDrawable:drawable];
  [commandBuffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  _redLevel = 0.0;
  _metalView = [[MTKView alloc] initWithFrame:self.view.frame];
  [_metalView setDevice:MTLCreateSystemDefaultDevice()];
  _device = [_metalView device];
  [_metalView setClearColor:(MTLClearColor){ _redLevel, 0.0, 0.0, 1.0 }];
  _metalView.delegate = self;

  _commandQueue = [_device newCommandQueue];

  [self.view addSubview:_metalView];
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property (nonatomic, strong) NSWindow* window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
  // create a 1280x720 window and present it
  NSRect frame = NSMakeRect(0, 0, 1280, 720);
  self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:(NSWindowStyleMaskTitled |
                                                         NSWindowStyleMaskClosable |
                                                         NSWindowStyleMaskResizable |
                                                         NSWindowStyleMaskMiniaturizable)
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
  [self.window setTitle:@"Metal Window"];
  [self.window makeKeyAndOrderFront:nil];
  [self.window orderFrontRegardless];

  MainViewController* viewController = [[MainViewController alloc] init];
  [self.window setContentViewController:viewController];
}
@end

int main(int argc, const char * argv[]) {
    AppDelegate* delegate = [[AppDelegate alloc] init];
    NSApplication* application = [NSApplication sharedApplication];
    [application setDelegate:delegate];
    [application run];

    return 0;
}
