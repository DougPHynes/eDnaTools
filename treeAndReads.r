## ---- treeReads --------

library(tidyverse)
library(rotl)
library(ggtree)
library(phylobase)
library(aplot)
library(scico)
library(gtools)

data <- read_csv("C:/Users/HynesD/Documents/eDNA/eDnaCombined.csv")

finalDf <- data %>% 
  mutate(taxa = case_when(str_detect(taxa, "Cyprinodont") ~ "Cyprinodontiformes",
                          TRUE ~ taxa)) %>% #fix spelling of taxon 
  mutate(taxa = case_when(str_detect(taxa, "Esociforme") ~ "Esociformes",
                          TRUE ~ taxa)) %>% #fix spelling of taxon  
  mutate(taxa = str_replace(taxa, pattern = "sp.", replacement = "")) %>%
  mutate(taxa = case_when(str_detect(taxa, "Ondatra zibethicus sp.") ~ "Ondatra zibethicus",
                          TRUE ~ taxa)) %>% #fix spelling
  mutate(commonName = case_when(str_detect(commonName, "Common muskrat") ~ "Muskrat",
                                TRUE ~ taxa)) %>% #fix spelling
  mutate(locality = case_when(str_detect(locality, "Boot Island NWA") ~ "Boot Island",
                              TRUE ~ locality)) %>% #fix name
  mutate(locality = case_when(str_detect(locality, "North Mud") ~ "Mud Island",
                              TRUE ~ locality)) %>% #fix name
  mutate(taxa = str_replace(taxa, pattern = "sp.", replacement = "")) %>%
  filter(!sampleId %in% c(21, 65)) %>% #remove controls
  mutate(qubitYieldNgPerMl = case_when(
    str_detect(qubitYieldNgPerMl, ">") ~ "12000", #
    TRUE ~ qubitYieldNgPerMl)) %>%
  mutate_at(vars(qubitYieldNgPerMl), as.numeric) %>%
  mutate(taxa = str_trim(taxa, side = "right")) %>%
  mutate(rain = case_when(
    sampleId == "48" ~ "After rain",
    sampleId == "49" ~ "After rain, not paired",
    sampleId == "50" ~ "After rain",
    sampleId == "51" ~ "After rain",
    sampleId == "52" ~ "After rain",
    sampleId == "53" ~ "After rain",
    sampleId == "30" ~ "Before rain",
    sampleId == "31" ~ "Before rain",
    sampleId == "32" ~ "Before rain",
    sampleId == "33" ~ "Before rain",
    sampleId == "35" ~ "Before rain",
    TRUE ~ "Not paired")) %>% #54 & 55 after rain but on Flat Island 
  mutate(rainPaired = case_when(
    sampleId == "48" ~ "A",
    sampleId == "49" ~ "After rain, not paired",
    sampleId == "50" ~ "B",
    sampleId == "51" ~ "C",
    sampleId == "52" ~ "D",
    sampleId == "53" ~ "E",
    sampleId == "30" ~ "A",
    sampleId == "31" ~ "B",
    sampleId == "32" ~ "C",
    sampleId == "33" ~ "E",
    sampleId == "35" ~ "D",
    TRUE ~ "Not paired")) %>%
  mutate(waterbody = case_when(
    sampleId == "25" ~ "Seep",
    sampleId == "35" ~ "Seep",
    sampleId == "23" ~ "Brackish",
    str_detect(ecosystemNotes, "Barachois") ~ "Brackish",
    str_detect(ecosystemNotes, "barachois") ~ "Brackish",
    str_detect(ecosystemNotes, "Emergence") ~ "Seep",
    str_detect(ecosystemNotes, "Well") ~ "Well",
    str_detect(ecosystemNotes, "well") ~ "Well",
    str_detect(ecosystemNotes, "After rain, was dry before") ~ "Brackish",
    str_detect(ecosystemNotes, "Following rain") ~ "Brackish",
    str_detect(ecosystemNotes, "Following rain, previously sampled") ~ "Seep",
    str_detect(ecosystemNotes, "Isthmus pond, behind dune") ~ "Brackish",
    str_detect(ecosystemNotes, "Pond behind barrier dune") ~ "Brackish",
    str_detect(ecosystemNotes, "behind barrier dune") ~ "Brackish",
    str_detect(ecosystemNotes, "Feeds largest barachois from point E of N Home") ~ "Seep",
    str_detect(ecosystemNotes, "Very small stream") ~ "Seep",
    str_detect(ecosystemNotes, "Isthmus pond, behind dune") ~ "Brackish",
    str_detect(ecosystemNotes, "Standing water") ~ "Seep",
    str_detect(ecosystemNotes, "pan") ~ "Brackish",
    str_detect(ecosystemNotes, "Pond") ~ "Seep",
    str_detect(ecosystemNotes, "Small bog upstream") ~ "Brackish",
    str_detect(ecosystemNotes, "bog") ~ "Seep"
  )) %>%
  mutate(site = case_when(
    sampleId == "12" ~ "M1",
    sampleId == "15" ~ "M1",
    sampleId == "40" ~ "S1",
    sampleId == "41" ~ "S1",
    sampleId == "42" ~ "S2",
    sampleId == "43" ~ "S3",
    sampleId == "38" ~ "S4",
    sampleId == "39" ~ "S4",
    sampleId == "37" ~ "S5",
    sampleId == "53" ~ "S6",
    sampleId == "33" ~ "S6",
    sampleId == "44" ~ "S7",
    sampleId == "35" ~ "S8",
    sampleId == "52" ~ "S8",
    sampleId == "34" ~ "S8",
    sampleId == "32" ~ "S9",
    sampleId == "51" ~ "S9",
    sampleId == "49" ~ "S10",
    sampleId == "50" ~ "S11",
    sampleId == "31" ~ "S11",
    sampleId == "48" ~ "S12",
    sampleId == "30" ~ "S12",
    sampleId == "45" ~ "S13",
    sampleId == "23" ~ "S14",
    sampleId == "25" ~ "S15",
    sampleId == "27" ~ "S16",
    sampleId == "28" ~ "S17",
    sampleId == "29" ~ "S17",
    sampleId == "55" ~ "F1",
    sampleId == "54" ~ "F2",
    sampleId == "62" ~ "B1",
    sampleId == "61" ~ "B2",
    sampleId == "60" ~ "B3",
    sampleId == "64" ~ "B4",
    sampleId == "63" ~ "B5"))

sumData2 <- finalDf %>%
  mutate(taxa = case_when(str_detect(taxa, "Lavin") ~ "Leuciscidae",
                          TRUE ~ taxa)) %>%
  mutate(taxa = case_when(str_detect(taxa, "Phoca") ~ "Phoca vitulina",
                          TRUE ~ taxa)) %>%
  mutate(taxa = case_when(str_detect(taxa, "Canis lupus") ~ "Canis latrans",
                          TRUE ~ taxa)) %>%
  mutate(taxa = case_when(str_detect(taxa, "Sus") ~ "Sus scrofa domesticus",
                          TRUE ~ taxa)) %>%
  mutate(taxa = case_when(str_detect(taxa, "Equus") ~ "Equus caballus",
                          TRUE ~ taxa)) %>%
  group_by(site, taxa) %>%
  mutate(reads2 = sum(reads)) %>% distinct(taxa, .keep_all = TRUE) %>%
  mutate(readsT = round(reads2^(1/5), 1)) %>%
  filter(!taxa == "Esociformes") %>%
  select(site, taxa, readsT) %>%
  pivot_wider(names_from = site, values_from = readsT) 


taxonSearch <- tnrs_match_names(names = sumData2$taxa, context_name = "All life")
sumData2$ottName <- unique_name(taxonSearch)
sumData2$ottId <- taxonSearch$ott_id
ottInTree <- ott_id(taxonSearch)[is_in_tree(ott_id(taxonSearch))]
tre <- tol_induced_subtree(ott_ids = ottInTree)
tre$tip.label <- strip_ott_ids(tre$tip.label, remove_underscores = TRUE)

sum_numeric <- sumData2[, c(2:26)]
rownames(sum_numeric) <- sumData2$ottName
treeData <- phylo4d(tre, sum_numeric)

p <- ggtree(treeData) + geom_tiplab(fontface = 3, size = 3.25) + ggexpand(5, side = "h") + 
  geom_cladelab(23, "Mammalia", offset = -12, offset.text= -4.5, angle = 90, barsize = 2, hjust = "center")+
  geom_cladelab(35, "Aves/Reptilia", offset = -12, offset.text= -4.5, angle = 90, barsize = 2, hjust = "center")+
  geom_cladelab(36, "Actinopterygii", offset = -12, offset.text= -4.5, angle = 90, barsize = 2, hjust = "center")


sumData3 <- finalDf %>%
  mutate(taxa = case_when(str_detect(taxa, "Lavin") ~ "Leuciscidae",
                          TRUE ~ taxa)) %>%
  mutate(taxa = case_when(str_detect(taxa, "Phoca") ~ "Phoca vitulina",
                          TRUE ~ taxa)) %>%
  mutate(taxa = case_when(str_detect(taxa, "Canis lupus") ~ "Canis latrans",
                          TRUE ~ taxa)) %>%
  mutate(taxa = case_when(str_detect(taxa, "Sus") ~ "Sus scrofa domesticus",
                          TRUE ~ taxa)) %>%
  mutate(taxa = case_when(str_detect(taxa, "Equus") ~ "Equus caballus",
                          TRUE ~ taxa)) %>%
  group_by(site, taxa) %>%
  filter(!taxa == "Esociformes") %>%
  mutate(reads2 = sum(reads)) %>% distinct(taxa, .keep_all = TRUE) %>%
  mutate(readsT = round(reads2^(1/5), 1)) %>%
  #mutate(readsT = round(log(reads2), 1)) %>%
  select(site, taxa, readsT) %>%
  filter(taxa %in% tre$tip.label) %>% 
  ungroup() %>%
  complete(site, taxa) %>% replace_na(list(readsT = 0)) %>%
  slice(mixedorder(site))

p2 <- ggplot(sumData3, aes(x=fct_inorder(as.factor(site)), y=taxa)) + 
  geom_tile(aes(fill=readsT), color = "gray") + scale_fill_scico(palette = "oslo", direction = -1, begin = 0, end = 1) + 
  xlab("Sites") + ylab(NULL) + labs(fill = expression(sqrt("Reads", 5))) +
  theme(axis.text.y=element_blank()) +
  scale_x_discrete(expand = c(0,0)) +
  scale_y_discrete(expand = c(0,0)) +
  theme(legend.title = element_text(size = 11)) +
  theme(
    axis.ticks.length.x = unit(0.15, "cm"),
    axis.ticks.length.y = unit(0.15, "cm"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.background = element_blank()) 


p3 <- p2 %>% insert_left(p, width = 0.36)

print(p3)
