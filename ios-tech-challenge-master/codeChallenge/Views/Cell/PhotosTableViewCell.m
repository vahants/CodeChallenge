//
//  CustomCell.m
//  codeChallenge
//
//  Created by Nano Suarez on 18/04/2018.
//  Copyright © 2018 Fernando Suárez. All rights reserved.
//

#import "PhotosTableViewCell.h"

@interface PhotosTableViewCell ()

@property (weak, nonatomic) IBOutlet CHImageView *imageCell;
@property (weak, nonatomic) IBOutlet UILabel *imageTitleCell;
@property (weak, nonatomic) IBOutlet UILabel *imageSubtitleCell;

@end

@implementation PhotosTableViewCell

- (void)configureCell:(CHFlickrPhoto *)photo {
    self.imageTitleCell.text = photo.title;
    self.imageSubtitleCell.text = photo.descriptionPhoto;
    
    _imageSubtitleCell.numberOfLines = 2;
//    [_imageSubtitleCell sizeToFit];
    
    UIImage* image = [UIImage imageNamed:@"defaultPhoto"];
    [self.imageCell setImageWithPhoto:photo size:PhotoSizeThumbnail defautImage:image];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.contentView.alpha = highlighted ? 0.7 : 1;
}

@end
