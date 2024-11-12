# Project Overview

In this project, we create Violin Plots and Heat Maps to analyze data from high-throughput studies. These visualizations will help us evaluate the quality of experimental data and gain insights into how various conditions—such as drug treatments or temperature changes—impact cell trafficking. We’ll process the experimental data using R and RStudio.

**Note**: Download R, RStudio from the Internet and the necessary files from the Kroncke OneDrive, and update file paths in the scripts.

---

# Instructions

## Step 1: Processing Individual Experiments

1. Begin by running the `Tile3sortedCells-11848-dmso.R`. This will produce both a heat map and a violin plot, as well as a CSV file named `11848_e_dmso.csv`. These outputs help evaluate the quality of experiment `11848` under the DMSO condition.

2. Repeat this process for each of the following conditions and samples:

   - **Conditions**: dmso, eva, e4031, temperature
   - **Samples**: 11848, 11882, 11921

   Each run will generate a CSV file, e.g., `11848_e_dmso.csv` for the DMSO condition of sample 11848.

3. **Check**: Ensure you use the correct `barcodekey`. Confirm the data’s plasmid source with either the experimenter or Mr. Kroncke. For example, data from sample `11247` comes from plasmid `384`, so we use `barcode-key.tile3.lv384.csv`.

## Step 2: Combining the Data

1. Use the `Tile3-meta_processing-dmso.R` script to combine the data from different samples and correct any inconsistencies. This script will aggregate the CSV files generated in Step 1, such as:

   - `11848_e_dmso.csv`
   - `11882_e_dmso.csv`
   - `11921_e_dmso.csv`

2. The output will be a combined CSV file called `Tile3-dmso.csv`, which reflects the average results across the samples.

3. **Check**: Confirm that the `resnum` range is correct. For example, in `meta-process 103 rows`, use the line `d<-d[d$resnum>474 & d$resnum<638,]` to limit `resnum` for KCNH2 Tile3. Each tile has different `resnum` ranges (e.g., for Tile4, the range is `660 < resnum < 938`). Validate these ranges with the experimenter or Mr. Brett.

## Step 3: Comparing Experimental Conditions

1. Finally, use the `Tile3-meta_diff.R` script to compare results from different conditions. For example, the `Tile3-meta_diff-v2.R` script can compare cell trafficking under `eva` versus `dmso`, allowing you to assess the effects of drug treatments or temperature changes on the cells.

2. **Tip**: Throughout each step, consider organizing your data locations efficiently to optimize the `setwd` command’s functionality.

---

# Glossary

- **Tile3**: Represents one of five segments of the KCNH2 gene, used for easier analysis.
- **dmso, eva, e4031, temperature**: Experimental conditions. `dmso` is the control; `eva` and `e4031` are drug treatments. Temperature conditions involve testing at different thermal settings (note: no specific temperature scripts are in this repository).
- **pRU327**: The plasmid used in these experiments.
