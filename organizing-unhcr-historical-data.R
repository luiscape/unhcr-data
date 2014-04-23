#### The first step is to organize UNHCR's historical data into the format we use in HDX

library(countrycode)
library(ggplot2)
library(reshape2)
library(lubridate)

# First load the data-models we are going to use. 
dataset <- read.csv('cps-export/dataset.csv')
indicator <- read.csv('cps-export/indicator.csv')
value <- read.csv('cps-export/value.csv')

# Then load UNHCR historical data (from 2000 to 2012)
unhcr.data <- read.csv('data/unhcr-historical-data-2000-2012.csv', skip = 4)
unhcr.data$Country...territory.of.residence.iso3 <- 
    hdxdictionary(unhcr.data$Country...territory.of.residence.iso3, 'country.name', 'iso3c')
unhcr.data$Origin...Returned.from.iso3 <- 
    hdxdictionary(unhcr.data$Origin...Returned.from.iso3, 'iso2c', 'iso3c')

# from wide to long 
unhcr.long <- melt(unhcr.data, id.vars = c("Origin...Returned.from.iso3", 
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




pop.summary <- data.frame(table(unhcr.data$Population.type))
ggplot(pop.summary, aes(Var1, Freq)) + 
    geom_bar(aes(reorder(pop.summary$Var1, - pop.summary$Freq), Freq), 
             stat = 'identity', fill = '#0988bb') +
    geom_text(aes(label = Freq), position = position_dodge(width = 0.9), vjust = -0.25 ) +
    labs(title = "Number of classified populations.", 
         x = "Class", 
         y = "Count")


unhcr.people.of.concern <- function (df = NULL, 
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
        it.years$inID <- "Number of People of Concern by Origin"
        if (i == 1) { final <- it.years }
        else { final <- rbind(final, it.years) }
    
    }
    
    final
}

system.time(z <- unhcr.people.of.concern(df = unhcr.long))





# Using the model.
disasters <- read.csv('data-summary/ReliefWeb-ALLCountries-disaster-2000-2014-long.csv')
disasters$indID <- 'RW001'
colnames(disasters)[1] <- 'value'
colnames(disasters)[2] <- 'period'
colnames(disasters)[3] <- 'region'
disasters$dsID <- 'reliefweb'
disasters$Country.Name <- NULL
disasters$source <- NA
