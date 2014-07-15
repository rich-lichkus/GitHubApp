//
//  CKMenuTableViewCell.m
//  GitHubClient
//
//  Created by Richard Lichkus on 7/14/14.
//  Copyright (c) 2014 Richard Lichkus. All rights reserved.
//

#import "CKMenuTableViewCell.h"


#define CELL_SEPARATOR_HEIGHT 1

@interface CKMenuTableViewCell ()



@end

@implementation CKMenuTableViewCell

//-(instancetype)initWithFrame:(CGRect)frame{
//    self = [super initWithFrame:frame];
//    NSLog(@"frame");
//    return self;
//}
//
//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    NSLog(@"style");
//    return self;
//}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];

    if(self){
        NSLog(@"Coder");
//        
//        float x = self.textLabel.frame.origin.x;
//        float y = self.frame.size.height-1;
//        float width = self.textLabel.frame.size.width;
//        float height = 1;
//        
//        
//        self.uivSeparator = [[UIView alloc] initWithFrame:CGRectMake(x,y,50,height)];
//                                                                     
//                                                                     
//        self.uivSeparator.backgroundColor = [UIColor whiteColor];
//        [self addSubview:self.uivSeparator];
    }
    return self;
}



@end
