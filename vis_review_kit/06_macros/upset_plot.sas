/*** HELP START ***//*

Macro Name     : %upset_plot

 Description    : Generates an UpSet plot to visualize co-occurrence patterns across 
                  multiple items per individual. If no input dataset is provided, 
                  a synthetic test dataset is generated internally.
                  The macro performs data preprocessing, aggregation, transposition,
                  and graphical rendering using PROC TEMPLATE and PROC SGRENDER.

 Parameters     :
    data     = Input dataset name (if not specified, a test dataset is auto-generated)
    personID = Variable name identifying individuals (e.g., ID)
    itemnum  = Numeric variable representing item code (e.g., itemnum)
    itemname = Character variable for item label (e.g., itemname)
    width    = Width of the output PNG image in pixels (default: 1000)
    height   = Height of the output PNG image in pixels (default: 650)

 Output         : 
    - Intermediate datasets are created in the WORK/temp library.
    - Final output is rendered as a PNG-based UpSet plot using ODS Graphics.

 Requirements   : 
    - If specifying a dataset via `data=`, the variables passed in 
      `personID=`, `itemnum=`, and `itemname=` must exist in that dataset.

 Example Usage  :
    %upset_plot(data=demodata, personID=SUBJID, itemnum=symptom_code, itemname=symptom_label);

 Author         : Morioka Yutaka

*//*** HELP END ***/

%macro upset_plot(data=testdata_upset, personID=ID ,itemnum=itemnum, itemname=itemname,width=1000,height=650);

data testdata_upset;
call streaminit(123);
do ID = 1 to 100;
  iend=rand("integer",1,3);
  do i = 1 to iend;
    itemnum = rand("integer",1,5);
    itemname = choosec(itemnum,"Rhinorrhoea","Fatigue ","Sore throat","Cough","Fever");
    output;
  end;
end;
drop i iend;
run;

%let WORKPATH = %sysfunc(pathname(WORK));
options DLCREATEDIR;
libname outtemp "&WORKPATH/temp";
options NODLCREATEDIR;


%if %length(&data) eq 0 %then %do;
 data outtemp.upset1;
   set testdata_upset;
 run;
%end;
%if %length(&data) ne 0 %then %do;
 data outtemp.upset1;
   set &data;
    ID = &personID;
    itemnum = &itemnum.;
    itemname = &itemname.;
 run;
%end;

proc sql noprint;
 select count(distinct itemnum) into: item_n trimmed from outtemp.upset1;
quit;
%put &=item_n;

proc sort data=outtemp.upset1(keep=itemnum itemname) out=outtemp.itemlist nodupkey;
  by  itemnum;
run;

data outtemp.itemformat;
 set outtemp.itemlist;
 FMTNAME="itemformat";
 START=itemnum;
 LABEL=itemname;
run;

proc format lib=work cntlin=outtemp.itemformat;
run;

proc sort data=outtemp.upset1 out=outtemp.upset2 nodupkey;
  by ID itemnum;
run;

proc summary data=outtemp.upset2 nway ;
 class itemnum itemname;
 output out=outtemp._single_count(drop=_TYPE_ rename=(_FREQ_=single_count) );
run;

data outtemp.single_count;
 set outtemp._single_count;
 single_start=0;
 run;

proc transpose data=outtemp.upset2 out=outtemp.upset3 prefix=item_;
 by ID;
 id itemnum;
 var itemnum;
run;

data outtemp.upset4;
length comb $200.;
 set outtemp.upset3;
 array ar item_:;
 do over ar;
  if ^missing(ar) then comb=catx("/",comb,ar);
 end;
 count=1;
run;

proc summary data=outtemp.upset4 nway missing;
 class comb: item_:;
 output out=outtemp._comb_count(drop=_TYPE_ rename=(_FREQ_=comb_count) );
run;

proc sort data=outtemp._comb_count;
 by descending comb_count;
run;

proc sql noprint;
 select count(*) into:comb_n from outtemp._comb_count;
 select max(comb_count) into:comb_max from outtemp._comb_count;
quit;

data outtemp.comb_count;
set outtemp._comb_count;
 array dummy_{&item_n};
 do i = 1 to &item_n;
    dummy_{i}=i;
 end;
min = min(of item_:);
max = max(of item_:);
x = _N_;
drop i;
run;

data outtemp.graph_data;
 set outtemp.comb_count
       outtemp.single_count;
run;

%macro scatterplot();
 %do i = 1 %to &item_n;
    scatterplot x=x y=item_&i /yaxis=y2 markerattrs=(size=12 symbol=circlefilled);
    scatterplot x=x y=dummy_&i /yaxis=y2 datatransparency=0.9 markerattrs=(size=12 symbol=circlefilled);
 %end;
%mend;

proc template ;
  define statgraph upset;
      begingraph ;
          layout lattice/ rowdatarange = union
                             columnweights = (0.25 0.75)
                             rowweights = (0.6 0.4)
                             columns = 2 rows = 2 
                             pad=(top=0 bottom=0 left=0 right=0) 
                             ; 
              layout overlay / pad=(top=0 bottom=0 left=0 right=0)
                                     outerpad=(top=0 bottom=0 left=0 right=0) 
                                     xaxisopts  = (display =none);
              endlayout;
           
              layout overlay /pad=(top=0 bottom=0 left=0 right=0) 
                                   outerpad=(top=0 bottom=0 left=0 right=0)
                                    walldisplay=none
                                    xaxisopts  = (display =none linearopts = (viewmin=1 viewmax=&item_n tickvaluesequence = (start=1 end=&item_n increment=1)))
                                    yaxisopts  = (display= (line tickvalues) linearopts = (tickvaluesequence = (start=0 end=&comb_max. increment=5))) ;
                                    barchartparm category=x response=comb_count/datalabel=comb_count;
              endlayout;

              layout overlay /pad=(top=0 bottom=0 left=0 right=0)
                                    outerpad=(top=0 bottom=0 left=0 right=0)
                                    walldisplay=none
                                    xaxisopts  = (display= none reverse=true)
                                    yaxisopts = (display =none linearopts = (viewmin=1 viewmax=&item_n tickvaluesequence = (start=1 end=&item_n increment=1)))
                                    y2axisopts = (display =(tickvalues) tickvalueattrs=(size=9) linearopts = (viewmin=0 viewmax=&item_n tickvaluesequence = (start=1 end=&item_n increment=1)));
                                    highlowplot y=itemnum high=single_count low=single_start 
                                    /yaxis=y2 group=itemnum type=bar barwidth=0.5 fillattrs=(color=VLIGB) outlineattrs=(color=VLIGB) 
                                     highlabel=single_count labelattrs=(color=black) ;
              endlayout;

              layout overlay  /pad=(top=0 bottom=0 left=0 right=0)
                                    outerpad=(top=0 bottom=0 left=0 right=0)
                                     xaxisopts  = (display =none linearopts = (tickvaluesequence = (start=1 end=&comb_n. increment=1)))
                                     yaxisopts  = (display= (line ) linearopts = (viewmin=0 viewmax=&item_n  ))
                                     y2axisopts  = (display=none linearopts = (viewmin=0 viewmax=&item_n  ))
                                     walldisplay=none;
                                     %scatterplot();
                                     highlowplot x=x low=min high=max/yaxis=y2;
              endlayout;
           endlayout;
      endgraph;
  end;
run;

ods graphics / reset
                     noborder
                     noscale
                     imagefmt=png
                     width=&width. px
                     height= &height. px
				             attrpriority=none;
proc sgrender data=outtemp.graph_data template=upset;
format itemnum itemformat.;
run;
%mend;
