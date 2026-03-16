library(shiny)

# Univariate specialization of csn::dcsn (which uses pmvnorm/dmvnorm from mvtnorm).
# Original source: csn package by Gonzalez-Farias, Dominguez-Molina, Gupta (GPL-2).
# f(x) = dmvnorm(x; mu, sigma) * pmvnorm(upper=gamma*(x-mu); nu, delta)
#         / pmvnorm(upper=0; nu, delta + gamma*sigma*gamma)
dcsn <- function(x, mu, sigma, gamma, nu, delta) {
  f1 <- pnorm(0, mean = nu, sd = sqrt(delta + gamma^2 * sigma))
  f2 <- pnorm(gamma * (x - mu), mean = nu, sd = sqrt(delta))
  f3 <- dnorm(x, mean = mu, sd = sqrt(sigma))
  f2 * f3 / f1
}

csn_moments <- function(mu, sigma, gamma, nu, delta) {
  S <- delta + gamma^2 * sigma
  kappa <- nu / sqrt(S)
  beta <- (gamma * sigma) / sqrt(S)
  r0 <- dnorm(-kappa) / pnorm(-kappa)
  k1 <- mu + beta * r0
  k2 <- sigma + beta^2 * (kappa * r0 - r0^2)
  k3 <- beta^3 * (r0 * (kappa^2 - 1) - 3 * kappa * r0^2 + 2 * r0^3)
  list(mean = k1, var = k2, skewness = k3 / (k2^(3 / 2)))
}

ui <- fluidPage(
  tags$head(
    tags$script("Shiny.addCustomMessageHandler('toggleMu', function(enabled) {
      var el = document.getElementById('mu');
      if (el) { el.disabled = !enabled; el.style.backgroundColor = enabled ? '' : '#e9ecef'; }
    });")
  ),
  titlePanel("Univariate CSN Distribution Explorer"),
  sidebarLayout(
    sidebarPanel(
      numericInput("mu", "\u03bc", value = 0, step = 0.1),
      numericInput("sigma", "\u03a3", value = 1, min = 0.01, step = 0.1),
      numericInput("gamma", "\u0393", value = 5, step = 0.5),
      numericInput("nu", "\u03bd", value = 0, step = 0.5),
      numericInput("delta", "\u0394", value = 1, min = 0.001, step = 0.1),
      checkboxInput("fix_mean", "Set \u03bc so that E[X] = 0", value = FALSE),
      hr(),
      numericInput("x_min", "x min", value = -3.6, step = 0.5),
      numericInput("x_max", "x max", value = 3.6, step = 0.5)
    ),
    mainPanel(
      plotOutput("density_plot", height = "500px"),
      h4(textOutput("moments_text"))
    )
  )
)

server <- function(input, output, session) {
  observe({
    if (isTRUE(input$fix_mean)) {
      req(input$sigma > 0, input$delta > 0)
      m <- csn_moments(0, input$sigma, input$gamma, input$nu, input$delta)
      updateNumericInput(session, "mu", value = round(-m$mean, 6))
    }
    session$sendCustomMessage("toggleMu", !isTRUE(input$fix_mean))
  })

  observe({
    session$onFlushed(function() {
      session$sendCustomMessage("toggleMu", !isTRUE(input$fix_mean))
    }, once = TRUE)
  })

  params <- reactive({
    req(input$sigma > 0, input$delta > 0)
    mu <- input$mu
    if (isTRUE(input$fix_mean)) {
      m <- csn_moments(0, input$sigma, input$gamma, input$nu, input$delta)
      mu <- -m$mean
    }
    list(mu = mu, sigma = input$sigma, gamma = input$gamma,
         nu = input$nu, delta = input$delta)
  })

  output$density_plot <- renderPlot({
    p <- params()
    x <- seq(input$x_min, input$x_max, length.out = 400)
    y <- dcsn(x, p$mu, p$sigma, p$gamma, p$nu, p$delta)
    plot(x, y, type = "l", lwd = 2.5, col = "black",
         xlab = "x", ylab = "Density",
         main = sprintf("CSN(\u03bc=%.2f, \u03a3=%.2f, \u0393=%.2f, \u03bd=%.2f, \u0394=%.2f)",
                        p$mu, p$sigma, p$gamma, p$nu, p$delta))
  })

  output$moments_text <- renderText({
    p <- params()
    m <- csn_moments(p$mu, p$sigma, p$gamma, p$nu, p$delta)
    sprintf("E[X] = %.4f,   Sd[X] = %.4f,   Skew[X] = %.4f",
            m$mean, sqrt(m$var), m$skewness)
  })
}

shinyApp(ui, server)
