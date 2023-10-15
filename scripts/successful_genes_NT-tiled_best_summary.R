#### INITIALIZE ####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
library(janitor)

inFile <- "successful_genes_NT-tiled_best_summary_cov.tsv"
outFilePrefix <- 
  str_remove(
    inFile,
    "\\.tsv$"
  )

#### READ IN DATA & WRANGLE ####
data_mitofinder <-
  read_tsv(inFile) %>%
  clean_names() %>%
  rename(library = treatment) %>%
  separate(library,
           into = c(
             "wga",
             "morphospecies_id",
             "era_location",
             "repair",
             "ng_dna",
             "lane"
           ),
           sep = "[_-]",
           remove = FALSE
  ) %>%
  mutate(
    era = str_sub(
      era_location,
      1,
      1
    ),
    location_id = str_remove(
      era_location,
      "^[AC]"
    ),
    treatment_group = str_remove(
      library,
      "_N*R_.*_L[1-9]$"
    ),
    genus = str_remove(
      species,
      " .*$"
    ),
    genus = case_when(
      genus == "Parambassis" ~ "Ambassis",
      TRUE ~ genus
    ),
    morphogenus = case_when(
      morphospecies_id == "Ako" ~ "Ambassis",
      morphospecies_id == "Aur" ~ "Ambassis",
      morphospecies_id == "Dba" ~ "Atherinomorus",
      morphospecies_id == "Dva" ~ "Atherinomorus",
      morphospecies_id == "Ela" ~ "Equulites",
      morphospecies_id == "Ele" ~ "Equulites",
      morphospecies_id == "Hte" ~ "Hypoatherina",
      morphospecies_id == "Sob" ~ "Sphyraena",
      morphospecies_id == "Ssp" ~ "Siganus",
      morphospecies_id == "Tbi" ~ "Taeniamia"
    ),
    match_morpho_blast = case_when(
      morphogenus == genus & pident > 97 ~ "Strong Match",
      morphogenus == genus & pident > 94 ~ "Match",
      morphogenus == genus ~ "Weak Match",
      morphogenus != genus & pident > 97 ~ "Strong Mismatch",
      morphogenus != genus & pident > 94 ~ "Mismatch",
      morphogenus != genus ~ "Weak Mismatch",
      TRUE ~ NA_character_
    ),
    match_morpho_blast = factor(match_morpho_blast,
                                levels = c(
                                  "Strong Match",
                                  "Match",
                                  "Weak Match",
                                  "Weak Mismatch",
                                  "Mismatch",
                                  "Strong Mismatch"
                                )
    )
  )

# #### PLOT: COLUMN PLOT OF CONTIG CVG VS INDIVIDUAL BY GENUS ####
#
# data_mitofinder %>%
#   group_by(treatment_group,
#            morphospecies_id,
#            wga,
#            era,
#            assembler,
#            genus) %>%
#   summarize(mean_contig_cvg = mean(contig_coverage,
#                                    na.rm = TRUE),
#             sd_contig_cvg = sd(contig_coverage,
#                                na.rm = TRUE),
#             mean_pident = mean(pident,
#                                na.rm = TRUE)) %>%
#   ggplot() +
#   aes(x=treatment_group,
#       y=mean_contig_cvg,
#       fill = genus,
#       alpha = mean_pident) +
#   geom_col(position='dodge') +
#   geom_errorbar(aes(ymin = mean_contig_cvg - sd_contig_cvg,
#                     ymax = mean_contig_cvg + sd_contig_cvg),
#                 width = 0.2,
#                 position = position_dodge(0.9)) +
#   theme_classic() +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
#   scale_y_log10() +
#   guides(fill = guide_legend(ncol = 1)) +
#   facet_wrap(era + wga ~ .,
#              scales = "free_x")
#
# #### PLOT: COLUMN PLOT OF CONTIG CVG VS INDIVIDUAL BY SPECIES ####
#
# data_mitofinder %>%
#   group_by(treatment_group,
#            morphospecies_id,
#            wga,
#            era,
#            assembler,
#            species) %>%
#   summarize(mean_contig_cvg = mean(contig_coverage,
#                                    na.rm = TRUE),
#             sd_contig_cvg = sd(contig_coverage,
#                                na.rm = TRUE),
#             mean_pident = mean(pident,
#                                na.rm = TRUE)) %>%
#   ggplot() +
#   aes(x=treatment_group,
#       y=mean_contig_cvg,
#       fill = species,
#       alpha = mean_pident) +
#   geom_col(position='dodge') +
#   theme_classic() +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
#   scale_y_log10() +
#   guides(fill = guide_legend(ncol = 2)) +
#   facet_wrap(era ~ .,
#              scales = "free_x")
#
#### PLOT: COLUMN PLOT OF CONTIG CVG VS INDIVIDUAL BY MORPHO BLAST MATCH ####

data_mitofinder %>%
  group_by(
    treatment_group,
    morphospecies_id,
    wga,
    era,
    # assembler,
    match_morpho_blast
  ) %>%
  summarize(
    mean_contig_cvg = mean(contig_coverage,
                           na.rm = TRUE
    ),
    sd_contig_cvg = sd(contig_coverage,
                       na.rm = TRUE
    ),
    mean_pident = mean(pident,
                       na.rm = TRUE
    )
  ) %>% # view()
  ungroup() %>%
  complete(
    treatment_group,
    # morphospecies_id,
    # wga,
    # era,
    # # assembler,
    match_morpho_blast,
    fill = list(
      mean_contig_cvg = NA,
      sd_contig_cvg = NA,
      mean_pident = NA
    )
  ) %>%
  # fill(morphospecies_id, wga, era, .direction = "downup") %>% view()
  mutate(
    wga = str_remove(
      treatment_group,
      "_.*$"
    ),
    morphospecies_id = str_remove(
      treatment_group,
      "^N*o*WGA_"
    ) %>%
      str_remove(., "\\-.*$"),
    era = str_remove(
      treatment_group,
      "^.*\\-"
    ) %>%
      str_sub(., 1, 1)
  ) %>% # view()
  ggplot() +
  aes(
    x = treatment_group,
    y = mean_contig_cvg,
    fill = match_morpho_blast,
    # alpha = mean_pident
  ) +
  geom_col(position = "dodge") +
  geom_errorbar(
    aes(
      ymin = mean_contig_cvg - sd_contig_cvg,
      ymax = mean_contig_cvg + sd_contig_cvg
    ),
    width = 0.2,
    position = position_dodge(0.9)
  ) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_log10() +
  scale_fill_manual(values = colorRampPalette(c("green3", "red3"))(6)) +
  guides(fill = guide_legend(ncol = 1)) +
  facet_wrap(wga + era ~ .,
             scales = "free_x"
  )

ggsave(str_c(outFilePrefix,
             "_cvg_grouped.png"))

#### PLOT: COLUMN PLOT OF CONTIG LENGTH VS INDIVIDUAL BY MORPHO BLAST MATCH ####

data_mitofinder %>%
  group_by(
    treatment_group,
    morphospecies_id,
    wga,
    era,
    # assembler,
    match_morpho_blast
  ) %>%
  summarize(
    mean_contig_cvg = mean(contig_coverage,
                           na.rm = TRUE
    ),
    sd_contig_cvg = sd(contig_coverage,
                       na.rm = TRUE
    ),
    mean_pident = mean(pident,
                       na.rm = TRUE
    ),
    mean_contig_len = mean(length,
                           na.rm = TRUE
    ),
    sd_contig_len = sd(length,
                       na.rm = TRUE
    )
  ) %>% # view()
  ungroup() %>%
  complete(
    treatment_group,
    # morphospecies_id,
    # wga,
    # era,
    # # assembler,
    match_morpho_blast,
    fill = list(
      mean_contig_cvg = NA,
      sd_contig_cvg = NA,
      mean_pident = NA,
      mean_contig_len = NA,
      sd_contig_len = NA
    )
  ) %>%
  # fill(morphospecies_id, wga, era, .direction = "downup") %>% view()
  mutate(
    wga = str_remove(
      treatment_group,
      "_.*$"
    ),
    morphospecies_id = str_remove(
      treatment_group,
      "^N*o*WGA_"
    ) %>%
      str_remove(., "\\-.*$"),
    era = str_remove(
      treatment_group,
      "^.*\\-"
    ) %>%
      str_sub(., 1, 1)
  ) %>% # view()
  ggplot() +
  aes(
    x = treatment_group,
    y = mean_contig_len,
    fill = match_morpho_blast,
    # alpha = mean_pident
  ) +
  geom_col(position = "dodge") +
  geom_errorbar(
    aes(
      ymin = mean_contig_len - sd_contig_len,
      ymax = mean_contig_len + sd_contig_len
    ),
    width = 0.2,
    position = position_dodge(0.9)
  ) +
  geom_hline(
    yintercept = 18000,
    linetype = "dashed",
    color = "grey"
  ) +
  geom_hline(
    yintercept = 15000,
    linetype = "dashed",
    color = "grey"
  ) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  # scale_y_log10() +
  scale_fill_manual(values = colorRampPalette(c("green3", "red3"))(6)) +
  guides(fill = guide_legend(ncol = 1)) +
  facet_wrap(wga + era ~ .,
             scales = "free_x"
  )

ggsave(str_c(outFilePrefix,
             "_len_grouped.png"))

#### PLOT: COLUMN PLOT OF CONTIG CVG VS INDIVIDUAL BY MORPHO BLAST MATCH ####

data_mitofinder %>%
  group_by(
    library,
    # treatment_group,
    morphospecies_id,
    wga,
    era,
    # assembler,
    match_morpho_blast
  ) %>%
  summarize(
    mean_contig_cvg = mean(contig_coverage,
                           na.rm = TRUE
    ),
    sd_contig_cvg = sd(contig_coverage,
                       na.rm = TRUE
    ),
    mean_pident = mean(pident,
                       na.rm = TRUE
    ),
    mean_contig_len = mean(length,
                           na.rm = TRUE
    ),
    sd_contig_len = sd(length,
                       na.rm = TRUE
    )
  ) %>% # view()
  ungroup() %>%
  complete(
    library,
    # treatment_group,
    # morphospecies_id,
    # wga,
    # era,
    # # assembler,
    match_morpho_blast,
    fill = list(
      mean_contig_cvg = NA,
      sd_contig_cvg = NA,
      mean_pident = NA,
      mean_contig_len = NA,
      sd_contig_len = NA
    )
  ) %>%
  # fill(morphospecies_id, wga, era, .direction = "downup") %>% view()
  mutate(
    wga = str_remove(
      library,
      "_.*$"
    ),
    morphospecies_id = str_remove(
      library,
      "^N*o*WGA_"
    ) %>%
      str_remove(., "\\-.*$"),
    era = str_remove(
      library,
      "^.*\\-"
    ) %>%
      str_sub(., 1, 1)
  ) %>% # view()
  ggplot() +
  aes(
    x = library,
    y = mean_contig_cvg,
    fill = match_morpho_blast,
    # alpha = mean_pident
  ) +
  geom_col(position = "dodge") +
  geom_errorbar(
    aes(
      ymin = mean_contig_cvg - sd_contig_cvg,
      ymax = mean_contig_cvg + sd_contig_cvg
    ),
    width = 0.2,
    position = position_dodge(0.9)
  ) +
  geom_hline(
    yintercept = 1000,
    linetype = "dashed",
    color = "grey"
  ) +
  geom_hline(
    yintercept = 10,
    linetype = "dashed",
    color = "grey"
  ) +
  theme_classic() +
  theme(axis.text.x = element_text(
    angle = 90,
    vjust = 0.5,
    hjust = 1
  )) +
  scale_y_log10() +
  scale_fill_manual(values = colorRampPalette(c("green3", "red3"))(6)) +
  guides(fill = guide_legend(ncol = 1)) +
  facet_wrap(wga + era ~ .,
             scales = "free_x"
  )

ggsave(str_c(outFilePrefix,
             "_cvg_library.png"))

#### PLOT: COLUMN PLOT OF CONTIG LENGTH VS INDIVIDUAL BY MORPHO BLAST MATCH ####

data_mitofinder %>%
  group_by(
    library,
    # treatment_group,
    morphospecies_id,
    wga,
    era,
    # assembler,
    match_morpho_blast
  ) %>%
  summarize(
    mean_contig_cvg = mean(contig_coverage,
                           na.rm = TRUE
    ),
    sd_contig_cvg = sd(contig_coverage,
                       na.rm = TRUE
    ),
    mean_pident = mean(pident,
                       na.rm = TRUE
    ),
    mean_contig_len = mean(length,
                           na.rm = TRUE
    ),
    sd_contig_len = sd(length,
                       na.rm = TRUE
    )
  ) %>% # view()
  ungroup() %>%
  complete(
    library,
    # treatment_group,
    # morphospecies_id,
    # wga,
    # era,
    # # assembler,
    match_morpho_blast,
    fill = list(
      mean_contig_cvg = NA,
      sd_contig_cvg = NA,
      mean_pident = NA,
      mean_contig_len = NA,
      sd_contig_len = NA
    )
  ) %>%
  # fill(morphospecies_id, wga, era, .direction = "downup") %>% view()
  mutate(
    wga = str_remove(
      library,
      "_.*$"
    ),
    morphospecies_id = str_remove(
      library,
      "^N*o*WGA_"
    ) %>%
      str_remove(., "\\-.*$"),
    era = str_remove(
      library,
      "^.*\\-"
    ) %>%
      str_sub(., 1, 1)
  ) %>% # view()
  ggplot() +
  aes(
    x = library,
    y = mean_contig_len,
    fill = match_morpho_blast,
    # alpha = mean_pident
  ) +
  geom_col(position = "dodge") +
  geom_errorbar(
    aes(
      ymin = mean_contig_len - sd_contig_len,
      ymax = mean_contig_len + sd_contig_len
    ),
    width = 0.2,
    position = position_dodge(0.9)
  ) +
  geom_hline(
    yintercept = 18000,
    linetype = "dashed",
    color = "grey"
  ) +
  geom_hline(
    yintercept = 15000,
    linetype = "dashed",
    color = "grey"
  ) +
  theme_classic() +
  theme(axis.text.x = element_text(
    angle = 90,
    vjust = 0.5,
    hjust = 1
  )) +
  # scale_y_log10() +
  scale_fill_manual(values = colorRampPalette(c("green3", "red3"))(6)) +
  guides(fill = guide_legend(ncol = 1)) +
  facet_wrap(wga + era ~ .,
             scales = "free_x"
  )

ggsave(str_c(outFilePrefix,
             "_len_library.png"))
