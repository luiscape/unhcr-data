#### The first step is to organize UNHCR's historical data into the format we use in HDX

library(reshape2)
library(countrycode)

# First load the data-models we are going to use.
# dataset <- read.csv('data/cps/dataset.csv')
# indicator <- read.csv('data/cps/indicator.csv')
# value <- read.csv('data/cps/value.csv')

# Load UNHCR historical data (from 2000 to 2012)
unhcr_data <- read.csv('data/source/unhcr-historical-data-2000-2013.csv', skip = 4)
unhcr_data$Country...territory.of.residence.iso3 <-
    countrycode(unhcr_data$Country...territory.of.residence, 'country.name', 'iso3c')

unhcr_data$Origin...Returned.from.iso3 <-
    countrycode(unhcr_data$Origin...Returned.from, 'country.name', 'iso3c')

## Yugoslavia not present so creating it manually using the code 'YUG'
for (i in 1:nrow(unhcr_data)) {
    if (unhcr_data$Country...territory.of.residence[i] == 'Federal Republic of Yugoslavia') { 
        unhcr_data$Country...territory.of.residence.iso3[i] <- 'YUG'
    }
    if (unhcr_data$Origin...Returned.from[i] == 'Federal Republic of Yugoslavia') { 
        unhcr_data$Origin...Returned.from.iso3[i] <- 'YUG'
    }
}


# from wide to long using `reshape2`
unhcr_long <- melt(unhcr_data, 
                   id.vars = c("Country...territory.of.residence", "Origin...Returned.from", "Population.type", "Country...territory.of.residence.iso3", "Origin...Returned.from.iso3"))


# standardizing values
# here i am dropping the *. take a look at UNHCR's website to make sure
# that this information is drapable. 
unhcr_long$value <- as.numeric(unhcr_long$value)

# cleaning names
names(unhcr_long) <- c('country_residence', 
                       'country_origin', 
                       'population_type', 
                       'country_residence_iso3',
                       'country_origin_iso3',
                       'period', 
                       'value')

# cleaning years
unhcr_long$period <- sub("x", "", unhcr_long$period, ignore.case = TRUE)

# function for the number of people of concern per country of origin
peopleOfConcern <- function (df = NULL, focus = NULL) {
    source('code/cpser/is_number.R')
    min_year <- as.numeric(summary(as.numeric(df$period))[1])
    max_year <- as.numeric(summary(as.numeric(df$period))[6])
    
    # Country of origin
    message('Generating: Number of People of Concern by Origin.')
    iso3_list <- unique(df$country_origin_iso3)
    pb <- txtProgressBar(min = 0, max = length(iso3_list), style = 3)
    for (i in 1:length(iso3_list)) { 
        setTxtProgressBar(pb, i) 
        
        for (j in min_year:max_year) { 
            period <- j
            year_sub <- subset(df, (country_origin_iso3 == iso3_list[i] 
                                    & period == j))
            value <- sum(as.numeric(year_sub$value), na.rm = TRUE)
            a <- data.frame(period, value)
            if (j == min_year) { b <- a }
            else { b <- rbind(b, a) }
        }
        b$region <- iso3_list[i]
        if (i == 1) { z <- b }
        else { z <- rbind(z, b) }
    }
    z$indID <- "CHD.B.PRO.0001.T6"  # not CHD final code.
    z$source <- "http://popstats.unhcr.org"
    z$dsID <- "unhcr-popstats"
    z$is_number <- isNumber(z)
    population_of_concern_origin <- z
    
    # Country of residence
    message('Generating: Number of People of Concern by Residence')
    iso3_list <- unique(df$country_residence_iso3)
    population_of_concern_residence <- tapply(df$value, df$period, sum, na.rm = TRUE)
    pb <- txtProgressBar(min = 0, max = length(iso3_list), style = 3)
    for (i in 1:length(iso3_list)) { 
        setTxtProgressBar(pb, i) 
        
        for (j in min_year:max_year) { 
            period <- j
            year_sub <- subset(df, (country_residence_iso3 == iso3_list[i] 
                                    & period == j))
            value <- sum(as.numeric(year_sub$value), na.rm = TRUE)
            a <- data.frame(period, value)
            if (j == min_year) { b <- a }
            else { b <- rbind(b, a) }
        }
        b$region <- iso3_list[i]
        if (i == 1) { z <- b }
        else { z <- rbind(z, b) }
    }
    z$indID <- "CHD.B.PRO.0002.T6"  # not CHD final code.
    z$source <- "http://popstats.unhcr.org"
    z$dsID <- "unhcr-popstats"
    z$is_number <- isNumber(z)
    population_of_concern_residence <- z
    
    
    ##########################################
    ##########################################
    ## Collecting all the native indicators ##
    ##########################################
    ##########################################
    
    
    # Country of Origin #
    message('Collecting native indicators by origin.')
    indicator_list <- read.csv('data/cps/indicator.csv')
    type_list <- unique(df$population_type)
    pb <- txtProgressBar(min = 0, max = length(type_list), style = 3)
    for (i in 1:length(type_list)) {
        setTxtProgressBar(pb, i)
        tdata <- df[df$population_type == type_list[i], ]
        for (j in min_year:max_year) {
            ydata <- tapply((tdata[tdata$period == j, ])$value,
                            tdata[tdata$period == j, ]$country_origin_iso3, 
                            sum, na.rm = TRUE)
            if (j == min_year) zdata <- ydata
            else zdata <- rbind(zdata, ydata)
        }
        zdata <- data.frame(zdata)
        zdata$year <- min_year:max_year
        idata <- melt(zdata, id.vars = 'year')
        idata$indID <- 
            indicator_list[indicator_list$name == paste(type_list[i], 'by Country of Origin'), 2]
        if (i == 1) country_of_origin <- idata
        else country_of_origin <- rbind(country_of_origin, idata)
    }
    
    # Country of Residence #
    message('Collecting native indicators by residence.')
    pb <- txtProgressBar(min = 0, max = length(type_list), style = 3)
    for (i in 1:length(type_list)) {
        setTxtProgressBar(pb, i)
        tdata <- df[df$population_type == type_list[i], ]
        for (j in min_year:max_year) {
            ydata <- tapply((tdata[tdata$period == j, ])$value,
                            tdata[tdata$period == j, ]$country_residence_iso3, 
                            sum, na.rm = TRUE)
            if (j == min_year) zdata <- ydata
            else zdata <- rbind(zdata, ydata)
        }
        zdata <- data.frame(zdata)
        zdata$year <- min_year:max_year
        idata <- melt(zdata, id.vars = 'year')
        idata$indID <- 
            indicator_list[indicator_list$name == paste(type_list[i], 'by Country of Origin'), 2]
        if (i == 1) country_of_residence <- idata
        else country_of_residence <- rbind(country_of_residence, idata)
    }
    
    message('Aggregating all data.')
    all_idata <- rbind(country_of_residence, country_of_origin)
    
    all_idata$dsID <- "unhcr-popstats"
    all_idata$source <- "http://popstats.unhcr.org"
    all_idata$is_number <- 1
    names(all_idata) <- c('period',
                          'region',
                          'value',
                          'indID',
                          'dsID',
                          'source',
                          'is_number')
#     all_idata <- isNumber(all_idata)  # taking too long
    pop_concern_or <<- population_of_concern_origin
    pop_concern_res <<- population_of_concern_residence
    all_native <<- all_idata
    value <- rbind(population_of_concern_origin, 
                    population_of_concern_residence,
                   all_idata, row.names = NULL)
    
    message('Done.')
    return(value)
}

system.time(value <- peopleOfConcern(df = unhcr_long))


# writing the output
write.csv(value, file = 'data/cps/value.csv', row.names = FALSE)
