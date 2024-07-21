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
  id<MTLRenderPipelineState> _pipelineState;
  id<MTLBuffer> _vertexBuffer;
  float _vertices[9];
}

- (void)buildModel
{
  _vertexBuffer = [_device newBufferWithBytes:_vertices
                                        length:sizeof(_vertices)
                                       options:MTLResourceStorageModeShared];
}

- (void)buildPipeline
{
  NSError* error = nil;
  // read contents of shader.metal file
  NSString* shader = [NSString stringWithContentsOfFile:@"shader.metal"
                                                encoding:NSUTF8StringEncoding
                                                   error:&error];
  id<MTLLibrary> library = [_device newLibraryWithSource:shader options:nil error:&error];
  if (!library) {
    NSLog(@"Failed to create library, error %@", error);
  }

  id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vertex_shader"];
  id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragment_shader"];

  MTLRenderPipelineDescriptor* pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
  pipelineDescriptor.vertexFunction = vertexFunction;
  pipelineDescriptor.fragmentFunction = fragmentFunction;
  pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;

  _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
  if (!_pipelineState) {
    NSLog(@"Failed to create pipeline state, error %@", error);
  }
}

- (void)drawInMTKView:(MTKView *)view
{
  [_metalView setClearColor:(MTLClearColor){ 1.0, 0.0, 0.0, 1.0 }];
  id descriptor = view.currentRenderPassDescriptor;
  id drawable = view.currentDrawable;
  id pipelineState = _pipelineState;
  id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];

  id commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
  [commandEncoder setRenderPipelineState:pipelineState];
  [commandEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
  [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
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

  // set frame size to 1280x720
  self.view.frame = NSMakeRect(0, 0, 1280, 720);

  _vertices[0] = -1.0; _vertices[1] = -1.0; _vertices[2] = 0.0;
  _vertices[3] =  1.0; _vertices[4] = -1.0; _vertices[5] = 0.0;
  _vertices[6] =  0.0; _vertices[7] =  1.0; _vertices[8] = 0.0;

  _metalView = [[MTKView alloc] initWithFrame: NSMakeRect(280, 0, 720, 720)];
  [_metalView setDevice:MTLCreateSystemDefaultDevice()];
  _device = [_metalView device];
  _metalView.delegate = self;

  _commandQueue = [_device newCommandQueue];

  [self buildModel];
  [self buildPipeline];
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
