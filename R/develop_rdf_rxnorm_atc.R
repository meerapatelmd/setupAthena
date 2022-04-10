develop_rdf_rxnorm_atc <-
  function(conn,
           conn_fun = "pg13::local_connect()",
           target_schema = "omop_athena",
           output_folder = "~/Desktop",
           checks = "",
           verbose = TRUE,
           render_sql = TRUE,
           render_only = FALSE) {


omop_version <-
  pg13::query(
    conn_fun = conn_fun,
    sql_statement =
    "
    SELECT sa_release_version
    FROM public.setup_athena_log
    WHERE sa_datetime IN (SELECT MAX(sa_datetime) FROM public.setup_athena_log);
    ",
    checks = checks,
    verbose = verbose,
    render_sql = render_sql) %>%
  unlist() %>%
  unname()


rdf_file <-
file.path(
"inst",
"data",
"rdf",
omop_version,
"Drug",
"RxNorm ATC Classification.rdf"
 )

if (!file.exists(rdf_file)) {
# Workflow
library(tidyverse)
library(rdflib)
library(rdfR)
library(pg13)
conn_fun <- "pg13::local_connect()"

get_athena_version <-
  function(conn,
           conn_fun,
           ...) {

    sql_statement <-
      "SELECT
          'OMOP Vocabularies' AS resource,
          sa_datetime AS load_datetime,
          sa_release_version AS version
       FROM public.setup_athena_log
       WHERE sa_datetime IN (SELECT max(sa_datetime) from public.setup_athena_log);"

    output <-
      pg13::query(conn = conn,
                  conn_fun = conn_fun,
                  sql_statement = sql_statement,
                  ...)

    output
  }

omop_version <-
  get_athena_version(conn_fun = conn_fun)
omop_version

drug_rdf <-
  initialize_rdf(name = "OMOP RxNorm ATC Classification",
                 base_uri = "http://omop/drug",
                 version =  omop_version,
                 comment = "ATC classes with RxNorm and RxNorm Extension Ingredient concept class individuals.")


base_uri <- query_base_uri(drug_rdf)
drug_rdf <-
  append_annotation_properties(rdf = drug_rdf,
                               base_uri = base_uri,
                               "load_datetime",
                               "version")


add_annotation_property_value(rdf = drug_rdf,
                            entity = base_uri,
                            annotation_property = "load_datetime",
                            value = omop_version$load_datetime)

add_annotation_property_value(rdf = drug_rdf,
                            entity = base_uri,
                            annotation_property = "version",
                            value = omop_version$version)
drug_rdf


# Reading OMOP ATC classifications.
atc_classes <-
query(sql_statement = glue::glue("SELECT * FROM {target_schema}.concept WHERE vocabulary_id = 'ATC' AND standard_concept = 'C' AND invalid_reason IS NULL;"))
atc_classes

atc_classes2 <-
  atc_classes %>%
  mutate(class_id = sprintf("%s/%s", base_uri,concept_id)) %>%
  mutate(class_label = sprintf("%s [%s %s]", concept_name, vocabulary_id, concept_code))
atc_classes2

drug_rdf2 <-
  append_annotation_properties(
    rdf = drug_rdf,
    base_uri = base_uri,
    colnames(atc_classes)
  )
drug_rdf2



drug_rdf3 <-
df_add_classes(
  rdf = drug_rdf2,
  data = atc_classes2,
  class_id_col = class_id,
  class_label_col = class_label
)
drug_rdf3



atc_classes3 <-
atc_classes2 %>%
  select(-class_label) %>%
  mutate_all(as.character) %>%
  pivot_longer(cols = !class_id,
               names_to = "annotation_property_label",
               values_drop_na = TRUE)

atc_classes3



atc_classes4 <-
  atc_classes3 %>%
  split(.$annotation_property_label) %>%
  map(select,
      -annotation_property_label)

atc_classes4



drug_rdf4 <-
  drug_rdf3
for (i in seq_along(atc_classes4)) {
  drug_rdf4 <-
  df_add_annotation_property_value(
    rdf = drug_rdf4,
    data = atc_classes4[[i]],
    entity_col = class_id,
    annotation_property_label = names(atc_classes4)[i],
    value_col = value
  )
}




atc_subclassof <-
query(sql_statement = glue::glue("SELECT ca.* FROM {target_schema}.concept_ancestor ca INNER JOIN {target_schema}.concept a ON a.concept_id = ca.ancestor_concept_id INNER JOIN {target_schema}.concept d ON d.concept_id = ca.descendant_concept_id WHERE a.vocabulary_id = 'ATC' AND a.standard_concept = 'C' AND a.invalid_reason IS NULL AND D.vocabulary_id = 'ATC' AND d.standard_concept = 'C' AND d.invalid_reason IS NULL;"))
atc_subclassof


atc_subclassof %>%
  dplyr::filter(ancestor_concept_id == descendant_concept_id) %>%
  distinct(min_levels_of_separation, max_levels_of_separation)


atc_subclassof2 <-
  atc_subclassof %>%
  dplyr::filter(ancestor_concept_id != descendant_concept_id)
atc_subclassof2



atc_subclassof2 %>%
  dplyr::filter(min_levels_of_separation != max_levels_of_separation)



atc_subclassof3 <-
  atc_subclassof2 %>%
  transmute(ancestor_concept_id,
            descendant_concept_id,
            level = min_levels_of_separation)
atc_subclassof3



atc_subclassof4 <-
  atc_subclassof3 %>%
  mutate_at(vars(ancestor_concept_id,
                 descendant_concept_id),
            ~sprintf("%s/%s", base_uri,.))
atc_subclassof4



atc_subclassof5 <-
  atc_subclassof4 %>%
  pivot_wider(names_from = level,
              values_from = descendant_concept_id,
              values_fn = list) %>%
  select(ancestor_concept_id,
         as.character(1:4))
atc_subclassof5


drug_rdf5 <- drug_rdf4
for (i in 1:4) {

  if (i == 1) {

    col1 <- "ancestor_concept_id"
    col2 <- as.character(i)

  } else {


    col1 <- as.character(i-1)
    col2 <- as.character(i)


  }


  atc_subclassof6 <-
  atc_subclassof5 %>%
    select(all_of(c(col1, col2))) %>%
    unnest(all_of(col2))

  colnames(atc_subclassof6) <-
    c("parent_id", "child_id")

  drug_rdf5 <-
  df_add_subclassof(
    rdf = drug_rdf5,
    data = atc_subclassof6,
    parent_class_id_col = parent_id,
    child_class_id_col = child_id
  )

}

drug_rdf5



rxnorm_individuals <-
query(sql_statement = glue::glue("SELECT * FROM {target_schema}.concept WHERE vocabulary_id IN ('RxNorm', 'RxNorm Extension') AND standard_concept <> 'C' AND concept_class_id = 'Ingredient' AND invalid_reason IS NULL;"))
rxnorm_individuals



rxnorm_individuals2 <-
  rxnorm_individuals %>%
  mutate(individual_id = sprintf("%s/%s", base_uri,concept_id)) %>%
  mutate(individual_label = sprintf("%s [%s %s]", concept_name, vocabulary_id, concept_code))

rxnorm_individuals2




drug_rdf6 <- drug_rdf5
drug_rdf6 <-
df_add_individuals(
  rdf = drug_rdf6,
  data = rxnorm_individuals2,
  individual_id_col = individual_id,
  individual_label_col = individual_label
)




rxnorm_individuals3 <-
rxnorm_individuals2 %>%
  select(-individual_label) %>%
  mutate_all(as.character) %>%
  pivot_longer(cols = !individual_id,
               names_to = "annotation_property_label",
               values_drop_na = TRUE)

rxnorm_individuals3



rxnorm_individuals4 <-
  rxnorm_individuals3 %>%
  split(.$annotation_property_label) %>%
  map(select,
      -annotation_property_label)

rxnorm_individuals4



drug_rdf7 <- drug_rdf6
for (i in seq_along(rxnorm_individuals4)) {
  drug_rdf7 <-
  df_add_annotation_property_value(
    rdf = drug_rdf7,
    data = rxnorm_individuals4[[i]],
    entity_col = individual_id,
    annotation_property_label = names(rxnorm_individuals4)[i],
    value_col = value
  )
}




rxnorm_individual_classes <-
query(
  sql_statement =
    glue::glue(
  "
  SELECT ca.*
  FROM {target_schema}.concept_ancestor ca
  INNER JOIN
    (SELECT concept_id
    FROM {target_schema}.concept rx
    WHERE
      rx.vocabulary_id IN ('RxNorm', 'RxNorm Extension') AND
      rx.standard_concept <> 'C' AND
      rx.concept_class_id = 'Ingredient' AND
      rx.invalid_reason IS NULL) c
  ON c.concept_id = ca.descendant_concept_id
  INNER JOIN
    (
    SELECT concept_id
    FROM {target_schema}.concept
    WHERE
      vocabulary_id IN ('ATC') AND
      standard_concept = 'C' AND
      invalid_reason IS NULL
    ) atc
  ON atc.concept_id = ca.ancestor_concept_id;"))
rxnorm_individual_classes



rxnorm_individual_classes %>%
  distinct(min_levels_of_separation,
           max_levels_of_separation)



rxnorm_individual_classes %>%
  dplyr::filter(min_levels_of_separation == 0,
                max_levels_of_separation == 0)




rxnorm_individual_classes2 <-
  rxnorm_individual_classes %>%
  transmute(ancestor_concept_id,
            descendant_concept_id,
            level = max_levels_of_separation) %>%
  dplyr::filter(level %in% c(0, 1)) %>%
  select(ancestor_concept_id,
         descendant_concept_id) %>%
  mutate_all(~sprintf("%s/%s", base_uri, .))
rxnorm_individual_classes2



drug_rdf8 <- drug_rdf7
drug_rdf8 <-
df_add_individual_class(
  rdf = drug_rdf8,
  data = rxnorm_individual_classes2,
  individual_id_col = descendant_concept_id,
  class_id_col = ancestor_concept_id
)




final_rdf <-
  drug_rdf8


write_rdf(final_rdf,
  rdf_file)
}

}
