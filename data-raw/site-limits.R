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

## Process the wq limits (guidelines) in limits.csv for inclusion in the
## package. See limits.Rmd for details

library(wqbc)
library(dplyr)
library(magrittr)
library(devtools)
library(chk)

rm(list = ls())

site_limits <- read.csv("data-raw/site-limits.csv", na.strings = c("NA", ""), stringsAsFactors = FALSE)

### fix Barium units
site_limits$Units[site_limits$Variable == "Barium Total"] <- "mg/L"

site_limits$UpperLimit %<>% as.character()
site_limits$Statistic <- "mean"
wqbc:::check_limits(site_limits)

chk_join(limits, wqbc::codes, by = c("Variable", "Units"))

use_data(site_limits, overwrite = TRUE, compress = "xz")
