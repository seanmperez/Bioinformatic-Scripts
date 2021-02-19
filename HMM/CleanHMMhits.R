# A Script to Convert a mutiple HMM hits table to 
# This will only work if the sequence database used was a Trinity Denovo Transcriptome

# This script will:
# 1. Filter for only e-values < 1e-10
# 2. Spread domains for each gene with e-value
# 3. Filter for length > 1000

suppressPackageStartupMessages(library("tidyverse"))

args = commandArgs(trailingOnly = TRUE)

if (length(args) <2) {
  stop("You must have both an input and output file!", call. = FALSE)
} else if (length(args == 2)) {
  inputfile = args[1]
  outputfile = args[2]
}


clean_hmm <- read.table(inputfile) %>%
  as_tibble() %>%
  select(Transcript = V1,
         Domain = V3,
         eValue = V5,
         Completeness = V20,
         Length = V21) %>%
  mutate_if(is.factor, as.character) %>%
  mutate(Length = as.numeric(str_remove(Length, "len:"))) %>%
  mutate(Completeness = str_remove(Completeness, "type:")) %>%
  filter(eValue <= 1e-10 ) 

spread_hmm <- clean_hmm %>%
  select(Transcript, Domain, eValue) %>%
  spread(Domain, eValue)

join_hmm <- left_join(spread_hmm, distinct(select(clean_hmm, -Domain, -eValue))) %>%
  filter(Length >= 1000)

write.table(x = join_hmm, file = outputfile)
