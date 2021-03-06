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

messages_match_substitution <- function(x, y, txt = "substitute") {
  x <- as.character(x)
  y <- as.character(y)
  d <- data.frame(x = x, y = y, stringsAsFactors = FALSE)
  d <- unique(d)
  d <- dplyr::arrange(d, .data$x)
  b <- !is.na(d$x) & !is.na(d$y) & d$x != d$y
  if (any(b)) {
    db <- d[b, , drop = FALSE]
    message(
      capitalize(txt), "d ",
      punctuate_strings(paste0("'", db$x, "' with '", db$y, "'"), "and"), "."
    )
  }
  b <- !is.na(d$x) & is.na(d$y)
  if (any(b)) {
    db <- d[b, , drop = FALSE]
    message(
      "Failed to ", txt, " ",
      punctuate_strings(paste0("'", db$x, "'"), "and"), "."
    )
  }
  NULL
}

all_words_in_x_in_y_one <- function(x) {
  all(strsplit(x[1], " ")[[1]] %in% strsplit(x[2], " ")[[1]])
}

all_words_in_x_in_y <- function(x, y) {
  mat <- as.matrix(data.frame(x = x, y = y))
  apply(mat, MARGIN = 1, all_words_in_x_in_y_one)
}

wqbc_substitute <- function(org, mod = org, sub, sub_mod = sub, messages) {
  org <- stringr::str_trim(org, side = "both")
  mod <- stringr::str_trim(mod, side = "both")
  sub <- stringr::str_trim(sub, side = "both")
  sub_mod <- stringr::str_trim(sub_mod, side = "both")

  orgd <- data.frame(org = org, match = tolower(mod), stringsAsFactors = FALSE)
  subd <- data.frame(sub = sub, match = tolower(sub_mod), stringsAsFactors = FALSE)

  orgd$sub <- NA_character_
  orgd$multi <- FALSE

  ## First check for exact matches:
  matches <- orgd$match %in% subd$match
  orgd$sub[matches] <- vapply(orgd$match[matches], function(x) subd$sub[subd$match == x],
                              FUN.VALUE = character(1)
  )

  ## Then for name matches
  if (!all(matches)) {
    for (i in seq_len(nrow(subd))) {
      bol <- all_words_in_x_in_y(subd$match[i], orgd$match[!matches])

      if (any(bol)) {
        if (!all(is.na(orgd$sub[!matches][bol]))) {
          orgd$multi[!matches] <- orgd$multi[!matches] | (bol & !is.na(orgd$sub[!matches]))
        }
        orgd$sub[!matches][bol] <- subd$sub[i]
      }
    }
  }

  orgd$sub[orgd$multi] <- NA_character_
  if (messages) messages_match_substitution(orgd$org, orgd$sub)
  orgd$sub
}

#' Substitute Units
#'
#' Substitutes provided unit names for recognised units.
#' Before matching all spaces and "units" or "UNITS" are removed.
#' The case is not important. Where
#' there are no matches missing values are returned.
#'
#' @param x The character vector of units to substitute.
#' @param messages A flag indicating whether to print messages.
#' @examples
#' substitute_units(c("mg/L", "MG/L", "mg /L ", "Kg/l", "gkl"), messages = TRUE)
#' @seealso \code{\link{substitute_variables}}
#' @export
substitute_units <- function(
  x, messages = getOption("wqbc.messages", default = TRUE)) {
  chkor(chk_character(x), chk_s3_class(x, "factor"))
  check_values(messages, TRUE)

  x <- as.character(x)

  y <- gsub("units", "", x, ignore.case = TRUE)
  y <- gsub(" ", "", y)
  y <- gsub("_", "", y)

  wqbc_substitute(org = x, mod = y, sub = lookup_units(), messages = messages)
}

#' Substitute Variables
#'
#' Substitutes provided variable names for recognised names. The case is not
#' important. Where
#' there are no matches missing values are returned. When strict = TRUE
#' all words in a recognised variable must be present in x but when
#' strict = FALSE (soft-deprecated) the only requirement is that the first word is present.
#' When strict = FALSE recognised variables with the same first word
#' such as "Iron Dissolved" and "Iron Total"  are excluded from matches.
#' In both cases the only requirement is that all words or just the first word
#' are present in x. The order of the words does not matter nor does the
#' presence of other words. This means that a value such as
#' "Total Fluoride Hardness" matches two recognised variables which causes an
#' error. The code also considers
#' Aluminium to be a match with Aluminum.
#'
#' @param x A character vector of variable names to substitute.
#' @param strict A flag indicating whether to require all words
#' in a recognised variable name to be present in x (strict = TRUE)
#' or only the first one (strict = FALSE) \lifecycle{soft-deprecated}.
#' @param messages A flag indicating whether to print messages.
#' @examples
#' substitute_variables(c(
#'   "ALUMINIUM SOMETHING", "ALUMINUM DISSOLVED",
#'   "dissolved aluminium", "BORON Total", "KRYPTONITE",
#'   "Total Fluoride Hardness"
#' ), messages = TRUE)
#' @seealso \code{\link{substitute_units}}
#' @export
substitute_variables <- function(
  x, strict = TRUE, messages = getOption("wqbc.messages", default = TRUE)) {

  chkor(chk_character(x), chk_s3_class(x, "factor"))
  check_values(strict, TRUE)
  check_values(messages, TRUE)

  if(!vld_true(strict)) {
    lifecycle::deprecate_soft(
      "0.3.2", "substitute_variables(strict = )"
    )
  }

  x <- as.character(x)

  # y <- gsub("Aluminum", "Aluminium", x, ignore.case = TRUE)
  y <- gsub("Total Dissolved", "Dissolved", x, ignore.case = TRUE)

  sub <- lookup_variables()
  sub_mod <- sub
  if (!strict) { # pull out first word and remove duplicates
    sub_mod <- stringr::word(sub)
    bol <- sub_mod %in% unique(sub_mod[duplicated(sub_mod)])
    sub <- sub[!bol]
    sub_mod <- sub_mod[!bol]
  }
  wqbc_substitute(org = x, mod = y, sub = sub, sub_mod = sub_mod, messages = messages)
}
