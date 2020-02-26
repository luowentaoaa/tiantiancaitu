//
//  ViewController.m
//  chaojicaitu
//
//  Created by luowentao on 2020/2/26.
//  Copyright © 2020 luowentao. All rights reserved.
//

#import "ViewController.h"
#import "LLQuestion.h"
@interface ViewController ()

//所有问题的数据↓
@property(nonatomic,strong)NSArray *questions;

// 默认int 类型 初始值0
@property(nonatomic,assign)int index;

// 记录头像原始的frame
@property(nonatomic,assign)CGRect iconFrame;

@property (weak, nonatomic) IBOutlet UILabel *lblIndex;
@property (weak, nonatomic) IBOutlet UIButton *btnScore;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *bigImage;
@property (weak, nonatomic) IBOutlet UIView *answerView;
@property (weak, nonatomic) IBOutlet UIView *optionsView;





@property(weak,nonatomic)UIButton *cover;

- (IBAction)btnIconClick:(id)sender;
- (IBAction)btnNextClick;
- (IBAction)btnTip;
//用来阴影阴影按钮


- (IBAction)bigImageClick:(id)sender;


@end

@implementation ViewController
-(NSArray *)questions{
    if (_questions==nil){
        NSString *path=[[NSBundle mainBundle]pathForResource:@"questions.plist" ofType:nil];
        NSArray *arrayDict=[NSArray arrayWithContentsOfFile:path];
        NSMutableArray *arrayModel=[NSMutableArray array];
        
        for(NSDictionary *dict in arrayDict){
            LLQuestion *model=[LLQuestion questionWithDict:dict];
            [arrayModel addObject:model];
        }
        _questions=arrayModel;
    }
    return _questions;
}


- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.index=-1;
    [self.answerView setBackgroundColor:[UIColor clearColor]];
    [self nextQuestion];
}


- (IBAction)btnNextClick {
    //移动到下一题
    [self nextQuestion];
}



-(void)nextQuestion{
    if(self.index+1==self.questions.count){
        
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"Title" message:@"过关" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
            [self reStart];
            [self nextQuestion];
            NSLog(@"self =%d",self.index);
          //  [self reStart];
        }]];
        //alert.view.userInteractionEnabled=NO;
        [self presentViewController:alert animated:YES completion:nil];
        NSLog(@"guaoi");
        return;
    }
    self.index++;
    
    //判断是否越界
    //获取当前模型索引数据
    
    LLQuestion *model =self.questions[self.index];
    [self settingData:model];
    //把模型数据设置到对应的控件上
    [self makeAnswerButtons:model];
    
    // 生成待选按钮
    [self makeOptionsButton:model];
    
    
}
-(void)reStart{
    self.index=-1;
}
// 加载数据，把模型数据设置到界面的控件上;
-(void)settingData:(LLQuestion *)model{
    
      self.lblIndex.text=[NSString stringWithFormat:@"%d / %ld",self.index+1,self.questions.count];
      self.lblTitle.text=model.title;
      [self.btnIcon setImage:[UIImage imageNamed:model.icon] forState:UIControlStateNormal];
      
      //4.设置到达最后一题后警用下一题按钮
      
      self.btnNext.enabled=self.index!=self.questions.count-1;
}
-(void)makeAnswerButtons:(LLQuestion *)model{
    // 5.获取当前答案的文字
     // 5.0 清除所有的答案按钮
     
     [self.answerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
     
     // 5.1 获取当前答案文字的个数
     NSUInteger len=model.answer.length;
     //5.2 循环创建答案按钮 有几个文字就创建几个按钮
     CGFloat answerW=35,answerH=35,answerY=0;
     CGFloat margin=10; //间距;
     CGFloat marginLeft=(self.answerView.frame.size.width-(len*answerW)-(len-1)*margin)*0.5;
     
     for(int i=0;i<len;i++){
         UIButton *btnAnswer =[[UIButton alloc]init];
         //设置按钮的背景图
         [btnAnswer setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
         [btnAnswer setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"]  forState:UIControlStateHighlighted];
         
         //计算按钮的x
         CGFloat answerX=marginLeft+i*(answerW+margin);
         btnAnswer.frame=CGRectMake(answerX,answerY, answerW, answerH);
         [btnAnswer setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         [self.answerView addSubview:btnAnswer];
         
         // 为答案按钮注册点击事件；
         [btnAnswer addTarget:self action:@selector(btnAnswerClick:) forControlEvents:UIControlEventTouchUpInside];
     }
}
-(void)btnAnswerClick:(UIButton *)senter{
    // 1.清空当前被点击答案的文字
    [self setAnswerColor:[UIColor blackColor]];
    self.optionsView.userInteractionEnabled=YES;
    for(UIButton *optBtn in self.optionsView.subviews){
        if(senter.tag==optBtn.tag){
            optBtn.hidden=NO;
            break;
        }
    }
    // 2. 在“待选按钮中找到”
    
    [senter setTitle:nil forState:UIControlStateNormal];
    
}
-(void)makeOptionsButton:(LLQuestion *)model{
    //1,清楚所有待选按钮:
    [self.optionsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.optionsView.userInteractionEnabled=YES;
    //2.根据待选文字个数生成
    NSArray *word=model.options;
    //3.根据待选文字循环创建按钮
    
    // 指定每个待选按钮的大小
    CGFloat optionW=35,optionH=35;
    //间距
    CGFloat marginX=10;
    CGFloat marginY=20;
    
    int colums=7;
    int rowlums=3;
    //计算出每行第一个按钮距离左边的距离
    CGFloat marginLeft =self.optionsView.frame.size.width-colums*optionW-(colums-1)*marginX;
    CGFloat marginRight =self.optionsView.frame.size.height-rowlums*optionH-(rowlums-1)*marginY;
    marginRight*=0.5;
    marginLeft*=0.5;
    
    marginRight-=30;
    
    for(int i=0;i<word.count;i++){
        UIButton *btnOpt =[[UIButton alloc]init];
        btnOpt.tag=i;
        [btnOpt setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
        [btnOpt setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
        
        [btnOpt setTitle:word[i] forState:UIControlStateNormal];
        
        [btnOpt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //计算当前按钮的坐标
        int colIdx=i%colums;
        int rowIdx=i/colums;
        CGFloat optionX=marginLeft+colIdx*(marginX+optionW);
        CGFloat optionY=marginRight+rowIdx*(marginY+optionH);
        
        
        btnOpt.frame=CGRectMake(optionX, optionY, optionW, optionH);
        
        [self.optionsView addSubview:btnOpt];
        
        [btnOpt addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}

-(void)optionButtonClick:(UIButton *)sender{
    // 1, 隐藏当前被点击的按钮
    sender.hidden=YES;
    
    // 2.把当前b按钮的文字显示到第一个为空的按钮上
  //  NSString *text=[sender titleForState:UIControlStateNormal];
    NSString *text=sender.currentTitle;
    //2.1
    for (UIButton *answerBtn in self.answerView.subviews){
        //判断按钮上的文字为nil
        if (answerBtn.currentTitle==nil){
            [answerBtn setTitle:text forState:UIControlStateNormal];
            answerBtn.tag=sender.tag;
            break;
        }
    }
    
    BOOL isFULL=YES;
    NSMutableString *userInput=[NSMutableString string];
    
    for(UIButton *btnAnswer in self.answerView.subviews){
        if(btnAnswer.currentTitle==nil){
            isFULL=NO;
            break;
        }
        else{
            [userInput appendString:btnAnswer.currentTitle];
        }
    }
    if (isFULL){
        self.optionsView.userInteractionEnabled=NO;
        // 4.如果答案按钮被填满了 那么就判断用户点击的答案是否与标准答案一致
        // 如果一致就设置答案文字为蓝色，同时在0.5秒跳转下一题
        //如果答案错误设置答案按钮文字为红色；
        LLQuestion *model=self.questions[self.index];
        if([model.answer isEqualToString:userInput]){
            //设置所有答案颜色为蓝色
            [self setAnswerColor:[UIColor blueColor] ];
            
            [self performSelector:@selector(nextQuestion)withObject:nil afterDelay:0.5];
            [self addScore:100];
        }
        else{
            [self setAnswerColor:[UIColor redColor]];
        }
        
    }
}
-(void)addScore:(int)score{
    NSString *str=self.btnScore.currentTitle;
    int currentScore=str.intValue;
    currentScore+=score;
    [self.btnScore setTitle:[NSString stringWithFormat:@"%d",currentScore] forState:UIControlStateNormal];
}
-(void) setAnswerColor:(UIColor *)color{
    for(UIButton *btnAnswer in self.answerView.subviews){
        [btnAnswer setTitleColor:color forState:UIControlStateNormal];
    }
};
//显示大图
- (IBAction)bigImageClick:(id)sender {
    
    self.iconFrame=self.btnIcon.frame;
    
    //1,创建一个大小和self.view一样的按钮，把这个按钮作为一个阴影。
    UIButton *btnCover =[[UIButton alloc]init];
    btnCover.frame=self.view.bounds;
    //设置按钮背景色/
    btnCover.backgroundColor=[UIColor blackColor];
    // 透明度
    btnCover.alpha=0.0;
    [self.view addSubview:btnCover];
    
    //为阴影按钮注册一个单击事件
    [btnCover addTarget:self action:@selector(smallImage) forControlEvents:UIControlEventTouchUpInside];
    
    
    //2.把图片设置到阴影的上面
    // 把图片设置到最上层
    [self.view bringSubviewToFront:self.btnIcon];
    
    self.cover=btnCover;
    
    CGFloat iconW=self.view.frame.size.width;
    CGFloat iconH=self.view.frame.size.width;
    CGFloat iconX=0;
    CGFloat iconY=(self.view.frame.size.height-iconH)/2.0;

    [UIView animateWithDuration:0.7 animations:^{
        
        btnCover.alpha=0.6;
        
        self.btnIcon.frame=CGRectMake(iconX, iconY, iconW, iconH);
    }];
    //3.通过动画把图片放大。

}

-(void )smallImage{
    //1.设置按钮的frame还原，
    [UIView animateWithDuration:0.7 animations:^{
        self.btnIcon.frame=self.iconFrame;
        
        //2.让阴影按钮的透明度变成0
        self.cover.alpha=0.0;
        
    } completion:^(BOOL finished){
        if(finished){
            [self.cover removeFromSuperview];
            self.cover=nil;
        }
    }];

    //3.移除“阴影、”
}

- (IBAction)btnIconClick:(id)sender {
    if (self.cover) [self smallImage];
    else [self bigImageClick: nil];
}
- (IBAction)btnTip{
    [self addScore:-100];
    for(UIButton *btnAnswer in self.answerView.subviews){
        [self btnAnswerClick:btnAnswer];
    }
    LLQuestion *model=self.questions[self.index];
    NSString *firstString=[model.answer substringToIndex:1];
    
    for(UIButton *btnOpt in self.optionsView.subviews){
        if([btnOpt.currentTitle isEqualToString:firstString]){
            [self optionButtonClick:btnOpt];
            break;
        }
    }
}
@end
