#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(tidyverse)
library(shiny)

# Read file of users
users <- read_csv("data/users.csv")
coffees_per_line <- 50

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    titlePanel(title=div("I", img(src="lov.png"), "coffee")),
    #img(src = "lov.png", height = 140, width = 400),
    
        tabsetPanel(
            tabPanel("Drink a coffee", 
            
                    selectInput(
                        "drinker", 
                        h3("Who is having a coffee?"), 
                        choices = users$user),
                    
                    radioButtons(
                        "coffee_length",
                        "Coffee length", 
                        choices = c("simple" = 1, "double" = 2),
                        selected = 1),
                    
                    actionButton("cheers", "Cheers"),
                    
                    br(),
                    br(),
                    
                    textOutput("credits_left")
            ),
            
            tabPanel("Buy a line",
                     selectInput(
                         "user_name_buy", 
                         h3("Who is buying lines?"), 
                         choices = users$user),
                     
                     numericInput(
                         "user_lines_buy", 
                         h3("Number of lines I want to buy"), 
                         value = 1),
                     
                     actionButton("user_buy", "Buy lines (by clicking this button…)"),
                     
            ), 
            
            tabPanel("New user",
                     textInput(
                         "new_user_name", 
                         "", 
                         value = "Enter your name"),
                     
                     numericInput(
                         "new_user_lines", 
                          h3("Number of lines I want to buy"), 
                          value = 1),
                     
                     actionButton("new_user_reg", "Register (by clicking this button…)"),
                     
                     br(),
                     br(),
                     
                     textOutput("new_user_welcome")
                     
                     
                     ), 
            

            
            tabPanel("See my credits",
                     selectInput(
                         "user_name_check", 
                         "", 
                         choices = users$user),
                     
                     actionButton("user_check", "Check my credits"),
                     
                     br(),
                     br(),
                     
                     textOutput("user_check_credits")
                     
            ), 
        )
)

server <- function(input, output) {
    ## Drink a coffee
    observeEvent(input$cheers, {
        message("cheers")
        users$credit[users$user == input$drinker] = users$credit[users$user == input$drinker] - as.numeric(input$coffee_length)
        write_csv(users, file = "data/users.csv")
        output$credits_left <- renderText(paste("You have", users$credit[users$user == input$drinker], "credits left."))
    })
    
    ## Buy lines for a registered user
    observeEvent(input$user_buy, {
        message("buy line")
        users$credit[users$user == input$user_name_buy] = users$credit[users$user == input$user_name_buy] + input$user_lines_buy * coffees_per_line
        write_csv(users, file = "data/users.csv")
    })
    
    ## Register a new user
    observeEvent(input$new_user_reg, {
        message("new user")
        new_user <- tibble(user = input$new_user_name, credit = input$new_user_lines * coffees_per_line)
        users <- users %>% 
            bind_rows(new_user)
        write_csv(users, file = "data/users.csv")
        output$new_user_welcome <- renderText(paste0("Welcome ", input$new_user_name, "!"))
    })
    
    ## Check my credits
    observeEvent(input$user_check, {
        message("check")
        credits <- users$credit[users$user == input$user_name_check]
        output$user_check_credits <- renderText(paste0(
            "Hi ",
            input$user_name_check,
            ", you have ", 
            credits, 
            " credits left."))
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
