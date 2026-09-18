# Data

The corpus is not included in this repository.

## Obtaining the corpus

Schoenfeld, M., Eckhard, S., Patz, R., & van Meegdenburg, H.
*The UN Security Council Debates.* Harvard Dataverse.
https://doi.org/10.7910/DVN/KGVSYH

Dataset paper: https://arxiv.org/abs/1906.10969

Download the corpus and place it in `data/raw/`, then run the scripts in
`notebooks/` in order.

## Expected layout

```
data/raw/
  speeches/*.txt
  meta.tsv
  speaker.tsv
```

File and column names in the download may differ from the ones used in
`01_corpus_temporal.R`. Check with `list.files("data/raw", recursive = TRUE)`
and adjust the loading section accordingly.

## Generated files

Running the scripts writes intermediate results here:
`ukraine_corpus.rds`, `speeches_by_country.csv`, `monthly_volume.csv`,
`keyness_pre_post_2014.csv`, `similarity_matrix.rds`, `network_communities.csv`.
