library(devtools)
#
#1
# Using a local build is possible, see devtools::install_local()
#
# Better way is to get the source from github, since Jenkins will
# build and test every commit
#
# default value for ref in master, but can be any branch or tag
devtools::install_github('Praqma/toggleR', ref = 'master')
library(toggleR)
# Load tidyverse to get more methods to handle the data
library(tidyverse)

# Check if the needed environment variables are set
# .Renviron for Rstudio
# .bashrc for R CMD
workspace <- Sys.getenv("TOGGL_WORKSPACE")
if (is.element("", workspace)) {
  stop("TOGGL_WORKSPACE is not a correct environment variable")
}
token <- Sys.getenv("TOGGL_TOKEN")
if (is.element("", token)) {
  stop("TOGGL_TOKEN needs to set as an environment variable")
}

# get the accessable groups in the workspace
groups <- as_tibble(get.toggl.groups(token, workspace))

groups.names <- length(groups$name)

if (!groups.names > 0) {
  stop("Did not find any groups for the workspace")
}

print(paste("Found", groups.names, "groups for that workspace"))
for(i in 1:groups.names) {
  print(groups$name[i])
# }
#group <- as.integer(runif(1, min = 1, max = groups.names))
#group.name <- groups$name[group]
group.name <- groups$name[i]
group.id <- groups[groups$name == group.name, ]$id
print(paste("Fetching detail data for", group.name, "with group Id:", group.id))

days.since.the.first <- as.numeric(strsplit(as.character(Sys.Date()), split = '-')[[1]][3]) - 1
weekds.since.the.first <- 5 * (round(days.since.the.first/7) + 1)

group.detail.1w <- as_tibble(get.toggl.group.data(token, workspace, group.id, since = Sys.Date() - days.since.the.first, verbose = TRUE))
print(paste("Response is a table with", length(group.detail.1w), "columns and", length(group.detail.1w$id), "entries"))

group.detail.1w <- group.detail.1w %>%
  dplyr::mutate(
    duration = dur/(60*60*1000),
    date = as.Date(start)
  )

day.data <- group.detail.1w %>%
  dplyr::group_by(user, date) %>%
  dplyr::summarise(
    hours = sum(duration)
  ) %>%
  dplyr::mutate(
    day = strftime(date,"%A"),
    sum = cumsum(as.numeric(hours))
  )

wday.colors <- c("Monday" = "grey",
                 "Tuesday" = "grey",
                 "Wednesday" = "grey",
                 "Thursday" = "grey",
                 "Friday" = "grey",
                 "Saturday" = "red",
                 "Sunday" = "red")

seven.days <- ggplot(day.data, aes(x = date, y = hours)) +
  geom_col(aes(fill = day), show.legend = FALSE) +
  geom_step(aes(y = sum/weekds.since.the.first), direction = "vh", color = "Blue", size = 2) +
  facet_wrap(~user, ncol = max(2, round(length(levels(factor(day.data$user))))/5)) +
  scale_fill_manual(values = wday.colors) +
  scale_y_continuous(name = "Hours/day",
                     breaks = c(0,2,4,6,8,10),
                     sec.axis = sec_axis(~ . * weekds.since.the.first, name = "Hours this month")) +
  labs(title = group.name) +
  theme(
    axis.text.x = element_text(size = 6, angle = 45, hjust = 1),
    axis.title.y = element_text(color = "grey"),
    axis.title.y.right = element_text(color = "blue"),
    axis.text.y.left = element_text(color = "grey"),
    axis.text.y.right = element_text(color = "blue"))

plot(seven.days)

png(paste("img/", group.name, ".png", sep = ""), width = 5000, height = 3000, res = 550, pointsize = 10)
plot(seven.days)
dev.off()
}
