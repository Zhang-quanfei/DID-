******************由于中国企业污染排放数据库，论文作者只有使用权，不具有所有权并已签订保密协定，不能扩散，作者是依托其他团队购买的，因此没有公开
******************如果读者感兴趣可以通过email 跟作者直接联系（联系方式见论文正文），谢谢。

******表1******
use 匹配后千家企业.dta
set more off
keep(so2_emission post_treatment treatment lny lnEC tfp_op lnP lnK2 soe)
order(so2_emission post_treatment treatment lny lnEC tfp_op lnP lnK2 soe)
outreg2 using 描述性统计.doc, replace sum(log)

use 未匹配千家企业.dta
sort treatment
drop if year>2005
by treatment: outreg2 using 描述性统计2.doc, replace sum(detail) eqkeep(N mean sd min max)


******附表2******
forvalue i=2002/2010{
use 未匹配千家企业.dta
drop if year!=`i' //只对当年进行匹配
g match=0 if treat==1 
g matchmark=. 

logit treatment lny tfp_op lnEC, robust
predict pscore if e(sample),pr
destring cic2,force replace
gen pscore2=cic2*10 + pscore //行业上选的两位代码
set seed 0001
gen tmp = runiform()
sort tmp
psmatch2 treatment , out(so2_emission) pscore(pscore2) common noreplacement n(1) cal(0.05)
replace match=1 if treat==0 & _weight!=.
replace matchmark=_n1 if _treat==1
save 匹配`i',replace
}
use 匹配2002.dta
forvalue i=2003/2010{
use 匹配`i'.dta
if year==`i' {save 匹配后千家企业.dta,replace
             }
     else         
            {append using 匹配后千家企业.dta,replace
			}
}

**关于附表2标准偏差减少幅度（%）采用以下的结果
pstest lny lnEC tfp_op lnP lnK2 soe, both
*关于两组匹配前后差异的显著性检验，我们未采用给定的pstest的结果计算，
*因为我们是在行业年的基础上进行的匹配，所以需要在行业以及年的范围内进行差异性显著性检验
*匹配前
use 未匹配千家企业.dta,clear
reg lnK  treatment i.year i.cic_adj ,vce(cluster cic_adj)
reg lny  treatment i.year i.cic_adj ,vce(cluster cic_adj)
reg lnEC  treatment i.year i.cic_adj ,vce(cluster cic_adj)
reg lnP  treatment i.year i.cic_adj ,vce(cluster cic_adj)
reg soe  treatment i.year i.cic_adj ,vce(cluster cic_adj)
*匹配后
use  匹配后千家企业.dta,clear
drop if treatment==1 & matchmark==.  //剔除未匹配成功的实验组
drop if match==.
drop match matchmark
save ,replace
reg lnK  treatment i.year i.cic_adj ,vce(cluster cic_adj)
reg lny  treatment i.year i.cic_adj ,vce(cluster cic_adj)
reg lnEC  treatment i.year i.cic_adj ,vce(cluster cic_adj)
reg lnP  treatment i.year i.cic_adj ,vce(cluster cic_adj)
reg soe  treatment i.year i.cic_adj ,vce(cluster cic_adj)
**********


******表2******
use 未匹配千家企业.dta
reghdfe so2_emission post_treatment, absorb(idnew year) cluster(cic_adj) 
outreg2 using "基本回归.xls", addtext(Firm FE, YES, Year FE, YES) replace se  nocons  dec(5)
reghdfe so2_emission post_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic_adj)    
outreg2 using "基本回归.xls", addtext(Firm FE, YES, Year FE, YES) append se  nocons  dec(5)

use 匹配后千家企业.dta
reghdfe so2_emission post_treatment, absorb(idnew year) cluster(cic_adj) 
outreg2 using "基本回归.xls", addtext(Firm FE, YES, Year FE, YES) replace se  nocons  dec(5)
reghdfe so2_emission post_treatment lny lnEC tfp_op lnK2 lnP soe , absorb(idnew year) cluster(cic_adj)    
outreg2 using "基本回归.xls", addtext(Firm FE, YES, Year FE, YES) append se  nocons  dec(5)


******图8******
use 匹配后千家企业.dta
xi: char year[omit] "2005"
xi char i.year[omit] 2005
local i = 2002
while `i' <= 2004{
gen treat_`i'=treatment*_Iyear_`i'
local i = `i' + 1
}
local i = 2006
while `i' <= 2010{
gen treat_`i'=treatment*_Iyear_`i'
local i = `i' + 1
}
reghdfe so2_emission treat_* lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic_adj)
outreg2 using "平行趋势.xls", append se nocons dec(5)

est store WW
matrix A=J(9,4,0)
forvalues i=1/10{
local j=`i'+2001
capture scalar a`i'=_b[treat_`j'] 
capture  scalar b`i'=(_b[treat_`j']+invttail(e(df_r),0.05)*_se[treat_`j'])
capture  scalar c`i'=(_b[treat_`j']-invttail(e(df_r),0.05)*_se[treat_`j'])
capture   mat A[`i',1]=`j'
capture  mat A[`i',2]=a`i'
capture  mat A[`i',3]=b`i'
capture  mat A[`i',4]=c`i'
}
mat2txt,matrix(A) saving(so2_emission) replace 
insheet using so2_emission.txt,clear
keep c1 c2 c3 c4
rename c1 year
rename c2 treat_deregu
rename c3 up
rename c4 low
drop in 4
save so2_emission.dta,replace
twoway (connected treat_deregu year,msymbol(T)) (line up year,lpattern(shortdash)) (line low year,lpattern(longdash)),  yline(0,lc(black)lp(solid)lw(medthick))  xscale(range(2002 2010)) xlabel(2002(1)2010) xtitle("年份") ytitle("回归系数") legend(label(1 "估计值") label(2 "95%的上界") label(3 "95%的下界")) scale(0.8)  saving(so2_emission,replace)  


******附表5******
*最邻近1:3
forvalue i=2002/2010{
use 匹配后千家企业.dta
drop if year!=`i' 
g match=0 if treat==1 
g matchmark=. 

logit treatment lny tfp_op lnEC, robust
predict pscore if e(sample),pr
destring cic2,force replace
gen pscore2=cic2*10 + pscore 
set seed 0001
gen tmp = runiform()
sort tmp
psmatch2 treatment , out(so2_emission) pscore(pscore2) common ties n(3) cal(0.05)
replace match=1 if treat==0 & _weight!=.
replace matchmark=_n1 if _treat==1
save n3匹配`i',replace
}
use n3匹配2002.dta
forvalue i=2003/2010{
append using n3匹配`i'.dta
}
drop if treatment==1 & matchmark==.  
drop if match==.
drop match matchmark
reghdfe so2_emission post_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic_adj)
outreg2 using "变化匹配方法.xls", addtext(Firm FE, YES, Year FE, YES) replace se  nocons  dec(5)

*最邻近1:5
forvalue i=2002/2010{
use 匹配后千家企业.dta
drop if year!=`i' 
g match=0 if treat==1 
g matchmark=. 

logit treatment lny tfp_op lnEC, robust
predict pscore if e(sample),pr
destring cic2,force replace
gen pscore2=cic2*10 + pscore 
set seed 0001
gen tmp = runiform()
sort tmp
psmatch2 treatment , out(so2_emission) pscore(pscore2) common ties n(5) cal(0.05)
replace match=1 if treat==0 & _weight!=.
replace matchmark=_n1 if _treat==1
save n5匹配`i',replace
}
use n5匹配2002.dta
forvalue i=2003/2010{
append using n3匹配`i'.dta
}
drop if treatment==1 & matchmark==.  
drop if match==.
drop match matchmark
reghdfe so2_emission post_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic_adj)
outreg2 using "变化匹配方法.xls", addtext(Firm FE, YES, Year FE, YES) replace se  nocons  dec(5)

*半径匹配
forvalue i=2002/2010{
use 匹配后千家企业.dta
drop if year!=`i' 
g match=0 if treat==1 
g matchmark=. 

logit treatment lny tfp_op lnEC, robust
predict pscore if e(sample),pr
destring cic2,force replace
gen pscore2=cic2*10 + pscore 
set seed 0001
gen tmp = runiform()
sort tmp
psmatch2 treatment , out(so2_emission) pscore(pscore2) radius caliper(0.005) common
replace match=1 if treat==0 & _weight!=.
replace matchmark=_weight if _treat==1
save r匹配`i',replace
}
use r匹配2002.dta
forvalue i=2003/2010{
append using r匹配`i'.dta
}
drop if treatment==1 & matchmark==. 
drop if match==.
drop match matchmark
reghdfe so2_emission post_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic_adj)
outreg2 using "变化匹配方法.xls", addtext(Firm FE, YES, Year FE, YES) append se  nocons  dec(5)

*核匹配
forvalue i=2002/2010{
use 匹配后千家企业.dta
drop if year!=`i' 
g match=0 if treat==1 
g matchmark=. 

logit treatment lny tfp_op lnEC, robust
predict pscore if e(sample),pr
destring cic2,force replace
gen pscore2=cic2*10 + pscore 
set seed 0001
gen tmp = runiform()
sort tmp
psmatch2 treatment , out(so2_emission) pscore(pscore2) kernel
replace match=1 if treat==0 & _weight!=.
replace matchmark=_weight if _treat==1
save k匹配`i',replace
}
use k匹配2002.dta
forvalue i=2003/2010{
append using k匹配`i'.dta
}
drop if treatment==1 & matchmark==.  //剔除未匹配成功的实验组
drop if match==.
drop match matchmark
reghdfe so2_emission post_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic_adj)
outreg2 using "变化匹配方法.xls", addtext(Firm FE, YES, Year FE, YES) append se  nocons  dec(5)


*******附表6******
use 匹配后千家企业.dta
gen mark=0
replace mark=1 if cic2 == 44&33&32&25&31&22
replace mark=0 if year<2007
replace mark=0 if treatment==0
drop if mark==1
drop mark
save 稳健PSM千家, replace
forvalue i=2002/2010{
use 稳健PSM千家.dta
drop if year!=`i'
g match=0 if treat==1 
g matchmark=. 

logit treatment lny tfp_op lnEC, robust
predict pscore if e(sample),pr
destring cic2,force replace
gen pscore2=cic2*10 + pscore 
set seed 0001
gen tmp = runiform()
sort tmp
psmatch2 treatment, out(so2_emission) pscore(pscore2) common noreplacement n(1) cal(0.05)
replace match=1 if treat==0 & _weight!=.
replace matchmark=_n1 if _treat==1
save 稳健匹配`i',replace
}
use 稳健匹配2002.dta
forvalue i=2003/2010{
append using 稳健匹配`i'.dta
}
drop if treatment==1 & matchmark==.  //剔除未匹配成功的实验组
drop if match==.
drop match matchmark
reghdfe so2_emission post_treatment, absorb(idnew year) cluster(cic_adj) 
outreg2 using "稳健性分析.xls", addtext(Firm FE, YES, Year FE, YES) replace  se  nocons  dec(5)
reghdfe so2_emission post_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic_adj)    
outreg2 using "稳健性分析.xls", addtext(Firm FE, YES, Year FE, YES) append  se  nocons  dec(5)


******附表7******
use 匹配后千家企业.dta
drop if year>2005
gen post2002=1 == year>2002
gen post2002_treatment = post2002*treatment
gen post2003=1 == year>2003
gen post2003_treatment = post2003*treatment
gen post2004=1 == year>2004
gen post2004_treatment = post2004*treatment

reghdfe so2_emission  post2002_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic_adj)
outreg2  using  "安慰剂稳健.xls", addtext(Firm FE, YES, Year FE, YES) replace  se  nocons  dec(5)
reghdfe so2_emission  post2003_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic_adj)
outreg2  using  "安慰剂稳健.xls", addtext(Firm FE, YES, Year FE, YES) append  se  nocons  dec(5)
reghdfe so2_emission  post2004_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic_adj)
outreg2  using  "安慰剂稳健.xls", addtext(Firm FE, YES, Year FE, YES) append  se  nocons  dec(5)


******附表8******
use 匹配后千家企业.dta
sort cic_adj
bys cic_adj : egen employ_mean  = mean(employment) if year==2005
gen fx = 0 if year==2005
sum employ_mean , detail
replace fx = 1 if employ_mean > `r(p50)' & employ_mean ~= . 
bys idnew: egen firmsize  = max(fx)
drop fx
drop if firmsize=0
reghdfe so2_emission post_treatment, absorb(idnew year) cluster(cic_adj) 
outreg2 using "稳健性分析2.xls", addtext(Firm FE, YES, Year FE, YES) replace  se  nocons  dec(5)
reghdfe so2_emission post_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic_adj)
outreg2 using "稳健性分析2.xls", addtext(Firm FE, YES, Year FE, YES) append  se  nocons  dec(5)


******附表9******
use 匹配后千家企业.dta
reghdfe so2_emission post_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic4_year)
outreg2 using "稳健性分析3.xls", addtext(Firm FE, YES, Year FE, YES) replace  se  nocons  dec(5)
reghdfe so2_emission post_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(pro_cic4)
outreg2 using "稳健性分析3.xls", addtext(Firm FE, YES, Year FE, YES) append  se  nocons  dec(5)
reghdfe so2_emission post_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(pro_year)
outreg2 using "稳健性分析3.xls", addtext(Firm FE, YES, Year FE, YES) append se  nocons  dec(5)
reghdfe so2_emission post_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(city_cic4)
outreg2 using "稳健性分析3.xls", addtext(Firm FE, YES, Year FE, YES) append se  nocons  dec(5)


******附表10******
use 匹配后千家企业.dta
merge m:1 cic4 using 四位数行业污染排放.dta",gen(merinten)
drop if merinten==2
drop if merinten==1
gen post_treat_industry = post_treatment * coal_intensity
gen post_industry = post * coal_intensity
gen treat_industry = treat * coal_intensity
reghdfe so2_emission post_treat_industry post_treatment post_industry treat_industry  lny lnEC tfp_op lnK2 lnP soe  , absorb(idnew year cic_adj) cluster(cic_adj)    
outreg2 using "DDD.xls", addtext(Firm FE, YES, Year FE, YES,) append  se  nocons  dec(5)


******表3******
use 匹配后千家企业.dta
gen fuel_efficiency  = ln(coal_fuel_cosump)
reghdfe fuel_efficiency post_treatment, absorb(idnew year) cluster(cic_adj)
outreg2  using  "机制检验.xls", addtext(Firm FE, YES, Year FE, YES) replace  se  nocons  dec(5)


gen diese = ln(diese缩尾处理)
reghdfe diese post_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic_adj) 
outreg2  using  "机制检验.xls", addtext(Firm FE, YES, Year FE, YES) append  se  nocons  dec(5)

gen gas = ln(gas缩尾)
reghdfe gas post_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic_adj) 
outreg2  using  "机制检验.xls", addtext(Firm FE, YES, Year FE, YES) append  se  nocons  dec(5)


******表4******
reghdfe output post_treatment, absorb(idnew year) cluster(cic_adj) 
outreg2  using  "机制检验.xls", addtext(Firm FE, YES, Year FE, YES) replace  se  nocons  dec(5)

gen production= so2_treatment_kg + so2_discharge_kg
gen so2_production=ln(so2产生量缩尾) 
gen so2_treatment=ln(so2去除量缩尾)
gen rate_treat = so2_treatment / so2_production
reghdfe so2_production post_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic_adj)
outreg2  using  "机制检验.xls", addtext(Firm FE, YES, Year FE, YES) append  se  nocons  dec(5)
reghdfe rate_treat post_treatment lny lnEC tfp_op lnK2 lnP soe, absorb(idnew year) cluster(cic_adj)
outreg2  using  "机制检验.xls", addtext(Firm FE, YES, Year FE, YES) append  se  nocons  dec(5)


******表5******
*Panel A
forvalue i=0(1)1{
reghdfe so2_emission post_treatment lny lnEC tfp_op lnK2 lnP if soe==`i', absorb(idnew year) cluster(cic_adj)
outreg2 using "国有非国有.xls", addtext(Firm FE, YES, Year FE, YES,) append  se  nocons  dec(5)
}
*Panel B
forvalue i=0(1)1{
reghdfe fuel_efficiency post_treatment if soe==`i', absorb(idnew year) cluster(cic_adj)
outreg2 using "机制国有非国有.xls", addtext(Firm FE, YES, Year FE, YES,) append  se  nocons  dec(4)
}
forvalue i=0(1)1{
reghdfe output post_treatment  if soe==`i', absorb(idnew year) cluster(cic_adj)
outreg2 using "机制国有非国有.xls", addtext(Firm FE, YES, Year FE, YES,) append  se  nocons  dec(4)
}
forvalue i=0(1)1{
reghdfe so2_production post_treatment  lny lnEC tfp_op lnK2 lnP  if soe==`i', absorb(idnew year) cluster(cic_adj)
outreg2 using "机制国有非国有.xls", addtext(Firm FE, YES, Year FE, YES,) append  se  nocons  dec(4)
}
forvalue i=0(1)1{
reghdfe rate_treat post_treatment lny lnEC tfp_op lnK2 lnP  if soe==`i', absorb(idnew year) cluster(cic_adj)
outreg2 using "机制国有非国有.xls", addtext(Firm FE, YES, Year FE, YES,) append  se  nocons  dec(4)
}


******附表1******
sort prov cic2 year
bys prov cic2 year : egen so2emi2 = mean(so2_emission)
bys prov cic2 year : egen lny2 = mean(lny)
bys prov cic2 year: egen lnEC2 = mean(lnEC)
bys prov cic2 year : egen tfp2 = mean(tfp_op)
bys prov cic2 year : egen lnKL2 = mean(lnK2)
bys prov cic2 year : egen lnP2 = mean(lnP)
gen so2emi_new = so2_emission/so2emi
gen lny_new = lny/lny2
gen lnEC_new = lnEC/lnEC2
gen tfp_new = tfp_op/tfp2
gen lnK_new = lnK2/lnKL
gen lnP_new = lnP/lnP2
duplicates drop prov cic2 year,force
destring cic2, force replace
forvalue i=0(1)1{
reghdfe so2emi_new post_treatment  lny_new  lnEC_new  tfp_new  lnK_new  lnP_new   if soe==`i', absorb(idnew year) cluster(cic_adj)

outreg2 using "国有非国有回复意见(city).xls", addtext(Firm FE, YES, Year FE, YES,) append  se  nocons  dec(5)
}


******表6******
*Panel A
gen east=1==inlist(province,11,12,21,13,31,32,33,37,35,44,46)
forvalue i=0(1)1 {
reghdfe so2_emission post_treatment lny lnEC tfp_op lnK2 lnP soe if east==`i',absorb(idnew year) cluster(cic_adj)
outreg2 using "分地区.xls", addtext(Firm FE, YES, Year FE, YES) append  se  nocons  dec(5)
}
*Panel B
forvalue i=0(1)1{
reghdfe fuel_efficiency post_treatment  if east==`i', absorb(idnew year) cluster(cic_adj)
outreg2 using "机制分地区.xls", addtext(Firm FE, YES, Year FE, YES,) append  se  nocons  dec(5)
}
forvalue i=0(1)1{
reghdfe output post_treatment  if east==`i', absorb(idnew year) cluster(cic_adj)
outreg2 using "机制分地区.xls", addtext(Firm FE, YES, Year FE, YES,) append  se  nocons  dec(5)
}
forvalue i=0(1)1{
reghdfe so2_production post_treatment lny lnEC tfp_op  lnK2 lnP soe if east==`i', absorb(idnew year) cluster(cic_adj)
outreg2 using "机制分地区.xls", addtext(Firm FE, YES, Year FE, YES,) append  se  nocons  dec(5)
}
forvalue i=0(1)1{
reghdfe rate_treat post_treatment lny lnEC tfp_op lnK2 lnP soe if east==`i', absorb(idnew year) cluster(cic_adj)
outreg2 using "机制分地区.xls", addtext(Firm FE, YES, Year FE, YES,) append  se  nocons  dec(5)
}


******表7******
*Panel A
su employment if year==2005, detail
gen firmsize=1==employment>1427
forvalue i=0(1)1{
reghdfe so2_emission post_treatment lny lnEC tfp_op  lnK2 lnP soe if firmsize==`i', absorb(idnew year) cluster(cic_adj)
outreg2 using "企业规模.xls", addtext(Firm FE, YES, Year FE, YES) append  se  nocons  dec(5)
}
*Panel B
forvalue i=0(1)1{
reghdfe fuel_efficiency post_treatment  if firmsize==`i', absorb(idnew year) cluster(cic_adj)
outreg2 using "机制分规模.xls", addtext(Firm FE, YES, Year FE, YES,) append  se  nocons  dec(5)
}
forvalue i=0(1)1{
reghdfe output post_treatment  if firmsize==`i', absorb(idnew year) cluster(cic_adj)
outreg2 using "机制分规模.xls", addtext(Firm FE, YES, Year FE, YES,) append  se  nocons  dec(5)
}
forvalue i=0(1)1{
reghdfe so2_production post_treatment lny lnEC tfp_op lnK2 lnP soe if firmsize==`i', absorb(idnew year) cluster(cic_adj)
outreg2 using "机制分规模.xls", addtext(Firm FE, YES, Year FE, YES,) append  se  nocons  dec(5)
}
forvalue i=0(1)1{
reghdfe rate_treat post_treatment lny lnEC tfp_op lnK2 lnP soe if firmsize==`i', absorb(idnew year) cluster(cic_adj)
outreg2 using "机制分规模.xls", addtext(Firm FE, YES, Year FE, YES,) append  se  nocons  dec(5)
}
