*------------------
*--回归提取系数方法
*------------------	
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
	*1、meta 提取系数和方差
	*tempname Var b  //生成临时文件
	mata: st_matrix("Var",diagonal(st_matrix("e(V)")[1::10,1..10])')  //diagonal()提取对角线元素保留为矩阵，A'表示矩阵A的转置
	mata st_matrix("b",  st_matrix("e(b)")[,1..10])
	matrix colnames Var = T-4 T-3 T-2 T-1 T+0 T+1 T+2 T+3 T+4 T+5
	matrix colnames b  = T-4 T-3 T-2 T-1 T+0 T+1 T+2 T+3 T+4 T+5
	event_plot b#Var, stub_lag(T+#) stub_lead(T-#) trimlag(5) ciplottype(rcap) plottype(scatter)  ///
	graph_opt(bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0, lpattern(dash) lcolor(gs12) lwidth(thin)) legend(off) ///
	yline(0, lpattern(solid) lcolor(gs12) lwidth(thin)) legend(off) ///
	ylabel(, labsize(small)) ///
	xlabel( -4 -3 -2 -1 0 1 2 3 4 5, labsize(small)) ///
	ytitle("Coefficient", height(6) size(small)) title("Borusyak, Jaravel, and Spiess (2021)",size(small)) ///
	xtitle("Semester to/from FB Introduction", height(6) size(small)) xsize(6) ysize(4)) ///
	lag_opt(msymbol(D) mcolor(blue) mfc(none) msize(small)) lead_opt(msymbol(D) mfc(none) mcolor(blue) msize(small)) ///
	lag_ci_opt(lcolor(blue) lwidth(medthin)) lead_ci_opt(lcolor(blue) lwidth(medthin))
	*/
	*2、meta提取置信区间和系数

		tempname CI b  //生成临时文件
		mata st_matrix("`CI'", st_matrix("r(table)")[5::6, 1..10]) //提取上下置信区间，mata st_matrix("`CI'", st_matrix("r(table)")[5::6,1::10])表示提取5-6行的1-10列（[5::6,1..10]也是），[5::6,(1,3,4)]，表示提取5-6行的第一三四列
		mata st_matrix("`b'",  st_matrix("e(b)")[,1..10])
		matrix colnames `CI' = -4 -3 -2 -1 0 1 2 3 4 5
		matrix colnames `b'  =   -4 -3 -2 -1 0 1 2 3 4 5   //不能直接等于`:rownames e(thetastar)'，因为有缺失值
		coefplot matrix(`b'), ci(`CI') vertical yline(0) ciopts(recast(rcap) lwidth(thin) lpattern(dash) lcolor(red)) 
		/*
			*----2.单行调用Mata并计算t统计量---
			mata: st_matrix("bst",st_matrix("e(b)") :/ sqrt(diagonal(st_matrix("e(V)"))'))
			该行代码具体解释如下：
			st_matrix()的使用可利用 help mata st_matrix 进行查看
			bst为逗号后矩阵命名。st_matrix(name, X)将Stata中的名为name的矩阵新建/替换为X中的内容
			st_matrix("e(b)")调用系数矩阵
			diagonal(st_matrix("e(V)"))'代表提取协方差矩阵后取对角线元素，并转置。//diagonal()提取对角线元素保留为矩阵，A'表示矩阵A的转置
			利用元素运算符:/完成对应估计量的t统计量运算
			例如，m3 = r1 :/ r2    //将行向量r1中的元素逐行除以r2的每一行，得3*3矩阵
			mata: st_matrix("bst",diagonal(st_matrix("e(V)")[1::10,1..10]))，获得10×10矩阵对角线元素，原矩阵是11×11			
			*/

	*3、常规矩阵，逐个导入
	matrix define mat1_bor=e(b) //定义矩阵mat1_bor等于e(b)
	mat colnames mat1_bor= T+0 T+1 T+2 T+3 T+4 T-1 T-2 T-3 T-4
	forvalues i=1(1)9 {
	local v_`i'=e(V)[`i',`i']
	}
	matrix input mat2_bor= (`v_1',`v_2',`v_3',`v_4',`v_5',`v_6',`v_7',`v_8',`v_9') //生成1×10矩阵
	mat colnames mat2_bor= T+0 T+1 T+2 T+3 T+4 T-1 T-2 T-3 T-4
	
	
		