library('ggplot2')
library('plyr')

site <- "http://deq2.bse.vt.edu/d.dh"    #Specify the site of interest, either d.bet OR d.dh
base_url <- "http://deq2.bse.vt.edu/d.dh/"
hydro_tools <- 'C:\\Users\\nrf46657\\Desktop\\VAHydro Development\\GitHub\\hydro-tools\\' #location of hydro-tools repo
save_directory <- "C:/Users/nrf46657/Desktop/VAHydro Development/GitHub/plots/" 
path <- "/Users/nrf46657/Desktop/VAHydro Development/GitHub/r-dh-ecohydro/Analysis/"
basepath='C:/Users/nrf46657/Desktop/VAHydro Development/GitHub/r-dh-ecohydro/';

source(paste(basepath,'config.local.private',sep='/'));
source(paste(path,"query_elf_statistics.R", sep = ""))

#Generate REST token for authentication              
rest_uname = FALSE
rest_pw = FALSE
source(paste(hydro_tools,"auth.private", sep = "\\")); #load rest username and password, contained in auth.private file
source(paste(hydro_tools,"VAHydro-2.0","rest_functions.R", sep = "\\")) #load REST functions
token <- rest_token(site, token, rest_uname, rest_pw)

##########################################################################################################


export.df <- data.frame(pctchg=as.Date(character()),
                        flow=character(), 
                        ifim_site=character(), 
                        hab_chg=character(),
                        custom_taxachg=character(),
                        custom_tag=character(),
                        custom_huc_unit=character(),
                        custom_huc=character(),
                        huc8_taxachg=character(),
                        huc8_tag=character(),
                        huc8=character(),
                        stringsAsFactors=FALSE) 

#LOOP THRU PERCENT FLOW REDUCTION
#flow_reductions <- c("10","20")
#pctchg <- "10"
#flow.reduction <- c("10","20","30","40","50")
flow.reduction <- c("10")

#j <- 2
for (j in 1:length(flow.reduction)) {
pctchg <- flow.reduction[j]


all_sites <- read.csv(paste(basepath,"Analysis/habitat/pctchg_datasets/all_flows/IFIM_SITES_",pctchg,"%Reduction.csv",sep=""))
#all_sites <- read.csv(paste(basepath,"Analysis/habitat/pctchg_datasets/tenth_percentile_flow_and_below/IFIM_SITES_",pctchg,"%Reduction.csv",sep=""))



# Remove Potomac Sites when doing all_flows 
all_sites <- all_sites[-which(all_sites$ifim_site_name=="T8&9"),] 
all_sites <- all_sites[-which(all_sites$ifim_site_name=="T11&12"),] 

fish.only <- "yes" #"yes" to plot for fish habitat metrics only 


#-----------------------------------------------------------------------------------------------------
# REMOVE NON-FISH METRICS
#-----------------------------------------------------------------------------------------------------
if (fish.only == "yes") {
all_sites <- all_sites[-which(all_sites$metric=="alg_mid"),]        # Algae and Midge Guild
all_sites <- all_sites[-which(all_sites$metric=="bd_high_grad"),]   # Benthos Diversity, high gradient
all_sites <- all_sites[-which(all_sites$metric=="bd_low_grad"),]    # Benthos Diversity, low gradient
all_sites <- all_sites[-which(all_sites$metric=="benth_mac"),]      # Benthic Macroinvertebrates
all_sites <- all_sites[-which(all_sites$metric=="cf"),]             # Crayfish
all_sites <- all_sites[-which(all_sites$metric=="e_comp"),]         # Eastern Elliptio mussel, Elliptio complanata
all_sites <- all_sites[-which(all_sites$metric=="eph_mac"),]        # Mayfly
all_sites <- all_sites[-which(all_sites$metric=="l_rad"),]          # Eastern lampmussel
all_sites <- all_sites[-which(all_sites$metric=="plec_mac"),]       # Stonefly
all_sites <- all_sites[-which(all_sites$metric=="pwb"),]            # Purple Wartyback mussel
all_sites <- all_sites[-which(all_sites$metric=="sm_shal_slow"),]   # Spike Mussel, Shallow
all_sites <- all_sites[-which(all_sites$metric=="sm_int"),]         # Spike Mussel, Intermediate
all_sites <- all_sites[-which(all_sites$metric=="tric_mac"),]       # Caddisfly
}
#-----------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------
# Single metric tests
#all_sites <- all_sites[which(all_sites$metric=="smb_adult"),]  
#all_sites <- all_sites[which(all_sites$metric=="nh_adult"),]    
#all_sites <- all_sites[which(all_sites$metric=="alg_mid"),]   


site_subset <- data.frame(ifim_site_name = character(),
                          ifim_da_sqmi = character(), 
                          metric = character(), 
                          flow = character(), 
                          pctchg = character(), 
                          stringsAsFactors=FALSE) 


 site_subset <- rbind(site_subset, all_sites[which(all_sites$ifim_site_name=="Dunlap"),])       
 site_subset <- rbind(site_subset, all_sites[which(all_sites$ifim_site_name=="Craig"),])  
 site_subset <- rbind(site_subset, all_sites[which(all_sites$ifim_site_name=="Plains Mill"),])    
 site_subset <- rbind(site_subset, all_sites[which(all_sites$ifim_site_name=="North Anna Piedmont"),])      
 site_subset <- rbind(site_subset, all_sites[which(all_sites$ifim_site_name=="North Anna Fall Zone"),])      
 site_subset <- rbind(site_subset, all_sites[which(all_sites$ifim_site_name=="North Anna Coastal Plain"),])      
 

 all_sites <- site_subset
#-----------------------------------------------------------------------------------------------------

MAF_all_sites <- all_sites[all_sites$flow %in% "MAF",]
MAF_all_sites <- na.omit(MAF_all_sites) #remove NA rows prior to calculating medians
MAF_all_sites_medians <- aggregate(list(pctchg = MAF_all_sites$pctchg), list(ifim_da_sqmi = MAF_all_sites$ifim_da_sqmi), median)

Jan_all_sites <- all_sites[all_sites$flow %in% "Jan",]
Jan_all_sites <- na.omit(Jan_all_sites) #remove NA rows prior to calculating medians
Jan_all_sites_medians <- aggregate(list(pctchg = Jan_all_sites$pctchg), list(ifim_da_sqmi = Jan_all_sites$ifim_da_sqmi), median)

Feb_all_sites <- all_sites[all_sites$flow %in% "Feb",]
Feb_all_sites <- na.omit(Feb_all_sites) #remove NA rows prior to calculating medians
Feb_all_sites_medians <- aggregate(list(pctchg = Feb_all_sites$pctchg), list(ifim_da_sqmi = Feb_all_sites$ifim_da_sqmi), median)

Mar_all_sites <- all_sites[all_sites$flow %in% "Mar",]
Mar_all_sites <- na.omit(Mar_all_sites) #remove NA rows prior to calculating medians
Mar_all_sites_medians <- aggregate(list(pctchg = Mar_all_sites$pctchg), list(ifim_da_sqmi = Mar_all_sites$ifim_da_sqmi), median)

Apr_all_sites <- all_sites[all_sites$flow %in% "Apr",]
Apr_all_sites <- na.omit(Apr_all_sites) #remove NA rows prior to calculating medians
Apr_all_sites_medians <- aggregate(list(pctchg = Apr_all_sites$pctchg), list(ifim_da_sqmi = Apr_all_sites$ifim_da_sqmi), median)

May_all_sites <- all_sites[all_sites$flow %in% "May",]
May_all_sites <- na.omit(May_all_sites) #remove NA rows prior to calculating medians
May_all_sites_medians <- aggregate(list(pctchg = May_all_sites$pctchg), list(ifim_da_sqmi = May_all_sites$ifim_da_sqmi), median)

Jun_all_sites <- all_sites[all_sites$flow %in% "Jun",]
Jun_all_sites <- na.omit(Jun_all_sites) #remove NA rows prior to calculating medians
Jun_all_sites_medians <- aggregate(list(pctchg = Jun_all_sites$pctchg), list(ifim_da_sqmi = Jun_all_sites$ifim_da_sqmi), median)

Jul_all_sites <- all_sites[all_sites$flow %in% "Jul",]
Jul_all_sites <- na.omit(Jul_all_sites) #remove NA rows prior to calculating medians
Jul_all_sites_medians <- aggregate(list(pctchg = Jul_all_sites$pctchg), list(ifim_da_sqmi = Jul_all_sites$ifim_da_sqmi), median)

Aug_all_sites <- all_sites[all_sites$flow %in% "Aug",]
Aug_all_sites <- na.omit(Aug_all_sites) #remove NA rows prior to calculating medians
Aug_all_sites_medians <- aggregate(list(pctchg = Aug_all_sites$pctchg), list(ifim_da_sqmi = Aug_all_sites$ifim_da_sqmi), median)

Sep_all_sites <- all_sites[all_sites$flow %in% "Sep",]
Sep_all_sites <- na.omit(Sep_all_sites) #remove NA rows prior to calculating medians
Sep_all_sites_medians <- aggregate(list(pctchg = Sep_all_sites$pctchg), list(ifim_da_sqmi = Sep_all_sites$ifim_da_sqmi), median)

Oct_all_sites <- all_sites[all_sites$flow %in% "Oct",]
Oct_all_sites <- na.omit(Oct_all_sites) #remove NA rows prior to calculating medians
Oct_all_sites_medians <- aggregate(list(pctchg = Oct_all_sites$pctchg), list(ifim_da_sqmi = Oct_all_sites$ifim_da_sqmi), median)

Nov_all_sites <- all_sites[all_sites$flow %in% "Nov",]
Nov_all_sites <- na.omit(Nov_all_sites) #remove NA rows prior to calculating medians
Nov_all_sites_medians <- aggregate(list(pctchg = Nov_all_sites$pctchg), list(ifim_da_sqmi = Nov_all_sites$ifim_da_sqmi), median)

Dec_all_sites <- all_sites[all_sites$flow %in% "Dec",]
Dec_all_sites <- na.omit(Dec_all_sites) #remove NA rows prior to calculating medians
Dec_all_sites_medians <- aggregate(list(pctchg = Dec_all_sites$pctchg), list(ifim_da_sqmi = Dec_all_sites$ifim_da_sqmi), median)

################################################################################################################
################################################################################################################
################################################################################################################
# RETREIEVE IFIM SITE DH FEATURE AND ITS MAF AND DA PROPERTIES
################################################################################################################
Dunlap.site.inputs <- list(bundle = 'monitoringpoint',ftype = 'ifim_transect',hydrocode = 'ifim_uja_00',stringsAsFactors=FALSE) 
Dunlap.site.dataframe <- getFeature(Dunlap.site.inputs, token, site, feature)
Dunlap.site.hydroid <- as.character(Dunlap.site.dataframe$hydroid)
#
Dunlap.maf.inputs <-list(featureid = Dunlap.site.hydroid,varkey = 'erom_q0001e_mean',entity_type = 'dh_feature')
Dunlap.maf.dataframe <- getProperty(Dunlap.maf.inputs, site, prop)
Dunlap.erom_q0001e_mean <- as.numeric(as.character(Dunlap.maf.dataframe$propvalue))
#
Dunlap.da.inputs <-list(featureid = Dunlap.site.hydroid,varkey = 'nhdp_drainage_sqmi',entity_type = 'dh_feature')
Dunlap.da.dataframe <- getProperty(Dunlap.da.inputs, site, prop)
Dunlap.nhdp_drainage_sqmi <- as.numeric(as.character(Dunlap.da.dataframe$propvalue))
#---------------------------------------------------------------------------------------------------------------
PlainsMill.site.inputs <- list(bundle = 'monitoringpoint',ftype = 'ifim_transect',hydrocode = 'ifim_nfs_00',stringsAsFactors=FALSE) 
PlainsMill.site.dataframe <- getFeature(PlainsMill.site.inputs, token, site, feature)
PlainsMill.site.hydroid <- as.character(PlainsMill.site.dataframe$hydroid)
#
PlainsMill.maf.inputs <-list(featureid = PlainsMill.site.hydroid,varkey = 'erom_q0001e_mean',entity_type = 'dh_feature')
PlainsMill.maf.dataframe <- getProperty(PlainsMill.maf.inputs, site, prop)
PlainsMill.erom_q0001e_mean <- as.numeric(as.character(PlainsMill.maf.dataframe$propvalue))
#
PlainsMill.da.inputs <-list(featureid = PlainsMill.site.hydroid,varkey = 'nhdp_drainage_sqmi',entity_type = 'dh_feature')
PlainsMill.da.dataframe <- getProperty(PlainsMill.da.inputs, site, prop)
PlainsMill.nhdp_drainage_sqmi <- as.numeric(as.character(PlainsMill.da.dataframe$propvalue))
#---------------------------------------------------------------------------------------------------------------
NorthAnnaPiedmont.site.inputs <- list(bundle = 'monitoringpoint',ftype = 'ifim_transect',hydrocode = 'ifim_yor_00',stringsAsFactors=FALSE) 
NorthAnnaPiedmont.site.dataframe <- getFeature(NorthAnnaPiedmont.site.inputs, token, site, feature)
NorthAnnaPiedmont.site.hydroid <- as.character(NorthAnnaPiedmont.site.dataframe$hydroid)
#
NorthAnnaPiedmont.maf.inputs <-list(featureid = NorthAnnaPiedmont.site.hydroid,varkey = 'erom_q0001e_mean',entity_type = 'dh_feature')
NorthAnnaPiedmont.maf.dataframe <- getProperty(NorthAnnaPiedmont.maf.inputs, site, prop)
NorthAnnaPiedmont.erom_q0001e_mean <- as.numeric(as.character(NorthAnnaPiedmont.maf.dataframe$propvalue))
#
NorthAnnaPiedmont.da.inputs <-list(featureid = NorthAnnaPiedmont.site.hydroid,varkey = 'nhdp_drainage_sqmi',entity_type = 'dh_feature')
NorthAnnaPiedmont.da.dataframe <- getProperty(NorthAnnaPiedmont.da.inputs, site, prop)
NorthAnnaPiedmont.nhdp_drainage_sqmi <- as.numeric(as.character(NorthAnnaPiedmont.da.dataframe$propvalue))
#---------------------------------------------------------------------------------------------------------------
NorthAnnaFallZone.site.inputs <- list(bundle = 'monitoringpoint',ftype = 'ifim_transect',hydrocode = 'ifim_yor_01',stringsAsFactors=FALSE) 
NorthAnnaFallZone.site.dataframe <- getFeature(NorthAnnaFallZone.site.inputs, token, site, feature)
NorthAnnaFallZone.site.hydroid <- as.character(NorthAnnaFallZone.site.dataframe$hydroid)
#
NorthAnnaFallZone.maf.inputs <-list(featureid = NorthAnnaFallZone.site.hydroid,varkey = 'erom_q0001e_mean',entity_type = 'dh_feature')
NorthAnnaFallZone.maf.dataframe <- getProperty(NorthAnnaFallZone.maf.inputs, site, prop)
NorthAnnaFallZone.erom_q0001e_mean <- as.numeric(as.character(NorthAnnaFallZone.maf.dataframe$propvalue))
#
NorthAnnaFallZone.da.inputs <-list(featureid = NorthAnnaFallZone.site.hydroid,varkey = 'nhdp_drainage_sqmi',entity_type = 'dh_feature')
NorthAnnaFallZone.da.dataframe <- getProperty(NorthAnnaFallZone.da.inputs, site, prop)
NorthAnnaFallZone.nhdp_drainage_sqmi <- as.numeric(as.character(NorthAnnaFallZone.da.dataframe$propvalue))
#---------------------------------------------------------------------------------------------------------------
Craig.site.inputs <- list(bundle = 'monitoringpoint',ftype = 'ifim_transect',hydrocode = 'ifim_uja_01',stringsAsFactors=FALSE) 
Craig.site.dataframe <- getFeature(Craig.site.inputs, token, site, feature)
Craig.site.hydroid <- as.character(Craig.site.dataframe$hydroid)
#
Craig.maf.inputs <-list(featureid = Craig.site.hydroid,varkey = 'erom_q0001e_mean',entity_type = 'dh_feature')
Craig.maf.dataframe <- getProperty(Craig.maf.inputs, site, prop)
Craig.erom_q0001e_mean <- as.numeric(as.character(Craig.maf.dataframe$propvalue))
#
Craig.da.inputs <-list(featureid = Craig.site.hydroid,varkey = 'nhdp_drainage_sqmi',entity_type = 'dh_feature')
Craig.da.dataframe <- getProperty(Craig.da.inputs, site, prop)
Craig.nhdp_drainage_sqmi <- as.numeric(as.character(Craig.da.dataframe$propvalue))
#---------------------------------------------------------------------------------------------------------------
NorthAnnaCoastalPlain.site.inputs <- list(bundle = 'monitoringpoint',ftype = 'ifim_transect',hydrocode = 'ifim_yor_02',stringsAsFactors=FALSE) 
NorthAnnaCoastalPlain.site.dataframe <- getFeature(NorthAnnaCoastalPlain.site.inputs, token, site, feature)
NorthAnnaCoastalPlain.site.hydroid <- as.character(NorthAnnaCoastalPlain.site.dataframe$hydroid)
#
NorthAnnaCoastalPlain.maf.inputs <-list(featureid = NorthAnnaCoastalPlain.site.hydroid,varkey = 'erom_q0001e_mean',entity_type = 'dh_feature')
NorthAnnaCoastalPlain.maf.dataframe <- getProperty(NorthAnnaCoastalPlain.maf.inputs, site, prop)
NorthAnnaCoastalPlain.erom_q0001e_mean <- as.numeric(as.character(NorthAnnaCoastalPlain.maf.dataframe$propvalue))
#
NorthAnnaCoastalPlain.da.inputs <-list(featureid = NorthAnnaCoastalPlain.site.hydroid,varkey = 'nhdp_drainage_sqmi',entity_type = 'dh_feature')
NorthAnnaCoastalPlain.da.dataframe <- getProperty(NorthAnnaCoastalPlain.da.inputs, site, prop)
NorthAnnaCoastalPlain.nhdp_drainage_sqmi <- as.numeric(as.character(NorthAnnaCoastalPlain.da.dataframe$propvalue))
#---------------------------------------------------------------------------------------------------------------




#months <- c("MAF","Jul","Aug","Sep")
#flow_metric <- c("erom_q0001e_mean","erom_q0001e_july","erom_q0001e_aug","erom_q0001e_sept")

months <- c("MAF","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")
flow_metric <- c("erom_q0001e_mean",
                 "erom_q0001e_jan",
                 "erom_q0001e_feb",
                 "erom_q0001e_mar",
                 "erom_q0001e_apr",
                 "erom_q0001e_may",
                 "erom_q0001e_june",
                 "erom_q0001e_july",
                 "erom_q0001e_aug",
                 "erom_q0001e_sept",
                 "erom_q0001e_oct",
                 "erom_q0001e_nov",
                 "erom_q0001e_dec")


#r<-1
for (r in 1:length(months)) {
  month <- months[r]
  if (month == "MAF"){month_data <- MAF_all_sites}
  if (month == "Jan"){month_data <- Jan_all_sites}
  if (month == "Feb"){month_data <- Feb_all_sites}
  if (month == "Mar"){month_data <- Mar_all_sites}
  if (month == "Apr"){month_data <- Apr_all_sites}
  if (month == "May"){month_data <- May_all_sites}
  if (month == "Jun"){month_data <- Jun_all_sites}
  if (month == "Jul"){month_data <- Jul_all_sites}
  if (month == "Aug"){month_data <- Aug_all_sites}
  if (month == "Sep"){month_data <- Sep_all_sites}
  if (month == "Oct"){month_data <- Oct_all_sites}
  if (month == "Nov"){month_data <- Nov_all_sites}
  if (month == "Dec"){month_data <- Dec_all_sites}
  
  stat <- "median"
  
  
  month_data_medians <- aggregate(list(pctchg = month_data$pctchg), 
                                  list(ifim_da_sqmi = month_data$ifim_da_sqmi), 
                                  stat)
  
  if (fish.only == "yes") {
    plot_name <- paste(month,"_boxplots_",stat,"_FISH",sep="") 
  } else {
    plot_name <- paste(month,"_boxplots_",stat,sep="") 
  }
  
  if (month == "MAF"){plot_name  <- paste("0-",plot_name,sep="")}
  if (month == "Jan"){plot_name  <- paste("1-",plot_name,sep="")}
  if (month == "Feb"){plot_name  <- paste("2-",plot_name,sep="")}
  if (month == "Mar"){plot_name  <- paste("3-",plot_name,sep="")}
  if (month == "Apr"){plot_name  <- paste("4-",plot_name,sep="")}
  if (month == "May"){plot_name  <- paste("5-",plot_name,sep="")}
  if (month == "Jun"){plot_name  <- paste("6-",plot_name,sep="")}
  if (month == "Jul"){plot_name  <- paste("7-",plot_name,sep="")}
  if (month == "Aug"){plot_name  <- paste("8-",plot_name,sep="")}
  if (month == "Sep"){plot_name  <- paste("9-",plot_name,sep="")}
  if (month == "Oct"){plot_name  <- paste("10-",plot_name,sep="")}
  if (month == "Nov"){plot_name  <- paste("11-",plot_name,sep="")}
  if (month == "Dec"){plot_name  <- paste("12-",plot_name,sep="")}
################################################################################################################
# RETREIEVE ELF STAT SUBMITTALS
################################################################################################################
#xvar <- 'erom_q0001e_mean'
#xvar <- 'erom_q0001e_july'
xvar <- flow_metric[r] 

# SPECIFY HUCS TO USE FOR EACH IFIM SITE 
# HUC 8:   
  Dunlap.huc8.code <- '02080201'
  PlainsMill.huc8.code <- '02070006'
  NorthAnna.huc8.code <- '02080106'
  Craig.huc8.code <- '02080201'
    
  #huc8_tag <- 'bpj-huc6-rcc' #NONE EXIST?
  huc8_tag <- 'bpj-huc6bp-rcc'
  #huc8_tag <- 'HUC8_quantregwHuc6bp'
  
# HUC 10: 
  Dunlap.huc10.code <- '0208020103'  
  PlainsMill.huc10.code <- '0207000603' 
  NorthAnna.huc10.code <- '0208010608'
  Craig.huc10.code <- '0208020112'

    
Dunlap.huc10.inputs <- list(bundle = 'watershed',ftype = 'nhd_huc10',hydrocode = Dunlap.huc10.code,stringsAsFactors=FALSE) 
Dunlap.huc10.dataframe <- getFeature(Dunlap.huc10.inputs, token, site, feature)
Dunlap.huc10.hydroid <- as.character(Dunlap.huc10.dataframe$hydroid)
  print(paste("Watershed Found: ",Dunlap.huc10.dataframe$name,sep=""))
Dunlap.huc10.stats.bpj_530 <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.80",dataset_tag = 'bpj-530',featureid = Dunlap.huc10.hydroid)
Dunlap.huc10.stats.bpj_q50 <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.50",dataset_tag = 'bpj-q50',featureid = Dunlap.huc10.hydroid)
Dunlap.huc10.stats.bpj_530_icthy <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.80",dataset_tag = 'bpj-530-icthy',featureid = Dunlap.huc10.hydroid)
Dunlap.huc10.stats.bpj_q50_icthy <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.50",dataset_tag = 'bpj-q50-icthy',featureid = Dunlap.huc10.hydroid)
Dunlap.huc8.inputs <- list(bundle = 'watershed',ftype = 'nhd_huc8',hydrocode = paste('nhd_huc8_',Dunlap.huc8.code,sep=""),stringsAsFactors=FALSE) 
Dunlap.huc8.dataframe <- getFeature(Dunlap.huc8.inputs, token, site, feature)
Dunlap.huc8.hydroid <- as.character(Dunlap.huc8.dataframe$hydroid)
  print(paste("Watershed Found: ",Dunlap.huc8.dataframe$name,sep=""))
Dunlap.huc8.stats <- fn_dh_elfstats(feature_ftype = 'nhd_huc8',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.80",dataset_tag = huc8_tag,featureid = Dunlap.huc8.hydroid)

PlainsMill.huc10.inputs <- list(bundle = 'watershed',ftype = 'nhd_huc10',hydrocode = PlainsMill.huc10.code,stringsAsFactors=FALSE) 
PlainsMill.huc10.dataframe <- getFeature(PlainsMill.huc10.inputs, token, site, feature)
PlainsMill.huc10.hydroid <- as.character(PlainsMill.huc10.dataframe$hydroid)
  print(paste("Watershed Found: ",PlainsMill.huc10.dataframe$name,sep=""))
PlainsMill.huc10.stats.bpj_530 <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.80",dataset_tag = 'bpj-530',featureid = PlainsMill.huc10.hydroid)
PlainsMill.huc10.stats.bpj_q50 <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.50",dataset_tag = 'bpj-q50',featureid = PlainsMill.huc10.hydroid)
PlainsMill.huc10.stats.bpj_530_icthy <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.80",dataset_tag = 'bpj-530-icthy',featureid = PlainsMill.huc10.hydroid)
PlainsMill.huc10.stats.bpj_q50_icthy <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.50",dataset_tag = 'bpj-q50-icthy',featureid = PlainsMill.huc10.hydroid)
PlainsMill.huc8.inputs <- list(bundle = 'watershed',ftype = 'nhd_huc8',hydrocode = paste('nhd_huc8_',PlainsMill.huc8.code,sep=""),stringsAsFactors=FALSE) 
PlainsMill.huc8.dataframe <- getFeature(PlainsMill.huc8.inputs,token, site, feature)
PlainsMill.huc8.hydroid <- as.character(PlainsMill.huc8.dataframe$hydroid)
  print(paste("Watershed Found: ",PlainsMill.huc8.dataframe$name,sep=""))
PlainsMill.huc8.stats <- fn_dh_elfstats(feature_ftype = 'nhd_huc8',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.80",dataset_tag = huc8_tag,featureid = PlainsMill.huc8.hydroid)

NorthAnna.huc10.inputs <- list(bundle = 'watershed',ftype = 'nhd_huc10',hydrocode = NorthAnna.huc10.code,stringsAsFactors=FALSE) 
NorthAnna.huc10.dataframe <- getFeature(NorthAnna.huc10.inputs,token, site, feature)
NorthAnna.huc10.hydroid <- as.character(NorthAnna.huc10.dataframe$hydroid)
  print(paste("Watershed Found: ",NorthAnna.huc10.dataframe$name,sep=""))
NorthAnna.huc10.stats.bpj_530 <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.80",dataset_tag = 'bpj-530',featureid = NorthAnna.huc10.hydroid)
NorthAnna.huc10.stats.bpj_q50 <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.50",dataset_tag = 'bpj-q50',featureid = NorthAnna.huc10.hydroid)
NorthAnna.huc10.stats.bpj_530_icthy <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.80",dataset_tag = 'bpj-530-icthy',featureid = NorthAnna.huc10.hydroid)
NorthAnna.huc10.stats.bpj_q50_icthy <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.50",dataset_tag = 'bpj-q50-icthy',featureid = NorthAnna.huc10.hydroid)
NorthAnna.huc8.inputs <- list(bundle = 'watershed',ftype = 'nhd_huc8',hydrocode = paste('nhd_huc8_',NorthAnna.huc8.code,sep=""),stringsAsFactors=FALSE) 
NorthAnna.huc8.dataframe <- getFeature(NorthAnna.huc8.inputs,token, site, feature)
NorthAnna.huc8.hydroid <- as.character(NorthAnna.huc8.dataframe$hydroid)
  print(paste("Watershed Found: ",NorthAnna.huc8.dataframe$name,sep=""))
NorthAnna.huc8.stats <- fn_dh_elfstats(feature_ftype = 'nhd_huc8',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.80",dataset_tag = huc8_tag,featureid = NorthAnna.huc8.hydroid)

Craig.huc10.inputs <- list(bundle = 'watershed',ftype = 'nhd_huc10',hydrocode = Craig.huc10.code,stringsAsFactors=FALSE) 
Craig.huc10.dataframe <- getFeature(Craig.huc10.inputs,token, site, feature)
Craig.huc10.hydroid <- as.character(Craig.huc10.dataframe$hydroid)
  print(paste("Watershed Found: ",Craig.huc10.dataframe$name,sep=""))
Craig.huc10.stats.bpj_530  <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.80",dataset_tag = 'bpj-530',featureid = Craig.huc10.hydroid)
Craig.huc10.stats.bpj_q50 <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.50",dataset_tag = 'bpj-q50',featureid = Craig.huc10.hydroid)
Craig.huc10.stats.bpj_530_icthy <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.80",dataset_tag = 'bpj-530-icthy',featureid = Craig.huc10.hydroid)
Craig.huc10.stats.bpj_q50_icthy <- fn_dh_elfstats(feature_ftype = 'nhd_huc10',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.50",dataset_tag = 'bpj-q50-icthy',featureid = Craig.huc10.hydroid)
Craig.huc8.inputs <- list(bundle = 'watershed',ftype = 'nhd_huc8',hydrocode = paste('nhd_huc8_',Craig.huc8.code,sep=""),stringsAsFactors=FALSE) 
Craig.huc8.dataframe <- getFeature(Craig.huc8.inputs,token, site, feature)
Craig.huc8.hydroid <- as.character(Craig.huc8.dataframe$hydroid)
  print(paste("Watershed Found: ",Craig.huc8.dataframe$name,sep=""))
Craig.huc8.stats <- fn_dh_elfstats(feature_ftype = 'nhd_huc8',yvar = 'aqbio_nt_total',xvar = xvar,sampres = 'species',stat_quantreg_qu = "0.80",dataset_tag = huc8_tag,featureid = Craig.huc8.hydroid)


################################################################################################################
# CALCULATE CUSTOM PERCENT CHANGE IN RICHNESS USING m, b, AND SITE MAF 
################################################################################################################
#pctchg <-10


Dunlap.huc10.m <- Dunlap.huc10.stats.bpj_q50$out_m
Dunlap.huc10.b <- Dunlap.huc10.stats.bpj_q50$out_b
Dunlap <- ((Dunlap.huc10.m*(log((1)/(1-(as.numeric(pctchg)/100)))))/(Dunlap.huc10.m*(log(Dunlap.erom_q0001e_mean))+Dunlap.huc10.b))*100

PlainsMill.huc10.m <- PlainsMill.huc8.stats$out_m
PlainsMill.huc10.b <- PlainsMill.huc8.stats$out_b
PlainsMill <- ((PlainsMill.huc10.m*(log((1)/(1-(as.numeric(pctchg)/100)))))/(PlainsMill.huc10.m*(log(PlainsMill.erom_q0001e_mean))+PlainsMill.huc10.b))*100

NorthAnna.huc10.m <- NorthAnna.huc10.stats.bpj_530_icthy$out_m
NorthAnna.huc10.b <- NorthAnna.huc10.stats.bpj_530_icthy$out_b
NorthAnnaPiedmont <- ((NorthAnna.huc10.m*(log((1)/(1-(as.numeric(pctchg)/100)))))/(NorthAnna.huc10.m*(log(NorthAnnaPiedmont.erom_q0001e_mean))+NorthAnna.huc10.b))*100
NorthAnnaFallZone <- ((NorthAnna.huc10.m*(log((1)/(1-(as.numeric(pctchg)/100)))))/(NorthAnna.huc10.m*(log(NorthAnnaFallZone.erom_q0001e_mean))+NorthAnna.huc10.b))*100
NorthAnnaCoastalPlain <- ((NorthAnna.huc10.m*(log((1)/(1-(as.numeric(pctchg)/100)))))/(NorthAnna.huc10.m*(log(NorthAnnaCoastalPlain.erom_q0001e_mean))+NorthAnna.huc10.b))*100


Craig.huc10.m <- Craig.huc10.stats.bpj_530_icthy$out_m
Craig.huc10.b <- Craig.huc10.stats.bpj_530_icthy$out_b
Craig <- ((Craig.huc10.m*(log((1)/(1-(as.numeric(pctchg)/100)))))/(Craig.huc10.m*(log(Craig.erom_q0001e_mean))+Craig.huc10.b))*100
################################################################################################################
################################################################################################################
################################################################################################################
# HUC 8 BLOCK
################################################################################################################
#pctchg <- 10

UpperJames.huc8.m <- Dunlap.huc8.stats$out_m
UpperJames.huc8.b <- Dunlap.huc8.stats$out_b
Dunlap.huc8 <- ((UpperJames.huc8.m*(log((1)/(1-(as.numeric(pctchg)/100)))))/(UpperJames.huc8.m*(log(Dunlap.erom_q0001e_mean))+UpperJames.huc8.b))*100
Craig.huc8 <- ((UpperJames.huc8.m*(log((1)/(1-(as.numeric(pctchg)/100)))))/(UpperJames.huc8.m*(log(Craig.erom_q0001e_mean))+UpperJames.huc8.b))*100

PlainsMill.huc8.m <- PlainsMill.huc8.stats$out_m
PlainsMill.huc8.b <- PlainsMill.huc8.stats$out_b
PlainsMill.huc8 <- ((PlainsMill.huc8.m*(log((1)/(1-(as.numeric(pctchg)/100)))))/(PlainsMill.huc8.m*(log(PlainsMill.erom_q0001e_mean))+PlainsMill.huc8.b))*100

NorthAnna.huc8.m <- NorthAnna.huc8.stats$out_m
NorthAnna.huc8.b <- NorthAnna.huc8.stats$out_b
NorthAnnaPiedmont.huc8 <- ((NorthAnna.huc8.m*(log((1)/(1-(as.numeric(pctchg)/100)))))/(NorthAnna.huc8.m*(log(NorthAnnaPiedmont.erom_q0001e_mean))+NorthAnna.huc8.b))*100
NorthAnnaFallZone.huc8 <- ((NorthAnna.huc8.m*(log((1)/(1-(as.numeric(pctchg)/100)))))/(NorthAnna.huc8.m*(log(NorthAnnaFallZone.erom_q0001e_mean))+NorthAnna.huc8.b))*100
NorthAnnaCoastalPlain.huc8 <- ((NorthAnna.huc8.m*(log((1)/(1-(as.numeric(pctchg)/100)))))/(NorthAnna.huc8.m*(log(NorthAnnaCoastalPlain.erom_q0001e_mean))+NorthAnna.huc8.b))*100

################################################################################################################
################################################################################################################
################################################################################################################
################################################################################################################


 custom_taxachg <- c(Dunlap,Craig,PlainsMill,NorthAnnaPiedmont,NorthAnnaFallZone,NorthAnnaCoastalPlain)

#taxa_chg <- c(Dunlap,Craig,North_Anna_Piedmont,North_Anna_Fall_Zone)

custom_taxachg <- -custom_taxachg #make negative because they're losses 
#bpj_q50_chg <- -taxa_chg #make negative because they're losses 

month_data_medians <- cbind(month_data_medians,custom_taxachg)
#month_data_medians <- cbind(month_data_medians,bpj_q50_chg)


Dunlap.df <- month_data_medians[1,]
Craig.df <- month_data_medians[2,]
Plains_Mill.df <- month_data_medians[3,]
North_Anna_Piedmont.df <- month_data_medians[4,]
North_Anna_Fall_Zone.df <- month_data_medians[5,]
North_Anna_Coastal_Plain.df <- month_data_medians[6,]


#----------------------------------------------------- 
# PLOT LABELS 
#----------------------------------------------------- 
Dunlap.lab <- paste("Dunlap (",round(Dunlap.erom_q0001e_mean, digits = 0)," MAF)",sep="")
PlainsMill.lab <- paste("PlainsMill (",round(PlainsMill.erom_q0001e_mean, digits = 0)," MAF)",sep="")
NorthAnnaPiedmont.lab <- paste("NorthAnnaPiedmont (",round(NorthAnnaPiedmont.erom_q0001e_mean, digits = 0)," MAF)",sep="")
NorthAnnaCoastalPlain.lab <- paste("NorthAnnaCoastalPlain (",round(NorthAnnaCoastalPlain.erom_q0001e_mean, digits = 0)," MAF)",sep="")
NorthAnnaFallZone.lab <- paste("NorthAnnaFallZone (",round(NorthAnnaFallZone.erom_q0001e_mean, digits = 0)," MAF)",sep="")
Craig.lab <- paste("Craig (",round(Craig.erom_q0001e_mean, digits = 0)," MAF)",sep="")

plot_labels <- data.frame(ifim_site_name=c(Dunlap.lab,
                                           PlainsMill.lab,
                                           NorthAnnaPiedmont.lab,
                                           NorthAnnaCoastalPlain.lab,
                                           NorthAnnaFallZone.lab,
                                           #NorthAnnaCoastalPlain.lab,
                                           Craig.lab),
                          pctchg=-5)
#----------------------------------------------------- 
#----------------------------------------------------- 
png(filename=paste(save_directory,"\\",plot_name,"_",pctchg,".png",sep=""),
    #width = 1500, 
    #height = 750)
    width = 1000, 
    height = 1000)




plot(month_data_medians$custom_taxachg, month_data_medians$pctchg,
     
    
     
     
     xlab="Percent Change Richness",
     ylab="Percent Change Habitat",cex.lab=1.5,
     cex.axis=2,
     #ylim=c(-80,80))
     #ylim=c(-20,20),
     #xlim=c(-20,20))
     ylim=c(-6,6),
     xlim=c(-6,6))

abline(a=0,b=0)
abline(v=0)

abline(lm(month_data_medians$pctchg ~ month_data_medians$custom_taxachg),col="black",lty=2)
r_adj <- summary(lm(month_data_medians$pctchg ~ month_data_medians$custom_taxachg))$r.squared
p_val <- summary(lm(month_data_medians$pctchg ~ month_data_medians$custom_taxachg))$coefficients[2,4]  


#points(month_data_medians$ifim_da_sqmi, month_data_medians$pctchg, col = "red",cex=5,pch="-") #pch=19 for circle point
points(Dunlap.df$custom_taxachg, Dunlap.df$pctchg, col = "blue",cex=3,pch=16) #pch=19 for circle point
points(Plains_Mill.df$custom_taxachg, Plains_Mill.df$pctchg, col = "red",cex=3,pch=16) #pch=19 for circle point
points(North_Anna_Piedmont.df$custom_taxachg, North_Anna_Piedmont.df$pctchg, col = "orange",cex=3,pch=16) #pch=19 for circle point
points(North_Anna_Coastal_Plain.df$custom_taxachg, North_Anna_Coastal_Plain.df$pctchg, col = "forestgreen",cex=3,pch=16) #pch=19 for circle point
points(North_Anna_Fall_Zone.df$custom_taxachg, North_Anna_Fall_Zone.df$pctchg, col = "purple",cex=3,pch=16) #pch=19 for circle point
points(Craig.df$custom_taxachg, Craig.df$pctchg, col = "green",cex=3,pch=16) #pch=19 for circle point



legend("topright",
       legend = plot_labels$ifim_site_name,
       pch=16,
       col=c("blue","red","orange","forestgreen","purple","green"),
       cex = 2)

#------------------------------------------
# Add r^2 and p-value to plot
rp = vector('expression',2)
rp[1] = substitute(expression(italic(R)^2 == MYVALUE), 
                   list(MYVALUE = format(r_adj,dig=2)))[2]
rp[2] = substitute(expression(italic(p) == MYOTHERVALUE), 
                   list(MYOTHERVALUE = format(p_val, digits = 2)))[2]
legend('topleft', legend = rp, bty = 'n', cex = 2)
#------------------------------------------
        
dev.off()


#------------------------------------------
ifim_site <- c("Dunlap","Plains Mill","North Anna Piedmont","North Anna Fall Zone","North Anna Coastal Plain","Craig")
export <- (rbind(Dunlap.df,Plains_Mill.df,North_Anna_Piedmont.df,North_Anna_Fall_Zone.df,North_Anna_Coastal_Plain.df,Craig.df))
colnames(export)[colnames(export)=="pctchg"] <- "hab_chg"
export <- cbind(export,custom_tag = c("bpj_q50",huc8_tag,"bpj_530_icthy","bpj_530_icthy","bpj_530_icthy","bpj_530_icthy"))
export <- cbind(export,custom_huc_unit = c("huc10","huc8","huc10","huc10","huc10","huc10"))
export <- cbind(export,custom_huc = c(Dunlap.huc10.code,PlainsMill.huc8.code,NorthAnna.huc10.code,NorthAnna.huc10.code,NorthAnna.huc10.code,Craig.huc10.code))
export <- cbind(export,huc8_taxachg = -c(Dunlap.huc8,PlainsMill.huc8,NorthAnnaPiedmont.huc8,NorthAnnaFallZone.huc8,NorthAnnaCoastalPlain.huc8,Craig.huc8))
export <- cbind(export,huc8_tag = huc8_tag)
export <- cbind(export,huc8 = c(Dunlap.huc8.code,PlainsMill.huc8.code,NorthAnna.huc8.code,NorthAnna.huc8.code,NorthAnna.huc8.code,Craig.huc8.code))

export <- data.frame(pctchg,month,ifim_site, export[-1])

export.df <- rbind(export.df,export)


} #end for loop
} #END PERCENT FLOW REDUCTION
####################################################################
# OUTPUT DATA AS CSV
####################################################################

# export.df <- data.frame(pctchg=as.Date(character()),
#                  xvar=character(), 
#                  ifim_site=character(), 
#                  hab_chg=character(),
#                  taxa_chg=character(),
#                  taxa_tag=character(),
#                  taxa_unit=character(),
#                  stringsAsFactors=FALSE) 
# 
# 
# 
#  ifim_site <- c("Dunlap","Plains Mill","North Anna Piedmont","North Anna Fall Zone","Craig")
#  export <- (rbind(Dunlap.df,Plains_Mill.df,North_Anna_Piedmont.df,North_Anna_Fall_Zone.df,Craig.df))
#  colnames(export)[colnames(export)=="pctchg"] <- "hab_chg"
#  #colnames(export)[colnames(export)=="taxa_chg"] <- "bpj_q50"
#  export <- cbind(export,taxa_tag = c("bpj_q50","bpj_rcc","bpj_530_icthy","bpj_530_icthy","bpj_530_icthy"))
#  export <- cbind(export,taxa_unit = c("huc10","huc8","huc10","huc10","huc10"))
#  export <- data.frame(pctchg,xvar,ifim_site, export[-1])

 write.csv(export.df, file = paste(save_directory,"\\","nt_hab_chg.csv",sep=""))
