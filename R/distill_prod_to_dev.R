distill_prod_to_dev <- function(p) {
f <- file.path('_site.yml')
x <- xfun::read_utf8(f)
contents <-paste0(stringr::str_sub(x[5],1,-2),"/dev\"")
output <- c(x[1:4],contents,x[(6):length(x)])
xfun::write_utf8(output,f)
}

distill_dev_to_prod <- function() {
  f <- file.path('_site.yml')
  x <- xfun::read_utf8(f)
  contents <-stringr::str_replace(x[5],"/dev\"$","\"")
  output <- c(x[1:4],contents,x[(6):length(x)])
  xfun::write_utf8(output,f)
}

