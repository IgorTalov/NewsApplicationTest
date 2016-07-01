//
//  NewsCell.m
//  News
//
//  Created by Игорь Талов on 29.06.16.
//  Copyright © 2016 Игорь Талов. All rights reserved.
//

#import "NewsCell.h"

@implementation NewsCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(CGFloat) heightForText:(NSString* )text{
    CGFloat offset = 5.0f;
    
    UIFont* font = [UIFont systemFontOfSize:12.f];
    
    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc]init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];//перенос слов
    [paragraph setAlignment:NSTextAlignmentCenter];//расположение текста
    
    //создаем атрибуты
    NSDictionary* attributes = [NSDictionary
                                dictionaryWithObjectsAndKeys:
                                font,NSFontAttributeName,
                                paragraph,NSParagraphStyleAttributeName,nil];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(320 - 2 * offset, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil];
    
    return CGRectGetHeight(rect) + 2 * offset;
}
@end
