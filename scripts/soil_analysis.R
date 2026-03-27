# ============================================================================
# Soil Microbiome Analysis
# Dataset: PRJNA937073 – Drought and future warming experiment
# Stress factor: Control (no drought + ambient) vs Stress (drought OR future)
# ============================================================================

# 1. Load libraries ---------------------------------------------------------
library(readxl)
library(vegan)
library(ggplot2)
library(igraph)

# 2. Set working directory (change to your project root) --------------------
# setwd("C:/Users/.../climate-microbiome-stress-analysis")

# 3. Read soil abundance data -----------------------------------------------
cat("\n========== SOIL MICROBIOME ==========\n")
soil_file <- "soil data set/41467_2023_41524_MOESM4_ESM.xlsx"
soil_abundance <- read_excel(soil_file, sheet = "Figure 1a")

# 4. Separate metadata (first 7 columns) and numeric data ------------------
soil_meta <- soil_abundance[, 1:7]
soil_numeric <- soil_abundance[, 8:ncol(soil_abundance)]
soil_numeric <- as.data.frame(lapply(soil_numeric, as.numeric))
soil_numeric[is.na(soil_numeric)] <- 0
soil_samples <- t(soil_numeric)   # rows = samples, cols = taxa
cat("Original dimensions: samples =", nrow(soil_samples), ", taxa =", ncol(soil_samples), "\n")

# 5. Identify Drought and Future columns automatically ----------------------
drought_col <- NULL
future_col <- NULL
for (col in colnames(soil_meta)) {
  if (grepl("drought", tolower(col))) drought_col <- col
  if (grepl("future|warming", tolower(col))) future_col <- col
}
if (is.null(drought_col)) drought_col <- "Drought"   # fallback
if (is.null(future_col)) future_col <- "Future"

# 6. Create stress factor: Stress if Drought == "Drought" OR Future == "Future"
drought <- soil_meta[[drought_col]]
future <- soil_meta[[future_col]]
condition_soil <- ifelse(drought == "Drought" | future == "Future", "Stress", "Control")
condition_soil <- factor(condition_soil, levels = c("Control", "Stress"))
cat("Stress distribution:\n")
print(table(condition_soil))

# 7. Remove samples with missing condition ----------------------------------
keep <- !is.na(condition_soil)
soil_samples <- soil_samples[keep, ]
condition_soil <- condition_soil[keep]

# 8. Subsample to manageable size (e.g., 200 samples) ----------------------
set.seed(123)
max_samples <- 200
if (nrow(soil_samples) > max_samples) {
  idx <- sample(1:nrow(soil_samples), max_samples)
  soil_samples <- soil_samples[idx, ]
  condition_soil <- condition_soil[idx]
  cat("Subsampled to", max_samples, "samples.\n")
}

# 9. Remove rare taxa (present in <5% of samples) --------------------------
presence <- colSums(soil_samples > 0) / nrow(soil_samples)
taxa_keep <- presence >= 0.05
soil_filtered <- soil_samples[, taxa_keep]
cat("After rare taxa removal: samples =", nrow(soil_filtered), ", taxa =", ncol(soil_filtered), "\n")

# 10. Alpha diversity (Shannon) --------------------------------------------
shannon_soil <- diversity(soil_filtered, index = "shannon")
png("figures/soil_shannon.png", width = 800, height = 600)
boxplot(shannon_soil ~ condition_soil,
        main = "Soil Microbial Shannon Diversity",
        xlab = "Stress Status", ylab = "Shannon Index",
        col = c("green", "orange"))
dev.off()
cat("Soil Shannon boxplot saved.\n")

# 11. Beta diversity – PCA on Hellinger‑transformed data -------------------
soil_hell <- decostand(soil_filtered, method = "hellinger")
pca <- rda(soil_hell)
scores <- as.data.frame(scores(pca, choices = 1:2, display = "sites"))
colnames(scores) <- c("PC1", "PC2")
scores$Condition <- condition_soil
var_exp <- round(eigenvals(pca)[1:2] / sum(eigenvals(pca)) * 100, 1)

p_pca <- ggplot(scores, aes(x = PC1, y = PC2, color = Condition)) +
  geom_point(size = 3, alpha = 0.8) +
  stat_ellipse(aes(group = Condition), type = "norm", linetype = 2, level = 0.95) +
  labs(title = "Soil Microbiome – PCA (Hellinger‑transformed)",
       x = paste0("PC1 (", var_exp[1], "%)"),
       y = paste0("PC2 (", var_exp[2], "%)"),
       color = "Stress Status") +
  theme_minimal()
ggsave("figures/soil_pca.png", p_pca, width = 8, height = 6, dpi = 300)
cat("Soil PCA plot saved.\n")

# 12. Network analysis (correlation‑based, |r| >= 0.6) ---------------------
# Use the top 200 most abundant taxa to keep network manageable
abundance <- colSums(soil_filtered)
top_taxa <- order(abundance, decreasing = TRUE)[1:min(200, length(abundance))]
soil_network_data <- soil_filtered[, top_taxa]

soil_cor <- cor(soil_network_data, method = "spearman")
soil_cor[abs(soil_cor) < 0.6] <- 0
diag(soil_cor) <- 0
soil_network <- graph_from_adjacency_matrix(soil_cor,
                                            mode = "undirected",
                                            weighted = TRUE,
                                            diag = FALSE)
# Remove isolated nodes
soil_network <- delete.vertices(soil_network, degree(soil_network) == 0)

png("figures/soil_network_final.png", width = 800, height = 800)
plot(soil_network,
     layout = layout_with_fr,
     vertex.size = degree(soil_network) * 2,
     vertex.label = NA,
     main = "Soil Microbial Network")
dev.off()
cat("Soil network saved with", vcount(soil_network), "nodes and",
    ecount(soil_network), "edges.\n")

# 13. Optional: PERMANOVA (Bray‑Curtis) on subsampled data -----------------
cat("\nRunning PERMANOVA on subsampled data...\n")
dist_sub <- vegdist(soil_hell, method = "bray")
adonis_sub <- adonis2(dist_sub ~ condition_soil, permutations = 99)
cat("\nPERMANOVA results:\n")
print(adonis_sub)

cat("\n===== Soil analysis completed =====\n")
