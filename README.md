# vis_review_kit
Visual tools for reviewing and monitoring clinical trial data. A SAS macro package to support QC and exploration through graphical representations.

![vis_review_kit](./vis_review_kit_small.png)  

# %event_gant_excel()
Description       : 
    This macro generates a Gantt chart in Excel format based on user-specified event data.  
    Given a dataset containing event start and end days, the macro builds a day-wise array  
    and visually highlights the event duration using colored cells via ODS EXCEL and  
    SAS RWI (Report Writing Interface)  
  
Main Features     :  
~~~text  
    - Automatically calculates the time range based on event dates
    - Distinguishes ongoing events (with missing end date) using separate cell styling
    - Displays events per subject along a horizontal timeline
    - All input elements (dataset, variable names, output path, etc.) are configurable
~~~

Input Parameters  :  
~~~text
    outpath             - Output directory path for the Excel file 
    outfile             - Output file name (e.g., gant.xlsx)
    target_dataest      - Input dataset (e.g., work.ae)
    target_id           - Subject identifier variable (e.g., SUBJID)
    target_event_name   - Event name variable (e.g., AETERM)
    target_st           - Event start day variable (e.g., AESTDY)
    target_en           - Event end day variable (e.g., AEENDY)
~~~

Assumptions       :  
~~~text
    - Event start and end values are integers (typically study day numbers)
    - Missing end date indicates an ongoing event
~~~
Limitations       :
    - Large time spans or a high number of subjects may lead to excessive memory use,  
      potentially resulting in runtime errors  
  
Usage Example     :  
~~~sas
    %event_gant_excel(
        outpath=F:\Project\output,
        outfile=ae_gant.xlsx,
        target_dataest=work.ae,
        target_id=SUBJID,
        target_event_name=AETERM,
        target_st=AESTDY,
        target_en=AEENDY
    );
~~~

<img width="858" height="158" alt="Image" src="https://github.com/user-attachments/assets/4464e378-8ba2-4663-aa72-b92f93c8ca1b" />  

# %upset_plot()
 Description    : Generates an UpSet plot to visualize co-occurrence patterns across   
                  multiple items per individual. If no input dataset is provided,   
                  a synthetic test dataset is generated internally.  
                  The macro performs data preprocessing, aggregation, transposition,  
                  and graphical rendering using PROC TEMPLATE and PROC SGRENDER.  

 Parameters     :   
 ~~~text
    data     = Input dataset name (if not specified, a test dataset is auto-generated)
    personID = Variable name identifying individuals (e.g., ID)
    itemnum  = Numeric variable representing item code (e.g., itemnum)
    itemname = Character variable for item label (e.g., itemname)
    width    = Width of the output PNG image in pixels (default: 1000)
    height   = Height of the output PNG image in pixels (default: 650)
~~~
 Output         :   
 ~~~text
    - Intermediate datasets are created in the WORK/temp library.
    - Final output is rendered as a PNG-based UpSet plot using ODS Graphics.
~~~
 Requirements   : 
    - If specifying a dataset via `data=`, the variables passed in 
      `personID=`, `itemnum=`, and `itemname=` must exist in that dataset.

 Example Usage  :  
~~~sas
    %upset_plot(data=testdata_upset, personID=ID ,itemnum=itemnum, itemname=itemname);
~~~
<img width="601" height="368" alt="Image" src="https://github.com/user-attachments/assets/88d29046-8c19-4d09-be4a-f82bae5a7c7d" />  

~~~sas
    %upset_plot(data=demodata, personID=SUBJID, itemnum=symptom_code, itemname=symptom_label);
~~~

# version history
0.1.0(28July2025): Initial version

## What is SAS Packages?  
The package is built on top of **SAS Packages framework(SPF)** developed by Bartosz Jablonski.
For more information about SAS Packages framework, see [SAS_PACKAGES](https://github.com/yabwon/SAS_PACKAGES).  
You can also find more SAS Packages(SASPACs) in [SASPAC](https://github.com/SASPAC).

## How to use SAS Packages? (quick start)
### 1. Set-up SPF(SAS Packages Framework)
Firstly, create directory for your packages and assign a fileref to it.
~~~sas      
filename packages "\path\to\your\packages";
~~~
Secondly, enable the SAS Packages Framework.  
(If you don't have SAS Packages Framework installed, follow the instruction in [SPF documentation](https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation) to install SAS Packages Framework.)  
~~~sas      
%include packages(SPFinit.sas)
~~~  
### 2. Install SAS package  
Install SAS package you want to use using %installPackage() in SPFinit.sas.
~~~sas      
%installPackage(packagename, sourcePath=\github\path\for\packagename)
~~~
(e.g. %installPackage(ABC, sourcePath=https://github.com/XXXXX/ABC/raw/main/))  
### 3. Load SAS package  
Load SAS package you want to use using %loadPackage() in SPFinit.sas.
~~~sas      
%loadPackage(packagename)
~~~
### Enjoy😁


