//
//  NSStatusBarWindow.h
//  NewBezelServices
//
//  Created by Kelian on 29/12/2016.
//  Copyright © 2016 OSXHackers. All rights reserved.
//

#import <AppKit/NSWindow.h>

@class NSMapTable, NSStatusItem, NSVisualEffectView;

@interface NSStatusBarWindow : NSWindow
{
    NSStatusItem *_statusItem;
    NSVisualEffectView *_effectView;
    NSMapTable *_viewToSelectionViewDictionary;
}

@property(retain) NSVisualEffectView *effectView; // @synthesize effectView=_effectView;
@property NSStatusItem *statusItem; // @synthesize statusItem=_statusItem;
- (BOOL)_hasActiveControls;
- (void)flushWindow;
- (BOOL)_ignoreForFullScreenTransition;
- (int)_semanticContext;
- (void)_automateLiveResize;
- (BOOL)canHide;
- (BOOL)worksWhenModal;
- (struct CGPoint)convertBaseToScreen:(struct CGPoint)arg1;
- (void)sendEvent:(id)arg1;
- (void)_noticeStatusBarVisibilityChangeIfNecessary;
- (void *)windowRef;
- (struct CGRect)constrainFrameRect:(struct CGRect)arg1 toScreen:(id)arg2;
- (void)setFrame:(struct CGRect)arg1 display:(BOOL)arg2;
- (void)_setWindowTag;
- (void)_updateManagedDisplay;
- (id)_bestScreenByGeometry;
- (BOOL)_showToolTip;
- (void)_setWindowNumber:(long long)arg1;
- (void)setStatusBarView:(id)arg1;
- (void)_testForAllowsVibrancy;
- (void)dealloc;
- (void)setSelection:(BOOL)arg1 inRect:(struct CGRect)arg2 ofView:(id)arg3;
- (void)_updateAppearanceAndMaterialOfVisualEffectView;
- (void)_activeMenuBarDrawingStyleDidChange;
- (id)initWithContentRect:(struct CGRect)arg1;
- (id)accessibilityChildrenAttribute;
- (BOOL)accessibilityIsIgnored;
- (id)accessibilityHitTest:(struct CGPoint)arg1;

@end
