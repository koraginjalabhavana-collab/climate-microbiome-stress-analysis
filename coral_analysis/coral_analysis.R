--------------------------------------------
Coral Microbiome Network Analysis
--------------------------------------------

Step 1: Load required libraries
library(readxl)
library(tidyverse)
library(reshape2)
library(igraph)

Step 2: Set working directory
setwd("C:/Users/HP/OneDrive/Desktop/4th sem/research")

Step 3: Load dataset
coral_abundance <- read_excel(
  "coral data set/supplementary_table_s2_updated2_ycae001.xlsx",
  skip = 2)

Step 4: Prepare numeric data
coral_numeric <- coral_abundance[, -1]

Step 5: Remove zero-variance features
coral_filtered <- coral_numeric[, apply(coral_numeric, 2, sd) != 0]

Step 6: Compute correlation matrix (subset for performance)
cor_small <- cor(coral_filtered[, 1:50])

Step 7: Filter strong correlations
cor_small[abs(cor_small) < 0.85] <- 0
diag(cor_small) <- 0

Step 8: Convert to edge list
cor_melt <- melt(cor_small)
edges_small <- subset(cor_melt, value != 0)
edges_small <- edges_small[edges_small$Var1 != edges_small$Var2, ]

Step 9: Create network
network_small <- graph_from_data_frame(edges_small, directed = FALSE)

Step 10: Calculate node importance (degree)
deg <- degree(network_small)

Step 11: Scale node size by importance
V(network_small)$size <- deg * 2

Step 12: Plot network
plot(network_small,
     layout = layout_with_fr,
     vertex.label = NA)

Step 13: Save network plot
png("coral_network_final.png", width = 800, height = 800)
plot(network_small,
     layout = layout_with_fr,
     vertex.label = NA)
dev.off()
