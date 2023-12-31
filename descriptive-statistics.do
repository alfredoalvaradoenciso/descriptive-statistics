*** Descriptive statistics using esttab (Basic) 
**treatment variable: foreign


sysuse auto, clear
global vars "price mpg trunk headroom length turn displacement"
eststo clear
eststo ttests: estpost ttest $vars, by(foreign)
eststo summstats: estpost summarize $vars
eststo treated: estpost summarize $vars if foreign==1
eststo non_treated: estpost summarize $vars if foreign==0
esttab summstats treated non_treated ttests using "table.csv", ///
       cell(p(fmt(%6.3f)) &  mean(fmt(%6.2f)) sd(fmt(%6.3f) par)) label replace  ///
       mtitle("Total" "Foreign"  "Domestic" "p-value")     ///
       title("Table. Descriptive statistics") collabels(none)

	   
*** Descriptive statistics using matrices
sysuse auto, clear
local vars "price mpg trunk headroom length turn displacement"
local num_vars: word count `vars'

local j = 1
foreach v of local vars {
mean `v' 
mat B`j'=[_b[`v'], _se[`v']]
matrix rownames B`j' = `e(varlist)'
count if foreign==1
mat N1`j'=r(N)
count if foreign==0
mat N0`j'=r(N)
local j = `j'+1
}

local j = 1
foreach v of local vars {
mean `v', over(foreign)
test _b[c.`v'@0bn.foreign]=_b[c.`v'@1.foreign]
mat E`j'=[_b[c.`v'@0bn.foreign],_se[c.`v'@0bn.foreign],_b[c.`v'@1.foreign],_se[c.`v'@1.foreign],r(p),e(N)]
local j = `j'+1
}
mat E=E1
mat B=B1
mat N1=N11
mat N0=N01
forval i =2/`num_vars'{
mat E=[E\E`i']
mat B=[B\B`i']
mat N1=[N1\N1`i']
mat N0=[N0\N0`i']
}
mat A=[B,E,N1,N0]

local num_vars: word count `vars'
xsvmat A, rowlabel(Variables) collabel(varname) list(, abbr(32) subvarname) norestore

forval s=2(2)6{ 
local k=`s'-1
replace A`k'=round(A`k',.1) if strmatch(Variables,"*%*")==0
replace A`k'=round(A`k'*100,.1) if strmatch(Variables,"*%*")==1
gen SE`s'="("+string(A`s',"%3.1f")+")" if strmatch(Variables,"*%*")==0
replace SE`s'="("+string(A`s'*100,"%3.1f")+")" if strmatch(Variables,"*%*")==1
}

rename (A1 A3 A5) (B1 B2 B3)

local num_vars = `num_vars'+2
set obs `num_vars'
gen id=_n
replace Variables="Control variables" if id==`num_vars'-1
replace Variables="Observations" if id==`num_vars'
replace id=4.5 if id==`num_vars'-1
sort id
replace B1=A8[1] if Variables=="Observations" 
replace B2=A9[1] if Variables=="Observations" 
replace B3=A10[1] if Variables=="Observations" 
gen B3star=string(B3,"%3.1f") 
replace B3star=string(B3,"%3.1f")+"*" if A7<=.1
replace B3star=string(B3,"%3.1f")+"**" if A7<=.05
replace B3star=string(B3,"%3.1f")+"***" if A7<=.01
replace B3star=string(A10[1],"%9.0fc") if Variables=="Observations" 
replace B3star="" if B3star=="."
label var Variables "Variables"
label var B1 "All"
label var B2 "Treated"
label var B3star "No treated"
format B1 B2 %9.1fc
order Variables B1 SE2 B2 SE4 B3star SE6
keep Variables B1 SE2 B2 SE4 B3star SE6

export excel "table.xlsx", replace firstrow(varl)

*Output in tex
/*
texsave Variables B1 SE2 B2 SE4 B3star SE6 using "table.tex", ///
 varlabels title("Descriptive statistics") nofix frag replace loc(htbp)  ///
 footnote("Source: Stata. Notes: Mean of variables. Standard errors in parentheses. Significance for mean tests between treated and not treated: * significant at 10%, ** significant at 5%, and *** significant at 1%.") 