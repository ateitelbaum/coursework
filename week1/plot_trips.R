########################################
# load libraries
########################################

# load some packages that we'll need
library(tidyverse)
library(scales)
library(lubridate)

# be picky about white backgrounds on our plots
theme_set(theme_bw())

# load RData file output by load_trips.R
load('trips.RData')


########################################
# plot trip data
########################################

# plot the distribution of trip times across all rides
#throwing away 1% of outliers
filter(trips, tripduration < quantile(tripduration, .99)) %>% ggplot(aes(x = tripduration/60)) +
  geom_histogram() +
  scale_x_log10(label = comma) +
  scale_y_continuous(label = comma) 

# plot the distribution of trip times by rider type
filter(trips, tripduration < quantile(tripduration, .99)) %>% 
  ggplot(aes(x=tripduration/60)) + 
  geom_histogram() +
  scale_x_log10(label = comma) +
  scale_y_continuous(label = comma) +
  facet_wrap(~ usertype, ncol = 1, scale = 'free_y') 

# plot the total number of trips over each day
mutate(trips, day = as.Date(starttime)) %>% 
  group_by(day) %>% 
  summarize(count = n()) %>% 
  ggplot(aes(x = day, y = count)) +
  geom_point()
  
# plot the total number of trips (on the y axis) by age (on the x axis) and gender (indicated with color)
mutate(trips, age = year(starttime) - birth_year) %>% group_by(age, gender) %>% 
  summarize(count = n()) %>% ungroup() %>% filter(count < quantile(count, .99)) %>%
  ggplot(aes(x = age, y = count, color = gender)) +
  geom_point(stat = 'identity') + 
  scale_y_continuous(label = comma) +
  xlim(c(16, 80))

# plot the ratio of male to female trips (on the y axis) by age (on the x axis)
# hint: use the spread() function to reshape things to make it easier to compute this 
mutate(trips, age = year(starttime) - birth_year) %>% group_by(age, gender) %>% summarize(count = n()) %>% 
  spread('gender', 'count') %>% mutate(ratio = Male/Female) %>%
  ggplot(aes(x = age, y = ratio)) +
  geom_bar(stat = 'identity') +
  scale_y_continuous(label = comma) +
  xlim(c(16, 80))
      
########################################
# plot weather data
########################################
# plot the minimum temperature (on the y axis) over each day (on the x axis)
ggplot(weather, aes(x = ymd, y = tmin)) +
  geom_point()+
  xlab("Day") +
  ylab("Minimum Temperature")

# plot the minimum temperature and maximum temperature (on the y axis, with different colors) over each day (on the x axis)
# hint: try using the gather() function for this to reshape things before plotting
gather(weather, "MaxMin", "Temperature", tmax, tmin) %>% 
  ggplot(aes(x = ymd, y = Temperature, color = MaxMin)) +
  geom_point() +
  xlab("Day") +
  ylab("Temperature")

########################################
# plot trip and weather data
########################################

# join trips and weather
trips_with_weather <- inner_join(trips, weather, by="ymd")

# plot the number of trips as a function of the minimum temperature, where each point represents a day
# you'll need to summarize the trips and join to the weather data to do this
group_by(trips_with_weather,ymd, tmin) %>% summarize(ridecount = n()) %>%
  ggplot(aes(x=tmin, y = ridecount)) +
  geom_point(position = 'jitter')

# repeat this, splitting results by whether there was substantial precipitation or not
# you'll need to decide what constitutes "substantial precipitation" and create a new T/F column to indicate this
mutate(trips_with_weather, substantial_prcp = ifelse(prcp > .0300, "T", "F")) %>% group_by(ymd, tmin, substantial_prcp) %>% summarize(ridecount = n()) %>%
  ggplot(aes(x=tmin, y = ridecount)) +
  geom_point(position = 'jitter') +
  facet_wrap(~ substantial_prcp)

# add a smoothed fit on top of the previous plot, using geom_smooth
mutate(trips_with_weather, substantial_prcp = ifelse(prcp > .0300, "T", "F")) %>% group_by(ymd, tmin, substantial_prcp) %>% summarize(ridecount = n()) %>%
  ggplot(aes(x=tmin, y = ridecount)) +
  geom_point(position = 'jitter') +
  facet_wrap(~ substantial_prcp)+
  geom_smooth()
  
# compute the average number of trips and standard deviation in number of trips by hour of the day
# hint: use the hour() function from the lubridate package
mutate(trips_with_weather, hour = hour(starttime)) %>% group_by(ymd, hour) %>% 
  count() %>% group_by(hour) %>% summarize(mean(n), sd(n))


# plot the above
mutate(trips_with_weather, hour = hour(starttime)) %>% group_by(ymd, hour) %>% 
  count() %>% group_by(hour) %>% summarize(avg = mean(n), sd = sd(n)) %>%
  ggplot(aes(x=hour, y = avg)) +
  geom_line() + 
  geom_ribbon(aes(ymin = avg-sd, ymax = avg+sd), alpha = .2)

# repeat this, but now split the results by day of the week (Monday, Tuesday, ...) or weekday vs. weekend days
# hint: use the wday() function from the lubridate package
mutate(trips_with_weather, hour = hour(starttime), dayOfWeek = wday(ymd, label = TRUE)) %>% group_by(ymd, dayOfWeek, hour) %>% 
  count() %>% group_by(dayOfWeek, hour) %>% summarize(avg = mean(n), sd = sd(n)) %>%
  gather("stat", "value", avg, sd) %>%
  ggplot(aes(x=hour, y = value, color = stat)) +
  geom_point() + 
  facet_wrap(~ dayOfWeek)
