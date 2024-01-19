*参考链接：https://zhuanlan.zhihu.com/p/355029888
use "E:\B站视频数据\连续DID平行趋势检验绘图\country.dta",clear

*生成年份虚拟变量和处理组变量交互项
foreach x in 1000 1100 1200 1300 1400 1500 1600 1700 1750 1800 1850 1900{
	gen ln_wpot_`x'=ln_wpot*[year==`x']
	}	
drop ln_wpot_1000



*******************-connect和line命令绘图*******************
*使用被解释变量（城市化率city_pop_share）对这些交互项进行回归
*可以使用reghdfe命令估计出各个交互项的系数（实际上就是一个动态DID模型的估计）
*特别注意的是，在回归时需要丢掉一期作为基准组，否则就会有多重共线性的问题
*关于基准组的选择，我个人比较推荐的是选择第1期或者-1期（政策时点前1期）
reghdfe city_pop_share ln_wpot_1*, absorb(year isocode c.ln_oworld#year c.ln_tropical#year c.ln_rugged#year c.ln_elevation#year) cluster(isocode)

*估计出回归系数后，需要做的就是在图中绘制出回归系数的取值情况和置信区间
*第一种绘图方法就是使用connect和line等绘图命令进行绘图(比较繁琐)
*第一步：
*需要导出回归结果(主要是回归系数和标准误)
outreg2 using "urbanization_figure.txt", replace sideway noparen se nonotes nocons noaster nolabel text keep(ln_wpot_1*)
*加载回归结果
insheet using "urbanization_figure.txt", clear
*对回归结果进行简单整理，去除如Observations等没有用的信息
keep if inrange(_n,5,15)
gen year = substr(v1,9,4)
rename (v2 v3)(coef se)
destring, force replace
keep year coef se
*第二步：需要计算出各个交互项系数的置信区间（t分布95%置信度的临界值大约等于1.96）
gen lb = coef - 1.96*se
gen ub = coef + 1.96*se
*第三步：在图中绘制出回归系数的取值和置信区间了
twoway (connect coef year,color(gs1) msize(small)) ///
(line lb year,lwidth(thin) lpattern(dash) lcolor(gs2)) ///置信区间下限
(line ub year,lwidth(thin) lpattern(dash) lcolor(gs2)), ///置信区间上限
yline(0,lwidth(vthin) lpattern(dash) lcolor(teal)) ///
xline(1700,lwidth(vthin) lpattern(dash) lcolor(teal)) ///
ylabel(,labsize(*0.85) angle(0)) xlabel(1100(100)1900,labsize(*0.75)) ///坐标刻度标签，标签字体缩放 0.75倍
ytitle("Coefficients") ///
xtitle("Year") ///
legend(off) ///图例
graphregion(color(white)) //白底




use "C:\Users\haoshuaikang\Desktop\数据代码\连续DID平行趋势检验绘图\country.dta",clear
*生成年份虚拟变量和处理组变量交互项
foreach x in 1000 1100 1200 1300 1400 1500 1600 1700 1750 1800 1850 1900{
	gen ln_wpot_`x'=ln_wpot*[year==`x']
	}	
drop ln_wpot_1000
*******************-coefplot命令绘图*******************
*coefplot命令可以便捷地根据回归结果帮助我们绘制回归系数的取值和置信区间，常用于DID平行趋势检验制图
*不需要手动导出导入回归结果，直接在回归后使用coefplot命令就能进行绘图操作
// coefplot命令部分绘图选项的解释如下：
// keep：保留指定系数，ln_wpot*指“ln_wpot”开头变量，在图中绘制“ln_wpot”开头的交互项系数和置信区间
// coeflabels：为系数指定自定义标签，在这里用来修改横坐标。
// msymbol、msize和mcolor：设置点的样式、大小和颜色。
// addplot(line @b @at)：增加点之间的连线。
// ciopts：设置置信区间样式
reghdfe city_pop_share ln_wpot_1*, absorb(year isocode c.ln_oworld#year c.ln_tropical#year c.ln_rugged#year c.ln_elevation#year) cluster(isocode)


coefplot, baselevels ///
keep(ln_wpot*) ///保留变量
vertical ///转置图形
coeflabels(ln_wpot_1100=1100 ln_wpot_1200=1200 ///
ln_wpot_1300=1300 ln_wpot_1400=1400 ln_wpot_1500=1500 ///
ln_wpot_1600=1600 ln_wpot_1700=1700 ln_wpot_1750=1750 ///
ln_wpot_1800=1800 ln_wpot_1850=1850 ln_wpot_1900=1900) /// 
yline(0,lwidth(vthin) lpattern(dash) lcolor(teal)) ///y竖线
xline(7,lwidth(vthin) lpattern(dash) lcolor(teal)) ///x竖线
ylabel(,labsize(*0.85) angle(0)) xlabel(,labsize(*0.75)) ///y刻度标签
ytitle("Coefficients") ///y标题
xtitle("Year") ///x标题
msymbol(O) msize(small) mcolor(gs1) ///plot样式
addplot(line @b @at,lcolor(gs1) lwidth(medthick)) ///增加点之间的连线
ciopts(recast(rcap) lwidth(thin) lpattern(dash) lcolor(gs2)) ///置信区间样式rline/rcap
graphregion(color(white)) //白底
