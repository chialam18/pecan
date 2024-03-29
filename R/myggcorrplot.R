#' myggcorrplot
#'
#' merge multiple dfs together, identifier must be first column, doesn't need to be same name
#' @export
myggcorrplot <- function (corr, method = c("square", "circle"), type = c("full", 
                                                                         "lower", "upper"), ggtheme = ggplot2::theme_minimal, title = "", 
                          show.legend = TRUE, legend.title = "Corr", show.diag = FALSE, 
                          colors = c("blue", "white", "red"), outline.color = "gray", 
                          hc.order = FALSE, hc.method = "complete", lab = FALSE, lab_col = "black", 
                          lab_size = 4, p.mat = NULL, sig.level = 0.05, insig = c("pch", 
                                                                                  "blank"), pch = 4, pch.col = "black", pch.cex = 5, tl.cex = 12, 
                          tl.col = "black", tl.srt = 45, lab.notsig="") 
{
  type <- match.arg(type)
  method <- match.arg(method)
  insig <- match.arg(insig)
  if (!is.matrix(corr) & !is.data.frame(corr)) 
    stop("Need a matrix or data frame!")
  corr <- as.matrix(corr)
  if (hc.order) {
    ord <- ggcorrplot:::.hc_cormat_order(corr)
    corr <- corr[ord, ord]
    if (!is.null(p.mat)) 
      p.mat <- p.mat[ord, ord]
  }
  if (type == "lower") {
    corr <- ggcorrplot:::.get_lower_tri(corr, show.diag)
    p.mat <- ggcorrplot:::.get_lower_tri(p.mat, show.diag)
  }
  else if (type == "upper") {
    corr <- ggcorrplot:::.get_upper_tri(corr, show.diag)
    p.mat <- ggcorrplot:::.get_upper_tri(p.mat, show.diag)
  }
  corr <- reshape2::melt(corr, na.rm = TRUE)
  corr$pvalue <- rep(NA, nrow(corr))
  corr$signif <- rep(NA, nrow(corr))
  if (!is.null(p.mat)) {
    p.mat <- reshape2::melt(p.mat, na.rm = TRUE)
    corr$coef <- corr$value
    corr$pvalue <- p.mat$value
    corr$signif <- as.numeric(p.mat$value <= sig.level)
    p.mat <- subset(p.mat, p.mat$value > sig.level)
    if (insig == "blank") 
      corr$value <- corr$value * corr$signif
  }
  corr$abs_corr <- abs(corr$value) * 10
  p <- ggplot2::ggplot(corr, ggplot2::aes_string("Var1", "Var2", 
                                                 fill = "value"))
  if (method == "square") 
    p <- p + ggplot2::geom_tile(color = outline.color)
  else if (method == "circle") {
    p <- p + ggplot2::geom_point(color = outline.color, shape = 21, 
                                 ggplot2::aes_string(size = "abs_corr")) + ggplot2::scale_size(range = c(4, 
                                                                                                         10)) + ggplot2::guides(size = FALSE)
  }
  p <- p + ggplot2::scale_fill_gradient2(low = colors[1], high = colors[3], 
                                         mid = colors[2], midpoint = 0, limit = c(-1, 1), space = "Lab", 
                                         name = legend.title) + ggtheme() + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = tl.srt, 
                                                                                                                               vjust = 1, size = tl.cex, hjust = 1), axis.text.y = ggplot2::element_text(size = tl.cex)) + 
    ggplot2::coord_fixed()
  label <- as.character(round(corr[, "value"], 2))
  label[label=="0"] <- lab.notsig
  if (lab)
    p <- p + ggplot2::geom_text(ggplot2::aes_string("Var1", 
                                                    "Var2", label = "label"), color = lab_col, size = lab_size)
  if (!is.null(p.mat) & insig == "pch") {
    p <- p + ggplot2::geom_point(data = p.mat, ggplot2::aes_string("Var1", 
                                                                   "Var2"), shape = pch, size = pch.cex, color = pch.col)
  }
  if (title != "") 
    p <- p + ggplot2::ggtitle(title)
  if (!show.legend) 
    p <- p + ggplot2::theme(legend.position = "none")
  p <- p + ggcorrplot:::.no_panel()
  p
}
