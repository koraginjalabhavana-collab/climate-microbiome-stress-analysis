Climate Microbiome Stress Analysis

Comparative microbial ecology analysis investigating how climate stressors reshape microbial community structure across coral reef and soil ecosystems using public 16S rRNA datasets.

---

📌 Project Overview

Climate change is altering microbial communities worldwide, but do marine and terrestrial microbiomes respond similarly? This independent research project compares:

- Coral reef microbiomes: under thermal stress (2020 bleaching event in Taiwan)
- Soil microbiomes: under combined drought and future warming conditions

We aim to identify common patterns of microbial adaptation and assess whether environmental stress drives community restructuring rather than simple diversity loss.

---

Hypothesis

 Environmental stress reorganises microbial communities – altering diversity, co‑occurrence networks, and beta‑diversity patterns – and these changes differ between host‑associated (coral) and free‑living (soil) microbiomes.

---

 Datasets

| Ecosystem | Bioproject | Stressor | Description |
|-----------|------------|----------|-------------|
| **Coral** | [PRJNA1010003](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1010003) | Thermal bleaching | 16S rRNA amplicons from three coral species in Taiwan during and after the 2020 mass bleaching event. |
| **Soil** | [PRJNA937073](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA937073) | Drought + future warming | 16S rRNA (qSIP) from a controlled experiment testing drought and future climate conditions. |

---

 Methods

All analyses were performed in R using:

- **vegan** – alpha diversity (Shannon), beta diversity (Bray‑Curtis PCoA, Hellinger‑PCA)
- **igraph** – correlation‑based co‑occurrence networks
- **ggplot2** – visualisation
- **readxl, tidyverse** – data handling

*Due to hardware limitations, the soil beta‑diversity analysis used PCA on Hellinger‑transformed data – a fast, ecologically valid alternative.*

---

Key Findings

| Analysis | Coral | Soil |
|----------|-------|------|
| **Alpha diversity** | Shannon index dips during bleaching, recovers afterwards | No major shift between control and stress groups |
| **Beta diversity** | Clear separation between bleached and recovering communities | Partial separation between control and stress communities (PERMANOVA significant) |
| **Network structure** | Centralised, modular network with hub taxa | Less centralised, more distributed interactions |

Conclusion:
Stress restructures microbial communities in both systems, but the effect is more pronounced in coral (acute thermal event) than in soil (gradual, multi‑factorial). Coral networks are host‑driven and centralised; soil networks reflect a flexible, functionally redundant community.

