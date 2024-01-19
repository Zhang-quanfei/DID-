*-------------DID稳健有效估计量--------------*
	
	---------------------------
	------主要命令一览表-------
	---------------------------
	交叠DID(系数诊断):bacondecomp
	交叠DID(负权重诊断): twowayfeweights
	交誉DID(组别--时期平均处理效应): did_multiplegt
	交叠DID(组别--时期平均处理效应): eventstudyinteract
	交叠DID(组别--时期平均处理效应): csdid
	交叠DID(插补估计量):did2s
	交叠DID(插补估计量):did_imputation
	交叠DID(堆叠估计量):stackedev
	交誉DID(其他命令):event_plot
	交叠DID(其他命令):fect
	交叠DID(其他命令):eventdd
	交叠DID(其他命令):staggered
	交叠DID(其他命令):xtevent

	*最近一系列文献都表明，当处理组个体接受处理的时间是交错的，而且平均处理效应随着组别以及时间发生变化时，
	//常见的双重差分估计就不能识别一个典型处理效应并做出合理的度量 (Borusyak and Jaravel, 2017; Athey and Imbens, 2018; Goodman-Bacon, 2018; de Chaisemartin and D'Haultfoeuille, 2020; Imai andKim, 2020; Sun and Abraham, 2020)。
	/*
	无论是经典的多期DID还是交错DID， 使用双向固定效应模型进行因果推断时， 需要满足以下四个重要假设：
	
	第一， 严格外生假设(Strict Exogeneity Assumption) 
该假设是使用面板数据进行因果推断的关键假设，它要求：不能存在随时间变化的混杂因素；过去的结果变量不能对当期的结果变量产生影响；过去的结果变量或协变量不能对当期和未来的处理状态产生影响；当期的处理状态不能对未来的结果变量产生影响。 数学上，严格外生假设强于平行趋势假设； 而实际研究中两者差别不大 (Xu，2022)。

	第二，无预期效应假设(No Anticipation Assumption) 	该假设指的是个体在当期的结果变量不会受到个体在未来的接受政策处理状态的影响。也即个体并不能预知其在未来是否会接受政策处理，从而根据这种预期改变其行为。
	
	第三，单位处理变量值稳定假设(Stable Unit Treatment Values Assumption) 其是指不同个体是否受到政策冲击是相互独立的， 某一个体受政策冲击的情况(Treatment Status)不影响任何其他个体的结果(黄炜等，2022)。
	
	第四，处理效应同质性假设(Homogeneous Treatment Effect Assumption)
它要求处理效应满足两个维度的同质性：第一，处理效应在不同的组别间是同质的，即同一政策对于不同处理组的影响是相同的。
第二，处理效应在时间维度上是同质的，即对于同一时间受到政策处理的所有个体， 随着时间推移， 处理效应的大小不变。
需要特别指出的是，在过往的研究中，使用 TWFE进行交错DID估计时，往往忽视了这一重要的隐含假设。
以Goodman-Bacon(2021)等为代表的一众学者指出，忽视这一假设将可能产生较为严重的估计偏误。
	*/
	
**********************
*** 面板数据可视化 *** --- panelview
**********************		
	*文章来源：https://www.lianxh.cn/news/78c21ab215c46.html
	
	*简介
	/*
		本文主要介绍由 Mou、Hongyu 和 Yiqing Xu (2022) 共同开发的面板数据可视化命令——panelview。该命令具备以下三大功能：
		1、在面板数据集中绘制处理组状态和缺失值；
		2、以时间序列的方式可视化感兴趣的变量；
		3、以单位或总体描述自变量与因变量之间的二元关系。
		4、这些工具可以帮助研究人员在进行统计分析之前，更好地理解他们的面板数据。
	*/
	*命令安装
	net install grc1leg, from(http://www.stata.com/users/vwiggins) replace
	net install gr0075, from(http://www.stata-journal.com/software/sj18-4) replace
	ssc install labutil, replace
	ssc install sencode, replace
	
	ssc install panelview, all replace 
	//或者net install panelview, all replace from("https://yiqingxu.org/packages/panelview_stata")
	
	*语法
	panelview Y D X [if] [in] , i(varname) t(varname numeric) type(string) [options]
	
	/*
		其中，
		Y D X：因变量、自变量和协变量。由于协变量中缺少值，包含协变量可能会改变图的外观；
		if 和 in：添加限定条件；
		i() 和 t()：指定单位 (组) 和时间指标；
		type()：type(treat) 使用热力图绘制处理组分配。type(outcome) 以时间序列的方式绘制结果变量。type(bivar) 或 type(bivariate) 在同一图表中绘制结果和处理组与时间的关系。type(miss) 或 type(missing) 绘制变量的数据缺失状态；
		continuoustreat：处理变量表示为连续变量；
		discreteoutcome：当变量是离散的，确保 panelview 在 type(outcome) 图中保持它的离散性；
		bytiming：按首次接受处理的时间对单位进行排序，如果时间是相同的，那么就是接受处理的总时长；
		ignoretreat：省略处理指标，即 Y 之后的所有变量都被解释为协变量；
		ignoreY：显示 varlist 中第一个变量的处理状态，而不是第二个，需要与 type(treat) 或 type(missing) 结合使用。如果 varlist 中只有一个变量，则该选项禁用；
		MYCOLor()：改变配色方案；
		PREpost：区分处理组的处理前和处理后阶段；
		xlabdist() 和 ylabdist()：更改 x 轴和 y 轴上标签之间的整数间隔，默认值为 1；
		bygroup：将每个单元放入不同的处理组，然后在调用 type(outcome) 时将它们分别绘制在列中；
		style()：确定绘图中元素的样式。第一项和第二项分别定义了结果变量和处理组的风格。Connected 或 c 表示连接线，line 或 l 表示线；
		byunit：当调用 type(bivar) 时，绘制每个单元的结果变量和处理变量与时间的关系图；
		theme(bw)：使用黑白主题，当指定 type(bivar) 时为默认；
		lwd()：设置行宽的 type(bivar)，默认为 medium；
		leavegap：如果时间分布不均匀，将时间间隔用白色条表示；
		bygroupside：将分组的子图形排列在一行中而不是列中；
		displayall：如果单位数超过 500，则显示所有单位，否则随机选择 500个单位呈现。
		*/
	*命令实操
	use turnout.dta, clear  
	panelview turnout policy_edr policy_mail_in policy_motor, i(abb) t(year) ///
		 type(treat) xtitle("Year") ytitle("State") title("Treatment Status") legend(pos(6) rows(1))
	//1.1 turnout 是结果，policy_edr 是处理变量，policy_mail_in 和 policy_motor 是协变量。由于在协变量中缺少值，包含协变量可能会改变图的外观
		 
	*1.2 我们可以使用 bytiming 选项来按接受处理的时间 (其次是按接受处理的总时间) 对单位进行排序，legend 选项来更改图例中的标签，以及 prepost 选项来区分处理组处理前和处理后的阶段。
	panelview turnout policy_edr policy_mail_in policy_motor, i(abb) t(year) type(treat) ///
     xtitle("Year") ytitle("State") title("Treatment Status") legend(pos(6) rows(1)) prepost bytiming
	*1.3 如果时间分布不均匀，我们可以使用 leavegap 来保持时间间隙为白条。否则，我们将跳过时间间隔，并警告 Time is not evenly distributed (possibly due to missing data)。
	drop if year==1924
	drop if year==1928
	drop if year==1940
	panelview turnout policy_edr policy_mail_in policy_motor, i(abb) t(year) type(treat) leavegap
	 
	*2.1 缺失和处理状态开关
			//对于处理组可能开启和关闭的面板数据集，我们不再区分处理前和处理后的状态。为了展示 panelview 如何在更一般的情况下使用，下图使用了 capacity.dta 数据集，该数据集用于调查民主的影响，其中 demo 是体制类型的二元指标。从下图中，我们看到了相当多的民主逆转的案例，有许多缺失的变量 (白色区域)。在这里，我们使用 xlabdist 和 ylabdist 选项来改变 x 轴和 y 轴上标签之间的间隙。
		use capacity.dta, clear 
		panelview lnpop demo lngdp , i(country) t(year) type(treat) mycolor(Reds) ///
			title("Democracy and State Capacity") xlabdist(3) ylabdist(10) legend(pos(6) rows(1))
		*2.1.1 如果 varlist 是 D X，我们可以用 ignoreY 来表示 D 的处理状态，不考虑 Y 缺失的状态。
		panelview lnpop demo lngdp  ,ignoreY i(country) t(year) type(treat) mycolor(Reds) ///
			title("Democracy and State Capacity") xlabdist(3) ylabdist(10) legend(pos(6) rows(1))
		*2.1.2 根据一个单位接受处理的第一个周期进行分类的单位，会提供一个更吸引人的视觉效果。
		 panelview lnpop demo lngdp, i(country) t(year) type(treat) mycolor(Reds) ///
			title("Democracy and State Capacity") xlabdist(3) ylabdist(10) bytiming legend(pos(6) rows(1))
	*2.2  绘制部分单位
		//有时，一个数据集有许多单位，我们只想取单位子集，此时可以通过 if 选项指定显示单元。注意，如果变量没有包含在 varlist 或 i()/t() 后面，我们建议研究人员添加变量到 varlist 中。在下图中，我们绘制了前 25 个单位的处理状态。
		egen ccodeid = group(ccode)
		panelview lnpop demo lngdp ccodeid if ccodeid >= 1 & ccodeid <= 26, i(ccode) ///
			t(year) type(treat) mycolor(PuBu) title("Democracy and State Capacity") xlabdist(3) legend(pos(6) rows(1))
	*2.3 两种以上的处理组特征
		*2.3.1 三种处理组类型
		//panelview 支持 2 级以上处理的面板数据。例如，我们创建了一个有三个处理水平的制度类型的变量。
		use capacity.dta, clear
		gen demo2 = 0
		replace demo2 = -1 if polity2 < -0.5
		replace demo2 = 1 if polity2 > 0.5
		panelview Capacity demo2 lngdp, i(ccode) t(year) type(treat) title("Regime Type") ///
			 xlabdist(3) ylabdist(10) mycolor(Reds) legend(pos(6) rows(1)) 
		*2.3.2 五种以上处理组类型
		//如果处理类型数大于 5，则处理指标视为连续变量。
		use capacity.dta, clear
		gen demo2 = 0
		replace demo2 = -2 if polity2 < -0.7
		replace demo2 = -1 if polity2 < -0.5 & polity2 > -0.7
		replace demo2 = 1 if polity2 > 0.5 & polity2 < 0.7
		replace demo2 = 2 if polity2 > 0.7
		tab demo2, m 
		panelview Capacity demo2 lngdp, i(ccode) t(year) type(treat) title("Regime Type") ///
			xlabdist(3) ylabdist(10) legend(pos(6) rows(1)) 
	*2.4 连续的处理变量
		//panelview 的第二个功能是以时间序列的方式显示面板数据集的原始结果变量。语法非常类似，只是我们需要指定 type(outcome)。不同的颜色代表不同的处理条件。
		*2.4.1 连续的处理变量
		//我们把处理开始前的一段时间画成处理期。与 type(treat) 不同，type(outcome) 不需要 xlabdist 和 ylabdist。如果需要，我们应该使用 xlabel 和 ylabel 来代替。同时使用 prepost 区分处理单元的处理前和处理后阶段。
		use turnout.dta, clear
		panelview turnout policy_edr policy_mail_in policy_motor, i(abb) t(year) type(outcome) ///
		   xtitle("Year") ytitle("Turnout") title("EDR Reform and Turnout") prepost legend(pos(6) rows(1)) 
		 *2.4.2 处理变量分组绘图
		//为了更好地理解数据，有时我们希望根据观察区间内处理状态是否发生变化来绘制结果，此时可以通过选项 bygroup 实现。算法会对数据进行分析，并自动将每个单元分成不同的组，如 1)一直是处理的单元，2) 一直是控制的单元，3) 处理状态发生变化的单元。
		use turnout.dta, clear
		panelview turnout policy_edr policy_mail_in policy_motor, i(abb) t(year) type(outcome) ///
			xtitle("Year") ytitle("Turnout") by(, title("EDR Reform and Turnout"))             ///
			bygroup xlabel(1920 (20) 2000) legend(pos(6) rows(1)) 
	*2.5 离散的处理变量
		//我们可以通过设定 discreteoutcome 来绘制离散的变量。下面是一个使用 pvsimdata.dta 数据集的示例，其中结果变量有三个值：0、1、2。
		lxhget pvsimdata.dta //得到数据
		use pvsimdata, clear
		panelview Y D if time >= 8 & time <= 15, type(outcome) i(id) t(time) mycolor(Reds) ///
			discreteoutcome title("Raw Data") xlabel(8 (2) 15) ylabel(0 (1) 2) legend(pos(6) rows(1)) 
	*2.6 同时绘制Y和D时间序列
		//通过指定 type(bivar) 或 type(bivariate)，实现在一个图中可视化结果和处理变量的时间序列。对于连续变量，我们默认使用线图，对于离散变量，我们使用条形图。
		*2.6.1 绘制所有单位的平均时间序列
		//对于连续的结果变量和离散的处理组，这里有两个例子。在前者中，style(c,b) 表示连接的散点图，而不是表示结果变量的默认线形图和处理组的条形图。如果有连接线，可以通过 msize() 指定符号的大小。
		use turnout.dta, clear
	panelview turnout policy_edr, i(abb) t(year) xlabdist(7) type(bivariate) msize(*0.5)     ///
		style(c b) ytitle("turnout") ytitle("policy_edr", axis(2)) legend(label(1 "turnout") ///
			label(2 "policy_edr")) ylabel(40 (10) 70) ylabel(0 (0.1) 0.5, axis(2))   legend(pos(6) rows(1))  //柱形图代表当年处理组占所有年份总处理组比重
		*2.6.2 按每个单位绘制时间序列图
		//我们使用 byunit 绘制 D 和 Y 与时间的关系图，并将四个子图排列在一行中。
		use turnout.dta, clear
		panelview turnout policy_edr policy_mail_in policy_motor if abb >= 1 & abb <= 12,     ///
			i(abb) t(year) xlabdist(10) type(bivar) byunit
		use capacity.dta, clear 
		panelview lnpop demo if country >= 1 & country <= 24, i(country) t(year) xlabdist(20) ///
			type(bivar) byunit
			
***********------------自有数据实操------------*******************
		use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear
		panelview so2 dum_ta , i(cname) t(year) type(treat)  xtitle("Year") ytitle("CityName") ///
		 	title("Democracy and State Capacity") xlabdist(3) ylabdist(10)  bytiming legend(pos(6) rows(1)) leavegap  //ylabdist(10)y轴标签间隔为10,mycolor(Blues)指定颜色，prepost显示处理前后，不能和leavegap连用
			
**************************
*** 培根分解(系数诊断) *** --- bacondecomp
**************************
	*视频：https://www.bilibili.com/video/BV1AL411Q7Au/?spm_id_from=333.337.search-card.all.click&vd_source=23c93267e6ec724940178872fe88f56d
	*文章来源：https://www.lianxh.cn/news/122dffa5b6d39.html
	*文献：Andrew Goodman-Bacon  (2021). Difference-in-differences with variation in treatment timing. Journal of Econometrics
	*--------命令实操----------
	ssc install bacondecomp,replace
	net install ddtiming, from(https://tgoldring.com/code/)
	use http://pped.org/bacon_example.dta,clear
	
	xtreg asmrs post pcinc asmrh cases i.year,fe r
	* 	asmrs 为自杀死亡率，post 表示实行改革以后，pcinc 为人均收入，asmrh 则为他杀死亡率，
	*	case 为该地区某年抚养未成年儿童家庭援助计划的数量
	
	
	bacondecomp asmrs post pcinc asmrh cases, stub(Bacon_) robust
	
	* 	从数据中可以看出，不同的地区执行该政策的时间是不同的，因此可以采用该文中提供的分解方法，
	*	将所有区域分为 14 个不同时点的处理组，其中包含 1 个永久处理组和 1 个从不处理组。

	* 	此外，该命令在默认情况下还为所有比较生成一个图表，最多显示三种类型的两组/两期比较，它们因对照组而异：
	*	时间组，或在不同时间接受处理可以作为彼此的对照组，并可按照之前所述的两种方式进行比较：
	*		较晚处理者为较早治疗组的对照组，较早处理者为较晚处理组的对照组；
	*		分析开始前处理的一组作为对照组；
	*		未接受处理的组为对照组。
	
	* 	从结果中可以看出，双向固定效应的 DD 估计量 -2.516 是不同组别的加权总和。
	*	其中不同处理时间带来的差异占据了总效应的 37.766%，而同组内的差异占比为 0.509%，
	*	一直接受处理与从未接受处理组的效应仅占 0.0018%。
	
	bacondecomp asmrs post , ddetail //不提供早处理和晚处理组
	*	最后，尽管该命令还提供了 DD 效应的详细分解，但目前只能够支持不含其它控制变量与权重调节的情况。
	*	在此仅对于关键自变量 post 进行回归。
	*	该分解可以将结果详细地分为上文中所讲的四组。
	*	其中新处理组与已处理组权重最大，达到 0.384，
	*	若处理效应随时间而变量，则该估计量很可能有偏。
	set scheme s2color
	ddtiming asmrs post ,i(stfips) t(year) //提供早处理和晚处理组
	*---------------自有数据操作-------------------
	use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear
	xtset cid year
	xtbalance,range(2003 2014)
	bacondecomp so2 dum_ta //强面板, ddetail
	//Timing_groups 包含了两种效应，早处理(实验组)VS晚处理(控制组)，和晚处理(实验组)VS早处理(控制组)，后面的有问题
	//Always_v_timing，一直处理组(控制组)VS时变组(实验组)，这个有问题
	//Never_v_timing，从未处理的组(控制组)VS时变组(实验组)
	di e(sumdd)[1,1]*e(sumdd)[1,2] + e(sumdd)[2,1]*e(sumdd)[2,2] + e(sumdd)[3,1]*e(sumdd)[3,2] //系数加权和
	
	ddtiming so2 dum_ta ,i(cid) t(year) legend(pos(6) rows(2)) //不要求强面板
	dis  0.217 * (-1.858) + 0.056 * 5.383+ 0.694* (-8.481)+ 0.033*(-23.769)
	//Later T vs. Earlier C和T vs. Already treated ，会导致出现问题，使用早处理组作为控制组

******************
*** 负权重诊断 *** --- twowayfeweights
******************
	use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear
	ssc install twowayfeweights, replace
	twowayfeweights so2 cid year dum, type(feTR) controls() //feTR表示对固定效应进行检验

****************
*** TWFE OLS *** --- TWFE
****************
	use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear

	*--------回归-------*
	gen treat = birth~=.
	gen event = year - birth   //减去政策发生年份 
		
	replace event = -5 if event < -5 
	replace event = 5 if event > 5   & event~=. 
	forvalues i=5(-1)1{
	  gen pre`i'=(event==-`i'& treat==1)
	}

	gen current=(event==0 & treat==1)

	forvalues i=1(1)5{         //政策发生后
	  gen post`i'=(event==`i'& treat==1)
	}

	drop pre5    //删掉基准组
	reghdfe so2 pre* current post* ,absorb(year cid ) clu(cid)
	
	*--------提取-------*
	*-提取前十个回归系数
	forvalues i=1(1)10 {
	local b_`i'=e(b)[1,`i']  //提取自变量系数
	}
	matrix define mat1_ols= (`b_1',`b_2',`b_3',`b_4',`b_5',`b_6',`b_7',`b_8',`b_9',`b_10') //定义系数1×10矩阵
	mat colnames mat1_ols =  T-4 T-3 T-2 T-1 T+0 T+1 T+2 T+3 T+4 T+5   //更改系数矩阵列名
	*-提取变量方差，
	forvalues i=1(1)10 {
	local v_`i'=e(V)[`i',`i']  //提取方差，类似（1，2）是协方差，（1，1）是pre4方差
	}
	matrix input mat2_ols = (`v_1',`v_2',`v_3',`v_4',`v_5',`v_6',`v_7',`v_8',`v_9',`v_10') //定义1×10方差矩阵
	mat colnames mat2_ols =  T-4 T-3 T-2 T-1 T+0 T+1 T+2 T+3 T+4 T+5  //更改方差矩阵列名
	
	gen t = _n
	replace t=t-5
	replace t=. if t>5 
	gen b=.
	gen se=.
	local row = 1
	*pre提取到对应行
	forvalues x = 4(-1)1 {
	local t="pre" + "`x'"
	replace b=_b[`t'] in `row'  //提取到第几行（row）
	replace se=_se[`t'] in `row'
	local ++row
	}
	*current 提取到第五行
	replace b=_b[current] in 5
	replace se = _se[current] in 5
	*post提取到对应行
	forvalues x = 1(1)5 {
	local z = `x' + 5
	local t="post" + "`x'"
	replace b=_b[`t'] in `z'  //提取到第几行（row）
	replace se=_se[`t'] in `z'
	}
	
	gen upper95=b+1.96*se   //95%置信区间
	gen lower95=b-1.96*se
	
	//mfc(none)  表示填充为空
	twoway (rcap upper95 lower95 t , lcolor(black)) ///
	(scatter b t , msymbol(S) mfc(none) mcolor(black)), ///
	bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0, lpattern(dash) lcolor(gs12) lwidth(thin)) legend(off) ///
	yline(0, lpattern(solid) lcolor(gs12) lwidth(thin)) legend(off) ///
	xtick(-4(1)5) xlabel( -4 -3 -2 -1 0 1 2 3 4 5) ///
	ytitle("Coefficient", height(6) size(medlarge)) title("Two Way Fixed Effect Model") ///
	xtitle("Semester to/from FB Introduction", height(6) size(medlarge)) xsize(5) ysize(4)
	graph save "$TEMP/event_study_TWFE", replace

*****************************
*** Borusyak et al.(2021) *** --- 插补
*****************************
	*文献：Kirill Borusyak , Xavier Jaravel , Jann Spiess  (2021). Revisiting Event Study Designs: Robust and Efficient Estimation.
	*文章来源：https://asjadnaqvi.github.io/DiD/docs/code/06_did_imputation/
	*--------方法简介----------*
	*-Borusyak 等 (2021) 提供了一种基于插补的反事实方法解决 TWFE 的估计偏误问题。基于 TWFE，通过估计组群固定效应、时间固定效应和处理组-控制组固定效应，可以得到更准确的估计量
	*插补估计量的直觉是：首先， 利用从未接受处理的样本或尚未接受处理的样本估计出每个处理组个体每个时期的反事实结果。此后， 计算处理组个体的处理效应，即真实结果与反事实结果的差。最后，将个体层面的处理效应进行加总， 即得到平均处理效应的估计。
	* 与前文介绍的加权法估计量相似， 该估计量同样依赖于平行趋势假设和无预期效应假设
	*相较于计算组别 － 时期的平均处理效应， 插补估计量在计算过程中由于没有造成大量的样本丢弃， 因而估计效率更高。

	*命令安装
	cnssc install did_imputation, replace
	*命令语法
	did_imputation Y i t Ei [if] [in] [estimation weights] [, options]
	*其中 Y 为结果变量，i 是观测的唯一识别符，t 为年份，Ei 为个体接受处理的时间 (缺失值则代表从未处理组)。
	event_plot , stub_lag(T+#) stub_lead(T-#) trimlag(4) ciplottype(rcap)plottype(scatter)
	*event_plot支持输入mat1_bor#mat2_bor矩阵交互，mat1_ols是系数矩阵，mat2_ols是方差矩阵；trimlag(4)表示截断到后面第四期 ，逗号前面不加变量默认输出回归的平行趋势
	*ciplottype(rcap)表示置信区间样式为“帽子”
	*plottype(scatter)表示画图类型用“点”表示
	*stub_lag表示政策的后几期；stub_lead表示政策的前几期，#代表前后后几期，例如stub_lead(T-1),表示政策前一期
	use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear
	did_imputation so2 cid year birth, fe(cid year) autosample horizons(0 1 2 3 4  ) pretrends(4) cluster(cid)   //horizons(0 1 2) 只汇报政策时 政策第一期 政策第二期
	event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
		title("Borusyak et al. (2021) imputaion estimator") xlabel(-4(1)5) name(BJS, replace)) together

***************
*** Gardner *** --- (插补)两阶段
***************
	*文献：John Gardner (2021). Two-stage differences in differences.
	*文章来源：https://mp.weixin.qq.com/s/u8S6xfpf2uBoUAr1M98LZw
	*Gardner (2021) 提出的两阶段双重差分的基本原理：在第一阶段识别组群处理效应和时期处理效应的异质性，在第二阶段时再将异质性处理效应剔除
	*二阶段 GMM 估计框架 (two-stage estimation framework)。在这个框架中，我们在第一阶段识别组别效应和时期效应，在移除了组别效应和时期效应之后，在第二阶段，通过比较处理组和对照组的结果差异来识别平均处理效应。两阶段方法对于被处理的时间是交错的以及处理效应具有异质性的情况下估计结果是稳健的，而且还能够用来识别许多不同的平均处理效应，方法简单直接好用；
	
	*---------did2s命令介绍----------*
	*命令安装
	net install did2s, from(http://fmwww.bc.edu/RePEc/bocode/d)
	net get did2s, from(http://fmwww.bc.edu/RePEc/bocode/d)
	*命令语法
	did2s depvar [if] [in] [weight], ///
		  first_stage(varlist)       ///
		  treat_formula(varlist)     ///
		  treat_var(varname)         ///
		  cluster_var(varname})      ///
		  [nboot(50)]	  
			/*
			depvar：被解释变量；
			first_stage(varlist)：第一阶段公式，包括用于估计 Y(0) 的固定效应和协变量，不能放入处理变量；
			treat_formula(varlist)：第二阶段公式，varlist 放入处理变量，这些处理变量可以是 0、1 表示处理与否的虚拟变量，也可以是事件研究中提前\滞后变量，或者是连续的处理变量；
			treat_var(varname)：这个必须设定为 0、1 类型的处理变量。其中 0 表示没有接受处理，1 表示接受处理；
			cluster_var(varname})：为 bootstrap 产生的样本选择聚类变量，如果不想聚类的话，可以直接填入 id；
			nboot(real)：可以设置 bootstrap 抽样次数，默认 50 次。
			*/
		*事件研究法
		did2s Y, first_stage(i t) second_stage(*leads* *lags*) treat_var(*D*) cluster(*var*)
			/*
			Y	outcome variable
			i	panel id
			t	time variable
			lags	manually generated lag variables
			leads	manually generated lead variables
			D	Dummy variable which =1 if treated，双重差分
			cluster(var)	Cluster variable is panel id or higher aggregation unit
			*/
		use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear
		
		*利用did2s进行估计
		did2s so2, first_stage(i.cid i.year) second_stage(i.dum_ta)  ///
        treatment(dum_ta) cluster(cid)
		
		use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear
		gen treat = birth~=.
		gen never_treat = birth==.
		gen event = year - birth   //减去政策发生年份 
			
		replace event = -5 if event < -5 
		replace event = 5 if event > 5   & event~=. 
		forvalues i=5(-1)1{
		  gen pre`i'=(event==-`i'& treat==1)
		}

		gen current=(event==0 & treat==1)

		forvalues i=1(1)5{         //政策发生后
		  gen post`i'=(event==`i'& treat==1)
		}

		drop pre5    //删掉基准组

		did2s so2, first_stage(cid year) second_stage(pre* current post*) treatment(dum_ta) cluster(cid)


		forvalue i=1(1)10 {
		local m_`i'=e(b)[1,`i']
		local v_`i'=e(V)[`i',`i']
		}
		matrix input mat1_ga= (`m_1',`m_2',`m_3',`m_4',`m_5',`m_6',`m_7',`m_8',`m_9',`m_10')
		mat colnames mat1_ga=     g_m4 g_m3 g_m2 g_m1 g_0 g_1 g_2 g_3 g_4 g_5
		matrix input mat2_ga= (`v_1',`v_2',`v_3',`v_4',`v_5',`v_6',`v_7',`v_8',`v_9',`v_10')
		mat colnames mat2_ga= 	g_m4 g_m3 g_m2 g_m1 g_0 g_1 g_2 g_3 g_4 g_5

		event_plot mat1_ga#mat2_ga, stub_lag(g_#) stub_lead(g_m#) trimlag(5) ciplottype(rcap) ///
		plottype(scatter) ///
		graph_opt(bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
		xline(0, lpattern(dash) lcolor(gs12) lwidth(thin)) legend(off) ///
		yline(0, lpattern(solid) lcolor(gs12) lwidth(thin)) legend(off) ///
		ylabel(, labsize(small)) ///
		xlabel( -4 -3 -2 -1 0 1 2 3 4 5, labsize(small)) ///
		ytitle("Coefficient", height(6) size(small)) title("Gardner (2021)",size(small)) ///
		xtitle("Semester to/from FB Introduction", height(6) size(small)) xsize(6) ysize(4)) ///
		lag_opt(msymbol(Th) mcolor(green) msize(small)) lead_opt(msymbol(Th) mcolor(green) msize(small)) ///
		lag_ci_opt(lcolor(green) lwidth(medthin)) lead_ci_opt(lcolor(green) lwidth(medthin))


*****************************************
*** DeChaisemartin and D'Haultfeuille *** --- 加权
*****************************************
	*文献：Clément de Chaisemartin, Xavier D'Haultfoeuille (2020). Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects. American Economic Review.
	*	  Clément de Chaisemartin, Xavier D'Haultfoeuille (2021). Two-way fixed effects regressions with several treatments.
	*-------DIDM：多期多个体倍分法--------*
	*De Chaisemartin 和 D`Haultfoeuille (2020) 提出通过加权计算两种处理效应的值得到平均处理效应的无偏估计，这两种处理效应为：
	*	t-1期未受处理而 t 期受处理的组与两期都未处理的组的平均处理效应；
	*	t-1期受处理而 t 期未受处理的组与两期都受处理的组的平均处理效应。
	*	该方法的前提条件是处理效应不具有动态性 (即处理效应与过去的处理状态无关)
	* DIDM考虑政策发生时点前后的观测，并将政策发生时点前后处理状态发生变化的个体视作处理组， 比较这些处理组个体实际接受处理后的结果与其反事实结果，从而得到处理效应。由于处理组个体在未接受政策处理状态下的反事实结果不可得，DIDM估计量的任务就是利用样本构造一个对应于 δ的估计量。在思想上，DIDM与传统的DID估计量非常相似，只不过其处理组限制为政策发生时点前后政策处理状态发生变化的个体，而控制组则限制为政策发生时点前后政策处理状态未发生变化的个体。
	注意： DIDM与传统的平均处理效应存在区别：DIDM考察的是处理组和控制组在 t-1期和t 期之间的差异， 因此它估计出的是即时处理效应(Instantaneous Treatment Effect)。传统的平均处理效应实际上是将政策带来的即时处理效应和动态处理效应进行加权平均后得到的结果 
	*文章来源：https://mp.weixin.qq.com/s/ZzYI41SHhTKLCXFGZYqvyA
				https://asjadnaqvi.github.io/DiD/docs/code/06_did_multiplegt/
				http://www.360doc.com/content/20/0907/20/29540381_934453798.shtml
	
	*-------did_multiplegt命令介绍--------*
	*命令安装
	ssc install did_multiplegt, replace
	*语法
	did_multiplegt Y G T D [if] [in] [, options]
		/*
		其中，输入的变量定义如下：
		Y 输入结果变量；
		G 输入分组变量；
		T 是时间变量；
		D 是处理变量，双重差分。
		options 选项定义如下：

		placebo(#)：输入安慰剂效应的数量；
			dynamic(#)	Number of lags to be estimated,此选项指定政策后几期
			placebo(#)	Number of leads to be estimated,此选项指定政策前几期，一般placebo数量小于dynamic
		controls(varlist)：加入控制变量；
		breps(#)：输入重抽样的次数，用以计算标准误。
		报告的结果保存到 e() 中，具体如下：

		e(effect_0)：估计政策转换的效应；
		e(N_effect_0)：估计的样本数；
		e(N_switchers_effect_0)：估计中出现政策转换 (0 到 1、1 到 0) 的数量；
		e(se_effect_0：当启用 breps() 时报告标准误；
		e(placebo_i) 是在政策转换之前  期的安慰剂效应估计；
		e(N_placebo_i) 是估计安慰剂用到的样本数；
		e(se_placebo_i) 是安慰剂效应的标准误。
		*/
	*使用 twowayfeweights 估计双边固定效应的系数，检验异质处理的稳健性，再使用 did_multiplegt 命令估计状态转换 (switchers) 的平均处理效应。
	*下载数据
		ssc install bcuse, replace
		bcuse wagepan,clear
	*固定效应估计和检验
		ssc install twowayfeweights, replace
		twowayfeweights lwage nr year union, type(feTR) controls()
		//其中，结果变量 lwage 是工资对数，分组变量 nr 相当于每一个人的 ID，时间变量 year 是 1980-1987 年，处理变量 union 是二元变量，并且 1 表示属于工会，0 表示不属于工会,type(feTR)表示考察双向固定效应Fe的权重。
		//结果：固定效应估计中，有 860 个正权重，204 个负权重，两个检验发现系数估计在异质处理下接近于 0，是不稳健的。因此，我们使用 DIDM 模型 did_multiplegt 进一步观察工会对于工人工资的影响。
	*模型估计
		did_multiplegt lwage nr year union, placebo(1) breps(50) cluster(nr)
		//结果显示，工会的作用效果为 0.026，即加入工会能够提高工资 2.6%，此结果与原论文的估计 20% 差异较大，说明异质性处理确实影响了系数的估计。在安慰剂效应中估计值为 0.099，拒接安慰剂估计为 0 的假设，说明模型可能不符合共同趋势的设定。
		did_multiplegt lwage nr year union, placebo(5) breps(50) cluster(nr) dynamic(1) //dynamic(5)处理前后五期
		use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear
		twowayfeweights so2 cid year dum_ta, type(feTR)
		did_multiplegt so2 cid year dum_ta,robust_dynamic dynamic(4) placebo(4) breps(500) cluster(cid) jointtestplacebo seed(1) covariances  //dum_ta处理变量，双重差分
		
***********************
*** Sun and Abraham *** --- (加权)考虑了后处理组
***********************
	*文章来源：https://asjadnaqvi.github.io/DiD/docs/code/06_eventstudyinteract/
	*文献：Liyang Sun, Sarah Abraham (2021). Estimating dynamic treatment effects in event studies with heterogeneous treatment effects. Journal of Econometrics.
	*Sun 和 Abraham (2021) 认为还能够使用后处理组作为控制组，允许使用简单的线性回归进行估计
	*作者定义了 "组别 － 时期平均处理效应"， 在估计时则选取 "尚未接受处理" 和 "从未接受处理" 的样本作为对照
	*命令安装
	ssc install eventstudyinteract, replace
	*语法
	eventstudyinteract Y *lags* *leads*, vce(cluster *var*) absorb(*i* *t*) cohort(first_treat) control_cohort(*variable*)
		/*
		Y	outcome variable
		i	panel id
		t	time variable
		lags	手动生成滞后变量
		leads	手动生成前置变量
		first_treat	首次处理的时间（未处理组缺失）
		control_cohort(var)	The variable here is either never treated observations, or last treated cohorts
		*/
	use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear
	gen treat = birth~=.
	gen never_treat = birth==.
	gen event = year - birth   //减去政策发生年份 
		
	replace event = -5 if event < -5 
	replace event = 5 if event > 5   & event~=. 
	forvalues i=5(-1)1{
	  gen pre`i'=(event==-`i'& treat==1)
	}

	gen current=(event==0 & treat==1)

	forvalues i=1(1)5{         //政策发生后
	  gen post`i'=(event==`i'& treat==1)
	}

	drop pre5    //删掉基准组

	eventstudyinteract so2 pre* current post*, cohort(birth) control_cohort(never_treat) absorb(i.cid i.year) vce(cluster cid)

	forvalue i=1(1)10 {
	local m_`i'=e(b_iw)[1,`i']
	local v_`i'=e(V_iw)[1,`i']
	}
	matrix input mat1_sa= (`m_1',`m_2',`m_3',`m_4',`m_5',`m_6',`m_7',`m_8',`m_9',`m_10')
	mat colnames mat1_sa=     g_m4 g_m3 g_m2 g_m1 g_0 g_1 g_2 g_3 g_4 g_5
	matrix input mat3_sa= (`v_1',`v_2',`v_3',`v_4',`v_5',`v_6',`v_7',`v_8',`v_9',`v_10')
	mat colnames mat3_sa= 	g_m4 g_m3 g_m2 g_m1 g_0 g_1 g_2 g_3 g_4 g_5

	event_plot mat1_sa#mat3_sa, stub_lag(g_#) stub_lead(g_m#) trimlag(5) ciplottype(rcap) ///
	plottype(scatter) ///
	graph_opt(bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0, lpattern(dash) lcolor(gs12) lwidth(thin)) legend(off) ///
	yline(0, lpattern(solid) lcolor(gs12) lwidth(thin)) legend(off) ///
	ylabel(, labsize(small)) ///
	xlabel( -4 -3 -2 -1 0 1 2 3 4 5, labsize(small)) ///
	ytitle("Coefficient", height(6) size(small)) title("Sun and Abraham (2021)",size(small)) ///
	xtitle("Semester to/from FB Introduction", height(6) size(small)) xsize(6) ysize(4)) ///
	lag_opt(msymbol(Th) mcolor(green) msize(small)) lead_opt(msymbol(Th) mcolor(green) msize(small)) ///
	lag_ci_opt(lcolor(green) lwidth(medthin)) lead_ci_opt(lcolor(green) lwidth(medthin))
	graph save "$TEMP/event_study_SA", replace

******************************
*** Callaway and Sant'Anna *** --- (加权)从未受处理
******************************	
	*文献：Brantly Callaway, Pedro H.C. Sant'Anna  (2020). Difference-in-Differences with multiple time periods, Journal of Econometrics .
	*Callaway 和 SantAnna (2021) 将 t 期以前从未受处理的组作为控制组进行估计
	*要使用 csdid 命令来获得 DID 无偏估计量，一般只能使用 never-treated 和 (或) not-yet-treated 的数据作为控制组，而不能使用 always-treated 组。否则由于异质性处理效应，平行趋势假设并不能满足，从而估计结果仍旧有偏；
	*该新方法适用于以下三种情形：
		1、时间分为多期；
		2、实验组受到政策冲击的时间并非同一；
		3、实验组和对照组只有在控制了协变量之后才满足平行趋势假定。
	* 他们提出的估计量同样需要先计算每个组别－时期内的平均处理效应即ATT， 随后对ATT进行加总从而获得平均处理效应的估计，而标准误则通过Bootstrap的方式获取。计算ATT时仅考虑组别第一次接受处理时期为 ｅ(接受处理时间点) 的样本和控制组的样本， 而忽略所有其他样本。同时给予控制组中的那些与处理组内出现更频繁的个体特征更相似的样本以更大的权重， 反之则给予较小的权重。 这种做法确保了处理组和控制组的个体在特征方面的平衡性。 值得注意的是， 控制组个体可以是从未接受处理的个体，也可以是在样本期ｔ之前尚未接受处理的个体。
	*但是，Callaway 和 SantAnna (2021) 提到，某些情况下研究者可能怀疑 "从未接受处理组" 在特征上与接受处理的样本存在较大差别， 出于这种顾虑研究者可以删去数据中所有从未接受处理的样本， 并在估计时选择 "尚未接受处理组(Not-Yet-Treated Group)"作为控制。 此外需要指出的是，Callaway 和 SantAnna (2021) 在原文中指出以从未接受处理组和以尚未接受处理组为控制组时计算 ATT的公式有所不同
	总结：Callaway 和 SantAnna (2021)与 Sun 和 Abraham (2020)的方法之间的主要区别在于：
	（１） 两者计算组别－时期平均处理效应的方式不同， 前者使用非参方法进行计算而后者则
采用线性回归进行计算； 
	（２） 两者对于组别－时期平均处理效应的加权方式有所不同。 值得一提的是， 当样本中存在从未接受处理组时，Callaway 和 SantAnna (2021) 提出的估计量 ATT(e,t) 与 Sun 和 Abraham (2021) 提出的估计量计算得到的 CATT在数值上是等价的。 两者的关键区别在于当不存在从未接受处理组时， Callaway 和 SantAnna (2021)提出的估计量可以使用尚未接受处理组(Not-Yet-Treated Group), 而 IW 估计量则需要对样本进行删减并使用最后接受处理的样本作为控制组
	（ 3 ） 不过这类方法仍有几个问题未能充分解决： 第一，计算组别 － 时期平均处理效应的过程中丢失了大量样本（Borusyak等，2021），这可能会影响估计效率；第二， 这类方法并非都能应对政策存在退出的情形。第三，部分方法会依赖 "从未接受处理组" 的存在。
	（ 4 ）  第一， 当样本量不充足时，这类方法的估计效率将会受到较大影响，因此要审慎解读估计结
果，与此同时建议研究者汇报这类方法在估计时使用到的样本量； 第二， 当政策存在退出情形时，Sun 和 Abraham (2021) 、Callaway 和 SantAnna (2021)提出的方法将不再适用， 因此建议研究者采用 De Chaisemartin 和 D`Haultfoeuille (2020a,2022a) 提出的估计量进行估计。 第三， 当样本中不存在 "从未接受处理的个体" 时， 建议谨慎采用Sun 和 Abraham (2021)的方法。尽管研究者可以通过将样本中最后接受处理的个体作为从未接受处理的个体来对待，即删除最后接受处理的个体在处理之后的全部样本， 但可能会带来样本筛选问题。
	*文章来源：https://www.lianxh.cn/news/762e878e7063b.html
				https://www.lianxh.cn/news/10d7ae6efea16.html
	
	* 命令的安装
	ssc install csdid, all replace
	ssc install drdid,replace
	* 命令的语法
	csdid depvar [indepvars] [if] [in] [weight], [ivar(varname)] time(varname) gvar(varname) [ options ]
	/*
	对于面板数据，模型设定的选项包括以下四类：
		depvar 为被解释变量，indepvars 为解释变量和控制变量；
		ivar(varname) 和 time (varname) 为面板设置选项。其中 ivar(varname) 设置个体标识变量，time (varname) 设置时间标识变量；
		gvar(varname) 为多时期 DID 标识变量，和通常的多时期 DID 赋值不太一样。如果在样本期受到过政策冲击，赋值等于其受到冲击的期数序号。例如，在第 1 期受到冲击，赋值为 1。需要注意的是，如果某个个体在样本期开始前就已经受到冲击，即属于所谓的 always-treated 组，默认是不进入回归中；
		notyet 要求对照组里不仅要有 not-yet 组里尚未受到冲击的样本，同时也要包括 always-treated 组样本。默认是不包括后者；
		long 和 long2 对于冲击发生前的样本期的样本，使用 long gaps 而非 shortgaps；
		估计方法的选项包括：渐进型双重稳健估计 (drimp)、基于 ipw 的双重稳健估计量 (dripw)、outcome regression 估计量 (reg)、标准化 ipw 估计量 (stdipw)、ipw 估计量 (ipw)；
		标准误的选项默认是 robust and asymptotic standard errors，同时也可以选择 wboot、cluster 等；
		不同组别政策效应加总 agg(aggtype)。加总方式 (aggtype) 包括：加总所有组所有时期 (simple)、每一组或者一群在所有时期加总 (group)、所有组在每一个时期分别加总 (calendar)、采用事件发生法在每一个时期分别加总 (event) 四大类。
	*/	
		 * 使用 agg(simple) 选项, 估计总 ATT；使用agg(event) 估计分时期ATT
		 * method(dripw) 表示使用增进型双重稳健估计
		 use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear

		 csdid so2,  time(year) gvar(birth) agg(event) method(dripw) notyetlong rseed(1) cluster(cid)  //agg(event) 估计分时期ATT,ivar(cid)要求每一年个体相同
			estat all  //列出所有组别政策效应加总
		event_plot e(b)#e(V), default_look graph_opt(xtitle("Periods since the event")             ///
		 ytitle("Average causal effect") xlabel(-4(1)5) title("Callaway and Sant'Anna (2020)") ///
		 name(CS, replace)) stub_lag(Tm#) stub_lead(Tp#) trimlag(5) trimlead(4) together

***************************
*** Cengiz et al.(2019) *** --- 堆叠
***************************
	*文献：Doruk Cengiz , Arindrajit Dube , Attila Lindner, Ben Zipperer  (2019). The effect of minimum wages on low-wage jobs. The Quarterly Journal of Economics.
	*文章来源：https://asjadnaqvi.github.io/DiD/docs/code/06_stackedev/
	*与计算加权 ATT 的方法相比，Cengiz 等 (2019) 认为堆叠 (Stacking) 也是解决 TWFE 估计偏误的替代方法，基本思路是将数据集重建为相对事件时间的平衡面板，然后控制组群效应和时间固定效应，以得到处理效应的加权平均值。
	* 从直觉上看， 这种方法为每一个处理组的观测都匹配了从未接受处理或尚未接受处理的观测， 进而形成一个数据集， 随后将这些数据集堆叠在一起， 通过进一步加入组别－个体、 组别－时间固定效应进行线性回归。与前两类方法相似，从本质上讲这种做法也是通过避免使用较早接受处理组作为控制组来解决处理效应异质性问题。具体来说，首先为每一个处理组ｍ匹配从未接受处理或尚未接受处理的样本作为控制组，以此形成一个数据集，再将这些数据集堆叠。定义组别ｍ的固定效应并将该固定效应与个体固定效应和时期固定效应交乘。最后，使用公式进行回归即可估计平均处理效应。
	*需要指出的是，堆叠回归估计量在应用中会出现数据重复或嵌套的问题，其原因在
	//于部分样本可能在不同的子数据集中作为控制组被重复使用， 因此在应用该方法时应格外注意样本量的变化以及聚类问题， 此外Cengiz et al.(2019) 在其研究工作中尚未提及这种堆叠估计量所依赖的前提假设和统计量的性质，因此这些方面的内容有待研究者进一步挖掘。
	* 堆叠回归估计量目前面临的主要问题有两个： 第一， 该方法提供的估计量的统计性质并没有给出， 也未经过严格证明；第二，该估计量在估计的过程中可能会造成数据重复使用的问题。 此外， 现有堆叠回归估计量的软件包不够完善，只能计算动态效应中各期的系数，无法直接实现加权平均， 目前研究者应用时大多手工堆叠数据后再进行回归， 因此没有形成统一且规范的做法。 基于以上问题，本文建议研究者谨慎采用堆叠估计量进行交错DID估计，当然，可以将其作为一种稳健性检验的方式。
	
	*安装命令
	ssc install stackedev, replace
	*语法
	stackedev Y F* L* , cohort(first_treat) time(t) never_treat(no_treat) unit_fe(i) clust_unit(i)
		/*
		Y	outcome variable
		i	panel id
		t	time variable
		lags	manually generated lag variables
		leads	manually generated lead variables
		first_treat	Year of first treatment
		no_treat	Dummy = 1 if unit is never treated
		*/
		

		use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear
		gen treat = birth~=.
		gen no_treat = birth==.
		gen event = year - birth   //减去政策发生年份 
			
		replace event = -5 if event < -5 
		replace event = 5 if event > 5   & event~=. 
		forvalues i=5(-1)1{
		  gen pre`i'=(event==-`i'& treat==1)
		}

		gen current=(event==0 & treat==1)

		forvalues i=1(1)5{         //政策发生后
		  gen post`i'=(event==`i'& treat==1)
		}

		drop pre5    //删掉基准组

		stackedev so2 pre* current post*, cohort(birth) time(year) never_treat(no_treat) unit_fe(cid) clust_unit(cid)

		forvalue i=1(1)10 {
		local m_`i'=e(b)[1,`i']
		local v_`i'=e(V)[`i',`i']
		}
		matrix input mat1_cd= (`m_1',`m_2',`m_3',`m_4',`m_5',`m_6',`m_7',`m_8',`m_9',`m_10')
		mat colnames mat1_cd=     g_m4 g_m3 g_m2 g_m1 g_0 g_1 g_2 g_3 g_4 g_5
		matrix input mat2_cd= (`v_1',`v_2',`v_3',`v_4',`v_5',`v_6',`v_7',`v_8',`v_9',`v_10')
		mat colnames mat2_cd= 	g_m4 g_m3 g_m2 g_m1 g_0 g_1 g_2 g_3 g_4 g_5

		event_plot mat1_cd#mat2_cd, stub_lag(g_#) stub_lead(g_m#) trimlag(5) ciplottype(rcap) ///
		plottype(scatter) ///
		graph_opt(bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
		xline(0, lpattern(dash) lcolor(gs12) lwidth(thin)) legend(off) ///
		yline(0, lpattern(solid) lcolor(gs12) lwidth(thin)) legend(off) ///
		ylabel(, labsize(small)) ///
		xlabel( -4 -3 -2 -1 0 1 2 3 4 5, labsize(small)) ///
		ytitle("Coefficient", height(6) size(small)) title("Cengiz et al.(2019)",size(small)) ///
		xtitle("Semester to/from FB Introduction", height(6) size(small)) xsize(6) ysize(4)) ///
		lag_opt(msymbol(Th) mcolor(green) msize(small)) lead_opt(msymbol(Th) mcolor(green) msize(small)) ///
		lag_ci_opt(lcolor(green) lwidth(medthin)) lead_ci_opt(lcolor(green) lwidth(medthin))

*********************************
*** Roth and Sant' Anna(2023) *** --- staggered
*********************************
	*在RS（2023）的文章中，作者从理论上证明，如果处理时点是（准）随机配置的，那么，我们可以获得比上述交叠DID估计量更精确的处理效应估计量。他们推导出了最有效率的估计量，并展示了基于t统计量和perimutation的推断。他们文章的实践含义在于，只要我们用随机处理检验来为平行趋势假设提供经验证据的话，使用RS（2023）估计量会极大地降低标准误。因此，在实践应用中，我们可以在随机处理检验，并通过该检验后，使用RS估计量来帮助识别出更精确的处理效应。
	*文章来源：https://mp.weixin.qq.com/s/TZZ19i9Vi1mzaMueQlT2sA
	*命令安装
	local github https://raw.githubusercontent.com
	net install staggered, all from(`github'/mcaceresb/stata-staggered/main) replace
	*语法
	staggered depvar , i(individual) t(time) g(cohort) estimand()  [options]
	* 加载数据
	local github https://github.com/mcaceresb/stata-staggered
    use `github'/raw/main/pj_officer_level_balanced.dta, clear

	//其中，uid是个体变量，period是时间变量，first_trained是同一处理时点类别变量，complaints是结果变量。
	//RS（2023）的stata命令staggered提供了三种方式来加总类别和时期间的处理效应：简单加权平均、时期加权平均和类别加权平均处理效应
	*① 计算简单加权平均估计量
	use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear
	staggered so2, i(cid) t(year) g(birth) estimand(simple)
	*② 计算类别加权估计量
	staggered so2, i(cid) t(year) g(birth) estimand(cohort)
	*③ 计算时期加权估计量
	staggered so2, i(cid) t(year) g(birth)  estimand(calendar)
	*④ 计算事件研究估计量
	staggered  so2, i(cid) t(year) g(birth) estimand(eventstudy) eventTime(-4/5)
		*做出事件研究图
		tempname CI b  //生成临时文件
		mata st_matrix("`CI'", st_matrix("r(table)")[5::6, .]) //提取上下置信区间，mata st_matrix("`CI'", st_matrix("r(table)")[5::6,1::10])表示提取5-6行的1-10列（[5::6,1..10]也是），[5::6,(1,3,4)]，表示提取5-6行的第一三四列
		mata st_matrix("`b'",  st_matrix("e(b)"))
		matrix colnames `CI' = -4 -3 -2 -1 0 1 2 3 4 5
		matrix colnames `b'  =   -4 -3 -2 -1 0 1 2 3 4 5   //不能直接等于`:rownames e(thetastar)'，因为有缺失值
		coefplot matrix(`b'), ci(`CI') vertical yline(0) ciopts(recast(rcap) lwidth(thin) lpattern(dash) lcolor(red)) 
		/*
		*----2.单行调用Mata并计算t统计量---
		mata: st_matrix("bst",st_matrix("e(b)") :/ sqrt(diagonal(st_matrix("e(V)"))'))
			/*该行代码具体解释如下：
			st_matrix()的使用可利用 help mata st_matrix 进行查看
			bst为逗号后矩阵命名。st_matrix(name, X)将Stata中的名为name的矩阵新建/替换为X中的内容
			st_matrix("e(b)")调用系数矩阵
			diagonal(st_matrix("e(V)"))'代表提取协方差矩阵后取对角线元素，并转置。//diagonal()提取对角线元素保留为矩阵，A'表示矩阵A的转置
			利用元素运算符:/完成对应估计量的t统计量运算
			例如，m3 = r1 :/ r2    //将行向量r1中的元素逐行除以r2的每一行，得3*3矩阵
			mata: st_matrix("bst",diagonal(st_matrix("e(V)")[1::10,1..10]))，获得10×10矩阵对角线元素，原矩阵是11×11
			*/

		*----3.处理生成的bst矩阵的行列名细节----
		matrix rownames bst = tstat                 //行命名
		matrix colnames bst = `: colnames e(b)'        //列命名
		matrix list bst, format(%9.3f)                //输出结果

		*/
	//除了上述t统计量推断外，还可以使用permutation推断。这些检验是基于studentized统计量。原假设：没有处理效应。
		* Calculate efficient estimator for the simple weighted average
		* Use Fisher permutation test with 500 permutation draws
	staggered so2, i(cid) t(year) g(birth) estimand(simple) num_fisher(500)
	*综合代码
	staggered so2, i(cid) t(year) g(birth) estimand(eventstudy simple) eventTime(-4/5) num_fisher(500)
			*做出事件研究图
		tempname CI b  //生成临时文件
		mata st_matrix("`CI'", st_matrix("r(table)")[5::6, .]) //提取上下置信区间
		mata st_matrix("`b'",  st_matrix("e(b)"))
		matrix colnames `CI' = -4 -3 -2 -1 0 1 2 3 4 5
		matrix colnames `b'  =   -4 -3 -2 -1 0 1 2 3 4 5   //不能直接等于`:rownames e(thetastar)'，因为有缺失值,matrix colnames `b'  = `:rownames e(thetastar)'
		coefplot matrix(`b'), ci(`CI') vertical yline(0) ciopts(recast(rcap) lwidth(thin) lpattern(dash) lcolor(red)) 
***********************************
*** Freyaldenhoven et al.(2019) *** --- xtevent
***********************************
	*文献：Simon Freyaldenhoven, Christian Hansen, Jesse M. Shapiro (2019). Pre-event Trends in the Panel Event-Study Design. American Economic Review .
	*Freyaldenhoven 等 (2019) 提出处理面板事件研究的估计方法
	use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear
	ssc install xtevent,replace
	xtevent so2, policyvar(dum_ta) panelvar(cid) timevar(year) window(3) plot 
	
*********************************************
*** Clarke and Kathya Tapia Schythe(2020) *** --- eventdd
*********************************************
	*文献：Damian Clarke, Kathya Tapia Schythe (2020). Implementing the Panel Event Study.
	*文章来源：https://mp.weixin.qq.com/s/Unp4LhnRPecwdtxe5nf38w
	*			https://lianxh.cn/news/e715545930fcf.html
	*本文介绍的是事件研究法 (event study) 在 Stata 中的实现命令 eventdd，该命令由 Damian Clarke 和 Kathya Tapia Schythe 在 2020 年共同开发。与以往关于事件研究法的介绍不同，本文将侧重于这种方法在倍分法平行趋势检验中的具体应用。事件研究法是一种与倍分法 (DID) 相类似的面板事件研究方法，eventdd 可实现对各时间项系数及置信区间的计算和图形展示。其中，各滞后项和前置项的系数对应的是该事件效应在不同时间中的变化趋势
	
	// 命令安装
	ssc install eventdd, replace
	// 基本语法
	eventdd varlist(min=2 fv ts numeric) [if] [in] [weight], timevar(varname) [options]
		/*
		其中基本选项如下，
		varlist(y x1 ... xn)：回归用到的因变量和控制变量；
		timevar()：回归用到的时间项；
		if、in 和 [weight]：与普通OLS回归一致，if 和  in 限定要导出的数据的范围，[weight] 是对数据进行加权的相关选项；
		options 选项如下：

		ci(string)：图形置信区间的风格 (必须设定)，rarea 指带有区域阴影，rcap 指带有上限的直线， rline 仅是直线；
		baseline(#)：选择哪一期作为基准组，默认选择 -1 期；
		level(#)：设定显著性水平，默认为 95%；
		ols：回归时使用 regress 命令；
		fe：回归时使用 xtreg 命令；
		hdfe：回归时使用 reghdfe 命令；
		keepbal(stfips)：仅保留在每一期都出现了的观测值；
		inrange：仅将特定时间区间的样本纳入回归；
		lags(#)：纳入回归的滞后项项数；
		leads(#)：纳入回归的前置项项数；
		graph_op(string)：画图相关命令，与 twoway 命令一致。
		其中，ci(string) 和 timevar(varname) 是必须进行设定的选项。在已经安装了 xtreg 和 reghdfe 的前提下，可以通过设定 fe 和 reghdfe 分别调用 xtreg 和 reghdfe 命令。最后，相关图形设定与 twoway 命令一致。关于该命令更多选项介绍，读者可通过 help eventdd 继续进行探索。
		*/
		use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear
		gen event = year - birth  
		eventdd so2 , method(hdfe,absorb(i.year i.cid) cluster(cid)) accum leads(5) lags(5)  timevar(event) ci(rcap) ///
       baseline(-5) graph_op(ytitle("Suicides per 1m Women") )  //除了仅展示部分期数外，还可以直接对超出分析窗口的期数做缩尾处理，将 inrange 替换为 accum 命令即可，其余设定不变。
	   //多数情况下，我们并不需要这么长的分析窗口，时间一长，很难避免其他不可观测因素的影响。因此，我们更倾向于把事件分析窗口压缩至较短范围。例如将分析窗口限定在政策实施前后的 10 期内：
	   
*-----------参考资料----------
	*文章来源：https://www.shangyexinzhi.com/article/4434294.html
	Andrew Goodman-Bacon  (2021). Difference-in-differences with variation in treatment timing. Journal of Econometrics
	Brantly Callaway, Pedro H.C. Sant'Anna  (2020). Difference-in-Differences with multiple time periods, Journal of Econometrics .
	John Gardner (2021). Two-stage differences in differences.
	De Chaisemartin C, d'Haultfoeuille X. Two-way fixed effects estimators with heterogeneous treatment effects[J]. American Economic Review, 2020, 110(9): 2964-96. 
	Clément de Chaisemartin, Xavier D'Haultfoeuille (2021). Two-way fixed effects regressions with several treatments.
	Kirill Borusyak , Xavier Jaravel , Jann Spiess  (2021). Revisiting Event Study Designs: Robust and Efficient Estimation.
	Damian Clarke, Kathya Tapia Schythe (2020). Implementing the Panel Event Study.
	Liyang Sun, Sarah Abraham (2021). Estimating dynamic treatment effects in event studies with heterogeneous treatment effects. Journal of Econometrics.
	Doruk Cengiz , Arindrajit Dube , Attila Lindner, Ben Zipperer  (2019). The effect of minimum wages on low-wage jobs. The Quarterly Journal of Economics.
	Simon Freyaldenhoven, Christian Hansen, Jesse M. Shapiro (2019). Pre-event Trends in the Panel Event-Study Design. American Economic Review .
	Baker A, Larcker D F, Wang C C Y. How Much Should We Trust Staggered Difference-In-Differences Estimates?[J]. Available at SSRN 3794018, 2021. 
	刘冲, 沙学康, 张妍. 交错双重差分:处理效应异质性与估计方法选择[J]. 数量经济技术经济研究, 2022, 39(9):28.
