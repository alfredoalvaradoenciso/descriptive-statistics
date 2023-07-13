gl bases "C:\Users\Dell\Desktop\Ideas\sunafil\BASES"

*** (Basic) Descriptive statistics using esttab
sysuse auto, clear
eststo clear
eststo ttests: estpost ttest price mpg trunk, by(foreign)
eststo summstats: estpost summarize price mpg trunk
eststo treated: estpost summarize price mpg trunk if foreign==1
eststo non_treated: estpost summarize price mpg trunk if foreign==0
esttab summstats             ///
       treated               ///
       non_treated           ///
       ttests,               ///
       cell(p(fmt(%6.3f)) &  ///
       mean(fmt(%6.2f))      ///
       sd(fmt(%6.3f) par))   ///
       label replace         ///
       mtitle("Total"        ///
              "Foreign"      ///
              "Domestic"     ///
              "p-value")     ///
       title(Descriptive     ///
             Table)          ///
       collabels(none)

	   
*** (Advanced) Descriptive statistics using matrices
	   
use "$bases\BASE_ENAHO_SIAF_SUNAFIL.dta", clear 
**variable tratamiento: policy

ds horasinf asal_sinseg sincont salmin 
local lista=r(varlist)
local vars "`lista' p512b p208a p207 _Ieduc_1 _Ieduc_2 _Ieduc_3"
local num_vars: word count `vars'

local j = 1
foreach v of local vars {
mean `v' 
mat B`j'=[_b[`v'], _se[`v']]
matrix rownames B`j' = `e(varlist)'
count if policy==1
mat N1`j'=r(N)
count if policy==0
mat N0`j'=r(N)
local j = `j'+1
}

local j = 1
foreach v of local vars {
mean `v', over(policy)
test _b[c.`v'@0bn.policy]=_b[c.`v'@1.policy]
mat E`j'=[_b[c.`v'@0bn.policy],_se[c.`v'@0bn.policy],_b[c.`v'@1.policy],_se[c.`v'@1.policy],r(p),e(N)]
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

lab var horasinf "Trabajar más de 48 horas, %"
lab var asal_sinseg "No contar con seguro de salud, %"
lab var sincont "No contar con contrato laboral, %"
lab var salmin "Ganar menos del salario mínimo, %"
lab var p208a "Edad"
lab var p207 "Hombre, %"
lab var lima "Vivir en la ciudad capital, %"
lab var p512b "Trabajadores en empresas"

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

local num_vars = `num_vars'+1
set obs `num_vars'
gen id=_n
replace Variables="Observaciones" if id==`num_vars'
replace B1=A8[1] if Variables=="Observaciones" 
replace B2=A9[1] if Variables=="Observaciones" 
replace B3=A10[1] if Variables=="Observaciones" 
gen B3star=string(B3,"%3.1f") 
replace B3star=string(B3,"%3.1f")+"*" if A7<=.1
replace B3star=string(B3,"%3.1f")+"**" if A7<=.05
replace B3star=string(B3,"%3.1f")+"***" if A7<=.01
replace B3star=string(A10[1],"%9.0fc") if Variables=="Observaciones" 
label var Variables "Variables"
label var B1 "Todos"
label var B2 "Tratados"
label var B3 "No Tratados"
format B1 B2 %9.1fc
order Variables B1 SE2 B2 SE4 B3star SE6
keep Variables B1 SE2 B2 SE4 B3star SE6

export excel "$bases\tabla1.xlsx", replace firstrow(var)

/*
texsave Variables B1 SE2 B2 SE4 B3star SE6 using "$bases/tabla1.tex", ///
 varlabels title("Descriptive statistics") nofix frag replace loc(htbp)  ///
 footnote("Source: \cite{eea}. Notes: Amounts in millions of Nuevos Soles (S/) except in firm age and those with \%. Controlled transactions (CT) refer to the absolute value of related-party payable plus the absolute value of related-party receivable at the end of 2017. UIT are tax units with the following equivalence in 2017: 1 UIT = S/ 4050. Panels (A), (B) and (C) show three ways to identify treated firms according to controlled transactions. Firms affected are those firms with total revenue greater than 2300 UIT. Standard errors in parentheses.") 