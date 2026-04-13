# Statistical analysis — LOP Iterative Improvement
# Exercise 1.1 and 1.2 — INFO-H-413 Heuristic Optimization

dir.create("results/figures", showWarnings=FALSE)

data <- read.table("results/raw_data.txt", header=TRUE, sep="\t")

data$label <- paste(data$algo, data$pivot, data$neighborhood, data$init, sep="_")

# Short readable names for plots
data$short_label <- with(data, {
    ifelse(algo == "VND",
        paste0(toupper(pivot), "+CW"),
        paste0(
            ifelse(pivot=="first","FI","BI"), "-",
            substr(neighborhood,1,3), "-",
            ifelse(init=="random","Rnd","CW")
        )
    )
})

# ─────────────────────────────────────────────────────────────────
# 1. SUMMARY TABLE
# ─────────────────────────────────────────────────────────────────
avg_rpd    <- tapply(data$rpd,      data$label, mean)
sd_rpd     <- tapply(data$rpd,      data$label, sd)
total_time <- tapply(data$time_sec, data$label, sum)

result <- data.frame(
    algorithm  = names(avg_rpd),
    avg_rpd    = round(avg_rpd,    4),
    sd_rpd     = round(sd_rpd,     4),
    total_time = round(total_time, 4)
)
result <- result[order(result$avg_rpd), ]
rownames(result) <- NULL

cat("=======================================================\n")
cat(" SUMMARY: Average RPD (%) and Total Time (s)\n")
cat("=======================================================\n")
print(result)

write.csv(result, "results/summary_table.csv", row.names=FALSE)
cat("\nSaved: results/summary_table.csv\n")

# ─────────────────────────────────────────────────────────────────
# 2. WILCOXON TESTS
# ─────────────────────────────────────────────────────────────────
# ─────────────────────────────────────────────────────────────────
# NOTE on RPD sign convention:
# We use RPD = 100 * (best_known - cost) / best_known  (positive, 0 = optimal)
# The prof's slides use (cost - best_known) / best_known (negative, 0 = optimal)
# Both are equivalent for statistical testing — only the sign differs.
# We use the positive convention as it is more intuitive for a maximization problem.
# ─────────────────────────────────────────────────────────────────

get_rpd <- function(piv, nei, ini) {
    sub <- data[data$algo=="II" & data$pivot==piv &
                data$neighborhood==nei & data$init==ini, ]
    sub[order(sub$instance), "rpd"]
}

get_vnd_rpd <- function(vnd) {
    sub <- data[data$algo=="VND" & data$pivot==vnd, ]
    sub[order(sub$instance), "rpd"]
}

# Run both t-test and Wilcoxon (paired) and return results
# H0 for both: no difference between the two algorithms (median of differences = 0)
# We reject H0 if p-value < alpha = 0.05
both_tests <- function(label_a, rpd_a, label_b, rpd_b) {
    w <- wilcox.test(rpd_a, rpd_b, paired=TRUE, exact=FALSE)
    t <- t.test(rpd_a,     rpd_b, paired=TRUE)
    w_sig <- ifelse(w$p.value < 0.05, "YES", "no")
    t_sig <- ifelse(t$p.value < 0.05, "YES", "no")
    cat(sprintf("  %-32s vs %-32s | Wilcoxon p=%.4f (%s) | t-test p=%.4f (%s)\n",
                label_a, label_b,
                w$p.value, w_sig,
                t$p.value, t_sig))
    data.frame(algo_a=label_a, algo_b=label_b,
               wilcoxon_p=round(w$p.value,4), wilcoxon_sig=w_sig,
               ttest_p=round(t$p.value,4),    ttest_sig=t_sig)
}

test_rows <- list()

cat("\n=======================================================\n")
cat(" STATISTICAL TESTS — Exercise 1.1\n")
cat(" H0: no difference in RPD between the two algorithms\n")
cat(" Alpha = 0.05 — H0 rejected if p-value < 0.05\n")
cat("=======================================================\n")

cat("\n--- First vs Best (same neighborhood + init) ---\n")
for (nei in c("transpose","exchange","insert")) {
    for (ini in c("random","cw")) {
        a <- get_rpd("first", nei, ini)
        b <- get_rpd("best",  nei, ini)
        test_rows[[length(test_rows)+1]] <-
            both_tests(paste("first",nei,ini), a, paste("best",nei,ini), b)
    }
}

cat("\n--- Neighborhood comparison (first-improvement, random init) ---\n")
t_r <- get_rpd("first","transpose","random")
e_r <- get_rpd("first","exchange", "random")
i_r <- get_rpd("first","insert",   "random")
test_rows[[length(test_rows)+1]] <- both_tests("first_transpose_random", t_r, "first_exchange_random", e_r)
test_rows[[length(test_rows)+1]] <- both_tests("first_transpose_random", t_r, "first_insert_random",   i_r)
test_rows[[length(test_rows)+1]] <- both_tests("first_exchange_random",  e_r, "first_insert_random",   i_r)

cat("\n--- Random vs CW (same pivot + neighborhood) ---\n")
for (piv in c("first","best")) {
    for (nei in c("transpose","exchange","insert")) {
        a <- get_rpd(piv, nei, "random")
        b <- get_rpd(piv, nei, "cw")
        test_rows[[length(test_rows)+1]] <-
            both_tests(paste(piv,nei,"random"), a, paste(piv,nei,"cw"), b)
    }
}

cat("\n=======================================================\n")
cat(" STATISTICAL TESTS — Exercise 1.2 (VND)\n")
cat(" H0: no difference in RPD between the two algorithms\n")
cat(" Alpha = 0.05 — H0 rejected if p-value < 0.05\n")
cat("=======================================================\n")

vnd1    <- get_vnd_rpd("vnd1")
vnd2    <- get_vnd_rpd("vnd2")
best_ii <- get_rpd("first","insert","cw")

cat("\n--- VND1 vs VND2 ---\n")
test_rows[[length(test_rows)+1]] <- both_tests("VND1_cw", vnd1, "VND2_cw", vnd2)

cat("\n--- VND vs best II (first_insert_cw) ---\n")
test_rows[[length(test_rows)+1]] <- both_tests("VND1_cw", vnd1, "first_insert_cw", best_ii)
test_rows[[length(test_rows)+1]] <- both_tests("VND2_cw", vnd2, "first_insert_cw", best_ii)

test_table <- do.call(rbind, test_rows)
write.csv(test_table, "results/wilcoxon_table.csv", row.names=FALSE)
cat("\nSaved: results/wilcoxon_table.csv\n")

# ─────────────────────────────────────────────────────────────────
# 3. FIGURES
# ─────────────────────────────────────────────────────────────────
library(ggplot2)
library(ggrepel)

# Order algorithms by avg RPD for all plots
ordered_labels <- result$algorithm
short_map <- unique(data[, c("label","short_label")])
ordered_short <- short_map$short_label[match(ordered_labels, short_map$label)]

data$short_label <- factor(data$short_label, levels=ordered_short)

# Color by neighborhood type
data$group <- with(data, ifelse(algo=="VND", "VND",
                   ifelse(neighborhood=="transpose", "Transpose",
                   ifelse(neighborhood=="exchange",  "Exchange", "Insert"))))
data$group <- factor(data$group, levels=c("VND","Insert","Exchange","Transpose"))

group_colors <- c("VND"="#2196F3", "Insert"="#4CAF50",
                  "Exchange"="#FF9800", "Transpose"="#F44336")

# ── Figure 1: Boxplot — two panels (zoom + full) ─────────────────
# Top panel: zoom on algorithms with RPD < 6%
# Bottom panel: full view including Transpose

top_algos <- levels(data$short_label)[1:10]   # VND + Insert + Exchange
data_top  <- data[data$short_label %in% top_algos, ]
data_top$short_label <- droplevels(data_top$short_label)

p_zoom <- ggplot(data_top, aes(x=short_label, y=rpd, fill=group)) +
    geom_boxplot(outlier.size=1.5, linewidth=0.4) +
    scale_fill_manual(values=group_colors, name="Neighborhood") +
    geom_hline(yintercept=0, linetype="dashed", color="red", linewidth=0.5) +
    labs(title="RPD distribution — VND, Insert, Exchange (zoomed)",
         x=NULL, y="RPD (%)") +
    theme_bw(base_size=11) +
    theme(axis.text.x=element_text(angle=35, hjust=1),
          legend.position="right")

ggsave("results/figures/boxplot_rpd_zoom.png", p_zoom, width=10, height=5, dpi=150)
cat("Saved: results/figures/boxplot_rpd_zoom.png\n")

# Full view: two separate panels with independent y-scales
# Panel A — VND + Insert + Exchange (RPD 1-5%)
data_good <- data[data$group %in% c("VND","Insert","Exchange"), ]
data_good$short_label <- droplevels(data_good$short_label)

# Panel B — Transpose only (RPD 15-40%)
data_tra  <- data[data$group == "Transpose", ]
data_tra$short_label <- droplevels(data_tra$short_label)

p_panel_a <- ggplot(data_good, aes(x=short_label, y=rpd, fill=group)) +
    geom_boxplot(outlier.size=1.5, linewidth=0.4) +
    scale_fill_manual(values=group_colors, name="Neighborhood") +
    geom_hline(yintercept=0, linetype="dashed", color="red", linewidth=0.5) +
    labs(title="A — VND, Insert, Exchange",
         x=NULL, y="RPD (%)") +
    theme_bw(base_size=10) +
    theme(axis.text.x=element_text(angle=40, hjust=1),
          legend.position="none")

p_panel_b <- ggplot(data_tra, aes(x=short_label, y=rpd, fill=group)) +
    geom_boxplot(outlier.size=1.5, linewidth=0.4) +
    scale_fill_manual(values=group_colors, name="Neighborhood") +
    labs(title="B — Transpose",
         x=NULL, y="RPD (%)") +
    theme_bw(base_size=10) +
    theme(axis.text.x=element_text(angle=40, hjust=1),
          legend.position="none")

# Combine side by side with patchwork or cowplot if available,
# otherwise save separately and note they go side by side
if (requireNamespace("patchwork", quietly=TRUE)) {
    library(patchwork)
    p_combined <- p_panel_a + p_panel_b +
        plot_layout(widths=c(3,1)) +
        plot_annotation(
            title="RPD distribution per algorithm — all 14 configurations",
            subtitle="Panel A: competitive algorithms (scale 0–6%) | Panel B: Transpose (scale 15–45%)",
            theme=theme(plot.title=element_text(size=12, face="bold"),
                        plot.subtitle=element_text(size=9, color="gray40"))
        )
    ggsave("results/figures/boxplot_rpd_full.png", p_combined, width=13, height=5, dpi=150)
} else {
    # fallback: save side by side manually
    png("results/figures/boxplot_rpd_full.png", width=1800, height=600, res=130)
    par(mfrow=c(1,2))
    print(p_panel_a)
    print(p_panel_b)
    dev.off()
}
cat("Saved: results/figures/boxplot_rpd_full.png\n")

# ── Figure 2: Barplot avg RPD — two panels ───────────────────────
result_plot <- data.frame(
    short_label = factor(ordered_short, levels=ordered_short),
    avg_rpd     = result$avg_rpd,
    sd_rpd      = result$sd_rpd,
    group       = with(result, ifelse(grepl("VND", algorithm), "VND",
                        ifelse(grepl("insert", algorithm), "Insert",
                        ifelse(grepl("exchange", algorithm), "Exchange", "Transpose"))))
)
result_plot$group <- factor(result_plot$group, levels=c("VND","Insert","Exchange","Transpose"))

# Zoom: first 10 algorithms (RPD < 6%)
result_zoom <- result_plot[1:10, ]

p_bar_zoom <- ggplot(result_zoom, aes(x=short_label, y=avg_rpd, fill=group)) +
    geom_bar(stat="identity", width=0.7) +
    geom_errorbar(aes(ymin=avg_rpd-sd_rpd, ymax=avg_rpd+sd_rpd),
                  width=0.25, linewidth=0.5) +
    geom_text(aes(label=sprintf("%.2f%%", avg_rpd)),
              vjust=-0.8, size=3.2) +
    scale_fill_manual(values=group_colors, name="Neighborhood") +
    labs(title="Average RPD — VND, Insert, Exchange (lower is better)",
         x=NULL, y="Average RPD (%)") +
    theme_bw(base_size=11) +
    theme(axis.text.x=element_text(angle=35, hjust=1),
          legend.position="right")

p_bar_full <- ggplot(result_plot, aes(x=short_label, y=avg_rpd, fill=group)) +
    geom_bar(stat="identity", width=0.7) +
    geom_errorbar(aes(ymin=avg_rpd-sd_rpd, ymax=avg_rpd+sd_rpd),
                  width=0.25, linewidth=0.5) +
    geom_text(aes(label=sprintf("%.2f%%", avg_rpd)),
              vjust=-0.8, size=2.8) +
    scale_fill_manual(values=group_colors, name="Neighborhood") +
    labs(title="Average RPD — all algorithms (lower is better)",
         x=NULL, y="Average RPD (%)") +
    theme_bw(base_size=11) +
    theme(axis.text.x=element_text(angle=35, hjust=1),
          legend.position="right")

ggsave("results/figures/barplot_avg_rpd_zoom.png", p_bar_zoom, width=10, height=5, dpi=150)
ggsave("results/figures/barplot_avg_rpd_full.png", p_bar_full, width=12, height=5, dpi=150)
cat("Saved: results/figures/barplot_avg_rpd_zoom.png\n")
cat("Saved: results/figures/barplot_avg_rpd_full.png\n")

# ── Figure 3: RPD vs Time trade-off ──────────────────────────────
p_tradeoff <- ggplot(result_plot, aes(x=result$total_time, y=avg_rpd,
                                       color=group, label=short_label)) +
    geom_point(size=3) +
    geom_text_repel(size=3, max.overlaps=20,
                    box.padding=0.5, point.padding=0.3) +
    scale_color_manual(values=group_colors, name="Neighborhood") +
    labs(title="Solution quality vs. Computation time trade-off",
         x="Total computation time (s)", y="Average RPD (%)") +
    theme_bw(base_size=11)

ggsave("results/figures/rpd_vs_time.png", p_tradeoff, width=10, height=6, dpi=150)
cat("Saved: results/figures/rpd_vs_time.png\n")

# ── Figure 4: Heatmap of pairwise Wilcoxon p-values ──────────────
# Get RPD vector for each of the 14 algorithms
all_labels <- ordered_short
all_rpds   <- lapply(ordered_labels, function(lbl) {
    data[data$label == lbl, ][order(data[data$label == lbl, "instance"]), "rpd"]
})
names(all_rpds) <- all_labels

n <- length(all_labels)
pmat <- matrix(NA, nrow=n, ncol=n, dimnames=list(all_labels, all_labels))

for (i in 1:n) {
    for (j in 1:n) {
        if (i == j) {
            pmat[i,j] <- 1
        } else if (i < j) {
            p <- wilcox.test(all_rpds[[i]], all_rpds[[j]],
                             paired=TRUE, exact=FALSE)$p.value
            pmat[i,j] <- p
            pmat[j,i] <- p
        }
    }
}

# Convert to long format for ggplot
pmat_df <- as.data.frame(as.table(pmat))
colnames(pmat_df) <- c("algo_a","algo_b","p_value")
pmat_df$algo_a <- factor(pmat_df$algo_a, levels=all_labels)
pmat_df$algo_b <- factor(pmat_df$algo_b, levels=rev(all_labels))
pmat_df$significant <- ifelse(pmat_df$p_value < 0.05, "p < 0.05", "p ≥ 0.05")
pmat_df$label <- ifelse(pmat_df$algo_a == pmat_df$algo_b, "",
                        ifelse(pmat_df$p_value < 0.001, "<0.001",
                               sprintf("%.3f", pmat_df$p_value)))

p_heatmap <- ggplot(pmat_df, aes(x=algo_a, y=algo_b, fill=p_value)) +
    geom_tile(color="white", linewidth=0.5) +
    geom_text(aes(label=label), size=2.2, color="black") +
    scale_fill_gradientn(
        colors  = c("#d73027","#f46d43","#fdae61","#ffffbf","#a6d96a","#1a9641"),
        values  = scales::rescale(c(0, 0.01, 0.05, 0.1, 0.5, 1)),
        limits  = c(0, 1),
        name    = "p-value",
        guide   = guide_colorbar(barwidth=1, barheight=8)
    ) +
    labs(title="Pairwise Wilcoxon signed-rank test — p-values",
         subtitle="Red = significant difference (p < 0.05) | Green = no significant difference",
         x=NULL, y=NULL) +
    theme_bw(base_size=9) +
    theme(axis.text.x=element_text(angle=45, hjust=1),
          axis.text.y=element_text(hjust=1),
          panel.grid=element_blank())

ggsave("results/figures/heatmap_pvalues.png", p_heatmap,
       width=11, height=9, dpi=150)
cat("Saved: results/figures/heatmap_pvalues.png\n")

# ── Figure 4b: Heatmap zoomed — competitive algorithms only ──────
# Focus on VND + Insert + Exchange (top-left 10x10 block)
top10_labels <- all_labels[1:10]
top10_rpds   <- all_rpds[1:10]

pmat10 <- matrix(NA, nrow=10, ncol=10,
                 dimnames=list(top10_labels, top10_labels))
for (i in 1:10) {
    for (j in 1:10) {
        if (i == j) {
            pmat10[i,j] <- 1
        } else if (i < j) {
            p <- wilcox.test(top10_rpds[[i]], top10_rpds[[j]],
                             paired=TRUE, exact=FALSE)$p.value
            pmat10[i,j] <- p
            pmat10[j,i] <- p
        }
    }
}

pmat10_df <- as.data.frame(as.table(pmat10))
colnames(pmat10_df) <- c("algo_a","algo_b","p_value")
pmat10_df$algo_a <- factor(pmat10_df$algo_a, levels=top10_labels)
pmat10_df$algo_b <- factor(pmat10_df$algo_b, levels=rev(top10_labels))
pmat10_df$label  <- ifelse(pmat10_df$algo_a == pmat10_df$algo_b, "",
                           ifelse(pmat10_df$p_value < 0.001, "<0.001",
                                  sprintf("%.3f", pmat10_df$p_value)))

p_heatmap_zoom <- ggplot(pmat10_df, aes(x=algo_a, y=algo_b, fill=p_value)) +
    geom_tile(color="white", linewidth=0.8) +
    geom_text(aes(label=label), size=3, fontface="bold", color="black") +
    scale_fill_gradientn(
        colors = c("#d73027","#f46d43","#fdae61","#ffffbf","#a6d96a","#1a9641"),
        values = scales::rescale(c(0, 0.01, 0.05, 0.1, 0.5, 1)),
        limits = c(0, 1),
        name   = "p-value",
        guide  = guide_colorbar(barwidth=1.2, barheight=10)
    ) +
    geom_rect(xmin=0.5, xmax=2.5, ymin=8.5, ymax=10.5,
              fill=NA, color="black", linewidth=1.2) +
    annotate("text", x=1.5, y=11.1, label="VND", size=3.2,
             fontface="bold", color="black") +
    labs(title="Pairwise Wilcoxon p-values — competitive algorithms",
         subtitle="Red = significant (p < 0.05)  |  Green = not significant  |  Bold box = VND algorithms",
         x=NULL, y=NULL) +
    theme_bw(base_size=10) +
    theme(axis.text.x=element_text(angle=40, hjust=1, size=9),
          axis.text.y=element_text(size=9),
          panel.grid=element_blank(),
          plot.subtitle=element_text(size=8.5, color="gray40"))

ggsave("results/figures/heatmap_pvalues_zoom.png", p_heatmap_zoom,
       width=9, height=8, dpi=150)
cat("Saved: results/figures/heatmap_pvalues_zoom.png\n")

cat("\n=======================================================\n")
cat(" All done.\n")
cat("=======================================================\n")
