library(tidyverse)
library(lubridate)
library(edwr)

dir_raw <- "data/raw/dka"
dir_external <- "data/external/dka"
tz <- "US/Central"

if (!dir.exists(dir_raw)) dir.create(dir_raw)
if (!dir.exists(dir_external)) dir.create(dir_external)

# run MBO query
#   * Patients - by ICD
#       - Admit date: 7/1/2017 - 5/31/2017
#       - Diagnosis Code: E10.10;E11.10;E11.00
#       - Diagnosis Type: FINAL;BILLING

pts <- read_data(dir_raw, "patients", FALSE) %>%
    as.patients()

mbo_id <- concat_encounters(pts$millennium.id) 

# run MBO query
#   * Visit Data

visits <- read_data(dir_raw, "visits", FALSE) %>%
    as.visits() %>%
    filter(
        admit.type == "Emergency",
        admit.datetime >= mdy("7/1/2017", tz = tz),
        admit.datetime < mdy("6/1/2018", tz = tz)
    )

mbo_id <- concat_encounters(visits$millennium.id)

# run MBO query
#   * Identifiers - by Millennium Encounter Id

identifiers <- read_data(dir_raw, "identifiers", FALSE) %>%
    as.id()

identifiers %>%
    select(-millennium.id) %>%
    write.csv(
        file = paste(dir_external, "patients.csv", sep = "/"),
        row.names = FALSE
    )
