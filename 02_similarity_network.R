# =============================================================
# 02 - Country similarity network
#
# Groups Ukraine-related speeches by country, measures
# rhetorical similarity between countries, and detects
# communities in the resulting network.
#
# Requires data/ukraine_corpus.rds produced by 01.
# =============================================================

library(tidyverse)
library(quanteda)
library(quanteda.textstats)
library(igraph)
library(ggraph)

out_dir <- "figures"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

corp <- readRDS("data/ukraine_corpus.rds")

corp_ukr <- corpus_subset(
  corp,
  str_detect(tolower(topic), "ukraine|ukrainian") &
    year >= 2014 & year <= 2023 &
    !is.na(country)
)

message("Speeches in network input: ", ndoc(corp_ukr))

# Drop countries with very few speeches - their profiles are noisy
min_speeches <- 5
counts <- table(docvars(corp_ukr, "country"))
keep   <- names(counts)[counts >= min_speeches]
corp_ukr <- corpus_subset(corp_ukr, country %in% keep)

message("Countries retained (>= ", min_speeches, " speeches): ", length(keep))

# =============================================================
# 1. SIMILARITY MATRIX
# =============================================================
corp_by_country <- corpus_group(corp_ukr, groups = country)
message("Country groups: ", ndoc(corp_by_country))

toks <- corp_by_country %>%
  tokens(remove_punct = TRUE, remove_numbers = TRUE) %>%
  tokens_tolower() %>%
  tokens_remove(stopwords("en")) %>%
  tokens_remove(c("ukraine", "ukrainian", "situation", "regarding"))

dfm_countries <- dfm(toks) %>%
  dfm_trim(min_termfreq = 2, min_docfreq = 2) %>%
  dfm_weight(scheme = "prop")

sim_mat <- textstat_simil(dfm_countries,
                          method = "cosine",
                          margin = "documents") %>%
  as.matrix()

message("Similarity matrix: ", nrow(sim_mat), " x ", ncol(sim_mat))
saveRDS(sim_mat, "data/similarity_matrix.rds")

# =============================================================
# 2. NETWORK
# =============================================================
# Keep the top 30% of country pairs by similarity
threshold <- quantile(sim_mat[upper.tri(sim_mat)], 0.7)
message("Edge threshold (70th percentile): ", round(threshold, 3))

adj <- sim_mat
adj[adj < threshold] <- 0
diag(adj) <- 0

g <- graph_from_adjacency_matrix(adj, mode = "undirected", weighted = TRUE)

V(g)$degree      <- degree(g)
V(g)$betweenness <- betweenness(g, normalized = TRUE)
V(g)$closeness   <- closeness(g, normalized = TRUE)

if (ecount(g) == 0) stop("No edges above threshold - lower the quantile.")

communities <- cluster_louvain(g, weights = E(g)$weight)
V(g)$cluster <- as.factor(membership(communities))

message("Communities detected: ", length(communities))
message("Modularity: ", round(modularity(communities), 3))

# Which countries fall in which community - this is the finding,
# so inspect it rather than only plotting it
cluster_table <- tibble(
  country = V(g)$name,
  cluster = as.integer(membership(communities)),
  degree  = V(g)$degree
) %>%
  arrange(cluster, desc(degree))

write_csv(cluster_table, "data/network_communities.csv")
print(cluster_table, n = 100)

# =============================================================
# 3. PLOT
# =============================================================
set.seed(42)  # layout reproducibility only

p_net <- ggraph(g, layout = "fr") +
  geom_edge_link(aes(width = weight), alpha = 0.25, show.legend = FALSE) +
  geom_node_point(aes(color = cluster, size = degree)) +
  geom_node_text(aes(label = name), repel = TRUE, size = 3) +
  scale_edge_width(range = c(0.2, 1.5)) +
  labs(title    = "Country similarity network, UNSC Ukraine speeches 2014-2023",
       subtitle = paste0("Cosine similarity on word frequencies; edges above the ",
                         "70th percentile; Louvain communities"),
       color = "Community", size = "Degree") +
  theme_void(base_size = 12)

ggsave(file.path(out_dir, "country_network.png"), p_net,
       width = 10, height = 8, dpi = 300)

message("02 complete.")
