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

selected.weeks.plot <- function(data, weeks, name, colors, fulltime) {

  working.days <- as.numeric(weeks) * 5

  this.plot <- ggplot(data, aes(x = date, y = hours)) +
    geom_hline(yintercept = fulltime/5, color = "blue")

  if (working.days == 10 || working.days == 20) {
    this.plot <- this.plot +
      geom_hline(yintercept = fulltime/10, color = "blue")
  }

  if (working.days == 15) {
    this.plot <- this.plot +
      geom_hline(yintercept = fulltime/15, color = "blue") +
      geom_hline(yintercept = 2*fulltime/15, color = "blue")
  }

  if (working.days == 20) {
    this.plot <- this.plot +
      geom_hline(yintercept = fulltime/20, color = "blue") +
      geom_hline(yintercept = 3*fulltime/20, color = "blue")
  }

  this.plot <- this.plot + geom_col(aes(fill = day), show.legend = FALSE) +
    geom_step(aes(y = sum / working.days), direction = "vh", color = "Blue", size = 2) +
    facet_wrap(~user,
               strip.position = "bottom",
               ncol = max(2, round(length(levels(factor(data$user))))/5)) +
    scale_fill_manual(values = colors) +
    scale_y_continuous(name = "Hours/day",
                       breaks = c(0,2,4,6,8,10),
                       sec.axis = sec_axis(~ . * working.days, name = "Total Hours")) +
    labs(title = name) +
    theme(
      axis.text.x = element_text(size = 6, angle = 45, hjust = 1),
      axis.title.y = element_text(color = "grey"),
      axis.title.y.right = element_text(color = "blue"),
      axis.text.y.left = element_text(color = "grey"),
      axis.text.y.right = element_text(color = "blue"))

  return(this.plot)
}


