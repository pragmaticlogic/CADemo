//
//  KeyPathAnimationView.m
//  CADemo
//
//  Created by Paul Franceus on 7/23/11.
//
//  MIT License
//
//  Copyright (c) 2011 Paul Franceus
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "KeyPathAnimationView.h"
@interface KeyPathAnimationView () 

@property(nonatomic, retain) NSMutableArray *touchPoints;
@property(nonatomic, retain) UITapGestureRecognizer *tapRecognizer;
@property(nonatomic, retain) CALayer *movingLayer;

@end

@implementation KeyPathAnimationView

@synthesize touchPoints = touchPoints_;
@synthesize tapRecognizer = tapRecognizer_;
@synthesize movingLayer = movingLayer_;

- (void)awakeFromNib {
  self.touchPoints = [NSMutableArray array];
  tapRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(viewTapped)];
  [self addGestureRecognizer:tapRecognizer_];
}

- (void)dealloc {
  [touchPoints_ release];
  [tapRecognizer_ release];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
  for (NSValue *loc in touchPoints_) {
    CGPoint location = [loc CGPointValue];
    [@"+" drawAtPoint:location withFont:[UIFont systemFontOfSize:24]];
  }
}
                                         
#pragma mark - 
#pragma mark Event handling

- (void)viewTapped {
  CGPoint location = [tapRecognizer_ locationInView:self];
  [touchPoints_ addObject:[NSValue valueWithCGPoint:location]];
  [self setNeedsDisplay];
}

#pragma mark -
#pragma mark KeyPathAnimationViewController methods

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
  [touchPoints_ removeAllObjects];
  [self setNeedsDisplay];
}

- (void)runAnimation {
  NSInteger points = [touchPoints_ count];
  if (points > 0) {
    CALayer *layer = self.layer;
    
    if (self.movingLayer) {
      [self.movingLayer removeFromSuperlayer];
    }
    self.movingLayer = [CALayer layer];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Wheel" ofType:@"png"];
    CGImageRef imageRef = [UIImage imageWithContentsOfFile:path].CGImage;
    self.movingLayer.contents = (id)imageRef;
    self.movingLayer.bounds = CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    self.movingLayer.position = [[touchPoints_ objectAtIndex:0] CGPointValue];
    
    [layer addSublayer:self.movingLayer];

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.removedOnCompletion = YES;
    animation.duration = 0.3 * points;
    animation.calculationMode = kCAAnimationCubicPaced;
    animation.rotationMode = kCAAnimationRotateAuto;
    animation.values = touchPoints_;
    animation.delegate = self;
    
    [self.movingLayer addAnimation:animation forKey:@"followPath"];
    
    // Make sure the animation sticks after it's done.
    self.movingLayer.position = [[touchPoints_ lastObject] CGPointValue];
  }  
}

@end
