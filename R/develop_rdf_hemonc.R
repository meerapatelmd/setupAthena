develop_rdf_hemonc <-
  function(
    conn,
    conn_fun = "pg13::local_connect()",
    schema = "omop_athena",
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
    "HemOnc.rdf"
  )

if (!file.exists(rdf_file)) {


library(tidyverse)
library(easyBakeOven)
library(glue)

# Summary
# Convert the ATC and RxNorm classification in the OMOP vocabularies to RDF.
# Workflow
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
  initialize_rdf(name = "OMOP HemOnc Ontology",
                 base_uri = "http://omop/hemonc",
                 version = omop_version,
                 comment = "HemOnc ontology as it is available at athena.ohdsi.org.")


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




classes <-
query(sql_statement = glue::glue("SELECT * FROM {schema}.concept WHERE vocabulary_id = 'HemOnc' AND standard_concept = 'C' AND invalid_reason IS NULL;"))
classes



classes2 <-
  classes %>%
  mutate(class_id = sprintf("%s/%s", base_uri,concept_id)) %>%
  mutate(class_label = sprintf("%s [%s %s]", concept_name, vocabulary_id, concept_code))

classes2



drug_rdf2 <-
  append_annotation_properties(
    rdf = drug_rdf,
    base_uri = base_uri,
    colnames(classes)
  )
drug_rdf2



drug_rdf3 <-
df_add_classes(
  rdf = drug_rdf2,
  data = classes2,
  class_id_col = class_id,
  class_label_col = class_label
)
drug_rdf3



classes3 <-
classes2 %>%
  select(-class_label) %>%
  mutate_all(as.character) %>%
  pivot_longer(cols = !class_id,
               names_to = "annotation_property_label",
               values_drop_na = TRUE)

classes3



classes4 <-
  classes3 %>%
  split(.$annotation_property_label) %>%
  map(select,
      -annotation_property_label)

classes4



drug_rdf4 <-
  drug_rdf3
for (i in seq_along(classes4)) {
  drug_rdf4 <-
  df_add_annotation_property_value(
    rdf = drug_rdf4,
    data = classes4[[i]],
    entity_col = class_id,
    annotation_property_label = names(classes4)[i],
    value_col = value
  )
}



subclassof <-
query(sql_statement = glue::glue("SELECT ca.* FROM {schema}.concept_ancestor ca INNER JOIN {schema}.concept a ON a.concept_id = ca.ancestor_concept_id INNER JOIN {schema}.concept d ON d.concept_id = ca.descendant_concept_id WHERE a.vocabulary_id = 'HemOnc' AND a.standard_concept = 'C' AND a.invalid_reason IS NULL AND d.vocabulary_id = 'HemOnc' AND d.standard_concept = 'C' AND d.invalid_reason IS NULL;"))
subclassof



subclassof %>%
  dplyr::filter(ancestor_concept_id == descendant_concept_id) %>%
  distinct(min_levels_of_separation, max_levels_of_separation)



subclassof2 <-
  subclassof %>%
  dplyr::filter(ancestor_concept_id != descendant_concept_id)
subclassof2



subclassof2 %>%
  dplyr::filter(min_levels_of_separation != max_levels_of_separation) %>%
  distinct(min_levels_of_separation,
           max_levels_of_separation)



subclassof2 %>%
  count(min_levels_of_separation)

subclassof2 %>%
  count(max_levels_of_separation)




subclassof3 <-
  subclassof2 %>%
  transmute(ancestor_concept_id,
            descendant_concept_id,
            level = min_levels_of_separation)
subclassof3



subclassof4 <-
  subclassof3 %>%
  mutate_at(vars(ancestor_concept_id,
                 descendant_concept_id),
            ~sprintf("%s/%s", base_uri,.))
subclassof4



subclassof5 <-
  subclassof4 %>%
  pivot_wider(names_from = level,
              values_from = descendant_concept_id,
              values_fn = list) %>%
  select(ancestor_concept_id,
         as.character(1:4))
subclassof5



drug_rdf5 <- drug_rdf4
for (i in 1:4) {

  if (i == 1) {

    col1 <- "ancestor_concept_id"
    col2 <- as.character(i)

  } else {


    col1 <- as.character(i-1)
    col2 <- as.character(i)


  }


  subclassof6 <-
  subclassof5 %>%
    select(all_of(c(col1, col2))) %>%
    unnest(all_of(col2))

  colnames(subclassof6) <-
    c("parent_id", "child_id")

  drug_rdf5 <-
  df_add_subclassof(
    rdf = drug_rdf5,
    data = subclassof6,
    parent_class_id_col = parent_id,
    child_class_id_col = child_id
  )

}

drug_rdf5



individuals <-
query(sql_statement = glue::glue("SELECT * FROM {schema}.concept WHERE vocabulary_id IN ('HemOnc') AND standard_concept <> 'C' AND  invalid_reason IS NULL;"))
individuals



individuals2 <-
  individuals %>%
  mutate(individual_id = sprintf("%s/%s", base_uri,concept_id)) %>%
  mutate(individual_label = sprintf("%s [%s %s]", concept_name, vocabulary_id, concept_code))

individuals2




drug_rdf6 <- drug_rdf5
drug_rdf6 <-
df_add_individuals(
  rdf = drug_rdf6,
  data = individuals2,
  individual_id_col = individual_id,
  individual_label_col = individual_label
)




individuals3 <-
individuals2 %>%
  select(-individual_label) %>%
  mutate_all(as.character) %>%
  pivot_longer(cols = !individual_id,
               names_to = "annotation_property_label",
               values_drop_na = TRUE)

individuals3



individuals4 <-
  individuals3 %>%
  split(.$annotation_property_label) %>%
  map(select,
      -annotation_property_label)

individuals4



drug_rdf7 <- drug_rdf6
for (i in seq_along(individuals4)) {
  drug_rdf7 <-
  df_add_annotation_property_value(
    rdf = drug_rdf7,
    data = individuals4[[i]],
    entity_col = individual_id,
    annotation_property_label = names(individuals4)[i],
    value_col = value
  )
}



individual_classes <-
query(
  sql_statement =
    glue::glue(
  "
  SELECT ca.*
  FROM {schema}.concept_ancestor ca
  INNER JOIN
    (SELECT concept_id
    FROM {schema}.concept rx
    WHERE
      rx.vocabulary_id IN ('HemOnc') AND
      rx.standard_concept <> 'C' AND
      rx.invalid_reason IS NULL) c
  ON c.concept_id = ca.descendant_concept_id
  INNER JOIN
    (
    SELECT concept_id
    FROM {schema}.concept
    WHERE
      vocabulary_id IN ('HemOnc') AND
      standard_concept = 'C' AND
      invalid_reason IS NULL
    ) atc
  ON atc.concept_id = ca.ancestor_concept_id;"))
individual_classes



individual_classes %>%
  distinct(min_levels_of_separation,
           max_levels_of_separation)



individual_classes %>%
  dplyr::filter(min_levels_of_separation == 0,
                max_levels_of_separation == 0)




individual_classes2 <-
  individual_classes %>%
  transmute(ancestor_concept_id,
            descendant_concept_id,
            level = max_levels_of_separation) %>%
  dplyr::filter(level %in% c(0, 1)) %>%
  select(ancestor_concept_id,
         descendant_concept_id) %>%
  mutate_all(~sprintf("%s/%s", base_uri, .))
individual_classes2



drug_rdf8 <- drug_rdf7
drug_rdf8 <-
df_add_individual_class(
  rdf = drug_rdf8,
  data = individual_classes2,
  individual_id_col = descendant_concept_id,
  class_id_col = ancestor_concept_id
)



final_rdf <-
  drug_rdf8

write_rdf(
  final_rdf,
  rdf_file
)

}

}


