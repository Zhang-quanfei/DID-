*Braghieri, Luca, Ro'ee Levy, and Alexey Makarin. 2022. "Social Media and Mental
*Health." American Economic Review , 112 (11): 3660-93.
*图二 的 代码
*******************************************************************************
**** FIGURE 2: EFFECTS OF FACEBOOK ON THE INDEX OF POOR MENTAL HEALTH BASED ON
**** DISTANCE TO/FROM FACEBOOK INTRODUCTION
* TWFE OLS
	use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear
	global controls 年末总人口_全市_万人
	
	preserve
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
	mata: st_matrix("mat2_ols",diagonal(st_matrix("e(V)")[1::10,1..10])')  //diagonal()提取对角线元素保留为矩阵，A'表示矩阵A的转置
	mata st_matrix("mat1_ols",  st_matrix("e(b)")[1::10])
	matrix colnames mat2_ols = T-4 T-3 T-2 T-1 T+0 T+1 T+2 T+3 T+4 T+5
	matrix colnames mat1_ols  = T-4 T-3 T-2 T-1 T+0 T+1 T+2 T+3 T+4 T+5
	
	event_plot mat1_ols#mat2_ols, stub_lag(T+#) stub_lead(T-#) trimlag(5) ciplottype(rcap) plottype(scatter)  ///
	graph_opt(bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0, lpattern(dash) lcolor(gs12) lwidth(thin)) legend(off) ///
	yline(0, lpattern(solid) lcolor(gs12) lwidth(thin)) legend(off) ///
	ylabel(, labsize(small)) ///
	xlabel( -4 -3 -2 -1 0 1 2 3 4 5, labsize(small)) ///
	ytitle("Coefficient", height(6) size(small)) title("Borusyak, Jaravel, and Spiess (2021)",size(small)) ///
	xtitle("Semester to/from FB Introduction", height(6) size(small)) xsize(6) ysize(4)) ///
	lag_opt(msymbol(D) mcolor(blue) mfc(none) msize(small)) lead_opt(msymbol(D) mfc(none) mcolor(blue) msize(small)) ///
	lag_ci_opt(lcolor(blue) lwidth(medthin)) lead_ci_opt(lcolor(blue) lwidth(medthin))
	restore
***********************
*** Borusyak et al. ***
***********************
* 提供了一种基于插补的反事实方法解决 TWFE 的估计偏误问题。基于 TWFE，通过估计组群固定效应、时间固定效应和处理组-控制组固定效应，可以得到更准确的估计量
* For this estimator, it's important to notice that the more pre-periods one adds, the more the  
//standard errors on the pre-period coefficients explode. So, we can't use all pre-periods. We need  
//to use only a subset of them.	
	preserve
	
	did_imputation so2 cid year birth, fe(cid year) autosample horizons(0 1 2 3 4  ) pretrends(4) cluster(cid)   //horizons(0 1 2) 只汇报政策时 政策后第一期 政策第二期

	matrix define mat1_bor=e(b)
	mata: st_matrix("mat2_bor",diagonal(st_matrix("e(V)"))')
	mat colnames mat1_bor= T+0 T+1 T+2 T+3 T+4 T-1 T-2 T-3 T-4
	mat colnames mat2_bor= T+0 T+1 T+2 T+3 T+4 T-1 T-2 T-3 T-4
	//支持输入mat1_bor#mat2_bor矩阵交互，mat1_ols是系数矩阵，mat2_ols是方差矩阵；trimlag(4)表示截断到后面第四期 ；ciplottype(rcap)表示置信区间样式为"帽子"；plottype(scatter)表示画图类型用"点"表示；stub_lag表示政策的后几期；stub_lead表示政策的前几期
	event_plot mat1_bor#mat2_bor, stub_lag(T+#) stub_lead(T-#) trimlag(4) ciplottype(rcap) plottype(scatter)  ///
	graph_opt(bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0, lpattern(dash) lcolor(gs12) lwidth(thin)) legend(off) ///
	yline(0, lpattern(solid) lcolor(gs12) lwidth(thin)) legend(off) ///
	ylabel(, labsize(small)) ///
	xlabel( -4 -3 -2 -1 0 1 2 3 4, labsize(small)) ///
	ytitle("Coefficient", height(6) size(small)) title("Borusyak, Jaravel, and Spiess (2021)",size(small)) ///
	xtitle("Semester to/from FB Introduction", height(6) size(small)) xsize(6) ysize(4)) ///
	lag_opt(msymbol(D) mcolor(blue) mfc(none) msize(small)) lead_opt(msymbol(D) mfc(none) mcolor(blue) msize(small)) ///
	lag_ci_opt(lcolor(blue) lwidth(medthin)) lead_ci_opt(lcolor(blue) lwidth(medthin))
	graph save "$TEMP/event_study_BJS", replace

******************************
*** Callaway and Sant'Anna ***
******************************
	csdid so2,  time(year) gvar(birth) agg(event) method(dripw) notyetlong rseed(1) cluster(cid)  //agg(event) 估计分时期ATT,ivar(cid)要求每一年个体相同
		estat all  //列出所有组别政策效应加总
	*提取想要的系数
	mata st_matrix("mat1_cs",  st_matrix("e(b)")[,12..21])
	mata: st_matrix("mat2_cs",diagonal(st_matrix("e(V)")[12..21,12..21])')  
	mat colnames mat1_cs=  T-4 T-3 T-2 T-1 T+0 T+1 T+2 T+3 T+4 T+5
	mat colnames mat2_cs=  T-4 T-3 T-2 T-1 T+0 T+1 T+2 T+3 T+4 T+5
	
	event_plot mat1_cs#mat2_cs , stub_lag(T+#) stub_lead(T-#) ciplottype(rcap) ///
	plottype(scatter) ///
	graph_opt(bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0, lpattern(dash) lcolor(gs12) lwidth(thin)) legend(off) ///
	yline(0, lpattern(solid) lcolor(gs12) lwidth(thin)) legend(off) ///
	ylabel(, labsize(small)) ///
	xlabel( -4 -3 -2 -1 0 1 2 3 4 5, labsize(small)) ///
	ytitle("Coefficient", height(6) size(small)) title("Callaway and Sant'Anna (2021)",size(small)) ///
	xtitle("Semester to/from FB Introduction", height(6) size(small)) xsize(6) ysize(4)) ///
	lag_opt(msymbol(o) mcolor(orange) msize(small)) lead_opt(msymbol(o) mcolor(orange) msize(small)) ///
	lag_ci_opt(lcolor(orange) lwidth(medthin)) lead_ci_opt(lcolor(orange) lwidth(medthin))
	graph save "$TEMP/event_study_CS", replace
	
*****************************************
*** DeChaisemartin and D'Haultfeuille ***
*****************************************
	*-------DIDM：多期多个体倍分法--------*
	*De Chaisemartin 和 D`Haultfoeuille (2020) 提出通过加权计算两种处理效应的值得到平均处理效应的无偏估计，这两种处理效应为：
	*	t-1期未受处理而 t 期受处理的组与两期都未处理的组的平均处理效应；
	*	t-1期受处理而 t 期未受处理的组与两期都受处理的组的平均处理效应。
	*	该方法的前提条件是处理效应不具有动态性 (即处理效应与过去的处理状态无关)
	*文章来源：https://mp.weixin.qq.com/s/ZzYI41SHhTKLCXFGZYqvyA
	*		   https://asjadnaqvi.github.io/DiD/docs/code/06_did_multiplegt/

	did_multiplegt so2 cid year dum_ta,robust_dynamic dynamic(4) placebo(4) breps(500) cluster(cid) jointtestplacebo seed(1) covariances  //dum_ta处理变量，双重差分
	//dynamic(#)	Number of lags to be estimated,此选项指定政策后几期；placebo(#)	Number of leads to be estimated,此选项指定政策前几期
	mata st_matrix("mat1_dcdh",  st_matrix("e(estimates)")')
	mata: st_matrix("mat2_dcdh",st_matrix(" e(variances) ")')  
	mat colnames mat1_dcdh= T+0 T+1 T+2 T+3 T+4 0 T-1 T-2 T-3 T-4 
	mat colnames mat2_dcdh= T+0 T+1 T+2 T+3 T+4 0 T-1 T-2 T-3 T-4 

	event_plot mat1_dcdh#mat2_dcdh, stub_lag(T+#) stub_lead(T-#) ciplottype(rcap) plottype(scatter) ///
	graph_opt(bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0, lpattern(dash) lcolor(gs12) lwidth(thin)) legend(off) ///
	yline(0, lpattern(solid) lcolor(gs12) lwidth(thin)) legend(off) ///
	xlabel( -4 -3 -2 -1 0 1 2 3 4, labsize(small)) ///
	ytitle("Coefficient", height(6) size(small)) title("De Chaisemartin and D'Haultfeuille(2020)", size(small)) ///
	xtitle("Semester to/from FB Introduction", height(6) size(small)) xsize(5) ysize(4)) ///
	lag_opt(msymbol(+) mcolor(red) msize(small)) lead_opt(msymbol(+) mcolor(red) msize(small)) ///
	lag_ci_opt(lcolor(red) lwidth(medthin)) lead_ci_opt(lcolor(red) lwidth(medthin))
	graph save "$TEMP/event_study_DCDH", replace
	restore
***********************
*** Sun and Abraham ***
***********************
	*文章来源：https://asjadnaqvi.github.io/DiD/docs/code/06_eventstudyinteract/
	
	*Sun 和 Abraham (2020) 认为还能够使用后处理组作为控制组，允许使用简单的线性回归进行估计
	preserve
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

	mata st_matrix("mat1_sa",  st_matrix("e(b_iw)"))
	mata: st_matrix("mat3_sa",diagonal(st_matrix("e(V_iw)"))') 
	mat colnames mat1_sa=     g_m4 g_m3 g_m2 g_m1 g_0 g_1 g_2 g_3 g_4 g_5
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
	restore
	
	* Combining
	event_plot mat1_bor#mat2_bor mat1_dcdh#mat2_dcdh mat1_cs#mat2_cs mat1_sa#mat3_sa mat1_ols#mat2_ols , stub_lag(T+# T+# T+# g_# T+#) stub_lead(T-# T-# T-# g_m# T-#)  ///
	plottype(scatter) ciplottype(rcap) together trimlag(5) noautolegend graph_opt(title("Event study estimators", size(medlarge)) xtitle("Periods since the event") ytitle("Average effect (std. dev.)")  ///  //trimlag展示变量滞后项
	xlabel( -4 -3 -2 -1 0 1 2 3 4 5, labsize(small)) ylabel(, labsize(small))  ///
	legend(region( lc(black) ) pos(10) ring(0) order(1 "Borusyak et al." 3 "De Chaisemartin-D'Haultfoeuille" 5 "Callaway-Sant'Anna" 7  ///   //ring(1) 表示在图外面，ring(0)表示在图内部，region(style(none))表示图例边框无格式 region(color(black)) 表示填充为黑色，region( lc(black) )表示边框为黑色
	"Sun-Abraham" 9 "TWFE OLS")  rows(3) ) xline(-0.5, lcolor(gs8) lpattern(dash))  /// 
	yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(-30(15)35, angle(horizontal)))  ///
	lag_opt1(msymbol(O) color(dkorange)) lag_ci_opt1(color(dkorange)) lag_opt2(msymbol(+)  ///
	color(cranberry)) lag_ci_opt2(color(cranberry)) lag_opt3(msymbol(Dh) color(navy))  ///
	lag_ci_opt3(color(navy)) lag_opt4(msymbol(Th) color(forest_green))   ///
	lag_ci_opt4(color(forest_green)) lag_opt5(msymbol(Sh) color(black)) lag_ci_opt5(color(black))  ///
	perturb(-0.325(0.13)0.325)   //表示将不同估计量的置信区间以0.13的值错开
	
	graph export "$REPLICATION/Figure 2.pdf", replace
