#' EuroMOMO number of deaths graph.
#'
#' @param dt Data.
#' @param c Country.
#' @param a ISOweek (YYYY-WMM) of data reporting
#' @param g group e.g. age group
#' @import data.table
#' @import ggplot2
#' @return graph
#' @export
MRGraph <- function(dt, c, r, g) {
  library(data.table)
  library(ggplot2)
  
  # dt <- data
  # c <- 'England'
  # r <- '2020-W13'
  # g <- '65 years or older'
  
  dt <-  setDT(dt)[(country == c) & (reporting == r) & (group == g),
                   .(nb = nb/(N/100000),
                     nbc = nbc/(N/100000),
                     pnb = pnb/(N/100000),
                     sdm2 = (max(0,pnb^(2/3)-2*(nbc^(2/3)-pnb^(2/3))/zscore)^(3/2))/(N/100000),
                     sd2 = ((pnb^(2/3)+2*(nbc^(2/3)-pnb^(2/3))/zscore)^(3/2))/(N/100000),
                     sd4 = ((pnb^(2/3)+4*(nbc^(2/3)-pnb^(2/3))/zscore)^(3/2))/(N/100000)
                   ), keyby = ISOweek]

  dt$wk = as.numeric(as.factor(dt$ISOweek))
  graph <- ggplot(dt, aes(x = wk)) +
    geom_line(aes(y = nbc, colour="darkgreen"), linetype="solid", size = 1) +
    geom_line(aes(y = pnb, colour="red"), linetype="solid", size = 1) +
    geom_line(aes(y = sdm2, colour="black"), linetype="dashed", size = 1) +
    geom_line(aes(y = sd2, colour="black"), linetype="dashed", size = 1) +
    geom_line(aes(y = sd4, colour="blue"), linetype="dashed", size = 1) +
    ggtitle(paste0(c, ", ", g)) + theme(plot.title = element_text(hjust = 0.5)) +
    scale_x_continuous(name = "ISOWeek",
                       labels = dt[seq(min(dt$wk), max(dt$wk), by = 6),]$ISOweek,
                       breaks = seq(min(dt$wk), max(dt$wk), by = 6)) +
    scale_y_continuous(name = "deaths / 100,000 persons") +
    theme(legend.position = "bottom", axis.text.x = element_text(angle = 60, hjust = 1, size = 7)) +
    scale_color_identity(name = "",
                         breaks = c("darkgreen", "red", 'black', 'blue'),
                         labels = c("Observed", "Baseline", "2 z-scores", "4 z-scores"),
                         guide = "legend") +
    labs(caption = paste('EuroMOMO:', r))
  
  return(graph)
}
