library(devtools)
#
#
# Using a local build is possible, see devtools::install_local()
#
# Better to get the source from github, since CI builds all commits
#
# default value for ref in master, but can be any branch or tag
devtools::install_github('drBosse/toggleR', ref = 'master')
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

source('toggl-helpers.R')

# The directory for the generated images
img.dir <- "this-month"
if (!dir.exists(img.dir)) {
  dir.create(img.dir)
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

  if (length(detailed.data.this.month) > 0) {
    detailed.data.this.month <- convert.duration.to.hours(detailed.data.this.month)

    day.data <- bin.data.by.day(detailed.data.this.month)

    this.month <- this.month.day.plot(day.data, group.name, wday.colors, days.since.the.first)
  } else {
    this.month <- empty.data.plot(
        paste("No time reported\nfor the ",
        group.name,
        " office\nthis month", sep = ""))
  }
  plot(this.month)

  png(paste(img.dir, "/", group.name, ".png", sep = ""), width = 5000, height = 3000, res = 550, pointsize = 10)
  plot(this.month)
  dev.off()
}

