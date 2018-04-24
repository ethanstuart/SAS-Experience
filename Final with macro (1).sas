

proc format;
	invalue lettertnum
	"A" = 4.0
	"A-" = 3.7
	"B+" = 3.4
	"B" = 3.0
	"B-"= 2.7
	"C+"= 2.4
	"C"= 2.0
	"C-"= 1.7
	"D+"= 1.4
	"D"= 1
	"D-"= .7
	other= 0
	;
run;

data final;
	infile "/folders/myfolders/sasuser.v94/224/Final Data/*.txt" dlm="@";
	length ID $ 5 Course $ 10;
	input ID $ Date Course $ Credit Grade $;
	GPAgrade=input(Grade, lettertnum.);
	if substr(Grade,1,1) = "P" then 
		GPAcred=0;
	else GPAcred=Credit;
run;

data math;
	set final;
	where Course =: "MATH" or Course=:"STAT";
run;
proc sort data=math ;
	by ID;
run;

%macro bigguy(which,Q);
proc sql;
	create table rep1&which as
	select ID, Date, sum(GPAgrade*GPAcred) as weight,
		sum(GPAgrade*GPAcred)/sum(GPAcred) as semGPA,
		sum(GPAcred) as GradedCredits,
		sum(Credit) as Credits
	from &which
	group by ID, Date	
	;
quit;

proc sql;
	create table gradessums&which as
	select ID, sum(count(Grade,"A")) as A_s,
	sum(count(Grade,"B")) as B_s,
	sum(count(Grade,"C")) as C_s,
	sum(count(Grade,"D")) as D_s,
	sum(count(Grade,"E")) as E_s,
	sum(count(Grade,"W")) as W_s,
	sum(count(Grade,"P")) as P_s,
	sum(GPAgrade*GPAcred)/sum(GPAcred) as overallGPA,
	sum(Credit) as overallCredits,
	sum(GPAcred) as overallGradCredits
	from &which
	group by ID
	;
quit;

proc sql;
	create table bystu&which as
	select ID, count(distinct Course) as DistCourses,
		count(Course) as Courses,
		calculated Courses- calculated DistCourses as Repeats&Q
		from &which
		group by ID
		;
quit;

data ethan&which;
	set rep1&which;
	length ClassStanding $ 9;
	by ID Date;	
	retain cumWeight 0;
	if first.ID then cumWeight=0;
	cumWeight=cumWeight+weight;
	retain cumGradedCred 0;
	if first.ID then cumGradedCred=0;
	cumGradedCred=cumGradedCred+GradedCredits;
	CumGPA= cumWeight/cumGradedCred;
	retain cumCredits 0;
	if first.ID then cumCredits=0;
	cumCredits=cumCredits+Credits;
	if cumCredits le 29.9 then ClassStanding = "Freshman";
	else if cumCredits le 59.9 then ClassStanding= "Sophomore";
	else if cumCredits le 89.9 then ClassStanding= "Junior";
	else ClassStanding= "Senior";	
run;

	
proc sql;
	create table report1a&which as
	select ID, Date, semGPA, CumGPA, cumCredits, cumGradedCred, ClassStanding
	from ethan&which;
quit;

data report&which (drop=Courses DistCourses);
	merge report1a&which bystu&which gradessums&which;
	by ID;
run;

%mend bigguy;


*not super specific with the macro, there is some unnecessary overlap, but it made
more sense for me to leave it like this;

%bigguy(final,F)
%bigguy(math,M)


proc sql;
	create table report2a as
	select ID,overallGPA, overallCredits, overallGradCredits,  
	A_s, B_s, C_s, D_s, E_s, W_s
	from gradessumsfinal;
quit;
proc sql;
	create table report2b as
	select ID,overallGPA as mathGPA, overallCredits as mathCredits,
	overallGradCredits as mathGradCredits, 
	A_s as MathAs, B_s as MathBs, C_s as MathCs, D_s as MathDs, E_s as
	MathEs, W_s as MathWs
	from gradessumsmath
	order by ID;
quit;

data report2 (drop= DistCourses Courses);
	merge report2a (rename=(A_s=As B_s=Bs C_s=Cs D_s=Ds E_s=Es W_s=Ws)) bystufinal (rename=(RepeatsF=Repeats)) 
	  report2b  bystumath(rename=(RepeatsM=MSRepeats)) ;
	by ID ;
run;


data report3;
	set report2;
	where overallCredits > 60 and overallCredits < 130;	
run;



proc sort data=report3;
	by descending overallGPA;
run;


data report4;
	set report2;
	where mathGradCredits gt 20;
run;
proc sort data=report4;
	by descending overallGPA;
run;

*create macros for the number of observations for report 3 and 4;
proc sql;
	select round(count(ID)/10) into :stuart3
	from report3
	;
quit;
proc sql;
	select round(count(ID)/10) into :stuart4
	from report4
	;
quit;

ods html file="/folders/myfolders/sasuser.v94/224/FinalESTU.html";
title "Report 1";
proc print data= reportfinal;
	var ID Date semGPA CumGPA cumCredits cumGradedCred ClassStanding RepeatsF
	A_s B_s C_s D_s E_s W_s;
run;
title "Report 2";
proc report data= report2;
run;
title "Report 3";
proc print data=report3 (obs=&stuart3);
	var ID overallGPA;
run;
title "Report 4";
proc print data=report4(obs= &stuart4);
	var ID overallGPA;
run;
ods html close;