-- Clear the tables first
DELETE FROM mvw_gpcontest_eboundary_answers_agg;
DELETE FROM mvw_gpcontest_eboundary_schoolcount_agg;
DELETE FROM mvw_gpcontest_institution_qdetails_percentages_agg;
DELETE FROM mvw_gpcontest_institution_stucount_agg;

-- Re-populate the tables
REFRESH MATERIALIZED VIEW CONCURRENTLY mvw_gpcontest_eboundary_answers_agg;
REFRESH MATERIALIZED VIEW CONCURRENTLY mvw_gpcontest_eboundary_schoolcount_agg;
REFRESH MATERIALIZED VIEW CONCURRENTLY mvw_gpcontest_institution_questiongroup_qdetails_correctans_agg;
REFRESH MATERIALIZED VIEW CONCURRENTLY mvw_gpcontest_institution_qdetails_percentages_agg;
REFRESH MATERIALIZED VIEW CONCURRENTLY mvw_gpcontest_institution_stucount_agg;
REFRESH MATERIALIZED VIEW CONCURRENTLY mvw_gpcontest_concept_percentages_agg;
REFRESH MATERIALIZED VIEW CONCURRENTLY mvw_gpcontest_school_details;
REFRESH MATERIALIZED VIEW CONCURRENTLY mvw_gpcontest_boundary_answers_agg;
REFRESH MATERIALIZED VIEW CONCURRENTLY mvw_gpcontest_boundary_counts_agg;

