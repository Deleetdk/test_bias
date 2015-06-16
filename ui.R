
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Test bias"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("A_mean",
                  "Mean score of the blue group's predictor variable",
                  min = 70,
                  max = 130,
                  value = 100),
      sliderInput("A_cor",
                  "Predictive validity (correlation) of the blue group's predictor variable",
                  min = 0,
                  max = 1,
                  value = .5),
      sliderInput("B_mean",
                  "Mean score of the red group's predictor variable",
                  min = 70,
                  max = 130,
                  value = 85),
      sliderInput("B_cor",
                  "Predictive validity (correlation) of the red group's predictor variable",
                  min = 0,
                  max = 1,
                  value = .5),
      sliderInput("A_intercept",
                  "Intercept bias in favor of the blue group",
                  min = -50,
                  max = 50,
                  value = 0),
      checkboxInput("force", "Force equal criteria means when adjusting slopes.")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      HTML("<p>The figure shows a scatter plot with test scores on the x-axis and criteria scores on the y-axis. There are two groups, blue and red. The lines show the regression lines for each group in their own colors. The blank line is the regression line for both groups together.</p>",
           "<p>A test with <em>perfect reliability</em> is a biased predictor with regards to two groups if the regression equation differs in slope, intercept or standard error of the prediction for a criteria variable. This means that if two persons, one from each group, have identical test scores they are not necessary expected to have the same criteria scores.</p>",
           "<p>The default settings show two groups that differ 15 points in their mean test scores and 5 points on the criteria variable, but the test is not biased because there is no difference (aside from small sampling error) in the slope, intercept or standard error of the prediction. Thus, a test can be unbiased despite groups differing in their mean scores on the test and on the criteria variable.</p>",
           "<p>To see what test bias looks like, change the predictive validity for red to .2. Notice how this changes the slope and standard error of the prediction. Test scores are now less related to criteria scores within the red group, but the red group does attain lower criteria scores than the blue group.</p>",
           "<p>Set the predictive validity of red back to .5 and change the intercept bias to 5. Notice how the lines are parallel but move away from each other. You see a scenario where one group performs 15 points better on the test, but performs no better on the real tasks.</p>",
           "<p>Set the validity for red to 0 and the intercept bias to 33 (or click the checkbox below). You see a scenario where test scores have no relationship at all to the criteria for red, but that the groups actually perform the same on the criteria.</p>",
           "<p>Try playing around with the sliders to get an idea of how test bias works.</p>"),
      plotOutput("plot"),
      DT::dataTableOutput("DT")
    )
  )
))
