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
