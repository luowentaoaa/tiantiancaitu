//
//  LLQuestion.m
//  chaojicaitu
//
//  Created by luowentao on 2020/2/26.
//  Copyright © 2020 luowentao. All rights reserved.
//

#import "LLQuestion.h"

@implementation LLQuestion

-(instancetype)initWithDict:(NSDictionary *)dict{
    if(self =[super init]){
        self.answer=dict[@"answer"];
        self.title=dict[@"title"];
        self.icon=dict[@"icon"];
        self.options=dict[@"options"];
    }
    return self;
}

+(instancetype)questionWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}
@end
