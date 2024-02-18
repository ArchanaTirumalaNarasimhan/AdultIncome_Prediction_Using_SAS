

PROC IMPORT OUT= Archana.adultdata
DATAFILE="C:\Users\ramph\Downloads\SAS PROJECT\adult.csv"
DBMS=CSV REPLACE;    
GETNAMES=YES;    
GUESSINGROWS=MAX;
RUN;
proc print data = Archana.adultdata (obs=5);
run;

/*age: The individual's age.*/
/*workclass: The type of employment (e.g., Private, Local-gov).*/
/*fnlwgt: Final weight. The number of people the census believes the entry represents.*/
/*education: The highest level of education achieved.*/
/*educational-num: The highest educational level in numerical form.*/
/*marital-status: Marital status (e.g., Never-married, Married-civ-spouse).*/
/*occupation: The individual's occupation.*/
/*relationship: Relationship status (e.g., Not-in-family, Husband).*/
/*race: The individual's race (e.g., Black, White).*/
/*gender: Male or Female.*/
/*capital-gain: Income from investment sources, apart from wages/salary.*/
/*capital-loss: Losses from investment sources, apart from wages/salary.*/
/*hours-per-week: Number of hours worked per week.*/
/*native-country: Country of origin.*/
/*income: Income class (<=50K or >50K).*/

proc contents data=Archana.adultdata;
run;
**************************checking missing values**************************;
/* Identifying missing values in each column */
proc freq data=Archana.adultdata;
    tables _all_ / missing;
run;
/* Summary statistics to identify missing values for numeric variables */
proc means data=Archana.adultdata N NMiss;
run;

/*Aparently we dont have any missing value but we have ? values in 3 columns
workclass has 2799 '?' values
occupation has 2809 '?' values
native_country has 857 '?' values
*/

/*here we will replace those values by their repective modes*/

/* Calculate the mode for 'workclass' */

proc sql noprint;
    create table workclass_counts as
    select workclass, count(*) as freq
    from Archana.adultdata
    where workclass not in (' ', '?') /* Exclude missing and unknown values */
    group by workclass;
quit;

proc sql noprint;
    select workclass into :workclass_mode from workclass_counts
    where freq = (select max(freq) from workclass_counts);
   
quit;

/* Calculate the mode for 'occupation' */

proc sql noprint;
    create table occupation_counts as
    select occupation, count(*) as freq
    from Archana.adultdata
    where occupation not in (' ', '?') /* Exclude missing and unknown values */
    group by occupation;
quit;

proc sql noprint;
    select occupation into :occupation_mode from occupation_counts
    where freq = (select max(freq) from occupation_counts);
   
quit;

/* Calculate the mode for 'native_country' */
proc sql noprint;
    create table native_country_counts as
    select native_country, count(*) as freq
    from Archana.adultdata
    where native_country not in (' ', '?') /* Exclude missing and unknown values */
    group by native_country;
quit;

proc sql noprint;
    select native_country into :native_country_mode from native_country_counts
    where freq = (select max(freq) from native_country_counts);
   
quit;

***********************************************/*Impute Missing Values with the Mode***********************************/;
data Archana.imputed_data;
    set Archana.adultdata;
    if workclass in (' ', '?') then workclass = "&workclass_mode";
    if occupation in (' ', '?') then occupation = "&occupation_mode";
    if native_country in (' ', '?') then native_country = "&native_country_mode";
run;

/* View a small sample of records before and after imputation */
proc print data=Archana.adultdata (obs=20);
    var workclass occupation native_country;
run;

proc print data=Archana.imputed_data (obs=20);
    var workclass occupation native_country;
run;



******************************************************************************************************************************;
/*Exploratory Data Analysis*/
/*Univariate Analysis*/
proc means data=Archana.imputed_data N mean std min max;
    var AGE;
run;

proc sgplot data=Archana.IMPUTED_DATA;
    histogram AGE;
run;
/*AGE IS RIGHT SKEWED*/
/*********************************************************/
proc means data=Archana.IMPUTED_DATA N mean std min max;
    var EDUCATIONAL_NUM;
run;

proc sgplot data=Archana.IMPUTED_DATA;
    histogram EDUCATIONAL_NUM;
run;
/****************************************************/

proc means data=Archana.imputed_data N mean std min max;
    var fnlwgt;
run;

proc sgplot data=Archana.imputed_data;
    histogram fnlwgt;
run;

/*fnlwgt is right skewed*/
/******************************************************/

proc means data=Archana.imputed_data N mean std min max;
    var capital_gain;
run;

proc sgplot data=Archana.imputed_data;
    histogram capital_gain;
run;

/************************************************************/

proc means data=Archana.imputed_data N mean std min max;
    var capital_loss;
run;

proc sgplot data=Archana.imputed_data;
    histogram capital_loss;
run;

/*capital_loss is right skewed*/
/************************************************************/


proc means data=Archana.imputed_data N mean std min max;
    var hours_per_week;
run;

proc sgplot data=Archana.imputed_data;
    histogram hours_per_week;
run;

/****************************************************************/

/*UNIVARIATE*/
* List of categorical variables;
%let cat_vars = workclass education marital_status occupation relationship race gender native_country;

* Frequency distribution for each categorical variable;
%macro univariate_categorical(var);
  proc freq data=Archana.imputed_data;
    tables &var / missing nocum;
    title "Frequency Distribution of &var";
  run;
%mend;

%univariate_categorical(workclass);
%univariate_categorical(education);
%univariate_categorical(marital_status);
%univariate_categorical(occupation);
%univariate_categorical(relationship);
%univariate_categorical(race);
%univariate_categorical(gender);
%univariate_categorical(native_country);
**************************************************************************;

* List of numerical variables;
%let num_vars = age fnlwgt educational_num capital_gain capital_loss hours_per_week;

* Summary statistics for each numerical variable;
proc means data=Archana.imputed_data N mean median min max std;
  var &num_vars;
  title "Summary Statistics for Numerical Variables";
run;

* Distribution plots for each numerical variable;
%macro univariate_numerical(var);
  proc sgplot data=Archana.imputed_data;
    histogram &var / scale=proportion;
    density &var / type=kernel;
    title "Distribution of &var";
  run;
%mend;

%univariate_numerical(age);
%univariate_numerical(fnlwgt);
%univariate_numerical(educational_num);
%univariate_numerical(capital_gain);
%univariate_numerical(capital_loss);
%univariate_numerical(hours_per_week);
********************************************************;

proc univariate data=Archana.imputed_data;
   var age fnlwgt educational_num capital_gain capital_loss hours_per_week;
   histogram;
   title "Univariate Analysis of Adult Dataset";
run;

*=============================================================================================================================;
/*Bivariate Analysis*/
/*A. Numerical-Numerical Relationships:*/
* Scatter plots for pairs of numerical variables;
proc sgscatter data=Archana.imputed_data;
  plot (age fnlwgt educational_num capital_gain capital_loss) * hours_per_week;
  title "Scatter Plots of Numerical Variables";
run;

/*correlation analysis*/

proc corr data=Archana.imputed_data plots=matrix;
   var age fnlwgt educational_num capital_gain capital_loss hours_per_week;
   title "Bivariate Analysis of Adult Dataset";
run;

******************;
/*B. Categorical-Numerical Relationships:*/
%macro bivariate_catnum(cat_var, num_var);
  proc sgplot data=Archana.imputed_data;
    vbox &num_var / category=&cat_var;
    title "Box plot of &num_var by &cat_var";
  run;
%mend;

%let cat_vars = workclass education marital_status occupation relationship race gender native_country;;
%let num_vars = age fnlwgt educational_num capital_gain capital_loss hours_per_week;

%macro generate_all_combinations;
  %let cat_count = %sysfunc(countw(&cat_vars));
  %let num_count = %sysfunc(countw(&num_vars));

  %do i = 1 %to &cat_count;
    %let cat_var = %scan(&cat_vars, &i);

    %do j = 1 %to &num_count;
      %let num_var = %scan(&num_vars, &j);

      %bivariate_catnum(&cat_var, &num_var);
    %end;
  %end;
%mend;

%generate_all_combinations;

*********************;

/*C. Categorical-Categorical Relationships:*/
%macro bivariate_catcat(var1, var2);
  proc freq data=Archana.imputed_data;
    tables &var1* &var2 / chisq expected;
    title "Crosstab of &var1 by &var2";
  run;
%mend;

%macro generate_all_cat_combinations;
  %let count = %sysfunc(countw(&cat_vars));

  %do i = 1 %to &count;
    %let var1 = %scan(&cat_vars, &i);
    
    %do j = &i %to &count;  /* Start from &i to avoid repeating pairs and self-comparison */
      %let var2 = %scan(&cat_vars, &j);

      %if %cmpres(&var1) ne %cmpres(&var2) %then %do;
        %bivariate_catcat(&var1, &var2);
      %end;
    %end;
  %end;
%mend;

%generate_all_cat_combinations;

/*=============================================================================================*/

/*UNDERSTANDING TARGET VARIABLE = INCOME*/

proc freq data=Archana.imputed_data;
    tables income / noprint out=income_summary;
run;

proc print data=income_summary;
    title "Summary of Target Variable";
run;

/*Income is Imbalance*/

/*==========================================================================================*/

/*NUMERICAL WITH TARGET*/

proc sgplot data=Archana.imputed_data;
    vbox age / category=income;
    title "Box Plot of age by income";
run;

proc sgplot data=Archana.imputed_data;
    vbox fnlwgt / category=income;
    title "Box Plot of fnlwgt by income";
run;
proc sgplot data=Archana.imputed_data;
    vbox educational_num / category=income;
    title "Box Plot of educational_num by income";
run;

proc sgplot data=Archana.imputed_data;
    vbox capital_gain / category=income;
    title "Box Plot of capital_gain by income";
run;

proc sgplot data=Archana.imputed_data;
    vbox capital_loss / category=income;
    title "Box Plot of capital_loss by income";
run;

proc sgplot data=Archana.imputed_data;
    vbox hours_per_week / category=income;
    title "Box Plot of hours_per_week by income";
run;

*********************************************************************************;
*********************************************************************************;

/* UNDERSTANDING THE RELATIONSHIP BETWEEN NUMERICAL FEATURE AND THE TARGET*/

proc logistic data=Archana.imputed_data;
    model income(event='<=50k') = age fnlwgt educational_num capital_gain capital_loss hours_per_week / selection=stepwise;
    title "Logistic Regression to Predict income with Numerical Features";
run;

/*CATEGORICAL WITH TARGET*/

proc freq data=Archana.imputed_data;
    tables workclass*income / chisq;
    title "Crosstab of workclass by income with Chi-Square Test";
run;

proc freq data=Archana.imputed_data;
    tables education*income / chisq;
    title "Crosstab of education by income with Chi-Square Test";
run;

proc freq data=Archana.imputed_data;
    tables marital_status*income / chisq;
    title "Crosstab of marital_status by income with Chi-Square Test";
run;

proc freq data=Archana.imputed_data;
    tables occupation*income / chisq;
    title "Crosstab of occupation by income with Chi-Square Test";
run;

proc freq data=Archana.imputed_data;
    tables relationship*income / chisq;
    title "Crosstab of relationship by income with Chi-Square Test";
run;
proc freq data=Archana.imputed_data;
    tables race*income / chisq;
    title "Crosstab of race by income with Chi-Square Test";
run;
proc freq data=Archana.imputed_data;
    tables gender*income / chisq;
    title "Crosstab of gender by income with Chi-Square Test";
run;
proc freq data=Archana.imputed_data;
	tables native_country*income / chisq;
	title "Crosstab of native_country by income with chi-square Test";
run;
*******************************;
/*Visualization for Categorical Variables:*/

proc sgplot data=Archana.imputed_data;
    vbar workclass / group=income;
    title "Count of income by workclass";
run;

proc sgplot data=Archana.imputed_data;
    vbar education / group=income;
    title "Count of income by education";
run;

proc sgplot data=Archana.imputed_data;
    vbar marital_status / group=income;
    title "Count of income by marital_status";
run;
proc sgplot data=Archana.imputed_data;
    vbar occupation / group=income;
    title "Count of income by occupation";
run;
proc sgplot data=Archana.imputed_data;
    vbar relationship / group=income;
    title "Count of income by relationship";
run;
proc sgplot data=Archana.imputed_data;
    vbar race / group=income ;
    title "count of income by race";
run;
proc sgplot data=Archana.imputed_data;
    vbar gender / group=income;
    title "Count of Income Categories by Gender";
run;

proc sgplot data=Archana.imputed_data;
	vbar native_country / group=income;
	title "count of Income by Native_country";
run;








**********************************;
/*UNDERSTANDING RELATIONSHIP VETWEEN EACH CATEGORICAL VARIABLE AND TARGET*/

proc logistic data=Archana.imputed_data;
    /* Specify the categorical variables and reference categories */
    class workclass(ref='Private') 
         education(ref='11th') 
         marital_status(ref='Never-married') 
         occupation(ref='Machine-op-inspct') 
         relationship(ref='Own-child') 
         race(ref='Black') 
         gender(ref='Male') 
		 native_country(ref = 'United-States')
         / param=ref;
    
    /* Specify the model */
    model income(event='<=50k') = workclass education marital_status occupation relationship race gender native_country / selection=stepwise;
    
    title "Logistic Regression to Predict income with Categorical Features";
run;

*******************************************************;
/*=============================================================================================*/
/*HANDLING OUTLIWERS USING LOG TRANSFORMATION*/

/*data madiha.transformed;*/
/*    set madiha.imputed_data;*/
/**/
/*    /* Log transformation of 'age'. Assuming 'age' doesn't have zero or negative values. */*/
/*    log_age = log(age);*/
/**/
/*    /* Log transformation of 'fnlwgt'. Assuming 'fnlwgt' doesn't have zero or negative values. */*/
/*    log_fnlwgt = log(fnlwgt);*/
/**/
/*    /* Log-plus-one transformation for 'capital_gain' because it may contain zeros. */*/
/*    log_capital_gain = log(capital_gain + 1);*/
/**/
/*    /* Log-plus-one transformation for 'capital_loss' because it may contain zeros. */*/
/*    log_capital_loss = log(capital_loss + 1);*/
/**/
/*    /* Log transformation of 'hours_per_week'. Assuming 'hours_per_week' doesn't have zero or negative values. */*/
/*    log_hours_per_week = log(hours_per_week);*/
/**/
/*    /* If you want to keep only the log-transformed variables in the new dataset: */*/
/*/*    keep log_age log_fnlwgt log_capital_gain log_capital_loss log_hours_per_week;*/*/
/*run;*/
/*proc print data = madiha.transformed (obs=2);run;*/
/*/*===================================================================================*/*/
/*/*VERIFYING RESULTS*/*/
/*/* Histograms for the original data */*/
/*ods on;*/
/*proc sgplot data=madiha.imputed_data;*/
/*    histogram age;*/
/*    title "Histogram of Age";*/
/*run;*/
/**/
/*proc sgplot data=madiha.imputed_data;*/
/*    histogram fnlwgt;*/
/*    title "Histogram of fnlwgt";*/
/*run;*/
/**/
/*proc sgplot data=madiha.imputed_data;*/
/*    histogram capital_gain;*/
/*    title "Histogram of Capital Gain";*/
/*run;*/
/**/
/*proc sgplot data=madiha.imputed_data;*/
/*    histogram capital_loss;*/
/*    title "Histogram of Capital Loss";*/
/*run;*/
/**/
/*proc sgplot data=madiha.imputed_data;*/
/*    histogram hours_per_week;*/
/*    title "Histogram of Hours Per Week";*/
/*run;*/
/**/
/*/* Histograms for the log-transformed data */*/
/*proc sgplot data=madiha.transformed;*/
/*    histogram log_age;*/
/*    title "Histogram of Log-transformed Age";*/
/*run;*/
/**/
/*proc sgplot data=madiha.transformed;*/
/*    histogram log_fnlwgt;*/
/*    title "Histogram of Log-transformed fnlwgt";*/
/*run;*/
/**/
/*proc sgplot data=madiha.transformed;*/
/*    histogram log_capital_gain;*/
/*    title "Histogram of Log-transformed Capital Gain";*/
/*run;*/
/**/
/*proc sgplot data=madiha.transformed;*/
/*    histogram log_capital_loss;*/
/*    title "Histogram of Log-transformed Capital Loss";*/
/*run;*/
/**/
/*proc sgplot data=madiha.transformed;*/
/*    histogram log_hours_per_week;*/
/*    title "Histogram of Log-transformed Hours Per Week";*/
/*run;*/
/*ods off;*/;

/*Feature Selection*/
proc varclus data=madiha.imputed_data maxeigen=1;
    var age fnlwgt educational_num capital_gain capital_loss hours_per_week; /* Only continuous variables */
run;

/*Since these variables explain only about 24% of the variance, it implies that each variable contributes unique information.
Therefore, we are retaining all variables */

/*========================================================================================================================================*/
/*Assumption checking for Logistic Regression*/

/*1.Linearity of independent variables and log odds
2.Absence of multicollinearity
3.No influential outliers*/

*******************************************************;

/* Calculate percentiles for age */
proc univariate data=Archana.imputed_data noprint;
    var age;
    output out=Percentiles_age pctlpts=1 99 pctlpre=P1_age_ P99_age_;
run;

/* Calculate percentiles for fnlwgt */
proc univariate data=Archana.imputed_data noprint;
    var fnlwgt;
    output out=Percentiles_fnlwgt pctlpts=1 99 pctlpre=P1_fnlwgt_ P99_fnlwgt_;
run;

/* Calculate percentiles for educational_num */
proc univariate data=Archana.imputed_data noprint;
    var educational_num;
    output out=Percentiles_edu_num pctlpts=1 99 pctlpre=P1_edu_num_ P99_edu_num_;
run;

/* Calculate percentiles for capital_gain */
proc univariate data=Archana.imputed_data noprint;
    var capital_gain;
    output out=Percentiles_cap_gain pctlpts=1 99 pctlpre=P1_cap_gain_ P99_cap_gain_;
run;

/* Calculate percentiles for capital_loss */
proc univariate data=Archana.imputed_data noprint;
    var capital_loss;
    output out=Percentiles_cap_loss pctlpts=1 99 pctlpre=P1_cap_loss_ P99_cap_loss_;
run;

/* Calculate percentiles for hours_per_week */
proc univariate data=Archana.imputed_data noprint;
    var hours_per_week;
    output out=Percentiles_hpw pctlpts=1 99 pctlpre=P1_hpw_ P99_hpw_;
run;
data All_Percentiles;
    set Percentiles_age 
        Percentiles_fnlwgt 
        Percentiles_edu_num 
        Percentiles_cap_gain 
        Percentiles_cap_loss 
        Percentiles_hpw;
run;

proc contents data=All_Percentiles;
run;

data Archana.capped_data;
    set Archana.imputed_data;
    if _n_ = 1 then set All_Percentiles;
    
    /* Apply the capping based on the percentiles */
    age = min(max(age, P1_age_1), P1_age_99);
    fnlwgt = min(max(fnlwgt, P1_fnlwgt_1), P1_fnlwgt_99);
    educational_num = min(max(educational_num, P1_edu_num_1), P1_edu_num_99);
    capital_gain = min(max(capital_gain, P1_cap_gain_1), P1_cap_gain_99);
    capital_loss = min(max(capital_loss, P1_cap_loss_1), P1_cap_loss_99);
    hours_per_week = min(max(hours_per_week, P1_hpw_1), P1_hpw_99);
run;



/* Box plot for 'age' */
proc sgplot data=Archana.capped_data;
    vbox age;
    title "Capped Box Plot for Age";
run;

/* Box plot for 'fnlwgt' */
proc sgplot data=Archana.capped_data;
    vbox fnlwgt;
    title "Capped Box Plot for fnlwgt";
run;

/* Box plot for 'age' */
proc sgplot data=Archana.capped_data;
    vbox educational_num;
    title "Capped Box Plot for educational_num";
run;


/* Box plot for 'fnlwgt' */
proc sgplot data=Archana.capped_data;
    vbox capital_gain;
    title "Capped Box Plot for capital_gain";
run;


/* Box plot for 'age' */
proc sgplot data=Archana.capped_data;
    vbox capital_loss;
    title "Capped Box Plot for capital_loss";
run;

/* Box plot for 'fnlwgt' */
proc sgplot data=Archana.capped_data;
    vbox hours_per_week;
    title "Capped Box Plot for hours_per_week";
run;

data Archana.modified_data;
    set Archana.capped_data;

    /* Exclude rare categories */
	if occupation = 'Priv-house-serv' then delete;
    if workclass in ('Never-worked') then delete;
    if native_country in ('Holand-Netherlands', 'Outlying-US(Guam-USVI-etc)','Columbia') then delete;
    if education = 'Preschool' then delete;

run;


data Archana.binned_data;
    set Archana.modified_data; /* Use the capped data */

    /* Binning 'age' */
    if age > 999.9999 then binned_age = 'Above 999.9999';
    else binned_age = put(age, best.);

    /* Binning 'fnlwgt' */
    if fnlwgt > 999.9999 then binned_fnlwgt = 'Above 999.9999';
    else binned_fnlwgt = put(fnlwgt, best.);

    /* Binning 'educational_num' */
    if educational_num > 999.9999 then binned_educational_num = 'Above 999.9999';
    else binned_educational_num = put(educational_num, best.);

    /* Binning 'capital_gain' */
    if capital_gain > 999.9999 then binned_capital_gain = 'Above 999.9999';
    else binned_capital_gain = put(capital_gain, best.);

    /* Binning 'capital_loss' */
    if capital_loss > 999.9999 then binned_capital_loss = 'Above 999.9999';
    else binned_capital_loss = put(capital_loss, best.);

    /* Binning 'hours_per_week' */
    if hours_per_week > 999.9999 then binned_hours_per_week = 'Above 999.9999';
    else binned_hours_per_week = put(hours_per_week, best.);


run;

proc print data=Archana.binned_data(obs=5);run;

/*SCALING*/

proc stdize data=Archana.binned_data out=Archana.finaldata method=std;
    var age fnlwgt educational_num capital_gain capital_loss hours_per_week; /* list all continuous variables you want to scale */
run;

/*VERIFYING THE SCALING*/

proc means data=Archana.finaldata mean stddev;
    var age fnlwgt educational_num capital_gain capital_loss hours_per_week;
    title "Check Standardized Continuous Variables";
run;

/* Set the seed for reproducibility */
%let seed = 12345;

/* Specify the proportion for the training set */
%let trainProportion = 0.7;

/* Create a training and testing set */
proc surveyselect data=Archana.finaldata out=finaldata_split
                  method=srs /* Simple random sampling */
                  rate=&trainProportion
                  outall
                  seed=&seed;
run;

/* Add a flag to the original data to indicate training or testing */
data Archana.finaldata_train Archana.finaldata_test;
    set finaldata_split;
    if Selected then output Archana.finaldata_train;
    else output Archana.finaldata_test;
run;

/*MODELING*/
proc logistic data=Archana.finaldata_train;
    /* Specify categorical variables */
    class workclass education marital_status occupation relationship race gender native_country / param=ref;
    
    /* Specify the model with both categorical and continuous variables */
    model income(event='<=50k') = workclass
							  education
							marital_status
							occupation
							relationship
							gender
							age
							fnlwgt
							educational_num  hours_per_week;
    title "Logistic Regression to Predict income with Categorical and Continuous Features";
run;

/*validation*/

proc logistic data=Archana.finaldata_test;
    /* Specify categorical variables */
    class workclass education marital_status occupation relationship race gender native_country / param=ref;
    
    /* Specify the model with both categorical and continuous variables */
    model income(event='<=50k') = workclass
							  education
							marital_status
							occupation
							relationship
							gender
							age
							fnlwgt
							educational_num hours_per_week;
    title "Logistic Regression to Predict income with Categorical and Continuous Features";
run;
