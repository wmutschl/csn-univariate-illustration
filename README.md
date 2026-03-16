# Univariate CSN Distribution Explorer

An interactive [Shinylive](https://posit-dev.github.io/r-shinylive/) app for exploring the probability density function of the univariate **Closed Skew Normal (CSN)** distribution.

This app accompanies the paper:

> Gaygysyz Guljanov, Willi Mutschler, Mark Trede (2026).
> *Pruned Skewed Kalman Filter and Smoother: With Application to DSGE Models*.

## Features

- Adjust all five CSN parameters interactively: μ, Σ, Γ, ν, Δ
- Real-time density plot and analytical moments (mean, standard deviation, skewness)
- Option to constrain μ so that E[X] = 0
- Runs entirely in the browser via [WebR](https://docs.r-wasm.org/webr/latest/) — no R installation or server required

## Live app

The app is hosted on GitHub Pages: **[Open the app](https://wmutschl.github.io/csn-univariate-illustration/)**

## Run locally

With R and the `shiny` package installed:

```r
shiny::runApp("app.R")
```

## Rebuild the Shinylive export

To regenerate the `docs/` folder for GitHub Pages deployment:

```r
# install.packages("shinylive")
shinylive::export(appdir = ".", destdir = "docs")
```

Then serve locally to test:

```r
httpuv::runStaticServer("docs/", port = 8008)
```

## License

This project is licensed under the GNU General Public License v3.0 — see [LICENSE](LICENSE) for details.

The CSN density function is a univariate specialization of `dcsn` from the [csn](https://CRAN.R-project.org/package=csn) R package by Gonzalez-Farias, Dominguez-Molina, and Gupta, licensed under GPL-2.
