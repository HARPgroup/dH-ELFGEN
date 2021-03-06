rm(list = ls())  #clear variables
options(timeout=240); # set timeout to twice default level to avoid abort due to high traffic

#----------------------------------------------
site <- "http://deq1.bse.vt.edu/d.dh"    #Specify the site of interest, either d.bet OR d.dh
#----------------------------------------------

#----FOR RUNNING LOCALLY:
#basepath='/var/www/R';
basepath='C:/Users/nrf46657/Desktop/VAHydro Development/GitHub/r-dh-ecohydro/';
source(paste(basepath,'config.local.private',sep='/'));

#Load Functions               
source(paste(fxn_locations,"elf_retrieve_data.R", sep = ""));  #loads function used to retrieve F:E data from VAHydro
source(paste(habitat_files,'hab_ts_functions.R',sep='/')) #loads habtat timeseries functions
source(paste(hydro_tools,"VAHydro-2.0/rest_functions.R", sep = "/"));       #loads file containing function that retrieves REST token
rest_uname = FALSE;
rest_pw = FALSE;
source(paste(hydro_tools,"auth.private", sep = "/"));#load rest username and password, contained in auth.private file
token <- rest_token(site, token, rest_uname, rest_pw);

#_________________________________________________________
# PROJECT               SITE HYDROIDS
#
# NF_Shenandoah         397290,397291,397292,397293,397294
# SF_Shenandoah         397299,397300,397301
# Upper_James           397302,397303,397304,397305
# New_River_Claytor     397284,397285
# Appomattox            397282,397283
# Potomac               397295,397296
# North_Anna            397286,397287,397288,397289
# Roanoke               397297,397298
#_________________________________________________________

#===============================================================
# BEGIN RETRIEVE IFIM DATA
#===============================================================
ifim_sites <- c(397290,397291,397292,397293,
                397294,397299,397300,397301,
                397302,397303,397304,397305,
                397282,397283,397295,397296,
                397286,397287,397288,397289,
                397297,397298,397284,397285)

#ifim_sites <- c(397290)
stat_method <- "median" #"mean" or " median"
pctchg <- "50"

#x <- 1
for (x in 1:length(ifim_sites)){
  ifim_featureid <- ifim_sites[x]
  
  ifim_dataframe <- vahydro_prop_matrix(ifim_featureid,'ifim_habitat_table')
  WUA.df <- ifim_dataframe
  targets <- colnames(WUA.df[-1])
  #targets <- colnames(WUA.df)
  
  ifim_site <- getFeature(list(hydroid = ifim_featureid), token, site, feature)
  ifim_site_name <- as.character(ifim_site$name)
  
  inputs = list(varkey = 'usgs_siteid',featureid = ifim_featureid,entity_type = 'dh_feature')
  gageprop <- getProperty(inputs,site,prop)
  gage <- as.character(gageprop$propcode)
  gage_factor <- as.numeric(as.character(gageprop$propvalue))
  
  ifim_da_sqmi <- getProperty(list(featureid = ifim_featureid,
                                   varkey = 'nhdp_drainage_sqmi',
                                   entity_type = 'dh_feature'), 
                              site, prop)
  ifim_da_sqmi <- round(as.numeric(as.character(ifim_da_sqmi$propvalue)),1)
  
  ifim_maf <- getProperty(list(featureid = ifim_featureid,
                               varkey = 'erom_q0001e_mean',
                               entity_type = 'dh_feature'), 
                          site, prop)
  ifim_maf <- round(as.numeric(as.character(ifim_maf$propvalue)),1)
  #===============================================================
  # END RETRIEVE IFIM DATA
  #===============================================================
  
  f_0 <- f_fxn(gage,0.0)
  flow.ts.range_0 <- flow.ts.range_fxn(f_0,"all")
  flow.ts.range_0$Flow <- ((flow.ts.range_0$Flow)*gage_factor)
  wua.at.q_0 <- wua.at.q_fxn(flow.ts.range_0)
  wua.at.q_0 <- data.frame(flow.ts.range_0,wua.at.q_0)
  
  f_10 <- f_fxn(gage,(as.numeric(pctchg)/100))
  flow.ts.range_10 <- flow.ts.range_fxn(f_10,"all")
  flow.ts.range_10$Flow <- ((flow.ts.range_10$Flow)*gage_factor)
  wua.at.q_10 <- wua.at.q_fxn(flow.ts.range_10)
  wua.at.q_10 <- data.frame(flow.ts.range_10,wua.at.q_10)
  
  #-------------------------------------------------------------------------------------------------
  
  wua_10pct_chg <- ((wua.at.q_0-wua.at.q_10)/wua.at.q_0)*100
  wua_10pct_chg<-wua_10pct_chg[,-1] #remove empty date col
  wua_10pct_chg<-wua_10pct_chg[,-1] #remove empty flow col
  wua_10pct_chg <- (wua_10pct_chg)*-1
  Date <- wua.at.q_0$Date
  Flow <- wua.at.q_0$Flow
  wua_10pct_chg <- data.frame(Date,Flow,wua_10pct_chg)
  #negative means habitat loss
  
  #-------------------------------------------------------------------------------------------------
  #Add column of month names
  wua_10pct_chg [grep('-01-', wua_10pct_chg$Date, perl= TRUE), "month" ] <- "Jan"
  wua_10pct_chg [grep('-02-', wua_10pct_chg$Date, perl= TRUE), "month" ] <- "Feb"
  wua_10pct_chg [grep('-03-', wua_10pct_chg$Date, perl= TRUE), "month" ] <- "Mar"
  wua_10pct_chg [grep('-04-', wua_10pct_chg$Date, perl= TRUE), "month" ] <- "Apr"
  wua_10pct_chg [grep('-05-', wua_10pct_chg$Date, perl= TRUE), "month" ] <- "May"
  wua_10pct_chg [grep('-06-', wua_10pct_chg$Date, perl= TRUE), "month" ] <- "Jun"
  wua_10pct_chg [grep('-07-', wua_10pct_chg$Date, perl= TRUE), "month" ] <- "Jul"
  wua_10pct_chg [grep('-08-', wua_10pct_chg$Date, perl= TRUE), "month" ] <- "Aug"
  wua_10pct_chg [grep('-09-', wua_10pct_chg$Date, perl= TRUE), "month" ] <- "Sep"
  wua_10pct_chg [grep('-10-', wua_10pct_chg$Date, perl= TRUE), "month" ] <- "Oct"
  wua_10pct_chg [grep('-11-', wua_10pct_chg$Date, perl= TRUE), "month" ] <- "Nov"
  wua_10pct_chg [grep('-12-', wua_10pct_chg$Date, perl= TRUE), "month" ] <- "Dec"
  #-------------------------------------------------------------------------------------------------
  start_date <- min(wua_10pct_chg$Date)
  end_date <- max(wua_10pct_chg$Date)
  
  Jan_data <- wua_10pct_chg[which(wua_10pct_chg$month == "Jan"),]
  Jan_data_percentile <- as.numeric(quantile(Jan_data$Flow, probs = c(0.1)))
  Jan_data <- Jan_data[which(Jan_data$Flow <= Jan_data_percentile),]
  #Jan_data <- Jan_data[,-2]
  
  Feb_data <- wua_10pct_chg[which(wua_10pct_chg$month == "Feb"),]
  Feb_data_percentile <- as.numeric(quantile(Feb_data$Flow, probs = c(0.1)))
  Feb_data <- Feb_data[which(Feb_data$Flow <= Feb_data_percentile),]
  #Feb_data <- Feb_data[,-2]
  
  Mar_data <- wua_10pct_chg[which(wua_10pct_chg$month == "Mar"),]
  Mar_data_percentile <- as.numeric(quantile(Mar_data$Flow, probs = c(0.1)))
  Mar_data <- Mar_data[which(Mar_data$Flow <= Mar_data_percentile),]
  #Mar_data <- Mar_data[,-2]
  
  Apr_data <- wua_10pct_chg[which(wua_10pct_chg$month == "Apr"),]
  Apr_data_percentile <- as.numeric(quantile(Apr_data$Flow, probs = c(0.1)))
  Apr_data <- Apr_data[which(Apr_data$Flow <= Apr_data_percentile),]
  #Apr_data <- Apr_data[,-2]
  
  May_data <- wua_10pct_chg[which(wua_10pct_chg$month == "May"),]
  May_data_percentile <- as.numeric(quantile(May_data$Flow, probs = c(0.1)))
  May_data <- May_data[which(May_data$Flow <= May_data_percentile),]
  #May_data <- May_data[,-2]
  
  Jun_data <- wua_10pct_chg[which(wua_10pct_chg$month == "Jun"),]
  Jun_data_percentile <- as.numeric(quantile(Jun_data$Flow, probs = c(0.1)))
  Jun_data <- Jun_data[which(Jun_data$Flow <= Jun_data_percentile),]
  #Jun_data <- Jun_data[,-2]
  
  Jul_data <- wua_10pct_chg[which(wua_10pct_chg$month == "Jul"),]
  Jul_data_percentile <- as.numeric(quantile(Jul_data$Flow, probs = c(0.1)))
  Jul_data <- Jul_data[which(Jul_data$Flow <= Jul_data_percentile),]
  #Jul_data <- Jul_data[,-2]
  
  Aug_data <- wua_10pct_chg[which(wua_10pct_chg$month == "Aug"),]
  Aug_data_percentile <- as.numeric(quantile(Aug_data$Flow, probs = c(0.1)))
  Aug_data <- Aug_data[which(Aug_data$Flow <= Aug_data_percentile),]
  #Aug_data <- Aug_data[,-2]
  
  Sep_data <- wua_10pct_chg[which(wua_10pct_chg$month == "Sep"),]
  Sep_data_percentile <- as.numeric(quantile(Sep_data$Flow, probs = c(0.1)))
  Sep_data <- Sep_data[which(Sep_data$Flow <= Sep_data_percentile),]
  #Sep_data <- Sep_data[,-2]
  
  Oct_data <- wua_10pct_chg[which(wua_10pct_chg$month == "Oct"),]
  Oct_data_percentile <- as.numeric(quantile(Oct_data$Flow, probs = c(0.1)))
  Oct_data <- Oct_data[which(Oct_data$Flow <= Oct_data_percentile),]
  #oct_data <- Oct_data[,-2]
  
  Nov_data <- wua_10pct_chg[which(wua_10pct_chg$month == "Nov"),]
  Nov_data_percentile <- as.numeric(quantile(Nov_data$Flow, probs = c(0.1)))
  Nov_data <- Nov_data[which(Nov_data$Flow <= Nov_data_percentile),]
  #Nov_data <- Nov_data[,-2]
  
  Dec_data <- wua_10pct_chg[which(wua_10pct_chg$month == "Dec"),]
  Dec_data_percentile <- as.numeric(quantile(Dec_data$Flow, probs = c(0.1)))
  Dec_data <- Dec_data[which(Dec_data$Flow <= Dec_data_percentile),]
  #Dec_data <- Dec_data[,-2]
  
  MAF_data <- wua_10pct_chg
  MAF_data_percentile <- as.numeric(quantile(MAF_data$Flow, probs = c(0.1)))
  MAF_data <- MAF_data[which(MAF_data$Flow <= MAF_data_percentile),]
  
  #wua_10pct_chg <- wua_10pct_chg [,-2]  
  
  dfList <- list(MAF = MAF_data, #wua_10pct_chg
                 Jan = Jan_data,
                 Feb = Feb_data,
                 Mar = Mar_data,
                 Apr = Apr_data,
                 May = May_data,
                 Jun = Jun_data,
                 Jul = Jul_data,
                 Aug = Aug_data,
                 Sep = Sep_data,
                 Oct = Oct_data,
                 Nov = Nov_data,
                 Dec = Dec_data)
  
  #colnames(wua_10pct_chg)
  #dfList$Nov
  
  box_table <- data.frame(metric = c(''),
                          flow = c(''),
                          pctchg = c(''),
                          stringsAsFactors=FALSE)
  
  #L <- 1
  for (L in 1:length(dfList)) {
    hab.df <- dfList[L]
    hab.df <- data.frame(hab.df)
    #names(hab.df) <- colnames(wua_10pct_chg)
    names(hab.df) <- colnames(wua_10pct_chg)
    
    #-------------------------------------------------------------------------------------------------
    #Build dataframe of means of each metric percent change
    
    col_all <- data.frame(col_all = c(''),
                          stringsAsFactors=FALSE)
    
    #col_num <- 1
    for (col_num in 2:length(colnames(hab.df))-1){
      col_data <- hab.df[,col_num]
      col_data <- col_data[!is.na(col_data)] #remove NA values prior to calculating mean
      col_data <- col_data[!is.infinite(col_data)]   #remove Inf values prior to calculating mean
      
      if (stat_method == "median"){
        col_stat <- median(col_data)
      } else {
        col_stat <- mean(col_data)
      }
      
      col_name <- colnames(hab.df[col_num])
      
      col_i <- data.frame(col_stat)
      names(col_i)[1]<-paste(col_name)
      
      col_all <-data.frame(col_all,col_i)
    }
    col_all <-col_all[,-1] #remove empty col
    col_all <- col_all[,!(names(col_all) %in% "Flow")] # remove Flow column
    col_all <- col_all[,!(names(col_all) %in% "Date")] # remove Date column
    
    
    #col_all <- col_all[,!(names(col_all) %in% "month")] #remove month col
    
    #col_all <- col_all[,!(names(col_all) %in% "Flow")] # remove Flow column
    #col_all <-col_all[,-1]#remove Flow col
    #col_all <-col_all[,-1] #remove date col
    #col_all = col_all[,!(names(col_all) %in% "month")] #remove month col
    #col_all <- col_all[,!(names(col_all) %in% "Date")] #remove month col
    #-------------------------------------------------------------------------------------------------
    box_table_i <- data.frame(metric = targets,
                              flow = names(dfList[L]),
                              pctchg = as.numeric(col_all[1,]),
                              stringsAsFactors=FALSE)
    
    box_table <- rbind(box_table, box_table_i)
  } #close df loop
  
  #-------------------------------------------------------------------------------------------------
  
  if (length(which(box_table$metric=="boat")) != 0 ){
    print("Removing boat")
    box_table <- box_table[-which(box_table$metric=="boat"),]
  } 
  
  if (length(which(box_table$metric=="canoe")) != 0 ){
    print("Removing canoe")
    box_table <- box_table[-which(box_table$metric=="canoe"),]
  }
  
  if (length(which(box_table$metric=="canoe_nov")) != 0 ){
    print("Removing canoe_nov")
    box_table <- box_table[-which(box_table$metric=="canoe_nov"),]
  }
  
  if (length(which(box_table$metric=="canoe_mid")) != 0 ){
    print("Removing canoe_mid")
    box_table <- box_table[-which(box_table$metric=="canoe_mid"),]
  }
  
  #-------------------------------------------------------------------------------------------------
  
  
  box_table <- box_table [-1,] #remove empty first row
  
  #convert table values to numeric before plotting 
  box_table[,3] <- as.numeric(as.character(box_table[,3]))
  
  ggplot(box_table, aes(flow,pctchg))+
    geom_boxplot(fill='#A4A4A4', color="darkred")+
    geom_text(aes(label=metric),hjust=0, vjust=0)+
    geom_hline(yintercept=0,col='#A4A4A4')+
    labs(title = paste("Percent Habitat Change with ",pctchg,"% Flow Reduction (",stat_method," monthly) - TENTH PERCENTILE FLOW AND BELOW",sep=""),
         subtitle = paste(ifim_site_name,":\nDrainage Area: ",ifim_da_sqmi," sqmi\nUSGS: ",gage," (",start_date," to ",end_date,")",sep=""))+
    
    xlab("Flow (cfs)")+ 
    ylab("Percent Habitat Change")+
    scale_x_discrete(limit = c("MAF",month.abb))
  #scale_y_continuous(limits = c(-10, 100))
  
  #filename <- paste(ifim_site_name,"10pct",stat_method,"boxplot.png", sep="_")
  #ggsave(file=filename, path = save_directory, width=14, height=8)
  
  
  table_export <- data.frame(ifim_site_name,ifim_da_sqmi,box_table)
  
  output_dir <- paste(save_directory,"\\WUA-CSV",sep="")
  dir.create(output_dir, showWarnings = FALSE) #creates output directory if doesn't exist 
  output_dir <- paste(save_directory,"\\WUA-CSV\\",stat_method,sep="")
  dir.create(output_dir, showWarnings = FALSE) #creates output sub-directory if doesn't exist 
  
  write.csv(table_export, file = paste(output_dir,"\\",ifim_site_name,"_",pctchg,"pct_",stat_method,"_tenth_percentile_flow_boxplot.csv",sep=""))
  
  
  filename <- paste(ifim_site_name,pctchg,"pct",stat_method,"tenth_percentile_flow_boxplot.png", sep="_")
  ggsave(file=filename, path = output_dir, width=14, height=8)
}

#-------------------------------------------------------------------------------------------------
