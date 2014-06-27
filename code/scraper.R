#### The first step is to organize UNHCR's historical data into the format we use in HDX

library(reshape2)
library(hdxdictionary)

# First load the data-models we are going to use.
# dataset <- read.csv('data/cps/dataset.csv')
# indicator <- read.csv('data/cps/indicator.csv')
# value <- read.csv('data/cps/value.csv')

# Load UNHCR historical data (from 2000 to 2012)
unhcr_data <- read.csv('data/source/unhcr-historical-data-2000-2012.csv', skip = 4)
unhcr_data$Country...territory.of.residence.iso3 <-
    hdxdictionary(unhcr_data$Country...territory.of.residence.iso3, 'country.name', 'iso2c')
unhcr_data$Origin...Returned.from.iso3 <-
    hdxdictionary(unhcr_data$Origin...Returned.from.iso3, 'iso2c', 'iso3c')

# from wide to long using `reshape2`
unhcr.long <- melt(unhcr_data, id.vars = c("Origin...Returned.from.iso3", 
                                           "Country...territory.of.residence.iso3",
                                           "Origin...Returned.from", 
                                           "Population.type", 
                                           "Country...territory.of.residence"))


# standardizing values
unhcr.long$value <- as.numeric(unhcr.long$value)


# cleaning names
names(unhcr.long) <- c('Origin_ReturnedFrom_iso3', 
                       'Country_TerritoryofResidence_iso3', 
                       'Origin_ReturnedFrom', 
                       'PopulationType',
                       'Country_TerritoryofResidence', 
                       'period', 
                       'value')
# cleaning years
unhcr.long$period <- sub("x", "", unhcr.long$period, ignore.case = TRUE)




peopleOfConcern <- function (df = NULL, 
                                     focus = TRUE) { 
    
    # create progress bar
    pb <- txtProgressBar(min = 0, max = length(focus.countries.iso3), style = 3)
    
    # for using only the focus countries
    if (focus == TRUE) { 
        focus.countries <- subset(hdx.dictionary, hdx.dictionary[7] == TRUE) 
        focus.countries.iso3 <- as.list(focus.countries$iso2c)  # apparently iso3c not working
    } 
    
    # creating the people of concern indicator per country
    for (i in 1:length(focus.countries.iso3)) { 
        
        setTxtProgressBar(pb, i)  # Updates progress bar.
        
        iso3 <- hdxdictionary(focus.countries.iso3[i], 'iso2c', 'iso3c')
        
        for (j in 2000:2012) { 
            period <- j
            origin.year <- subset(df, df$Origin_ReturnedFrom_iso3 == iso3 & df[6] == j)
            
            value <- sum(origin.year$value, na.rm = TRUE)
            it <- data.frame(period, value)
            if (j == 2000) { it.years <- it }
            else { it.years <- rbind(it.years, it) }
        
        }
        
        it.years$region <- iso3
        it.years$inID <- "CHD.O.PRO.0001.T6"  # not CHD final code.
        if (i == 1) { final <- it.years }
        else { final <- rbind(final, it.years) }
    
    }
    
    final
}

people_of_concern <- peopleOfConcern(df = unhcr.long)

write.csv(z, file = 'data/source/Number of People of Concern by Origin.csv', row.names = FALSE)



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
