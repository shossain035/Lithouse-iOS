//
//  PHLightListViewCell.m
//  ToDoList
//
//  Created by Shah Hossain on 5/2/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "PHLightListViewCell.h"

@implementation PHLightListViewCell

- (id)initWithCoder : (NSCoder *) aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
    }
    return self;
}

@end
