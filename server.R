
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(ggplot2)
library(MASS)
library(stringr)

#helper function
get_error_beta = function(cor) {
  #proportion of variance of predictor
  cor_sq = cor^2
  #proportion of var of error
  e_sq = 1 - cor_sq
  #error beta
  e = sqrt(e_sq)
  return(e)
}

#settings
n = 10000
Y_mean_adjust = 20
Y_SD = 10
X_SD = 15

shinyServer(function(input, output) {
  
  reac_d = reactive({
    #A
    A_error_beta = get_error_beta(input$A_cor)
    A_slope = input$A_cor * Y_SD/X_SD
    
    #generate
    A_X = matrix(rnorm(n))
    A_Y = matrix(A_X * input$A_cor + rnorm(n) * A_error_beta)
    
    #rescale
    A_X = A_X * X_SD + input$A_mean
    A_Y = A_Y * Y_SD + (A_slope * input$A_mean) + Y_mean_adjust
    
    #B
    B_error_beta = get_error_beta(input$B_cor)
    B_slope = input$B_cor * Y_SD/X_SD
    
    #generate
    B_X = matrix(rnorm(n))
    B_Y = matrix(B_X * input$B_cor + rnorm(n) * B_error_beta)
    
    #rescale
    B_X = B_X * X_SD + input$B_mean
    B_Y = B_Y * Y_SD + (B_slope * input$B_mean) + Y_mean_adjust
    
    #force equal means on criteria with unequal slopes?
    if (input$force) {
      A_Y = A_Y - (A_slope * input$A_mean)
      B_Y = B_Y - (B_slope * input$B_mean)
    }
    
    #intercept
    A_Y = A_Y - input$A_intercept
    
    #stack
    d = data.frame(rbind(A_X, B_X), rbind(A_Y, B_Y))
    
    #colnames and group
    colnames(d) = c("X", "Y")
    d$group = c(rep("A", n), rep("B", n))
    
    return(d)
  })

  output$plot <- renderPlot({
    #fetch data
    d = reac_d()
    
    #plot
    ggplot(d, aes(X, Y, color = group)) +
      geom_point(alpha = .5) +
      geom_smooth(method = lm, fullrange = T, se = F, size = 1, linetype = "dashed") +
      xlab("Test score") + ylab("Criteria score") +
      scale_color_manual(values = c("#4646ff", "#ff4646"), #, #change colors
                      name = "Group", #change legend title
                      labels = c("Blue", "Red")) + #change labels 
      xlim(0, NA) +
      geom_smooth(aes(color = NA), method = "lm", se = F, linetype = "dotted", color = "black",
                  fullrange = T, size = 1)
  })

  output$DT = DT::renderDataTable({
    #fetch data
    d = reac_d()
    d_A = d[d$group == "A", ]
    d_B = d[d$group == "B", ]
    
    #fits
    A_fit = lm(Y ~ X, d_A)
    B_fit = lm(Y ~ X, d_B)
    
    #prediction error
    A_SEE = sd(predict(A_fit) - d_A$Y)
    B_SEE = sd(predict(B_fit) - d_B$Y)
    
    #cors
    A_r = by(d[1:2], d$group, cor)[[1]][1, 2]
    B_r = by(d[1:2], d$group, cor)[[2]][1, 2]
    
    d2 = as.data.frame(t(data.frame(c(A_fit$coef[1], B_fit$coef[1]),
                    c(A_fit$coef[2], B_fit$coef[2]),
                    c(A_r, B_r),
                    c(A_SEE, B_SEE),
                    c(mean(d_A$X), mean(d_B$X)),
                    c(sd(d_A$X), sd(d_B$X)),
                    c(mean(d_A$Y), mean(d_B$Y)),
                    c(sd(d_A$Y), sd(d_B$Y)))))
    rownames(d2) = c("Intercept", 
                     "Slope", 
                     "Correlation", 
                     "Prediction error of the estimate",
                     "Mean test score",
                     "Standard deviation of test score",
                     "Mean criteria score",
                     "Standard deviation of criteria score")
    d2$diference = d2[, 1] - d2[, 2]
    colnames(d2) = c("Blue", "Red", "Difference in favor of blue")
    d2 = round(d2, 3)
    
    DT::datatable(d2, options = list(searching = F,
                                     ordering = F,
                                     paging = F,
                                     info = F))
  })

})
