library(rvest)
library(stringr)   
library(lubridate)
library(purrr)
library(dplyr)
library(feather)

extract_result_match <- function(result_node) {
  date <- result_node %>% html_node('.mu-i-date') %>% html_text() %>% dmy()
  home_team <- result_node %>% html_node('.t.home') %>% html_node('.t-nText') %>% html_text()  
  away_team <- result_node %>% html_node('.t.away') %>% html_node('.t-nText') %>% html_text() 
  score_text <- result_node %>% html_node('.s-scoreText') %>% html_text() %>% str_split('-') %>% unlist() %>% as.numeric()
  home_goals <- score_text[1]
  away_goals <- score_text[2]
  
  return(list(date=date, home_team=home_team, away_team=away_team, 
              home_goals=home_goals, away_goals=away_goals))
}

get_results <- function(url){
  url %>% read_html() %>% html_nodes('.mu.result') %>% map(extract_result_match) %>% bind_rows()
}

urls <- c('https://www.fifa.com/worldcup/preliminaries/southamerica/all-matches.html', 
          'https://www.fifa.com/worldcup/preliminaries/europe/all-matches.html', 
          'https://www.fifa.com/worldcup/preliminaries/nccamerica/all-matches.html', 
          'https://www.fifa.com/worldcup/preliminaries/africa/all-matches.html',
          'https://www.fifa.com/worldcup/preliminaries/asia/all-matches.html',
          'https://www.fifa.com/worldcup/preliminaries/oceania/all-matches.html')

results <- urls %>% map(get_results) %>% bind_rows()
path <- 'preliminaries.feather'
write_feather(results, path)