*参考链接：https://zhuanlan.zhihu.com/p/360047770
*参考链接：https://zhuanlan.zhihu.com/p/138108071

*在这篇论文中，作者将土豆的传入看作一项准自然实验，使用DID方法对土豆在旧大陆人口增长和城市化进程中的历史作用进行了全面的定量分析。在时间维度上，土豆传入旧大陆的时间是在17世纪末和18世纪初，因而我们可以轻松划分出土豆传入前和土豆传入后两个时期。在地区维度上，土豆几乎传入了旧大陆的所有国家，所以不存在明确的实验组和控制组，但是，不同国家对土豆种植的适宜性不同（这是由不随时间变化的地理气候条件决定的），这就会导致土豆的传入对不同国家的影响程度是不同的。这篇文章使用的并不是传统的DID识别策略，而是连续DID的识别策略。通过比较在旧大陆在土豆种植之前和之后，更适合土豆种植的旧大陆地区和不太适合土豆种植的地区之间的人口和城市化水平（所谓双重差分），我们即可识别出土豆在旧大陆人口增长和城市化进程中的历史作用。

*===========================基准回归====================================*

*将土豆的传入看作一项准自然实验，使用DID方法对土豆在旧大陆人口增长和城市化进程中的历史作用进行了分析
*在时间维度上，土豆传入旧大陆的时间，划分出土豆传入前和土豆传入后两个时期，
*在地区维度上，土豆几乎传入了旧大陆的所有国家，故不存在明确的实验组和控制组，但不同国家对土豆种植的适宜性不同
*导致土豆的传入对不同国家的影响程度是不同的，这并不是传统的DID识别策略，而是连续DID的识别策略。
*通过比较在旧大陆在土豆种植之前和之后，更适合土豆种植的旧大陆地区和不太适合土豆种植的地区之间的人口和城市化水平（所谓双重差分）
*可识别出土豆在旧大陆人口增长和城市化进程中的历史作用。



use "F:\科研资料\stata程序\平行趋势假设检验\连续DID平行趋势检验绘图\country.dta"  ,clear

*时间维度差异：1700年之后-post
*地区维度变异：不同国家对土豆种植的适宜性，用适合种植土豆的土地总面积的自然对数ln_wpot(区别)
*被解释变量人口（城市化率）

*交互项：时间维度*地区维度
*ln_wpot_post的系数反映的就是土豆的传入对旧大陆人口增长的影响
gen ln_wpot_post = ln_wpot*post


*DID模型实际上就是一个包含交互性的回归模型，故DID回归使用一般的回归命令即可，
*此外我们经常使用的回归命令主要有三个，分别是reg命令、xtreg命令和reghdfe命令

*1.reg命令是最一般的回归命令，对数据格式没有要求，常用于截面数据和混合截面数据的DID模型回归
reg ln_population ln_wpot_post ln_wpot post,cluster(isocode)

*2.通常情况下，习惯将固定效应引入DID模型，因为固定效应能够更为精确地反映两个维度上的变异性，
*  并且可以在一定程度上帮助我们缓解遗漏变量导致的偏误问题。
*  所以对面板数据的DID模型，更多用)xtreg命令，xtreg对数据格式有严格要求，要求必须是面板数据
encode isocode,gen(code)
xtset code year
xtreg ln_population ln_wpot_post i.year,fe cluster(isocode)

*3. 我们可能会在DID模型中引入高维固定效应（2维以上），这个时候reghdfe命令会是更好的选择
reghdfe ln_population ln_wpot_post,absorb(isocode year) cluster(isocode)





*================================平行趋势检验====================================*
*参考链接：https://zhuanlan.zhihu.com/p/355029888

*******************-connect和line命令绘图*******************
*使用被解释变量（城市化率city_pop_share）对这些交互项进行回归
*可以使用reghdfe命令估计出各个交互项的系数（实际上就是一个动态DID模型的估计）
*特别注意的是，在回归时需要丢掉一期作为基准组，否则就会有多重共线性的问题
*关于基准组的选择，我个人比较推荐的是选择第1期或者-1期（政策时点前1期）


use "F:\科研资料\stata程序\平行趋势假设检验\连续DID平行趋势检验绘图\country.dta" ,clear
*生成年份虚拟变量和处理组变量交互项
foreach x in 1000 1100 1200 1300 1400 1500 1600 1700 1750 1800 1850 1900{
	gen ln_wpot_`x'=ln_wpot*[year==`x']
	}	
drop ln_wpot_1000
*******************-coefplot命令绘图*******************
*coefplot命令可以便捷地根据回归结果帮助我们绘制回归系数的取值和置信区间，常用于DID平行趋势检验制图
*不需要手动导出导入回归结果，直接在回归后使用coefplot命令就能进行绘图操作
// coefplot命令部分绘图选项的解释如下：
// keep：保留指定系数，ln_wpot*指"ln_wpot"开头变量，在图中绘制"ln_wpot"开头的交互项系数和置信区间
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


