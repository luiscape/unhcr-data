#### The first step is to organize UNHCR's historical data into the format we use in HDX

library(reshape2)
library(countrycode)

# First load the data-models we are going to use.
# dataset <- read.csv('data/cps/dataset.csv')
# indicator <- read.csv('data/cps/indicator.csv')
# value <- read.csv('data/cps/value.csv')

# Load UNHCR historical data (from 2000 to 2012)
unhcr_data <- read.csv('data/source/unhcr-historical-data-2000-2012.csv', skip = 4)
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
    iso3_list <- unique(df$country_residence_iso3)
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
    print(class(z))
    z$inID <- "CHD.O.PRO.0001.T6"  # not CHD final code.
    z$source <- "http://popstats.unhcr.org"
    z$dsID <- "unhcr-popstats"
    z$is_number <- isNumber(z)
    population_of_concern_origin <- z
    
    # Country of residence
    message('Generating: Number of People of Concern by Residence')
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
    z$inID <- "CHD.O.PRO.0002.T6"  # not CHD final code.
    z$source <- "http://popstats.unhcr.org"
    z$dsID <- "unhcr-popstats"
    z$is_number <- isNumber(z)
    population_of_concern_residence <- z
    
    ## Add other indicators here ##
    
    output <- rbind(population_of_concern_origin, 
                    population_of_concern_residence)
    return(output)
}

system.time(people_of_concern <- peopleOfConcern(df = unhcr_long))


# writing the output
write.csv(people_of_concern, file = 'data/value.csv', row.names = FALSE)



# 
# # Using the CPS model.
# disasters <- read.csv('data-summary/ReliefWeb-ALLCountries-disaster-2000-2014-long.csv')
# disasters$indID <- 'RW001'
# colnames(disasters)[1] <- 'value'
# colnames(disasters)[2] <- 'period'
# colnames(disasters)[3] <- 'region'
# disasters$dsID <- 'reliefweb'
# disasters$Country.Name <- NULL
# disasters$source <- NA
