*基本检验
use "基础数据.dta",clear
vcemway probit turnout3 rj jibenyanglao i.year , cluster(pid year)
margins,dydx(_all)post
vcemway probit turnout3 rj jibenyanglao gender age age2 education wage2 marriage tenure2 hour1 housetype old1 child1 i.year , cluster(pid year)
margins,dydx(_all)post
vcemway probit turnout3 rj jibenyanglao gender age age2 marriage education wage2 tenure2 hour1 housetype old1 child1 i.year i.provcd , cluster(pid year)
margins,dydx(_all)post

//SDID
absdid turnout3, tvar(rj) xvar(gender age age2 marriage education wage2 hour1 tenure2  housetype old1 child1 i.year i.provcd ) 

*更换模型
vcemway biprobit(turnout  rj jibenyanglao child1 old1 housetype gender marriage tenure2 age age2 i.year i.provcd)(turnout3  rj jibenyanglao wage2  hour1 education age age2 education i.year i.provcd ),cluster(pid year)
vcemway heckprobit turnout3  rj jibenyanglao age age2 wage2 tenure2 i.year i.provcd,select (turnout = rj jibenyanglao age age2 wage2 tenure2 gender marriage i.year i.provcd ) cluster(pid year)
*更换样本
*完全平衡面板的检验/剔除跳跃性样本
bysort pid:egen turnout4=sum(turnout3)
gen wave=1 if year==2012
replace wave=2 if year==2014
replace wave=3 if year==2016
drop if wave==3
xtset pid wave
xtbalance , range(1 2)
reghdfe turnout3 rj  jibenyanglao gender age age2 marriage education wage2 tenure2 hour1 housetype old1 child1, absorb(year pid) cluster(pid)
drop if turnout4==2|turnout4==3

reghdfe turnout3 rj  jibenyanglao gender age age2 marriage education wage2 tenure2 hour1 housetype old1 child1, absorb(year pid) cluster(pid)
*更换控制组 
gen insurance1=0 if ownership==3
replace insurance1=1 if jibenyanglao==1
gen ij=insurance1*reform
vcemway probit turnout3 ij insurance1 marriage gender tenure2 age age2 wage2 education child1 old1 hour1 housetype i.year i.provcd , cluster(pid year) 
margins,dydx(_all)post

*平行趋势检验
use "平行趋势.dta",clear
   generate t5 = invttail(9233,0.001)
   vcemway probit turnout3 tj2 tj3 tj4 jibenyanglao  i.year , cluster(pid year)
   margins,dydx(_all)post 
   generate b_1 = _b[tj2]  
   generate se_b_1 = _se[tj2] 
   generate b_1LB = b_1 - t5*se_b_1 
   generate b_1UB = b_1 + t5*se_b_1
   generate b_2 = _b[tj3]  
   generate se_b_2 = _se[tj3] 
   generate b_2LB = b_2 - t5*se_b_2 
   generate b_2UB = b_2 + t5*se_b_2
   generate b_3 = _b[tj4]  
   generate se_b_3 = _se[tj4] 
   generate b_3LB = b_3 - t5*se_b_3 
   generate b_3UB = b_3 + t5*se_b_3
   gen wave=_n*2+2012
   generate b = . 
   generate LB = . 
   generate UB = . 
   replace b = b_1  if wave==2014
   replace b = b_2  if wave==2016
   replace b = b_3  if wave==2018
   replace LB = b_1LB if wave==2014
   replace LB = b_2LB if wave==2016
   replace LB = b_3LB if wave==2018
   replace UB = b_1UB if wave==2014
   replace UB = b_2UB if wave==2016
   replace UB = b_3UB if wave==2018
   keep wave b LB UB
   drop if wave>=2020
   twoway (connected b wave, sort lcolor(navy) mcolor(navy) msymbol(circle_hollow) cmissing(n)) ///
       (rcap LB UB wave, lcolor(navy) lpattern(dash) msize(medium)), ///
        ///
       yline(0, lwidth(vthin) lpattern(dash) lcolor(teal)) ylabel(, labsize(small) angle(horizontal) nogrid)  ///
        ///
       xline(2015, lwidth(vthin) lpattern(dash) lcolor(teal)) xlabel(2014(2)2018, labsize(small)) xmtick(2013(2)2019, nolabels ticks) /// 
       legend(off) ///
       graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
*安慰剂检验1
gen sh=1 if jibenyanglao==1 & turnout3==1
replace sh=0 if turnout3==0
gen rsh=reform*sh
gen os=1 if ownership3==0
replace os=0 if ownership3==1
reghdfe os rsh gender age age2 marriage education wage2 tenure2 hour1 housetype old1 child1 if  (jibenyanglao==1 & turnout3==1)|turnout3==0, absorb(year pid) cluster(pid)
gen sh1=1 if jibenyanglao==0 & turnout3==1
replace sh1=0 if turnout3==0
gen rsh1=reform*sh1
gen jibenyanglao1=1 if jibenyanglao==0
replace jibenyanglao1=0 if jibenyanglao==1
reghdfe  ownership3 rsh1 gender age age2 marriage education wage2 tenure2 hour1 housetype old1 child1 if  (jibenyanglao1==1 & turnout3==1)|turnout3==0, absorb(year pid) cluster(pid)

*安慰剂检验2 
*剔除自主经营
drop if chuangye==1
drop if chuangye2==1
vcemway probit turnout3 rj jibenyanglao gender age age2 marriage education wage2 tenure2 hour1 housetype old1 child1 i.year i.provcd , cluster(pid year)
margins,dydx(_all)post
use "基础数据.dta",clear
*双重差分创业
gen wave=1 if year==2012
replace wave=2 if year==2014
replace wave=3 if year==2016
xtset pid wave
xtbalance , range(1 2)
drop if chuangye==1
vcemway probit turnout3 rj jibenyanglao gender age age2 marriage education wage2 tenure2 hour1 housetype old1 child1 i.year i.provcd , cluster(pid year)
xtreg chuangye2 rj jibenyanglao gender age age2 marriage education wage2 tenure2 hour1 housetype old1 child1 i.year , fe r
*安慰剂检验3
use "安慰剂检验.dta",clear
gen rc=reform*chengjubao
probit turnout3 rc chengjubao gender age age2 marriage education wage2 tenure2 hour1 housetype old1 child1 i.year i.provcd if hour!=. , r
margins,dydx(_all)post


*年龄异质性
gen arj=age2*rj
gen rja=rj*age
vcemway probit turnout3 arj rja jibenyanglao gender  marriage education wage2 tenure2 hour1 housetype old1 child1 i.year i.provcd, cluster(pid year)
margins,dydx(_all)post
gen age1=age/100
gen age3=age2/10000
gen arj1=age3*rj
gen rja1=rj*age1
vcemway probit turnout3 arj1 rja1 jibenyanglao gender  marriage education wage2 tenure2 hour1 housetype old1 child1 i.year i.provcd, cluster(pid year)
margins,dydx(_all)post
vcemway probit turnout3 rj jibenyanglao gender age age2 marriage education wage2 hour1 housetype old1 child1 i.year i.provcd if tenure<=3, cluster(pid year) //新人
margins,dydx(_all)post
vcemway probit turnout3 rj gender age age2 marriage education wage2 tenure2 hour1 housetype old1 child1 i.year i.provcd if(age>=26&age<=50&gender==1)|(age>=26&age<=40&gender==0), cluster(pid year) //中人过渡期外
margins,dydx(_all)post
vcemway probit turnout3 rj  gender age age2 marriage education wage2 tenure2 hour1 housetype old1 child1 i.year i.provcd if(age>50&age<=60&gender==1)|(age>=40&age<=50&gender==0), cluster(pid year) //中人过渡期内
margins,dydx(_all)post
vcemway probit turnout3 rj jibenyanglao gender marriage education wage2  housetype old1 child1  if (age>=60&gender==1)|(age>=50&gender==0) , cluster(year pid) //老人
margins,dydx(_all)post

*地区异质性与努力程度异质性

vcemway probit turnout3 rj jibenyanglao marriage gender age age2 wage2 tenure2 education child1 old1 hour1 housetype i.year  if (provcd==51|provcd==50|provcd==11|provcd==12|provcd==15|provcd==44|provcd==31|provcd==32|provcd==33|provcd==35|provcd==37|provcd==53|provcd==52|provcd==41|provcd==42|provcd==43|provcd==36|provcd==22|provcd==46|provcd==62),cluster(pid year) //城市国有单位工资高于平均工资水平
margins,dydx(_all)post
vcemway probit turnout3 rj jibenyanglao marriage gender age age2 tenure2 wage2 education child1 old1 hour1 housetype i.year  if (provcd==61|provcd==13|provcd==45|provcd==34|provcd==23|provcd==21|provcd==14),cluster(pid year)
margins,dydx(_all)post //城市国有单位工资低于平均工资水平

vcemway probit turnout3 rj jibenyanglao marriage age age2 wage2 tenure2 education child1 old1 hour1 housetype i.year if hour>5.081404,cluster(pid year) //努力程度高
margins,dydx(_all)post
vcemway probit turnout3 rj jibenyanglao marriage age age2 wage2 tenure2 education child1 old1 hour1 housetype i.year if hour<=5.081404,cluster(pid year)  //努力程度低
margins,dydx(_all)post

*企业年金偏好
vcemway probit qiyenianjin2 qiyenianjin age age2  education child1 old1  housetype i.year i.provcd if turnout3==1&jibenyanglao==1,cluster(pid year)
margins,dydx(_all)post
use "工具变量.dta",clear
ivprobit qiyenianjin2 age age2 education child1 old1 housetype i.year i.provcd (qiyenianjin=pension_iv pension_i) if turnout3==1&jibenyanglao==1

 


