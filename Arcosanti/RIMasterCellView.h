//
//  IssueTableOfContentsCellView.h
//  Playground
//
//  Created by Jeff Kunzelman on 6/19/11.
//  Copyright 2011 river.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RIMasterCellView : UITableViewCell
{
    IBOutlet UIImageView *articleImageView1;
    IBOutlet UIImageView *backgroundImageView;
    IBOutlet UILabel *storyTitleLbl;
    IBOutlet UILabel *storyDescLbl;
    IBOutlet UILabel *categoryLbl;
    IBOutlet UILabel *teaserLbl;
    
}

@property (nonatomic, strong) IBOutlet UIImageView *articleImageView1;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet IBOutlet UILabel *storyTitleLbl;
@property (nonatomic, strong) IBOutlet IBOutlet UILabel *storyDescLbl;
@property (nonatomic, strong) IBOutlet IBOutlet UILabel *categoryLbl;
@property (nonatomic, strong) IBOutlet IBOutlet UILabel *teaserLbl;

@end
