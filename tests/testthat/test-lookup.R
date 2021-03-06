# Copyright 2015 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

context("lookup")

test_that("lookup_units", {
  opts <- options()
  on.exit(options(opts))
  options(wqbc.messages = FALSE)

  expect_is(lookup_units(), "character")
})

test_that("lookup_use", {
  opts <- options()
  on.exit(options(opts))
  options(wqbc.messages = FALSE)

  expect_is(lookup_use(), "character")
})

test_that("lookup_codes lookup_variables", {
  opts <- options()
  on.exit(options(opts))
  options(wqbc.messages = FALSE)

  expect_identical(
    lookup_codes(lookup_variables(c(lookup_codes(), NA, "KRYP"))),
    c(lookup_codes(), NA, NA)
  )
  expect_identical(
    lookup_variables(lookup_codes(c(lookup_variables(), NA, "Kryptonite"))),
    c(lookup_variables(), NA, NA)
  )
})
test_that("lookup_limits", {
  x <- lookup_limits()
  expect_is(x, "data.frame") # check if lookup_limits is a data frame
  expect_equal(ncol(x), 3) # check if loopup_limits has 3 columns


  y <- lookup_limits(term = "long")
  expect_identical(x, y) # check if lookup_limits() and lookup_limits(term="long")
  expect_equal(x$UpperLimit[x$Variable == "Aldicarb Total"], 1) # check if Aldicarb Total has an upperlimits with 1
  expect_equal(as.character(x$Units[x$Variable == "Aldicarb Total"]), "ug/L") # check if Aldicarb Total has unit ug/L

  z <- lookup_limits(term = "long", ph = 9) # EMS_0004
  expect_equal(z$UpperLimit[z$Variable == "Aluminum Dissolved"], 0.050) # check if Aluminum Dissolved with ph=9 and long term equals to 0.05 upperlimits

  m <- lookup_limits(term = "long", ph = 6.5) # EMS_0004
  expect_equal(z$UpperLimit[z$Variable == "Aluminum Dissolved"], 0.050) # check if Aluminum Dissolved with ph=9 and long term equals to 0.05 upperlimits

  n <- lookup_limits(term = "long", ph = 5) # EMS_0004
  expect_equal(as.character(n$Units[n$Variable == "Aluminum Dissolved"]), "mg/L") # check units with different conditions
  expect_equal(n$UpperLimit[n$Variable == "Aluminum Dissolved"], 0.006839778)
  expect_equal(as.character(n$UpperLimit[n$Variable == "Cadmium Dissolved"]), as.character(NA)) # upperlimit with NA
  expect_equal(as.character(n$UpperLimit[n$Variable == "Sulphate Total"]), as.character(NA))

  q <- lookup_limits(term = "short")
  expect_equal(as.character(q$UpperLimit[q$Variable == "Aluminum Dissolved"]), as.character(NA))
  expect_equal(q$UpperLimit[q$Variable == "Polychlorinated Biphenyls (PCB) Total"], 0.10)
  expect_equal(as.character(q$Units[q$Variable == "Polychlorinated Biphenyls (PCB) Total"]), "ng/L")

  p <- lookup_limits(term = "short", ph = 9) # EMS_0004
  expect_equal(as.character(p$Units[p$Variable == "Aluminum Dissolved"]), "mg/L")
  expect_equal(as.character(p$Units[p$Variable == "Lead Total"]), "ug/L")
  expect_equal(as.character(p$Units[p$Variable == "Ethinylestradiol 17a Total"]), "ng/L")
  expect_equal(p$UpperLimit[p$Variable == "Aluminum Dissolved"], 0.10)
  expect_equal(p$UpperLimit[p$Variable == "Cobalt Total"], 110.00)
  expect_equal(as.character(p$UpperLimit[p$Variable == "Lead Total"]), as.character(NA))
  expect_equal(as.character(p$UpperLimit[p$Variable == "Manganese Total"]), as.character(NA))
  expect_equal(as.character(p$UpperLimit[p$Variable == "Zinc Total"]), as.character(NA)) # NA upperlimits


  i <- lookup_limits(term = "short", ph = 6.5) # EMS_0004
  expect_equal(as.character(i$Units[i$Variable == "Aluminum Dissolved"]), "mg/L")
  expect_equal(as.character(i$Units[i$Variable == "Cyanide weak acid dissociable Total"]), "ug/L")
  expect_equal(as.character(i$Units[i$Variable == "Polychlorinated Biphenyls (PCB) Total"]), "ng/L")
  expect_equal(i$UpperLimit[i$Variable == "Aluminum Dissolved"], 0.1)
  expect_equal(as.character(i$UpperLimit[i$Variable == "Silver Total"]), as.character(NA))
  expect_equal(as.character(i$UpperLimit[i$Variable == "Zinc Total"]), as.character(NA))

  k <- lookup_limits(term = "long", hardness = 1.3) # out of bound
  # exp(0.736 * log(EMS_0107) - 4.943)
  expect_equal(as.character(k$Units[k$Variable == "Cadmium Dissolved"]), "ug/L")
  expect_equal(as.character(k$UpperLimit[k$Variable == "Cadmium Dissolved"]), as.character(NA))


  a <- lookup_limits(term = "long", hardness = 3.41) # boundary case for Cadmium Dissolved
  # exp(0.736 * log(EMS_0107) - 4.943)
  expect_equal(as.character(a$Units[a$Variable == "Cadmium Dissolved"]), "ug/L")
  expect_equal(a$UpperLimit[a$Variable == "Cadmium Dissolved"], 0.01759501)


  b <- lookup_limits(term = "long", hardness = 100)
  expect_equal(as.character(b$Units[b$Variable == "Cadmium Dissolved"]), "ug/L")
  # exp(0.736 * log(EMS_0107) - 4.943)
  expect_equal(b$UpperLimit[b$Variable == "Cadmium Dissolved"], 0.211486366)


  c <- lookup_limits(term = "long", hardness = 285) # boundary case for Cadmium Dissolved
  # exp(0.736 * log(EMS_0107) - 4.943)
  expect_equal(as.character(c$Units[c$Variable == "Cadmium Dissolved"]), "ug/L")
  expect_equal(c$UpperLimit[c$Variable == "Cadmium Dissolved"], 0.457138914)


  d <- lookup_limits(term = "long", hardness = 300) # out of bound
  # exp(0.736 * log(EMS_0107) - 4.943)
  expect_equal(as.character(d$Units[d$Variable == "Cadmium Dissolved"]), "ug/L")
  expect_equal(as.character(d$UpperLimit[d$Variable == "Cadmium Dissolved"]), as.character(NA))

  Cadmium <- lookup_limits(term = "short", hardness = 3) # out of bound
  expect_equal(as.character(Cadmium$Units[Cadmium$Variable == "Cadmium Dissolved"]), "ug/L")
  expect_equal(as.character(Cadmium$UpperLimit[Cadmium$Variable == "Cadmium Dissolved"]), as.character(NA))

  Cadmium_lowerboundary <- lookup_limits(term = "short", hardness = 7.1) # boundary for Cadmium Dissolved
  # exp(1.03 * log(EMS_0107) - 5.274)
  expect_equal(as.character(Cadmium_lowerboundary$Units[Cadmium_lowerboundary$Variable == "Cadmium Dissolved"]), "ug/L")
  expect_equal(Cadmium_lowerboundary$UpperLimit[Cadmium_lowerboundary$Variable == "Cadmium Dissolved"], 0.03857687, tolerance = 10^(-7))

  Cadmium_range <- lookup_limits(term = "short", hardness = 300)
  # exp(1.03 * log(EMS_0107) - 5.274)
  expect_equal(as.character(Cadmium_range$Units[Cadmium_range$Variable == "Cadmium Dissolved"]), "ug/L")
  expect_equal(Cadmium_range$UpperLimit[Cadmium_range$Variable == "Cadmium Dissolved"], 1.823752057)



  Cadmium_upperbound <- lookup_limits(term = "short", hardness = 455) # boundary for Cadmium Dissolved
  # exp(1.03 * log(EMS_0107) - 5.274)
  expect_equal(as.character(Cadmium_upperbound$Units[Cadmium_upperbound$Variable == "Cadmium Dissolved"]), "ug/L")
  expect_equal(Cadmium_upperbound$UpperLimit[Cadmium_upperbound$Variable == "Cadmium Dissolved"], 2.8008035)

  FluorideTotal <- lookup_limits(term = "short", hardness = -1) # negative hardness total
  expect_equal(as.character(FluorideTotal$Units[FluorideTotal$Variable == "Fluoride Total"]), "mg/L")
  expect_equal(as.character(FluorideTotal$UpperLimit[FluorideTotal$Variable == "Fluoride Total"]), as.character(NA))

  FluorideTotal_inrange <- lookup_limits(term = "short", hardness = 10) # boundary
  expect_equal(as.character(FluorideTotal_inrange$Units[FluorideTotal_inrange$Variable == "Fluoride Total"]), "mg/L")
  expect_equal(FluorideTotal_inrange$UpperLimit[FluorideTotal_inrange$Variable == "Fluoride Total"], 0.4)

  FluorideTotal_morethan10 <- lookup_limits(term = "short", hardness = 30)
  # (92.57 * log(EMS_0107, base = 10) - 51.73) * 0.01
  expect_equal(as.character(FluorideTotal_morethan10$Units[FluorideTotal_morethan10$Variable == "Fluoride Total"]), "mg/L")
  expect_equal(FluorideTotal_morethan10$UpperLimit[FluorideTotal_morethan10$Variable == "Fluoride Total"], 0.850071145)

  Lead_outofbound <- lookup_limits(term = "long", hardness = 3)
  # NA
  expect_equal(as.character(Lead_outofbound$Units[Lead_outofbound$Variable == "Lead Total"]), "ug/L")
  expect_equal(as.character(Lead_outofbound$UpperLimit[Lead_outofbound$Variable == "Lead Total"]), as.character(NA))

  Lead <- lookup_limits(term = "long", hardness = 9)
  # exp(1.273 * log(EMS_0107) - 4.704) + 3.31
  expect_equal(as.character(Lead$Units[Lead$Variable == "Lead Total"]), "ug/L")
  expect_equal(Lead$UpperLimit[Lead$Variable == "Lead Total"], 3.45853523)

  Lead_short <- lookup_limits(term = "short", hardness = 3)
  # 3
  expect_equal(as.character(Lead_short$Units[Lead_short$Variable == "Lead Total"]), "ug/L")
  expect_equal(Lead_short$UpperLimit[Lead_short$Variable == "Lead Total"], 3)

  Lead_morethan8 <- lookup_limits(term = "short", hardness = 10)
  #  exp(1.273 * log(EMS_0107) - 1.460)
  expect_equal(as.character(Lead_morethan8$Units[Lead_morethan8$Variable == "Lead Total"]), "ug/L")
  expect_equal(Lead_morethan8$UpperLimit[Lead_morethan8$Variable == "Lead Total"], 4.354417397)
})
