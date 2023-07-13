sysuse bplong, clear
** Mean test
mean bp, over(when)
test [bp]Before-[bp]After=0 // unpaired t test
lincom [bp]Before-[bp]After // unpaired t test
ttest bp, by(when) // unpaired t test
reg bp i.when  // unpaired t test

keep patient when bp
reshape wide bp, i(patient) j(when)
ttest bp1=bp2 // paired t test
gen diff=bp1-bp2
mean diff
test diff // paired t test
lincom diff // paired t test
reg dif   // paired t test

*** mean test , extracting p values:
sysuse bplong, clear
matrix meantest= J(18, 2, .)  
mean bp, over(sector2 uno)
local n = 1
forval i = 1(2)31{
local j = `i'+1
lincom [weighted]_subpop_`i'-[weighted]_subpop_`j'
matrix meantest[`n', 1] = (r(estimate), 2*ttail(r(df),abs(r(estimate)/r(se) )))
local n = `n' + 1
}
clear
svmat meantest, names(m)

*** mean test of variable bp over each level of category v and binary variable c
sysuse bplong, clear
gen fac=1
egen c=group(sex)
svyset [pw=fac]
local v "agegrp"
quietly ta `v'
mat def t=J(`r(r)',1,0)
levelsof `v', local(lvl)
local i = 1
foreach j of local lvl {
cap svy, subpop(if `v'==`j'): mean bp, over(c)
di "`j' `e(N_over)'"
if _rc==0 & `e(N_over)'==2 {
test _b[2]=_b[1]
mat def t[`i',1]=r(p)
}
else {
mat def t[`i',1]=.
}
local i = `i' + 1
}
collapse (mean) bp, by(c `v')
drop if `v'==.
reshape wide bp, i(`v') j(c)
svmat t, names(t)



*** Median test
sysuse bplong, clear
keep patient when bp
reshape wide bp, i(patient) j(when)
gen diff=bp1-bp2
signrank bp1=bp2
signtest bp1=bp2
bootstrap r(p50), reps(100): sum diff, d
epctile diff, p(50)
centile diff, centile(50)
gen signdiff=sign(bp1-bp2)
gen absdiff=abs(bp1-bp2)
somersd signdiff absdiff if absdiff!=0, transf(z) 


signrank ingprinmes_2008=ingprinmes_2009
bootstrap r(p50), reps(50): sum brecha0809mes, d
epctile brecha0809mes  if mov2_2008==0 & mov2_2009==2 , p(50)
centile brecha0809mes  , centile(50)
gen signdiff=sign(ingprinmes_2008-ingprinmes_2009) if mov2_2008==0 & mov2_2009==2
gen absdiff=abs(ingprinmes_2008-ingprinmes_2009) if mov2_2008==0 & mov2_2009==2
somersd signdiff absdiff if absdiff!=0 & mov2_2008==0 & mov2_2009==2, transf(z) 


epctile brecha0809mes  if mov2_2008==0 & mov2_2009==2 [iw= FAC5_2008 ], p(50)
