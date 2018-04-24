data keyA FormA;
	infile "/folders/myfolders/sasuser.v94/Project ish 124/FormA.csv" dlm="," dsd;
	input student $ (Q1-Q150)($);
	if substr(student,5,3)='KEY' then output keyA;
	else do;
	ID=input(student, 8.);
	output formA;
	end;
run;

data keyB FormB;
	infile "/folders/myfolders/sasuser.v94/Project ish 124/FormB.csv" dlm="," dsd;
	input student $ (Q1-Q150)($);
	if substr(student,5,3)='KEY' then output keyB;
	else do;
	ID=input(student, 8.);
	output formB;
	end;
run;
data keyC FormC;
	infile "/folders/myfolders/sasuser.v94/Project ish 124/FormC.csv" dlm="," dsd;
	input student $ (Q1-Q150)($);
	if substr(student,5,3)='KEY' then output keyC;
	else do;
	ID=input(student, 8.);
	output formC;
	end;
run;
data keyD FormD;
	infile "/folders/myfolders/sasuser.v94/Project ish 124/FormD.csv" dlm="," dsd;
	input student $ (Q1-Q150)($);
	if substr(student,5,3)='KEY' then output keyD;
	else do;
	ID=input(student, 8.);
	output formD;
	end;
run;

data DomainsA;
	infile "/folders/myfolders/sasuser.v94/Project ish 124/Domains FormA.csv" 
	dlm="," dsd firstobs=2;
	input  item_id  Domain $ Domain_num j;
run;

data DomainsB;
	infile "/folders/myfolders/sasuser.v94/Project ish 124/Domains FormB.csv" 
	dlm="," dsd firstobs=2;
	input  item_id  Domain $ Domain_num j;
run;
data DomainsC;
	infile "/folders/myfolders/sasuser.v94/Project ish 124/Domains FormC.csv" 
	dlm="," dsd firstobs=2;
	input  item_id  Domain $ Domain_num j;
run;
data DomainsD;
	infile "/folders/myfolders/sasuser.v94/Project ish 124/Domains FormD.csv" 
	dlm="," dsd firstobs=2;
	input  item_id  Domain $ Domain_num j;
run;

data scoreA;
	set keyA FormA;
	array ans(150) $ Q1-Q150;
	array key(150) $ K1-K150;
	array scr(150) S1-S150;
	retain K1-K150;
	if substr(student, 5,3)="KEY" then do;
	do i=1 to 150;
	key(i)=ans(i);
	end;
	delete;
	end;
	else do j=1 to 150;
	if ans(j)=key(j) then scr(j)=1;
	else scr(j)=0;
	score=scr(j);
	output; 
	end;
	keep ID j score;
run;

data scoreB;
	set keyB FormB;
	array ans(150) $ Q1-Q150;
	array key(150) $ K1-K150;
	array scr(150) S1-S150;
	retain K1-K150;
	if substr(student, 5,3)="KEY" then do;
	do i=1 to 150;
	key(i)=ans(i);
	end;
	delete;
	end;
	else do j=1 to 150;
	if ans(j)=key(j) then scr(j)=1;
	else scr(j)=0;
	score=scr(j);
	output;
	end;
	keep ID j score;
run;
data scoreC;
	set keyC FormC;
	array ans(150) $ Q1-Q150;
	array key(150) $ K1-K150;
	array scr(150) S1-S150;
	retain K1-K150;
	if substr(student, 5,3)="KEY" then do;
	do i=1 to 150;
	key(i)=ans(i);
	end;
	delete;
	end;
	else do j=1 to 150;
	if ans(j)=key(j) then scr(j)=1;
	else scr(j)=0;
	score=scr(j);
	output;
	end;
	keep ID j score;
run;
data scoreD;
	set keyD FormD;
	array ans(150) $ Q1-Q150;
	array key(150) $ K1-K150;
	array scr(150) S1-S150;
	retain K1-K150;
	if substr(student, 5,3)="KEY" then do;
	do i=1 to 150;
	key(i)=ans(i);
	end;
	delete;
	end;
	else do j=1 to 150;
	if ans(j)=key(j) then scr(j)=1;
	else scr(j)=0;
	score=scr(j);
	output;
	end;
	keep ID j score;
run;

proc sort data=DomainsA;
	by j;
run;

proc sort data=scoreA;
	by j;
run;

data mergedA;
	merge scoreA DomainsA;
	by j;
	drop item_id Domain;
	Form="A";
run;


proc sort data=DomainsB;
	by j;
run;

proc sort data=scoreB;
	by j;
run;

data mergedB;
	merge scoreB DomainsB;
	by j;
	drop item_id Domain;
	Form="B";
run;


proc sort data=DomainsC;
	by j;
run;

proc sort data=scoreC;
	by j;
run;

data mergedC;
	merge scoreC DomainsC;
	by j;
	drop item_id Domain;
	Form="C";
run;

proc sort data=DomainsD;
	by j;
run;

proc sort data=scoreD;
	by j;
run;

data mergedD;
	merge scoreD DomainsD;
	by j;
	drop item_id Domain;
	Form="D";
run;

data mergedall;
	set mergedA mergedB mergedC mergedD;
run;

proc sort data=mergedall;
	by ID domain_num;
run;

proc means data=mergedall mean sum noprint;
	var score;
	class ID domain_num; *group by students and by domains;
	ID Form;
	output out=calculation mean=Mean sum=Sum;
run;

proc sort data=calculation;
 	by ID;
	where ID ^= .; *not equal;
run;

data AC1; 			*allcalc;
	retain op os ds1-ds5 dp1-dp5;   *keep this and copy it;
	array scr[*] op os dp1 ds1 dp2 ds2 dp3 ds3 dp4 ds4 dp5 ds5;
	set calculation;
	by ID;        *set and by creates phantom variables first. and last. student = 1 ind = 0; 
	if first.ID then ind=0;
	ind+1;
	scr[ind]=Mean;
	ind+1;
	scr[ind]=Sum;
	if last.ID then output;
run;

options orientation=landscape linesize= 256;
ods pdf file="/folders/myfolders/sasuser.v94/Project ish 124/mylife_etan.pdf";
title "Report 1";
proc print data=AC1 label noobs;
	label op="Overall Percent"
	os="Overall Score"
	dp1="Domain 1 Percent"
	ds1="Domain 1 Score"
	dp2="Domain 2 Percent"
	ds2="Domain 2 Score"
	dp3="Domain 3 Percent"
	ds3="Domain 3 Score"
	dp4="Domain 4 Percent"
	ds4="Domain 4 Score"
	dp5="Domain 5 Percent"
	ds5="Domain 5 Score";
	format op dp1 dp2 dp3 dp4 dp5 percent7.1;
	var ID Form os op ds1 dp1 ds2 dp2 ds3 dp3 ds4 dp4 ds5 dp5;
run;

*Report 2 here;
proc sort data=AC1 out=AC2;
	by descending op ;
run;
title "Report 2";	
proc print data=AC2 label noobs;
	label op="Overall Percent"
	os="Overall Score"
	dp1="Domain 1 Percent"
	ds1="Domain 1 Score"
	dp2="Domain 2 Percent"
	ds2="Domain 2 Score"
	dp3="Domain 3 Percent"
	ds3="Domain 3 Score"
	dp4="Domain 4 Percent"
	ds4="Domain 4 Score"
	dp5="Domain 5 Percent"
	ds5="Domain 5 Score";
	format op dp1 dp2 dp3 dp4 dp5 percent7.1;
	var ID Form os op ds1 dp1 ds2 dp2 ds3 dp3 ds4 dp4 ds5 dp5;
run;

*boxplots of domains;

proc sort data=calculation;
	by Domain_num;
	where Domain_num^=.;
run;

proc boxplot data=calculation;
	plot mean * Domain_num;
run;

*Boxplot of Domains and Forms;
*option 1;
/*data cal2;
	set calculation;
	formdom = (trim(form)||Domain_num);
	where Domain_num ^= .;
run;

proc sort data=cal2;
	by formdom;
run;

proc boxplot data=cal2;
	plot mean* formdom;
run;*/
*option 2;
proc sgplot data=calculation;
	vbox Mean / category=Form group=Domain_num;
run;

*exam form by question;

proc sort data=mergedall;
	by Form j;
run;

proc means data=mergedall mean sum noprint; 
	var score;
	class Form j;
	output out=quest mean=Mean sum=Sum;
run;
proc sort data=quest;
	by Form j;
	where Form^=" " and j ^=.;
run;

title "Question Exam Form 1";
proc print data=quest label noobs;
	format Mean percent7.1;
	var Form j mean;
	label j="Question Number";
run;
title;
* BY DIFFICULTY;
proc sort data=quest out=quest2;
	by descending mean;
run;

title "Question Exam Form 2";
proc print data=quest2 label noobs;
	format Mean percent7.1;
	var mean Form j;
	label j="Question Number";
run;
title;

*Boxplot of Domains;
proc sort data=quest;
	by form;
run;
proc boxplot data=quest;
	plot mean * form;
run;
ods pdf close;


