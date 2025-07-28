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
