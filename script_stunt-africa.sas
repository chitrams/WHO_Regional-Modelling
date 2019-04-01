PROC IMPORT OUT= WORK.morris1 
            DATAFILE= "I:\UnitData\SURVEILLANCE\Unicef-WB-harmonization\2018\2018 January analysis\Joint-Malnutrition-Estimates-Jan_2018_29012018_UNreg.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     guessingrows=32767;
     DATAROW=2; 
RUN;

data work.test0;
set work.morris1;
/* if sex eq "B"; */
IF refno eq "" THEN refno=8888;
if unregion ne "AFRICA" then delete;
if ha_2 eq -1 and ctryname ne "X" then delete;
run;

/*Centering Years*/

data work.test;
set work.test0;
yearcen=year1-2000;
ycensq=yearcen*yearcen;
ycencub=ycensq*yearcen;
if ha_2 eq -1 then ha_2=.;
if (ha_2 ne 0) then lgstic_wa=log(ha_2/(100-ha_2)); else lgstic_wa=log((ha_2+0.01)/(100-(ha_2+0.01)));
run;

proc sort data=work.test;
by unregion ctryname;
run;

/*beginning of normalizing weights*/

proc means data=work.test noprint;
by unregion ctryname;
var pop_0_4;
output out=two mean=mpopu5;
run;

data three;
merge work.test two;
by unregion ctryname ;
run;

proc means data=two noprint;
by unregion;
var mpopu5;
output out=four sum=mmpopu5;
run;

data five;
merge three four;
by unregion;
run;

data work.testb;
set five;
popweigh=mpopu5/mmpopu5;
yearcen1=yearcen;
run;

proc sort data=work.testb;
by unregion ctryname;
run;

/*   Africa Model 1    */

proc mixed data=work.testb method=reml covtest empirical;
title 'Stunting, Repeated, Centered year, weights, linear - Compund symmetry';
class unsubregio ctryname yearcen1;

model lgstic_wa= unsubregio yearcen*unsubregio /noint solution outpm=estlgst;
repeated yearcen1/type=cs subject=ctryname;
weight popweigh;
run;

/*   Africa Model 2    - not used */
/*
proc mixed data=work.testb method=reml covtest empirical;
title 'Stunting, Repeated, Centered year, weights, linear';
class unsubregio ctryname yearcen1;

model lgstic_wa=unsubregio yearcen*unsubregio /noint solution outpm=estlgst;
repeated yearcen1/type=ar(1) subject=ctryname;
weight popweigh;
run;
*/
/*   Africa Model 3    */
/*
proc mixed data=work.testb method=reml covtest empirical;
title 'Stunting, Repeated, Centered year, weights, linear - Unstructure with random int and slope';
class unsubregio ctryname yearcen1;

model lgstic_wa= unsubregio yearcen*unsubregio /noint solution outpm=estlgst;
random intercept yearcen/type=un subject=ctryname;
weight popweigh;
run;
*/
/*    Africa Model 4  */
/*
proc mixed data=work.testb method=reml covtest empirical;
title 'Stunting, Repeated, Centered year, weights, linear';
class unsubregio ctryname yearcen1;

model lgstic_wa= unsubregio yearcen*unsubregio /noint solution outpm=estlgst;
random intercept/type=un subject=ctryname;
weight popweigh;
run;
*/

data unwa;
set estlgst;
prevest=100/(1+exp(-pred));
prevlcl=100/(1+exp(-lower));
prevucl=100/(1+exp(-upper));
IF refno ne "90001" and refno ne "90002" THEN DELETE;
run;

data predunwa;
merge estlgst testb;
prevest=100/(1+exp(-pred));
prevlcl=100/(1+exp(-lower));
prevucl=100/(1+exp(-upper));
IF refno eq "90000" or refno eq "90001" or refno eq "90002" or refno eq "90003" or refno eq "90004" or refno eq "90005" or refno eq "90006" or refno eq "90007" then delete;
keep UNREGION UNSUBREGIO CTRYNAME YEAR1 HA_2 lgstic_wa popweigh pred StdErrPred lower upper Resid prevest prevlcl prevucl;
run;

proc print data=unwa round;
var unregion year1 unsubregio prevest prevlcl prevucl;
run;


PROC EXPORT DATA= WORK.UNWA 
            OUTFILE= "I:\UnitData\SURVEILLANCE\Unicef-WB-harmonization\2018\2018 January analysis\UN regions\Wrap_stunting\Africa_stunting\Output\prevests_Africa_un_stunt1.csv" 
            DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA= WORK.PREDUNWA 
            OUTFILE= "I:\UnitData\SURVEILLANCE\Unicef-WB-harmonization\2018\2018 January analysis\UN regions\Wrap_stunting\Africa_stunting\Output\predunwa_Africa_un_stunt1.csv" 
            DBMS=CSV REPLACE;
RUN;

