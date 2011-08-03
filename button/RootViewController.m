//
//  RootViewController.m
//  button
//
//  Created by Jason Gregori on 8/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <pwd.h>

@interface GradientButton : UIButton
@end
@implementation GradientButton
+ (Class)layerClass {
    return [CAGradientLayer class];
}
@end

@interface RootViewController ()
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) UIView *container;
- (void)__save;
@end

@implementation RootViewController
@synthesize button, container;

- (void)__sharedInit {
    self.title = @"Make a Button";
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(__save)] autorelease];
    
    self.container = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease];
    self.container.backgroundColor = [UIColor colorWithWhite:0.867 alpha:1.000];
    
    self.button = [GradientButton buttonWithType:UIButtonTypeCustom];
    self.button.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin
                                    | UIViewAutoresizingFlexibleTopMargin
                                    | UIViewAutoresizingFlexibleRightMargin
                                    | UIViewAutoresizingFlexibleBottomMargin);
    self.button.bounds = CGRectMake(0, 0, 19, 46);
    [self.container addSubview:self.button];
    
    // border
    self.button.layer.borderColor = [UIColor colorWithRed:0.616 green:0.651 blue:0.714 alpha:1.000].CGColor;
    self.button.layer.borderWidth = 1;
    
    // color
//    self.button.backgroundColor = [UIColor whiteColor];
    ((CAGradientLayer *)self.button.layer).colors = [NSArray arrayWithObjects:
                                                     (id)[[UIColor colorWithRed:0.988 green:0.992 blue:0.992 alpha:1.000] CGColor],
                                                     (id)[[UIColor colorWithRed:0.902 green:0.922 blue:0.949 alpha:1.000] CGColor], nil];
    
    // corner radius
    self.button.layer.cornerRadius = 6;
    
    // shadow
    self.button.layer.shadowRadius = 0;
    self.button.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.button.layer.shadowOffset = CGSizeMake(0, 1);
    self.button.layer.shadowOpacity = 0.8;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self __sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self __sharedInit];
    }
    return self;
}

- (void)loadView {
    self.view = self.container;
    
    CGRect frame = self.button.frame;
    frame.origin.y = ceil((self.container.frame.size.height - frame.size.height)/2.0);
    frame.origin.x = ceil((self.container.frame.size.width - frame.size.width)/2.0);
    self.button.frame = frame;
    [self.container addSubview:self.button];
}

- (void)dealloc
{
    self.container = nil;
    self.button = nil;
    [super dealloc];
}

- (void)__save {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    static NSString *saveFolder = nil;
    if (!saveFolder) {
        // get desktop
#if TARGET_IPHONE_SIMULATOR
        NSString *logname = [NSString stringWithCString:getenv("LOGNAME") encoding:NSUTF8StringEncoding];
        struct passwd *pw = getpwnam([logname UTF8String]);
        NSString *home = pw ? [NSString stringWithCString:pw->pw_dir encoding:NSUTF8StringEncoding] : [@"/Users" stringByAppendingPathComponent:logname];
        saveFolder = [NSString stringWithFormat:@"%@/Desktop", home];
#else
        saveFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
#endif
        if (![fm fileExistsAtPath:saveFolder])
        {
            [fm createDirectoryAtPath:saveFolder withIntermediateDirectories:NO attributes:nil error:NULL];
        }
    }
    
    // save image
    CGSize sizeIncludingShadow = self.button.bounds.size;
    sizeIncludingShadow.height += fabs(self.button.layer.shadowOffset.height);
    sizeIncludingShadow.width += fabs(self.button.layer.shadowOffset.width);
    
    UIGraphicsBeginImageContext(sizeIncludingShadow);
    [self.button.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *data = UIImagePNGRepresentation(image);
    
    NSString *imagePathComponent = @"button.png";
    int i = 0;
    while ([fm fileExistsAtPath:[saveFolder stringByAppendingPathComponent:imagePathComponent]]) {
        i++;
        imagePathComponent = [NSString stringWithFormat:@"button %i.png", i];
    }
    
    [fm createFileAtPath:[saveFolder stringByAppendingPathComponent:imagePathComponent]
                contents:data
              attributes:nil];
    
    // tell user it is finished
    self.navigationItem.prompt = @"Saved to \"Desktop\"";
    
    [self.navigationItem performSelector:@selector(setPrompt:) withObject:nil afterDelay:2];
}

@end
