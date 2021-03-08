//
//  SCInfoViewController.m
//  SpotiCam
//
//  Created by Daniel Luo on 3/5/21.
//

#import "SCInfoViewController.h"

@interface SCInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (nonatomic) NSRange linkRange;
@property (nonatomic) NSLayoutManager *layoutManager;
@property (nonatomic) NSTextContainer *textContainer;
@property (nonatomic) NSTextStorage *textStorage;
@end

@implementation SCInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpLinkLabel];
    self.title =@"Info";
}

// Hyperlink solution from https://stackoverflow.com/a/28519273
- (void)setUpLinkLabel {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Have fun! If you run into any issues or have feedback/comments, please let me know on SpotiCam's GitHub Issues page." attributes:nil];
    NSRange linkRange = NSMakeRange(86, 30);
    self.linkRange = linkRange;
    
    NSDictionary *linkAttributes = @{
        NSForegroundColorAttributeName: [UIColor linkColor],
        NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
    };
    [attributedString setAttributes:linkAttributes range:linkRange];
    self.linkLabel.attributedText = attributedString;
    self.linkLabel.userInteractionEnabled = YES;
    [self.linkLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLabel:)]];
    
    // Handle dynamic label size
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    textContainer.lineFragmentPadding = 0.0;
    textContainer.lineBreakMode = self.linkLabel.lineBreakMode;
    textContainer.maximumNumberOfLines = self.linkLabel.numberOfLines;
    
    self.layoutManager = layoutManager;
    self.textContainer = textContainer;
    self.textStorage = textStorage;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.textContainer.size = self.linkLabel.bounds.size;
}

- (void)handleTapOnLabel:(UITapGestureRecognizer *)tapGesture {
    CGPoint locationOfTouchInLabel = [tapGesture locationInView:tapGesture.view];
    CGSize labelSize = tapGesture.view.bounds.size;
    CGRect textBoundingBox = [self.layoutManager usedRectForTextContainer:self.textContainer];
    CGPoint textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
    CGPoint locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                         locationOfTouchInLabel.y - textContainerOffset.y);
    NSInteger indexOfCharacter = [self.layoutManager characterIndexForPoint:locationOfTouchInTextContainer
                                                            inTextContainer:self.textContainer
                                   fractionOfDistanceBetweenInsertionPoints:nil];
    NSRange linkRange = self.linkRange;
    if (NSLocationInRange(indexOfCharacter, linkRange)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/bolderkat/SpotiCam/issues"]
                                           options:@{}
                                 completionHandler:nil];
    }
}
@end
