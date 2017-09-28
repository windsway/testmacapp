//
//  ViewController.m
//  testmacapp
//
//  Created by 王猛 on 2017/9/12.
//  Copyright © 2017年 suifeng. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "ContentView.h"
@interface ViewController()<NSTableViewDelegate,NSTableViewDataSource,NSTextFieldDelegate>
@property (weak) IBOutlet NSTableView *MYTableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) BOOL ISPOST;
@property (weak) IBOutlet NSTextField *BaseUrlTextFile;
@property (weak) IBOutlet NSTextField *ResultLabel;
@property (nonatomic, assign) BOOL RequestMethod;

@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _ISPOST = NO;
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    // Do any additional setup after loading the view.
    _MYTableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
 
}

#pragma mark - TEXTFILE
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    NSTextField *myfile = (NSTextField *)control;
    if (myfile == _BaseUrlTextFile) {
        return YES;
    }
    ContentView *subview = (ContentView *)[myfile superview];
    int row = [_MYTableView rowForView:subview];
    [_dataSource replaceObjectAtIndex:row withObject:myfile.stringValue];
    return YES;
}
#pragma mark - tableview
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    ContentView *cellView = (ContentView *)cell;
    cellView.MyContentTextfiel.delegate = self;
    cellView.MyContentTextfiel.stringValue = @"哈哈哈";
    [cellView.DeleBtn setTarget:self];
    [cellView.DeleBtn setAction:@selector(delerow:)];
   
}
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 30;
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _dataSource.count;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    return nil;
}


-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    ContentView *mycell = [tableView makeViewWithIdentifier:@"ContentView" owner:self];
    mycell.MyContentTextfiel.delegate = self;
    mycell.MyContentTextfiel.stringValue = _dataSource[row];
    [mycell.DeleBtn setTarget:self];
    [mycell.DeleBtn setAction:@selector(delerow:)];
    return mycell;
}
//method select
- (IBAction)RequestMethodBtnSelect:(NSPopUpButton *)sender {
    _ISPOST = sender.selectedTag;
}

//添加
- (IBAction)AddparameterBtnSelect:(NSButton *)sender {
    [_dataSource addObject:@""];
    [_MYTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:_dataSource.count-1] withAnimation:NSTableViewAnimationSlideRight];
    
}
//清空
- (IBAction)ClearBtnSelect:(id)sender {
    [_dataSource removeAllObjects];
    _BaseUrlTextFile.stringValue = @"";
    _ResultLabel.stringValue = @"";
    [_MYTableView reloadData];
}
//发送
- (IBAction)sendBtnSelect:(id)sender {
    
    if ([_BaseUrlTextFile.stringValue isEqualToString:@""]) {
        [self alterWarning:@"baseurl不能为空"];
        return;
    }
    if (![self judgeValueTure]) {
        [self alterWarning:@"参数格式不正确"];
        return;
    }
   
    NSDictionary *dic = (NSDictionary *)[self changeData];
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    if (_ISPOST) {
        [manger POST:_BaseUrlTextFile.stringValue parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, NSString *  _Nullable responseObject) {
            _ResultLabel.stringValue = [NSString stringWithFormat:@"%@",responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            _ResultLabel.stringValue = [NSString stringWithFormat:@"%@",error];
        }];
    }
    else
    {
        [manger GET:_BaseUrlTextFile.stringValue parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            _ResultLabel.stringValue = [NSString stringWithFormat:@"%@",responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            _ResultLabel.stringValue = [NSString stringWithFormat:@"%@",error];
        }];
    }
    
    
}
//删除
- (void)delerow:(NSButton *)mybtn
{
    ContentView *subview = (ContentView *)[mybtn superview];
    int row = [_MYTableView rowForView:subview];
    [_MYTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationSlideRight];
    [_dataSource removeObjectAtIndex:row];
}
- (void)alterWarning:(NSString *)message
{
//    CGRect rect = [message boundingRectWithSize:CGSizeMake(0, 20) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [NSFont userFontOfSize:13]}];
//    NSTextField *warningLabel = [[NSTextField alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-rect.size.width)/2, self.view.bounds.size.height/2-20,rect.size.width+50, 50)];
//    [self.view addSubview:warningLabel];
//    warningLabel.stringValue = message;
//    warningLabel.textColor = [NSColor whiteColor];
//    warningLabel.alignment = NSTextAlignmentCenter;
//    warningLabel.font = [NSFont systemFontOfSize:13];
//    warningLabel.backgroundColor = [NSColor blackColor];
//    warningLabel.alphaValue = 1;
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
//        [context setDuration:1];
//        [warningLabel setAlphaValue:.5];
//    } completionHandler:^{
////        [warningLabel removeFromSuperview];
//        NSLog(@"1111");
//    }];
   
    
}
- (BOOL)judgeValueTure
{
    for (int i = 0; i<_dataSource.count; i++) {
        NSString *tmpstr = _dataSource[i];
        if (([tmpstr rangeOfString:@"="].location == NSNotFound)||([[tmpstr componentsSeparatedByString:@"="] count]<2)) {
            return NO;
        }
    }
    return YES;
}
- (id)changeData
{
    NSMutableDictionary *tmpdic = [[NSMutableDictionary alloc] initWithCapacity:0];
    for (int i = 0; i<_dataSource.count; i++) {
        NSString *tmpstr = (NSString *)_dataSource[i];
        NSLog(@"%@",tmpstr);
        if ([tmpstr isEqualToString:@""]) {
            continue;
        }
        NSArray *tmpA = [tmpstr componentsSeparatedByString:@"="];
        [tmpdic setObject:tmpA[1] forKey:tmpA[0]];
        
    }
    if (!tmpdic.allKeys.count) {
        return nil;
    }
    else
    {
        return [NSDictionary dictionaryWithDictionary:tmpdic];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
