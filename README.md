Climate Microbiome Stress Analysis

Project Overview

This project investigates microbial community structure and interaction networks in coral reef ecosystems, with the broader goal of understanding how environmental stressors (e.g., climate change) influence microbial ecology.

The current stage focuses on establishing baseline microbial interaction patterns using correlation-based network analysis.
---
Coral Microbiome Analysis

Methodology

- Data preprocessing and cleaning  
- Removal of zero-variance features  
- Correlation analysis between microbial taxa  
- Filtering strong correlations (|r| ≥ 0.85)  
- Construction of microbial interaction network  
- Identification of hub taxa using degree centrality  

Key Findings

- The microbial network shows a **modular structure**  
- Distinct clusters indicate **co-occurring microbial groups**  
- A highly connected node (hub taxon) suggests a **potential keystone species**

---
Tools Used

- R  
- reshape2  
- igraph  

---
Future Work

- Soil microbiome analysis  
- Comparative analysis between coral and soil ecosystems  
- Investigation of climate stress impact on microbial networks  
