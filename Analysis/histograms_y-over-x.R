rm(list = ls())  #clear variables
options(timeout=2400); # set timeout to twice default level to avoid abort due to high traffic

library(quantreg);
library(ggplot2);
library(ggrepel);
library(ggpmisc);
library(grid);
library(httr);
library(data.table);
library(scales);
#----------------------------------------------
site <- "http://deq1.bse.vt.edu/d.dh"    #Specify the site of interest, either d.bet OR d.dh
#----------------------------------------------
#----FOR RUNNING LOCALLY:
# Only need to change 1 path here - set to wherever this code is located
basepath='C:\\usr\\local\\home\\git\\r-dh-ecohydro';

# set your local directory paths in config.local.private located in filepath above
# this file will NOT be sent to git, so it should persist
# so, edit config.local.private once and you should be good to go
source(paste(basepath,'config.local.private',sep='/'));
# all these rely on variables set in config.local.private
source(paste(fxn_vahydro,"rest_functions.R", sep = "/"));
source(paste(auth_rest,"rest.private", sep="/"));
source(paste(fxn_locations,"ELFGEN/internal/elf_quantreg.R", sep = "/"));
source(paste(fxn_locations,"ELFGEN/internal/elf_pct_chg.R", sep = "/"));
source(paste(fxn_locations,"ELFGEN/internal/elf_pw_it.R", sep = "/"));
source(paste(fxn_locations,"ELFGEN/internal/elf_assemble_batch.R", sep = "/"));

token <- rest_token(site, token, rest_uname, rest_pw);
#####
inputs <- list(
  site = site,
  pct_chg = 10,                             #Percent decrease in flow for barplots (keep at 10 for now)
  save_directory = save_directory, 
  x_metric = 'erom_q0001e_mean', #Flow metric to be plotted on the x-axis
  y_metric = 'aqbio_nt_total',	   #Biometric to be plotted on the y-axis, see "dh variable key" column for options: https://docs.google.com/spreadsheets/d/1PnxY4Rxfk9hkuaXy7tv8yl-mPyJuHdQhrOUWx_E1Y_w/edit#gid=0
  ws_ftype = c('nhd_huc10'),		     #Options: state, hwi_region, nhd_huc8, nhd_huc6, ecoregion_iii, ecoregion_iv, ecoiii_huc6
  target_hydrocode = 'usa_state_virginia',           #Leave blank to process all, individual examples: usa_state_virginia for all of VA, atl_non_coastal_plain_usgs,ohio_river_basin_nhdplus,nhd_huc8_05050001...
  quantile = .80,                  #Specify the quantile to use for quantile regresion plots 
  xaxis_thresh = 15000,            #Leave at 15000 so all plots have idential axis limits 
  analysis_timespan = 'full',      #used to plot for entire timespan 
  send_to_rest = "NO",            #"YES" to push ELF statistic outputs to VAHydro
  station_agg = "max",             #Specify aggregation to only use the "max" NT value for each station or "all" NT values
  sampres = 'species',                  
  glo = 1,  
  ghi = 530,
  dataset_tag = 'ymax75',
  token = token,
  startdate = '1900-01-01',
  enddate = '2100-01-01'
);

ua_hist <- function(data, freq = TRUE, breaks = 20) {
  data <- subset(data, data$drainage_area_sqmi >= 2.718282)
  data <- subset(data, data$ratio < 10.0)
  hist((data$y_value / log(data$x_value)), freq=freq, breaks=breaks);
}

##### Data Acquisition #####
# State
#retrieve raw data
mydata <- vahydro_fe_data(
  'usa_state_virginia', "erom_q0001e_mean", "aqbio_nt_total", 
  'landunit',  "state", "species"
);
data <- elf_cleandata(mydata, inputs);
ua_hist(data,freq=FALSE,breaks=15);


# Roanoke HUC6
mydata <- vahydro_fe_data(
  '0208020104', "erom_q0001e_mean", "aqbio_nt_total", 
  'watershed',  "nhd_huc10", "species"
);
data <- elf_cleandata(mydata, inputs);
ua_hist(data,freq=FALSE,breaks=15);

# Roanoke HUC8
mydata <- vahydro_fe_data(
  'nhd_huc8_02080201', "erom_q0001e_mean", "aqbio_nt_total", 
  'watershed',  "nhd_huc8", "species"
);
data <- elf_cleandata(mydata, inputs);
ua_hist(data,freq=FALSE,breaks=15);

# Roanoke HUC10
mydata <- vahydro_fe_data(
  '0208020104', "erom_q0001e_mean", "aqbio_nt_total", 
  'watershed',  "nhd_huc10", "species"
);
data <- elf_cleandata(mydata, inputs);
ua_hist(data,freq=FALSE,breaks=15);

#perform quantile regression calculation and plot 
elf_quantreg(
 inputs, data, x_metric_code = inputs$x_metric, 
 y_metric_code = inputs$y_metric, 
 ws_ftype_code = NULL, 
 Feature.Name_code = 'Roanoke ELF', 
 Hydroid_code = NULL, 
 search_code = NULL, token, 
 min(data$tstime), max(data$tstime)
)
plot(log(data$x_value), data$y_value)
reg <- lm(y_value~log(x_value),data)
abline(lm(y_value~log(x_value),data))
lines(log(data$x_value[order(data$x_value)]), loess(y_value~log(x_value),data)$fitted[order(data$x_value)],col="blue",lwd=3)
lines(table$x[order(table$x)],(loess(as.character(pct_chg_10) ~ x,data=table))$fitted[order(table$x)],col="blue",lwd=3)

summary(reg)

#for setting ghi = max x_value
inputs$ghi <- max(mydata$x_value);


##### Plot PWIT ####
# modify elf_pwit to do analysis and return results
elf_pw_it (
  inputs, data, inputs$x_metric, 
  inputs$y_metric, ws_ftype_code = NULL, 
  '020802', '020802', 
  '020802', token, 
  min(data$tstime), max(data$tstime)
)
# add new function
# plot_elf_pwit()
# add new function store_elf_pwit() (if SEND_TO_REST = TRUE)
