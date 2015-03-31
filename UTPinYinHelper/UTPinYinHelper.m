/*
 Copyright (c) 2015, 唐小喵(ttzzyy001@163.com). All rights reserved.
 Licensed under the MIT license <http://opensource.org/licenses/MIT>
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
 to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions
 of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
 */

// 代码地址: https://github.com/tangzhengyue/UTPinYinHelper

#import "UTPinYinHelper.h"

@interface UTPinYinHelper ()
@property(nonatomic, strong) NSDictionary *pinYinDict;
@end

@implementation UTPinYinHelper

-(id)init
{
    if (self = [super init]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // 读取拼音字典文件放入pinYinDict
            NSString *strPath = [[NSBundle mainBundle] pathForResource:@"pinyinDictUTF8.plist" ofType:nil];
            
            self.pinYinDict = [NSDictionary dictionaryWithContentsOfFile:strPath];
        });
    }
    
    return self;
}

singleton_m(PinYinHelper)

#pragma mark - 拼音搜索实现
// 转换一个字符串为对应的拼音字典。每个汉字对应字典的key，它的拼音（可能多个）作为value
- (NSMutableDictionary *)transStringToPinYins:(NSString *)strIn
{
    if (strIn.length <= 0) {
        return nil;
    }
    
    NSMutableDictionary *pinYins = [NSMutableDictionary dictionary];
    
    for(int i = 0; i < strIn.length; ++i)
    {
        NSRange range;
        for(int i=0; i<strIn.length; i+=range.length) {
            // 遍历获取字符串中的每一个字符
            range = [strIn rangeOfComposedCharacterSequenceAtIndex:i];
            NSString *sChar = [strIn substringWithRange:range];
            
            if (self.pinYinDict[sChar] != nil) {
                NSArray *curPinYin = self.pinYinDict[sChar];
                [pinYins setObject:curPinYin forKey:[NSNumber numberWithInt:i]];
            }else {
                [pinYins setObject:[NSArray arrayWithObject:sChar] forKey:[NSNumber numberWithInt:i]];
            }
        }
    }
    
    return pinYins;
}

// 判断一个字符串与要查询的字符串是否匹配
- (BOOL)isString:(NSString *)strName MatchsKey:(NSString *)strKey IgnorCase:(BOOL)bIgnorCase
{
    if(bIgnorCase) {
        strKey = [strKey lowercaseString];
        strName = [strName lowercaseString];
    }
    
    // 如果当前字符串匹配关键字
    if(strKey.length <= 0 || [strName rangeOfString:strKey].length > 0) {
        return YES;
    }
    
    if(strName.length <= 0) {
        return NO;
    }
    
    // 如果待匹配的字符串不包含汉字或者输入的关键字包含汉字,直接匹配
    if(![self IsIncludeChinese:strName] || [self IsIncludeChinese:strKey]) {
        return NO;
    }
    
    NSMutableDictionary *pinyins = [self transStringToPinYins:strName];
    
    // 开始匹配。如果之前一位匹配的是全拼（单个字符或数字也算是全拼）
    // 则当前位可以匹配全拼，也可以匹配首字母；
    // 如果之前一位匹配的是首字母，则当前位必须匹配首字母
    int i = 0; // 当前匹配map的第几个索引
    
    // 找到第一个首字母匹配的位置，再开始匹配
    NSString *strFirst = [strKey substringWithRange:NSMakeRange(0, 1)];
    while(YES) {
        NSArray *curPinYins = [pinyins objectForKey:[NSNumber numberWithInt:i]];
        
        if([curPinYins count] <= 0) {
            return NO;
        }
        
        for (int j = 0; j < curPinYins.count; j++) {
            NSString *strCurPinYin = [curPinYins objectAtIndex:j];
            if ([strCurPinYin hasPrefix:strFirst]) {
                if ([strCurPinYin hasPrefix:strKey]) {
                    return YES;
                } else if ([self keyString:strKey canMatchPinYins:pinyins atIndex:i matchFirst:NO]) {
                    return YES;
                }
            }
        }
        
        i++;
    }
    
    return NO;
}

// 这里其实就是一个深度优先搜索。
- (BOOL)keyString:(NSString *)strKey canMatchPinYins:(NSMutableDictionary *)pinyins atIndex:(NSUInteger)nIndex matchFirst:(BOOL)bIsMatchFirst
{
    // 依次匹配，直到返回TRUE
    int nKeySize = strKey.length;
    if(nKeySize == 0) {
        return YES;
    }
    
    NSArray *curPinYins = [pinyins objectForKey:[NSNumber numberWithInt:nIndex]];
    
    for (int i = 0; i < curPinYins.count; i++) {
        NSString *strPinYin = [curPinYins objectAtIndex:i];
        int nPinYinSize = strPinYin.length;
        
        // 如果当前全拼能够匹配完剩下的所有关键字，则返回TRUE
        // 因为最后一个字不管前面是否是匹配首字符，都可以完全匹配
        if([strPinYin hasPrefix:strKey]) {
            return YES;
        }
        
        // 先按全拼匹配
        if(!bIsMatchFirst && [strKey hasPrefix:strPinYin]) {
            if ([self keyString:[strKey substringFromIndex:nPinYinSize] canMatchPinYins:pinyins atIndex:nIndex+1 matchFirst:NO]) {
                return YES;
            };
        }
        
        // 匹配首字母
        if ([[strKey substringToIndex:1] isEqualToString:[strPinYin substringToIndex:1]]) {
            if ([self keyString:[strKey substringFromIndex:1] canMatchPinYins:pinyins atIndex:nIndex+1 matchFirst:YES]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)IsIncludeChinese:(NSString *)strIn
{
    NSRange range;
    for(int i=0; i<strIn.length; i+=range.length) {
        // 遍历获取字符串中的每一个字符
        range = [strIn rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *sChar = [strIn substringWithRange:range];
        
        if (self.pinYinDict[sChar] != nil) {
            return YES;
        }
    }
    
    return NO;
}

@end
