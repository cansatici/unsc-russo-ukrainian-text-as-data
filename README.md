# The Origins of Mayhem — A Text-as-Data Approach to the Russo-Ukrainian War (2014–2023)

Text analysis of UN Security Council speeches on the Russo-Ukrainian conflict, from the 2014 annexation of Crimea to 2023.

Course project, University of Bayreuth, May–August 2025. Presented at Days of Ukraine in Bavaria, German-Ukrainian Academic Society / University of Bayreuth, October 2025.

## Research question

Can text data analysis of UN Security Council speeches reveal both distinct geopolitical blocs and their evolving narrative strategies throughout the Russo-Ukrainian conflict from 2014 to 2023?

## Background

More than 8,000 UNSC speeches mention the conflict, more than were delivered on Syria, Iraq or Afghanistan.

## Data

UN Security Council debates corpus (1992–2023), compiled by Prof. Dr. Mirco Schoenfeld, University of Bayreuth.

Analysis window: 2014–2023, Ukraine-related speeches.
Speeches after filtering: [FILL IN]

The corpus is not included in this repository. See `data/README.md`.

## Methods

Preprocessing in Python. Topic modelling, speech-similarity analysis and network analysis in R/RStudio.

Fill in before publishing:

- Topic model: [LDA / STM / BERTopic], k = [N], selected by [criterion]
- Document vectorisation: [TF-IDF / embeddings]
- Similarity measure: [cosine / other]
- Network: [igraph / other], edge threshold [value]
- Sentiment: [lexicon or model]
- Python libraries: [list]
- R packages: [list]

Topics were grouped into five areas: Crisis & Response, Diplomacy & Process, Legal & Institutional, Regional & Cooperation, Security & Military.

## Findings

1. Distinct geopolitical blocs can be identified through speech similarity patterns. The diplomatic alignments they show persist across the conflict period.

2. Russia's framing in security terms was most prevalent in 2014.

3. Ukraine's emphasis on cooperation themes peaked in 2022, the year of the invasion. The same bloc structure is already visible in how the DPR and LPR are framed earlier in the corpus.

## Figures

- `figures/speech_volume_by_conflict.png` — UNSC speech volume, Ukraine compared to other conflicts
- `figures/topic_evolution.png` — proportional topic evolution for Russia and Ukraine, 2013–2023
- `figures/monthly_speech_volume.png` — monthly Ukraine-related speeches, with Crimea and invasion marked
- `figures/country_network.png` — country network by position on LPR/DPR
- `figures/sentiment_intensity.png` — sentiment toward LPR/DPR recognition against emotional intensity

## Repository structure

```
README.md
data/README.md          how to obtain the corpus
notebooks/              preprocessing and analysis scripts
figures/                output figures
poster/                 conference poster (PDF)
```

## Authors

Ahmet Can Satıcı, M.A. Social and Cultural Anthropology, University of Bayreuth
Eric Macpherson Bailón

Corpus by Prof. Dr. Mirco Schoenfeld.

## License

MIT for the code. The corpus has its own terms.
