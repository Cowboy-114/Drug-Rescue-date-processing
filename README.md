# 1. Project Overview

In this project, we will generate Violin Plots and Heat Maps to analyze data from High Throughput Studies. These visualizations will help assess the quality of experimental data and provide insights into how different conditions, such as drug treatments or temperature changes, affect cell trafficking. The project involves processing experimental data using R and R Studio.

Throughout the project, you will need to download the required files and update the file paths in the scripts.

# 2. Instructions

## Step 1: Processing individual experiments

We begin by running the `Tile3sortedCells-11848-dmso.R` script. This will create both a heat map and a violin plot, and output a CSV file named `11848_e_dmso.csv`. The heat map and violin plot will help evaluate the quality of experiment 11848 under the DMSO condition.

Repeat this process for the following conditions and samples:

**Conditions:** `dmso`, `eva`, `e4031`, and `temperature`  
**Samples:** `11848`, `11882`, `11921`

Each run will generate a CSV file, such as `11848_e_dmso.csv` for the DMSO condition of sample 11848.

## Step 2: Combining the data

Next, use the `Tile3-meta_processing-dmso.R` script to combine the results from different samples and remove any inconsistencies in the data. The script will take the CSV files generated in the previous step, such as:

- `11848_e_dmso.csv`
- `11882_e_dmso.csv`
- `11921_e_dmso.csv`

It will output a combined CSV file called `Tile3-dmso.csv`, which represents the average results across these samples.

## Step 3: Comparing experimental conditions

Finally, compare the results from different experimental conditions using the `Tile3-meta_diff.R` script. For example, you can use the `Tile3-meta_diff-v2.R` script to compare the trafficking of cells under the eva condition with the dmso condition.

# 3. Glossary

**Tile3:** The KCNH2 gene is divided into five sections, or "tiles," for easier analysis. Tile3 represents one of these segments.  
**dmso, eva, e4031, temperature:** These refer to the experimental conditions. `dmso` is the control, while `eva` and `e4031` represent drug treatments. `Temperature` refers to testing under different thermal conditions.  
**pRU327:** The name of the plasmid used in these experiments.
