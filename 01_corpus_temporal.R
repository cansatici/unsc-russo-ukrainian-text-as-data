# =============================================================
# 01 - Corpus loading, metadata parsing, temporal analysis
# UNSC Ukraine speeches
#
# Data: Schoenfeld, Eckhard, Patz & van Meegdenburg,
#       "The UN Security Council Debates", Harvard Dataverse
#       doi:10.7910/DVN/KGVSYH
#
# Place the downloaded corpus in data/raw/ before running.
# =============================================================

library(tidyverse)
library(quanteda)
library(quanteda.textstats)
library(readtext)
library(lubridate)

# ---- Relative paths only ----
raw_dir    <- "data/raw"
out_dir    <- "figures"
corpus_rds <- "data/ukraine_corpus.rds"

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
dir.create("data", showWarnings = FALSE)

# =============================================================
# 1. LOAD
# =============================================================
# CHECK FIRST: run list.files(raw_dir, recursive = TRUE) and
# compare against the file and column names used below. The
# Dataverse download may be structured differently.

if (file.exists(corpus_rds)) {
  message("Loading cached corpus")
  corp <- readRDS(corpus_rds)
} else {
  speeches <- readtext(file.path(raw_dir, "speeches", "*.txt"))

  meta    <- read_tsv(file.path(raw_dir, "meta.tsv"),    show_col_types = FALSE)
  speaker <- read_tsv(file.path(raw_dir, "speaker.tsv"), show_col_types = FALSE)

  corp <- corpus(speeches)

  key <- tibble(doc_id = docnames(corp)) %>%
    mutate(basename = str_remove(doc_id, "\\.txt$")) %>%
    left_join(meta,    by = "basename") %>%
    left_join(speaker, by = "basename")

  docvars(corp, "date")    <- as.Date(key$date)
  docvars(corp, "year")    <- as.numeric(key$year)
  docvars(corp, "month")   <- as.numeric(key$month)
  docvars(corp, "topic")   <- key$topic
  docvars(corp, "country") <- key$country_org
  docvars(corp, "speaker") <- key$speaker

  saveRDS(corp, corpus_rds)
}

message("Corpus: ", ndoc(corp), " speeches")

# =============================================================
# 2. FILTER TO UKRAINE
# =============================================================
corp_ukr_all <- corpus_subset(
  corp,
  str_detect(tolower(topic), "ukraine|ukrainian")
)
message("Ukraine-related speeches: ", ndoc(corp_ukr_all))

corp_ukr <- corpus_subset(corp_ukr_all, year >= 2014 & year <= 2023)
message("2014-2023 window: ", ndoc(corp_ukr))

# =============================================================
# 3. SPEECHES BY COUNTRY
# =============================================================
by_country <- docvars(corp_ukr) %>%
  filter(!is.na(country)) %>%
  count(country, name = "n_speeches") %>%
  arrange(desc(n_speeches))

write_csv(by_country, "data/speeches_by_country.csv")
print(head(by_country, 20))

p_country <- ggplot(head(by_country, 20),
                    aes(fct_reorder(country, n_speeches), n_speeches)) +
  geom_col(width = 0.8) +
  coord_flip() +
  labs(title    = "Top 20 speakers by number of Ukraine-related speeches",
       subtitle = "UNSC public meetings, 2014-2023",
       x = NULL, y = "Number of speeches") +
  theme_minimal(base_size = 12)

ggsave(file.path(out_dir, "top20_countries.png"), p_country,
       width = 8, height = 6, dpi = 300)

# =============================================================
# 4. MONTHLY SPEECH VOLUME
# =============================================================
monthly <- docvars(corp_ukr) %>%
  filter(!is.na(date)) %>%
  mutate(ym = floor_date(as.Date(date), "month")) %>%
  count(ym, name = "n_speeches")

write_csv(monthly, "data/monthly_volume.csv")

p_monthly <- ggplot(monthly, aes(ym, n_speeches)) +
  geom_line() +
  geom_vline(xintercept = as.Date("2014-03-18"), linetype = "dashed") +
  geom_vline(xintercept = as.Date("2022-02-24"), linetype = "dashed") +
  labs(title = "Monthly Ukraine-related UNSC speeches",
       subtitle = "Dashed lines: annexation of Crimea, full-scale invasion",
       x = NULL, y = "Number of speeches") +
  theme_minimal(base_size = 12)

ggsave(file.path(out_dir, "monthly_volume.png"), p_monthly,
       width = 10, height = 5, dpi = 300)

# =============================================================
# 5. KEYNESS - PRE/POST 2014
# =============================================================
dfm_periods <- corp_ukr_all %>%
  tokens(remove_punct = TRUE, remove_numbers = TRUE) %>%
  tokens_tolower() %>%
  tokens_remove(stopwords("en")) %>%
  dfm() %>%
  dfm_group(groups = ifelse(docvars(corp_ukr_all, "year") < 2014,
                            "Pre-2014", "Post-2014"))

if (nrow(dfm_periods) == 2) {
  keyness <- textstat_keyness(dfm_periods, target = "Post-2014")
  write_csv(as_tibble(keyness), "data/keyness_pre_post_2014.csv")
  print(head(keyness, 20))
} else {
  warning("Both periods not present - keyness skipped.")
}

message("01 complete.")
