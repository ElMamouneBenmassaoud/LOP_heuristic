# Statistical analysis — LOP Iterative Improvement
# Exercise 1.1 and 1.2 — INFO-H-413 Heuristic Optimization

data <- read.table("results/raw_data.txt", header=TRUE, sep="\t")

# Create a readable label for each algorithm configuration
data$label <- paste(data$algo, data$pivot, data$neighborhood, data$init, sep="_")

# ─────────────────────────────────────────────────────────────────
# 1. SUMMARY TABLE — average RPD and total time per algorithm
# ─────────────────────────────────────────────────────────────────
cat("Average RPD and total time per algorithm:\n")

summary_table <- aggregate(
    cbind(rpd, time_sec) ~ label,
    data = data,
    FUN = function(x) c(mean=mean(x), sd=sd(x), total=sum(x))
)

# Flatten the result
avg_rpd   <- tapply(data$rpd,      data$label, mean)
sd_rpd    <- tapply(data$rpd,      data$label, sd)
total_time <- tapply(data$time_sec, data$label, sum)

result <- data.frame(
    algorithm  = names(avg_rpd),
    avg_rpd    = round(avg_rpd,    4),
    sd_rpd     = round(sd_rpd,     4),
    total_time = round(total_time, 4)
)
result <- result[order(result$avg_rpd), ]
rownames(result) <- NULL
print(result)

# ─────────────────────────────────────────────────────────────────
# 2. WILCOXON TESTS — Exercise 1.1
#    Compare algorithms pairwise on their RPD vectors
#    (one RPD value per instance = 78 paired observations)
# ─────────────────────────────────────────────────────────────────
cat("\nWilcoxon tests — Exercise 1.1\n")

get_rpd <- function(piv, nei, ini) {
    sub <- data[data$algo=="II" & data$pivot==piv &
                data$neighborhood==nei & data$init==ini, ]
    sub[order(sub$instance), "rpd"]
}

wilcox_test <- function(label_a, rpd_a, label_b, rpd_b) {
    wt  <- wilcox.test(rpd_a, rpd_b, paired=TRUE, exact=FALSE)
    tt  <- t.test(rpd_a, rpd_b, paired=TRUE)
    sig <- ifelse(wt$p.value < 0.05, "YES ***", "no")
    cat(sprintf("  %-40s vs %-40s | wilcox p=%.4f | t-test p=%.4f | sig: %s\n",
                label_a, label_b, wt$p.value, tt$p.value, sig))
}

cat("\npivoting rule (first vs best)\n")
for (nei in c("transpose","exchange","insert")) {
    for (ini in c("random","cw")) {
        a <- get_rpd("first", nei, ini)
        b <- get_rpd("best",  nei, ini)
        wilcox_test(paste("first",nei,ini), a, paste("best",nei,ini), b)
    }
}

cat("\nneighborhood comparison\n")
t_r <- get_rpd("first","transpose","random")
e_r <- get_rpd("first","exchange", "random")
i_r <- get_rpd("first","insert",   "random")
wilcox_test("first_transpose_random", t_r, "first_exchange_random", e_r)
wilcox_test("first_transpose_random", t_r, "first_insert_random",   i_r)
wilcox_test("first_exchange_random",  e_r, "first_insert_random",   i_r)

cat("\ninitialization (random vs CW)\n")
for (piv in c("first","best")) {
    for (nei in c("transpose","exchange","insert")) {
        a <- get_rpd(piv, nei, "random")
        b <- get_rpd(piv, nei, "cw")
        wilcox_test(paste(piv,nei,"random"), a, paste(piv,nei,"cw"), b)
    }
}

# ─────────────────────────────────────────────────────────────────
# 3. WILCOXON TESTS — Exercise 1.2
#    Compare VND1 vs VND2, and each VND vs best II (insert+cw)
# ─────────────────────────────────────────────────────────────────
cat("\nWilcoxon tests — Exercise 1.2 (VND)\n")

get_vnd_rpd <- function(vnd) {
    sub <- data[data$algo=="VND" & data$pivot==vnd, ]
    sub[order(sub$instance), "rpd"]
}

vnd1 <- get_vnd_rpd("vnd1")
vnd2 <- get_vnd_rpd("vnd2")
best_ii <- get_rpd("first","insert","cw")   # best II from exercise 1.1

cat("\nVND1 vs VND2\n")
wilcox_test("VND1_cw", vnd1, "VND2_cw", vnd2)

cat("\nVND vs best II\n")
wilcox_test("VND1_cw", vnd1, "first_insert_cw", best_ii)
wilcox_test("VND2_cw", vnd2, "first_insert_cw", best_ii)

cat("\nDone.\n")

# ─────────────────────────────────────────────────────────────────
# 4. FIGURES
# ─────────────────────────────────────────────────────────────────
library(ggplot2)
library(ggrepel)
library(patchwork)
library(scales)

dir.create("results/figures", showWarnings=FALSE)

# Short readable labels for plots
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

ordered_labels <- result$algorithm
short_map      <- unique(data[, c("label","short_label")])
ordered_short  <- short_map$short_label[match(ordered_labels, short_map$label)]

data$short_label <- factor(data$short_label, levels=ordered_short)

data$group <- with(data, ifelse(algo=="VND", "VND",
                   ifelse(neighborhood=="transpose", "Transpose",
                   ifelse(neighborhood=="exchange",  "Exchange", "Insert"))))
data$group <- factor(data$group, levels=c("VND","Insert","Exchange","Transpose"))

group_colors <- c("VND"="#2196F3", "Insert"="#4CAF50",
                  "Exchange"="#FF9800", "Transpose"="#F44336")

result_plot <- data.frame(
    short_label = factor(ordered_short, levels=ordered_short),
    avg_rpd     = result$avg_rpd,
    sd_rpd      = result$sd_rpd,
    total_time  = result$total_time,
    group       = with(result, ifelse(grepl("VND", algorithm), "VND",
                        ifelse(grepl("insert", algorithm), "Insert",
                        ifelse(grepl("exchange", algorithm), "Exchange", "Transpose"))))
)
result_plot$group <- factor(result_plot$group, levels=c("VND","Insert","Exchange","Transpose"))

# Barplot — all 14 algorithms
p_bar_full <- ggplot(result_plot, aes(x=short_label, y=avg_rpd, fill=group)) +
    geom_bar(stat="identity", width=0.7) +
    geom_errorbar(aes(ymin=avg_rpd-sd_rpd, ymax=avg_rpd+sd_rpd),
                  width=0.25, linewidth=0.5) +
    geom_text(aes(label=sprintf("%.2f%%", avg_rpd)), vjust=-0.8, size=2.8) +
    scale_fill_manual(values=group_colors, name="Neighborhood") +
    labs(title="Average RPD: all algorithms (lower is better)", x=NULL, y="Average RPD (%)") +
    theme_bw(base_size=11) +
    theme(axis.text.x=element_text(angle=35, hjust=1), legend.position="right")

ggsave("results/figures/barplot_avg_rpd_full.png", p_bar_full, width=12, height=5, dpi=150)

# Barplot — zoom (VND + Insert + Exchange only)
result_zoom <- result_plot[1:10, ]
p_bar_zoom <- ggplot(result_zoom, aes(x=short_label, y=avg_rpd, fill=group)) +
    geom_bar(stat="identity", width=0.7) +
    geom_errorbar(aes(ymin=avg_rpd-sd_rpd, ymax=avg_rpd+sd_rpd),
                  width=0.25, linewidth=0.5) +
    geom_text(aes(label=sprintf("%.2f%%", avg_rpd)), vjust=-0.8, size=3.2) +
    scale_fill_manual(values=group_colors, name="Neighborhood") +
    labs(title="Average RPD: VND, Insert, Exchange (lower is better)", x=NULL, y="Average RPD (%)") +
    theme_bw(base_size=11) +
    theme(axis.text.x=element_text(angle=35, hjust=1), legend.position="right")

ggsave("results/figures/barplot_avg_rpd_zoom.png", p_bar_zoom, width=10, height=5, dpi=150)

# Boxplot — two panels
data_good <- data[data$group %in% c("VND","Insert","Exchange"), ]
data_good$short_label <- droplevels(data_good$short_label)
data_tra  <- data[data$group == "Transpose", ]
data_tra$short_label  <- droplevels(data_tra$short_label)

p_panel_a <- ggplot(data_good, aes(x=short_label, y=rpd, fill=group)) +
    geom_boxplot(outlier.size=1.5, linewidth=0.4) +
    scale_fill_manual(values=group_colors, name="Neighborhood") +
    geom_hline(yintercept=0, linetype="dashed", color="red", linewidth=0.5) +
    labs(title="A: VND, Insert, Exchange", x=NULL, y="RPD (%)") +
    theme_bw(base_size=10) +
    theme(axis.text.x=element_text(angle=40, hjust=1), legend.position="none")

p_panel_b <- ggplot(data_tra, aes(x=short_label, y=rpd, fill=group)) +
    geom_boxplot(outlier.size=1.5, linewidth=0.4) +
    scale_fill_manual(values=group_colors, name="Neighborhood") +
    labs(title="B: Transpose", x=NULL, y="RPD (%)") +
    theme_bw(base_size=10) +
    theme(axis.text.x=element_text(angle=40, hjust=1), legend.position="none")

p_combined <- p_panel_a + p_panel_b +
    plot_layout(widths=c(3,1)) +
    plot_annotation(
        title    = "RPD distribution per algorithm (all 14 configurations)",
        subtitle = "Panel A: competitive algorithms (scale 0-6%) | Panel B: Transpose (scale 15-45%)",
        theme    = theme(plot.title=element_text(size=12, face="bold"),
                         plot.subtitle=element_text(size=9, color="gray40"))
    )
ggsave("results/figures/boxplot_rpd_full.png", p_combined, width=13, height=5, dpi=150)

# RPD vs Time scatter
p_tradeoff <- ggplot(result_plot, aes(x=total_time, y=avg_rpd, color=group, label=short_label)) +
    geom_point(size=3) +
    geom_text_repel(size=3, max.overlaps=20, box.padding=0.5, point.padding=0.3) +
    scale_color_manual(values=group_colors, name="Neighborhood") +
    labs(title="Solution quality vs. Computation time trade-off",
         x="Total computation time (s)", y="Average RPD (%)") +
    theme_bw(base_size=11)

ggsave("results/figures/rpd_vs_time.png", p_tradeoff, width=10, height=6, dpi=150)

# Heatmap pairwise Wilcoxon p-values
all_labels <- ordered_short
all_rpds   <- lapply(ordered_labels, function(lbl) {
    sub <- data[data$label == lbl, ]
    sub[order(sub$instance), "rpd"]
})
names(all_rpds) <- all_labels

n    <- length(all_labels)
pmat <- matrix(NA, nrow=n, ncol=n, dimnames=list(all_labels, all_labels))
for (i in 1:n) {
    for (j in 1:n) {
        if (i == j) { pmat[i,j] <- 1 }
        else if (i < j) {
            p <- wilcox.test(all_rpds[[i]], all_rpds[[j]], paired=TRUE, exact=FALSE)$p.value
            pmat[i,j] <- p; pmat[j,i] <- p
        }
    }
}

pmat_df <- as.data.frame(as.table(pmat))
colnames(pmat_df) <- c("algo_a","algo_b","p_value")
pmat_df$algo_a <- factor(pmat_df$algo_a, levels=all_labels)
pmat_df$algo_b <- factor(pmat_df$algo_b, levels=rev(all_labels))
pmat_df$label  <- ifelse(pmat_df$algo_a == pmat_df$algo_b, "",
                         ifelse(pmat_df$p_value < 0.001, "<0.001",
                                sprintf("%.3f", pmat_df$p_value)))

p_heatmap <- ggplot(pmat_df, aes(x=algo_a, y=algo_b, fill=p_value)) +
    geom_tile(color="white", linewidth=0.5) +
    geom_text(aes(label=label), size=2.2, color="black") +
    scale_fill_gradientn(
        colors = c("#d73027","#f46d43","#fdae61","#ffffbf","#a6d96a","#1a9641"),
        values = rescale(c(0, 0.01, 0.05, 0.1, 0.5, 1)),
        limits = c(0, 1), name = "p-value",
        guide  = guide_colorbar(barwidth=1, barheight=8)
    ) +
    labs(title="Pairwise Wilcoxon signed-rank test: p-values",
         subtitle="Red = significant difference (p < 0.05) | Green = no significant difference",
         x=NULL, y=NULL) +
    theme_bw(base_size=9) +
    theme(axis.text.x=element_text(angle=45, hjust=1), panel.grid=element_blank())

ggsave("results/figures/heatmap_pvalues.png", p_heatmap, width=11, height=9, dpi=150)

cat("Figures saved to results/figures/\n")
