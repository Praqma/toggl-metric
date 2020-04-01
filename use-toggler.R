library(devtools)
#
#
# Using a local build is possible, see devtools::install_local()
#
# Better to get the source from github, since CI builds all commits
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

# The directory for the generated images
img.dir <- "this-month"
if (!dir.exists(img.dir)) {
  dir.create(img.dir)
}

# A few helper methods
convert.duration.to.hours <- function(data) {
  converted.data <- data %>%
    dplyr::mutate(
      duration = dur/(60*60*1000),
      date = as.Date(start)
    )
  return(converted.data)
}

bin.data.by.day <- function(data) {
  binned.data <- data %>%
    dplyr::group_by(user, date) %>%
    dplyr::summarise(
      hours = sum(duration)
    ) %>%
    dplyr::mutate(
      day = strftime(date,"%A"),
      sum = cumsum(as.numeric(hours))
    )

  return(binned.data)
}

wday.colors <- c("Monday" = "grey",
                 "Tuesday" = "grey",
                 "Wednesday" = "grey",
                 "Thursday" = "grey",
                 "Friday" = "grey",
                 "Saturday" = "red",
                 "Sunday" = "red")

this.month.day.plot <- function(data, name, colors, days) {

  weekds.since.the.first <- 5 * (round(days/7) + 1)

  this.plot <- ggplot(data, aes(x = date, y = hours)) +
    geom_col(aes(fill = day), show.legend = FALSE) +
    geom_step(aes(y = sum/weekds.since.the.first), direction = "vh", color = "Blue", size = 1.5) +
    facet_wrap(~user,
               strip.position = "bottom",
               ncol = max(2, round(length(levels(factor(data$user))))/5)) +
    scale_fill_manual(values = colors) +
    scale_y_continuous(name = "Hours/day",
                       breaks = c(0,2,4,6,8,10),
                       sec.axis = sec_axis(~ . * weekds.since.the.first, name = "Hours this month")) +
    scale_x_date(name = NULL) +
    labs(title = name) +
    theme(
      axis.text.x = element_text(size = 6, angle = 45, hjust = 1),
      axis.title.y = element_text(color = "grey"),
      axis.title.y.right = element_text(color = "blue"),
      axis.text.y.left = element_text(color = "grey"),
      axis.text.y.right = element_text(color = "blue"),
      strip.text.x = element_text(margin = margin(2, 0, 2, 0), size = rel(0.6)),
      strip.switch.pad.wrap = unit(0.0, "cm")
    )

  return(this.plot)
}



# get the accessable groups in the workspace
groups <- as_tibble(get.toggl.groups(token, workspace))

number.of.groups <- length(groups$name)

if (!number.of.groups > 0) {
  stop("Did not find any groups for the workspace")
}

days.since.the.first <- as.numeric(strsplit(as.character(Sys.Date()), split = '-')[[1]][3]) - 1

print(paste("Found", number.of.groups, "groups for that workspace"))
for (i in 1:number.of.groups) {
  print(groups$name[i])
  group.name <- groups$name[i]
  group.id <- groups[groups$name == group.name, ]$id
  print(paste("Fetching detail data for", group.name, "with group Id:", group.id))

  detailed.data.this.month <- as_tibble(get.toggl.group.data(token, workspace, group.id, since = Sys.Date() - days.since.the.first, verbose = TRUE))
  print(paste("Response is a table with", length(detailed.data.this.month), "columns and", length(detailed.data.this.month$id), "entries"))

  detailed.data.this.month <- convert.duration.to.hours(detailed.data.this.month)

  day.data <- bin.data.by.day(detailed.data.this.month)

  this.month <- this.month.day.plot(day.data, group.name, wday.colors, days.since.the.first)
  plot(this.month)

  png(paste(img.dir, "/", group.name, ".png", sep = ""), width = 5000, height = 3000, res = 550, pointsize = 10)
  plot(this.month)
  dev.off()
}

