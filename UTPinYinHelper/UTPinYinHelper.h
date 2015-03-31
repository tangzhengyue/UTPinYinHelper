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

#import <Foundation/Foundation.h>
#import "SingletonMacro.h"

@interface UTPinYinHelper : NSObject

singleton_h(PinYinHelper)

// 判断一个字符串与要查询的字符串是否匹配
- (BOOL)isString:(NSString *)strName MatchsKey:(NSString *)strKey IgnorCase:(BOOL)bIgnorCase;

@end
