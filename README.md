# aircraft-monitoring4wmo
This is set of tools preparing statistics for WMO: 

Development of Lead Centre for Aircraft-Based Observations Functionality, Specification of Requirements
Version 17 October 2022.
This is a summary description of the full requirements specification which is made in WMO No. 1200, Guide to Aircraft-Based Observations, Appendix B, GUIDANCE ON QUALITY MONITORING OF AIRCRAFT-BASED OBSERVATIONS.
Lead Centre Terms of Reference are provided below.
Requirement	Description	Functionality	Priority	Comment
1.	Monthly monitoring of ABO – air temperature and humidity	Monthly air temperature and humidity NWP comparison statistical report, essentially restoring the monthly reports previously provided by NCEP and distributed by email.	-	Contain results for all aircraft providing data to WIS; 
-	To be made available automatically by email to all focal points for operational ABO programme managers for the previous UTC month as soon after 0000 UTC of the first day of the new month as possible;
-	Sorted so as to provide suspect records first, followed by non-suspect records, grouped by programme;
-	Provided in the format described within Attachment B1 to appendix B of WMO No. 1200.	High	Restores the previous monthly reporting by the Lead Centre and distributes by email.
2.	Monthly monitoring of ABO – wind speed and direction	Monthly wind NWP comparison statistical report, essentially restoring the monthly reports previously provided by NCEP and distributed by email.	-	Contain results for all aircraft providing data to WIS; 
-	To be made available automatically by email to all focal points for operational ABO programme managers for the previous UTC month as soon after 0000 UTC of the first day of the new month as possible;
-	Sorted so as to provide suspect records first, followed by non-suspect records, grouped by programme;
-	Provided in the format described within Attachment B1 to appendix B of WMO No. 1200.	High	Restores the previous monthly reporting by the Lead Centre and distributes by email.
3.	Automated monitoring reports – Daily availability monitoring reports of ABO	Report that isolates and list those aircraft whose recent availability of observations over the past 3 days varies 
significantly from their availability of observations over the 7 days preceding the initial 
3-day period.	-	Report to be made available automatically by email to all focal points for operational ABO programme managers for the previous UTC day as soon after 0000 UTC as possible; 
-	Be provided in the format described within Attachment B1 to the present appendix.	High	Important report that alerts when data output declines.

4.	Daily 10-day moving monitoring report of ABO NWP comparison – air temperature and humidity.	Report that isolates and lists air temperature and humidity daily 10-day moving window NWP comparison.	-	Be limited to the provision of information that isolates errors or issues with a low probability of false alarm and according to the criteria;
-	Made available automatically by email to all focal points for operational ABO programme managers for the previous UTC day as soon after 0000 UTC as possible;
-	Provide a 10-day moving window of monitoring statistics for the current and prior 9 days; 
-	Provided in the format described within Attachment B1 to appendix B of WMO No. 1200.	High	Daily report that provides alert-based listing of suspect aircraft based on criteria.
5.	Daily 10-day moving monitoring report of ABO NWP comparison – wind.	Report that isolates and lists wind speed and direction daily 10-day moving window NWP comparison.	-	Be limited to the provision of information that isolates errors or issues with a low probability of false alarm and according to the criteria;
-	Made available automatically by email to all focal points for operational ABO programme managers for the previous UTC day as soon after 0000 UTC as possible;
-	Provide a 10-day moving window of monitoring statistics for the current and prior 9 days; 
-	Provided in the format described within Attachment B1 to appendix B of WMO No. 1200.	High	Daily report that provides alert-based listing of suspect aircraft based on criteria.
6.	Online provision of reports	Lead Center should provide an online site for archival and provision of reports 1-5.	-	Provision of 12 to 24 months of reports.	High	
7.	Incident Management System maintenance	Comply with ToR c).	-	Maintain an online record of data quality issues, with their status.
-	A spreadsheet or similar will suffice for this initially.	High	Ideally, the WIGOS Incident Management System should be used but it is currently under development.
8.	Database NWP comparison statistics	Online provision of graphical plotting of NWP comparison statistics with resolution of daily or higher.	-	Essentially, this would be a store of the data from reports 1-6 above.
-	Provision of single and multiple plotting of aircraft data series.
-	NWP comparison variables:
–	Air Temperature
–	Wind speed 
–	Wind direction 
–	Wind vector difference magnitude 
–	Humidity 	Medium	Database will be required to provide online analysis of NWP data. This could readily be facilitated with a freeware or off the shelf database application.
9.	Database of ABOP data values	Online provision of graphical plotting of ABO data (item 8) integrated with NWP comparison statistics with resolution of daily or higher.	-	Provision of single and multiple plotting of aircraft data series.
-	Overplotting of NWP comparison with ABO data series.
-	ABO variables:
–	Air Temperature
–	Wind speed 
–	Wind direction 
–	Wind vector difference magnitude 
–	Humidity	Medium	This could be a Phase 2 requirement.
 
Lead Centre Terms of Reference
Lead centres on ABO should provide the following functions and services to assist WMO Members in the quality management of their ABO systems: 
a)	Receive, process, archive and analyse monitoring reports from designated WMO global and regional monitoring centres for ABO; 
b)	Ensure WMO focal points on ABO receive monitoring reports and act upon issues arising from them; 
c)	Develop, implement and maintain an incident management system to record and manage faults or issues raised through the monitoring and quality evaluation processes; 
d)	Provide technical advice to assist Members in rectifying quality issues associated with their ABO systems; 
e)	Establish and maintain an online facility that provides the suite of quality monitoring information and tools as described in Attachment B3 to the present appendix; 
f)	Compile an annual report to the CBS Open Programme Area Group on Integrated Observing Systems on the performance of the ABO and ABO quality monitoring systems, highlighting any important issues
==============================================================================================
Monthly statistics are produced and uploaded to monitoring site on regular bases
https://www.nco.ncep.noaa.gov/pmb/qap/acars/   (4 reports)
https://www.nco.ncep.noaa.gov/pmb/qap/amdar/   (1 report) 
