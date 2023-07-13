****T STATISTIC:
sysuse auto, clear
qui reg mpg i.fore##i.rep
lincom 1.fore + 1.fore#4.rep
mat L = (r(estimate), r(se),r(estimate)/r(se) , 2*ttail(r(df),abs(r(estimate)/r(se) )))
mat lis L

****Z STATISTIC:
sysuse auto, clear
qui poisson mpg i.fore##i.rep
lincom 1.fore + 1.fore#4.rep
mat L=2*(1-normal(abs(r(estimate)/r(se))))
mat lis L
