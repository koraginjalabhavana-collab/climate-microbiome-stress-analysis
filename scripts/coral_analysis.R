
# ============================================================================
# Coral Microbiome Analysis
# Dataset: PRJNA1010003 – Coral microbiome of the 2020 mass bleaching event
# Stress factor: Bleaching (August 2020) vs Recovery (later months)
# ============================================================================

# 1. Load libraries ---------------------------------------------------------
library(readxl)
library(vegan)
library(ggplot2)
library(igraph)

# 2. Set working directory (change to your project root) --------------------
# setwd("C:/Users/.../climate-microbiome-stress-analysis")

# 3. Read coral abundance data ----------------------------------------------
cat("\n========== CORAL MICROBIOME ==========\n")
coral_file <- "coral data set/supplementary_table_s2_updated2_ycae001.xlsx"
coral_abundance <- read_excel(coral_file, skip = 2)

# 4. Extract sample IDs and numeric abundance ------------------------------
sample_ids <- coral_abundance[[1]]
coral_numeric <- coral_abundance[, -1]
coral_numeric <- as.data.frame(lapply(coral_numeric, as.numeric))
coral_numeric[is.na(coral_numeric)] <- 0

# 5. Create stress factor: Bleaching (Aug 2020) vs Recovery (all others) ---
date_part <- substr(sample_ids, nchar(sample_ids)-5, nchar(sample_ids))
condition_coral <- ifelse(date_part == "202008", "Bleaching", "Recovery")
condition_coral <- factor(condition_coral, levels = c("Bleaching", "Recovery"))
cat("Stress distribution:\n")
print(table(condition_coral))

# 6. Alpha diversity (Shannon) ----------------------------------------------
shannon_coral <- diversity(coral_numeric, index = "shannon")
png("figures/coral_shannon.png", width = 800, height = 600)
boxplot(shannon_coral ~ condition_coral,
        main = "Coral Microbial Shannon Diversity",
        xlab = "Stress Status", ylab = "Shannon Index",
        col = c("red", "blue"))
dev.off()
cat("Coral Shannon boxplot saved.\n")

# 7. Beta diversity – PCoA (Bray‑Curtis) -----------------------------------
dist_coral <- vegdist(coral_numeric, method = "bray")
pcoa_coral <- cmdscale(dist_coral, k = 2, eig = TRUE)
scores_coral <- as.data.frame(pcoa_coral$points)
colnames(scores_coral) <- c("PCoA1", "PCoA2")
scores_coral$Condition <- condition_coral
var_exp <- round(pcoa_coral$eig[1:2] / sum(pcoa_coral$eig) * 100, 1)

p_pcoa <- ggplot(scores_coral, aes(x = PCoA1, y = PCoA2, color = Condition)) +
  geom_point(size = 3, alpha = 0.8) +
  stat_ellipse(aes(group = Condition), type = "norm", linetype = 2, level = 0.95) +
  labs(title = "Coral Microbiome – PCoA (Bray‑Curtis)",
       x = paste0("PCoA1 (", var_exp[1], "%)"),
       y = paste0("PCoA2 (", var_exp[2], "%)"),
       color = "Stress Status") +
  theme_minimal()
ggsave("figures/coral_pcoa.png", p_pcoa, width = 8, height = 6, dpi = 300)
cat("Coral PCoA plot saved.\n")

# 8. Network analysis (correlation‑based, |r| >= 0.85) ---------------------
cat("Building coral correlation network...\n")
coral_cor <- cor(coral_numeric, method = "spearman")
coral_cor[abs(coral_cor) < 0.85] <- 0
diag(coral_cor) <- 0
coral_network <- graph_from_adjacency_matrix(coral_cor,
                                             mode = "undirected",
                                             weighted = TRUE,
                                             diag = FALSE)
# Remove isolated nodes
coral_network <- delete.vertices(coral_network, degree(coral_network) == 0)

png("figures/coral_network_final.png", width = 800, height = 800)
plot(coral_network,
     layout = layout_with_fr,
     vertex.size = degree(coral_network) * 2,
     vertex.label = NA,
     main = "Coral Microbial Network")
dev.off()
cat("Coral network saved with", vcount(coral_network), "nodes and",
    ecount(coral_network), "edges.\n")

cat("\n===== Coral analysis completed =====\n")
