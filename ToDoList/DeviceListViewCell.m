#import "DeviceListViewCell.h"
//#import "CustomCellBackground.h"

@implementation DeviceListViewCell

- (id)initWithCoder : (NSCoder *) aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // change to our custom selected background view
       //CustomCellBackground *backgroundView = [[CustomCellBackground alloc] initWithFrame:CGRectZero];
        //self.selectedBackgroundView = backgroundView;
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
    }
    return self;
}

@end
