/* View for getting basic information for a survey for an institution:
 * It has:- Survey id, Survey tag, Source, Institution Id, Year Month (YYMM),
 * Number of assessments, Number of children assessed, Number of users and 
 * date of last assessment.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * In case of GP Contests (School assessment):
 *       the number of answer groups == number of children assessed.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */ 
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_agg AS
SELECT format('A%s_%s_%s_%s_%s', survey_id,survey_tag,source,institution_id,yearmonth) as id,
    survey_id,
    survey_tag,
    source,
    institution_id,
    yearmonth,
    num_assessments,
    num_children,
    num_users,
    last_assessment
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        qg.source_id as source,
        ag.institution_id as institution_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        count(distinct ag.id) as num_assessments,
        case survey.id when 1 then count(distinct ag.id) when 18 then count(distinct ag.id) else 0 end as num_children, -- For GP contest
        count(distinct ag.created_by_id) as num_users,
        max(ag.date_of_visit) as last_assessment
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.is_verified=true
    GROUP BY survey.id,
        surveytag.tag_id,
        qg.source_id,
        ag.is_verified,
        ag.institution_id, 
        yearmonth)data
;

/* View for getting basic information for a survey for a boundary:
 * It has:- Survey id, Survey tag, Source, Boundary Id, Year Month (YYMM),
 * Number of assessments, Number of schools,  Number of children assessed, 
 * Number of users and date of last assessment.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * In case of GP Contests (School assessment):
 *       the number of answer groups == number of children assessed.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 AGGREGATED FOR INSTITUTION AND STUDENT SURVEYS
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_agg AS
SELECT format('A%s_%s_%s_%s_%s', survey_id,survey_tag,source,boundary_id,yearmonth) as id,
    survey_id,
    survey_tag,
    source,
    boundary_id,
    yearmonth,
    num_assessments,
    num_schools,
    num_children,
    num_users,
    last_assessment
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        qg.source_id as source,
        b.id as boundary_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        count(distinct ag.id) as num_assessments,
        count(distinct ag.institution_id) as num_schools,
        case survey.id when 1 then count(distinct ag.id) when 18 then count(distinct ag.id) else 0 end as num_children,
        count(distinct ag.created_by_id) as num_users,
        max(ag.date_of_visit) as last_assessment
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        schools_institution s,
        boundary_boundary b
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        --and survey.id in (1, 2, 4, 5, 6, 7, 11)
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
        and ag.is_verified=true
    GROUP BY survey.id,
        surveytag.tag_id,
        qg.source_id,
        ag.is_verified,
        b.id,
        yearmonth
UNION
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        qg.source_id as source,
        b.id as boundary_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        count(distinct ag.id) as num_assessments,
        count(distinct stu.institution_id) as num_schools,
        case survey.id when 36 then count(distinct ag.id) when 18 then count(distinct ag.id) else 0 end as num_children,
        count(distinct ag.created_by_id) as num_users,
        max(ag.date_of_visit) as last_assessment
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_student ag,
        assessments_surveytagmapping surveytag,
        schools_institution s,
        schools_student stu,
        boundary_boundary b
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        --and survey.id in (1, 2, 4, 5, 6, 7, 11)
        and ag.student_id = stu.id
        and stu.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
        and ag.is_verified=true
    GROUP BY survey.id,
        surveytag.tag_id,
        qg.source_id,
        ag.is_verified,
        b.id,
        yearmonth)data
;

/* View for getting basic information for a survey for a election boundary:
 * It has:- Survey id, Survey tag, Source, Election Boundary Id, Year Month (YYMM),
 * Number of assessments, Number of schools,  Number of children assessed, 
 * Number of users and date of last assessment.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * In case of GP Contests (School assessment):
 *       the number of answer groups == number of children assessed.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */

DROP MATERIALIZED VIEW IF EXISTS mvw_survey_electionboundary_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_electionboundary_agg AS
SELECT format('A%s_%s_%s_%s_%s', survey_id,survey_tag,source,electionboundary_id,yearmonth) as id,
    survey_id,
    survey_tag,
    source,
    electionboundary_id,
    yearmonth,
    num_assessments,
    num_schools,
    num_children,
    num_users,
    last_assessment
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        qg.source_id as source,
        eb.id as electionboundary_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        count(distinct ag.id) as num_assessments,
        count(distinct ag.institution_id) as num_schools,
        case survey.id when 1 then count(distinct ag.id) when 18 then count(distinct ag.id) else 0 end as num_children, --For GP contest
        count(distinct ag.created_by_id) as num_users,
        max(ag.date_of_visit) as last_assessment
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        schools_institution s,
        boundary_electionboundary eb
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.institution_id = s.id
        and (s.gp_id = eb.id or s.ward_id = eb.id or s.mla_id = eb.id or s.mp_id = eb.id) 
        and ag.is_verified=true
    GROUP BY survey.id,
        surveytag.tag_id,
        qg.source_id,
        ag.is_verified,
        eb.id,
        yearmonth)data
;

/* View for getting the survey infromation per respondent type for a boundary:
 * Respondent Type is present in answergroup table and stores the type of the 
 * person who responded to the survey.
 * Survey id, Survey tag, Boundary id, Source, Respondent Type, Year Month (YYMM),
 * Number of Assessments, Number of Schools, Number of Children & Last Assessment.
 * A union of two queries is done:- one for student assessment and other for 
 * school assessment.
 * For GP contest assessment (school assessment) the:-
 * number of children == number of assessments (answergroup entries)
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_respondenttype_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_respondenttype_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s', survey_id,survey_tag,boundary_id,source,respondent_type,yearmonth) as id,
    survey_id,
    survey_tag,
    boundary_id,
    source,
    respondent_type,
    yearmonth,
    num_assessments,
    num_schools,
    num_children,
    last_assessment
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        b.id as boundary_id,
        qg.source_id as source,
        rt.name as respondent_type,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        count(distinct ag.id) as num_assessments,
        count(distinct ag.institution_id) as num_schools,
        case survey.id when 1 then count(distinct ag.id) when 18 then count(distinct ag.id) else 0 end as num_children, --For GP contest
        max(ag.date_of_visit) as last_assessment
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        common_respondenttype rt,
        schools_institution s,
        boundary_boundary b
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.respondent_type_id = rt.char_id
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY survey.id,
        surveytag.tag_id,
        qg.source_id,
        ag.is_verified,
        rt.name,
        b.id,
        yearmonth)data
;


/* View for getting the survey infromation per respondent type for an institution:
 * Respondent Type is present in answergroup table and stores the type of the 
 * person who responded to the survey.
 * Survey id, Survey tag, Institution id, Source, Respondent Type, Year Month(YYMM),
 * Number of Assessments, Number of Schools, Number of Children & Last Assessment.
 * A union of two queries is done:- one for student assessment and other for 
 * school assessment.
 * For GP contest assessment (school assessment) the:-
 * number of children == number of assessments (answergroup entries)
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_respondenttype_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_respondenttype_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,source,respondent_type,yearmonth) as id,
    survey_id,
    survey_tag,
    institution_id,
    source,
    respondent_type,
    yearmonth,
    num_assessments,
    num_schools,
    num_children,
    last_assessment
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        ag.institution_id as institution_id,
        qg.source_id as source,
        rt.name as respondent_type,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        count(distinct ag.id) as num_assessments,
        count(distinct ag.institution_id) as num_schools,
        case survey.id when 1 then count(distinct ag.id) when 18 then count(distinct ag.id) else 0 end as num_children, -- For GP contest
        max(ag.date_of_visit) as last_assessment
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        common_respondenttype rt
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.respondent_type_id = rt.char_id
        and ag.is_verified=true
    GROUP BY survey.id,
        surveytag.tag_id,
        ag.institution_id,
        qg.source_id,
        ag.is_verified,
        rt.name,
        yearmonth)data
;

/* View for getting the survey infromation per user type for a boundary:
 * A User Type is the type of the user who created the particular survey entry.
 * Survey id, Survey tag, Boundary id, Source, User Type, Year Month (YYMM),
 * Number of Assessments, Number of Schools, Number of Children & Last Assessment.
 * A union of two queries is done:- one for student assessment and other for 
 * school assessment.
 * For GP contest assessment (school assessment) the:-
 * number of children == number of assessments (answergroup entries)
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_usertype_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_usertype_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s', survey_id,boundary_id,survey_tag,source,user_type,yearmonth) as id,
    survey_id,
    survey_tag,
    boundary_id,
    source,
    user_type,
    yearmonth,
    num_assessments,
    num_schools,
    num_children,
    last_assessment
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        b.id as boundary_id,
        qg.source_id as source,
        users.user_type_id as user_type,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        count(distinct ag.id) as num_assessments,
        count(distinct ag.institution_id) as num_schools,
        case survey.id when 1 then count(distinct ag.id) when 18 then count(distinct ag.id) else 0 end as num_children,
        max(ag.date_of_visit) as last_assessment
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        users_user users,
        schools_institution s,
        boundary_boundary b
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.created_by_id = users.id
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY survey.id,
        surveytag.tag_id,
        b.id,
        qg.source_id,
        ag.is_verified,
	users.user_type_id,
        yearmonth)data
;


/* View for getting the survey infromation per user type for a institution:
 * A User Type is the type of the user who created the particular survey entry.
 * Survey id, Survey tag, Institution id, Source, User Type, Year Month (YYMM),
 * Number of Assessments, Number of Children & Last Assessment.
 * A union of two queries is done:- one for student assessment and other for 
 * school assessment.
 * For GP contest assessment (school assessment) the:-
 * number of children == number of assessments (answergroup entries)
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_usertype_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_usertype_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,source,user_type,yearmonth) as id,
    survey_id,
    survey_tag,
    institution_id,
    source,
    user_type,
    yearmonth,
    num_assessments,
    num_children,
    last_assessment
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        ag.institution_id as institution_id,
        qg.source_id as source,
        ut.user_type_id as user_type,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        count(distinct ag.id) as num_assessments,
        case survey.id when 1 then count(distinct ag.id) when 18 then count(distinct ag.id) else 0 end as num_children, --For GP contest
        max(ag.date_of_visit) as last_assessment
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        users_user ut
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.created_by_id = ut.id
        and ag.is_verified=true
    GROUP BY survey.id,
        surveytag.tag_id,
        ag.institution_id,
        qg.source_id,
        ag.is_verified,
        ut.user_type_id,
        yearmonth)data
;


/* View for getting number of assessments per question key per survey in a
 * boundary.
 * Number of assessment per question key, year month, survey id and boundary.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 AGGREGATES BOTH INSTITUTION AND STUDENT ANSWERS
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_questionkey_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_questionkey_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s', survey_id,survey_tag,boundary_id,source,question_key,yearmonth) as id,
    survey_id,
    survey_tag,
    boundary_id, 
    source,
    yearmonth,
    question_key,
    lang_question_key,
    num_assessments
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        b.id as boundary_id,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        qmap.key as question_key,
	    qmap.lang_key as lang_question_key,
        count(distinct ag.id) as num_assessments
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        assessments_answerinstitution ans,
        assessments_competencyquestionmap qmap,
        assessments_question q,
        schools_institution s,
        boundary_boundary b
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and qg.id = qmap. questiongroup_id
        and q.id = qmap.question_id
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and q.is_featured = true
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY survey.id,
        surveytag.tag_id,
        b.id,
        qg.source_id,
        qmap.key,
	qmap.lang_key,
        yearmonth
    UNION
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        b.id as boundary_id,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        qmap.key as question_key,
	    qmap.lang_key as lang_question_key,
        count(distinct ag.id) as num_assessments
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_student ag,
        assessments_surveytagmapping surveytag,
        assessments_answerstudent ans,
        schools_student stu,
        assessments_competencyquestionmap qmap,
        assessments_question q,
        schools_institution s,
        boundary_boundary b
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and qg.id = qmap.questiongroup_id
        and q.id = qmap.question_id
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and q.is_featured = true
        and ag.is_verified=true
        and ag.student_id=stu.id 
        and stu.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY survey.id,
        surveytag.tag_id,
        b.id,
        qg.source_id,
        qmap.key,
	    qmap.lang_key,
        yearmonth
    )data
;


/* View for getting number of assessments per question key per survey in a
 * institution.
 * Number of assessment per question key, year month, survey id and institution.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_questionkey_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_questionkey_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,source,question_key,yearmonth) as id,
    survey_id,
    survey_tag,
    institution_id,
    source,
    yearmonth,
    question_key,
    lang_question_key,
    num_assessments
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        ag.institution_id as institution_id,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        qmap.key as question_key,
	qmap.lang_key as lang_question_key,
        count(distinct ag.id) as num_assessments
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        assessments_answerinstitution ans,
        assessments_competencyquestionmap qmap,
        assessments_question q
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and qmap.questiongroup_id = qg.id
        and qmap.question_id = q.id
        and q.is_featured = true
        and ag.is_verified=true
    GROUP BY survey.id,
        ag.institution_id,
        surveytag.tag_id,
        qg.source_id,
        qmap.key,
	qmap.lang_key,
        yearmonth)data
;


/* View for getting number of assessments per question key per questiongroup 
 * per survey in a boundary.
 * Number of assessment per question key, question group,  year month, survey id
 * and boundary.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 AGGREGATES FOR INSTITUTION AND STUDENT TABLES
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_questiongroup_questionkey_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_questiongroup_questionkey_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,boundary_id,source,questiongroup_id,question_key,yearmonth) as id,
    survey_id,
    survey_tag,
    boundary_id,
    source,
    questiongroup_id,
    questiongroup_name,
    yearmonth,
    question_key,
    lang_question_key,
    num_assessments
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        b.id as boundary_id,
        qg.source_id as source,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        qmap.key as question_key,
	    qmap.lang_key as lang_question_key,
        count(distinct ag.id) as num_assessments
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        assessments_answerinstitution ans,
        assessments_question q,
        schools_institution s,
        assessments_competencyquestionmap qmap,
        boundary_boundary b
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and qmap.questiongroup_id = qg.id
        and qmap.question_id = q.id
        and q.is_featured = true
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY survey.id,
        surveytag.tag_id,
        b.id,
        qg.source_id,
        qg.name,qg.id,
        qmap.key,
	qmap.lang_key,
        yearmonth
    UNION
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        b.id as boundary_id,
        qg.source_id as source,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        qmap.key as question_key,
	    qmap.lang_key as lang_question_key,
        count(distinct ag.id) as num_assessments
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_student ag,
        schools_student stu,
        assessments_surveytagmapping surveytag,
        assessments_answerstudent ans,
        assessments_question q,
        schools_institution s,
        assessments_competencyquestionmap qmap,
        boundary_boundary b
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and qmap.questiongroup_id = qg.id
        and qmap.question_id = q.id
        and q.is_featured = true
        and ag.is_verified=true
        and ag.student_id=stu.id
        and stu.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY survey.id,
        surveytag.tag_id,
        b.id,
        qg.source_id,
        qg.name,qg.id,
        qmap.key,
	    qmap.lang_key,
        yearmonth
    )data
;


/* View for getting number of assessments per question key per questiongroup 
 * per survey in a election boundary.
 * Number of assessment per question key, question group,  year month, survey id
 * and election boundary.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_eboundary_questiongroup_questionkey_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_eboundary_questiongroup_questionkey_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,eboundary_id,source,questiongroup_id,question_key,yearmonth) as id,
    survey_id,
    survey_tag,
    eboundary_id,
    const_ward_type_id,
    source,
    questiongroup_id,
    questiongroup_name,
    yearmonth,
    question_key,
    lang_question_key,
    num_assessments
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        eb.id as eboundary_id,
        eb.const_ward_type_id as const_ward_type_id,
        qg.source_id as source,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        qmap.key as question_key,
	qmap.lang_key as lang_question_key,
        count(distinct ag.id) as num_assessments
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        assessments_answerinstitution ans,
        assessments_question q,
        schools_institution s,
        assessments_competencyquestionmap qmap,
        boundary_electionboundary eb
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and qmap.questiongroup_id = qg.id
        and qmap.question_id = q.id
        and q.is_featured = true
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.mp_id = eb.id or s.mla_id = eb.id or s.gp_id = eb.id or s.ward_id = eb.id) 
    GROUP BY survey.id,
        surveytag.tag_id,
        eb.id,
        qg.source_id,
        qg.name,qg.id,
        eb.const_ward_type_id,
        qmap.key,
	qmap.lang_key,
        yearmonth)data
;


/* View for getting number of assessments per question key per questiongroup 
 * per survey in a institution.
 * Number of assessment per question key, question group,  year month, survey id
 * and institution.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 AGGREGATES FOR SCHOOL & STUDENT ASSESSMENTS
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_questiongroup_questionkey_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_questiongroup_questionkey_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,source,questiongroup_id,question_key,yearmonth) as id,
    survey_id,
    survey_tag,
    institution_id,
    source,
    questiongroup_id,
    questiongroup_name,
    yearmonth,
    question_key,
    lang_question_key,
    num_assessments
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        ag.institution_id as institution_id,
        qg.source_id as source,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        qmap.key as question_key,
	qmap.lang_key as lang_question_key,
        count(distinct ag.id) as num_assessments
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        assessments_answerinstitution ans,
        assessments_competencyquestionmap qmap,
        assessments_question q
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and qmap.questiongroup_id = qg.id
        and qmap.question_id = q.id
        and q.is_featured = true
        and ag.is_verified=true
    GROUP BY survey.id,
        surveytag.tag_id,
        ag.institution_id,
        qg.source_id,
        qg.name,qg.id,
        qmap.key,
	qmap.lang_key,
        yearmonth
    UNION
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        stu.institution_id as institution_id,
        qg.source_id as source,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        qmap.key as question_key,
	    qmap.lang_key as lang_question_key,
        count(distinct ag.id) as num_assessments
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_student ag,
        schools_student stu,
        assessments_surveytagmapping surveytag,
        assessments_answerstudent ans,
        assessments_competencyquestionmap qmap,
        assessments_question q
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.id = ans.answergroup_id
        and ag.student_id=stu.id
        and ans.question_id = q.id
        and qmap.questiongroup_id = qg.id
        and qmap.question_id = q.id
        and q.is_featured = true
        and ag.is_verified=true
    GROUP BY survey.id,
        surveytag.tag_id,
        stu.institution_id,
        qg.source_id,
        qg.name,qg.id,
        qmap.key,
	    qmap.lang_key,
        yearmonth
    )data
;


/* View for getting number of assessments per question group per student gender 
 * in a survey per election boundary.
 * Number of assessment specific to the child gender, per question group,  
 * year month, survey id and election boundary.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_eboundary_questiongroup_gender_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_eboundary_questiongroup_gender_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,eboundary_id,source,questiongroup_id,gender,yearmonth) as id,
    survey_id,
    survey_tag,
    eboundary_id,
    source,
    questiongroup_id,
    questiongroup_name,
    gender,
    yearmonth,
    count(ag_id) as num_assessments
from
    (select distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        eb.id as eboundary_id,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        ans1.answer as gender,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        ag.id as ag_id
    from assessments_answergroup_institution ag inner join assessments_answerinstitution ans1 on (ag.id=ans1.answergroup_id and ans1.question_id=291),
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
        schools_institution s,
        boundary_electionboundary eb
    where
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and ans.question_id=q.id
        and q.is_featured=true
        and stmap.survey_id=qg.survey_id
        and qg.survey_id in (1,18)
        and ag.institution_id = s.id
        and (s.mp_id = eb.id or s.mla_id = eb.id or s.gp_id = eb.id or s.ward_id = eb.id) 
    group by ag.id,qg.survey_id,eb.id,stmap.tag_id,yearmonth,source,qg.id, ans1.answer)data
GROUP BY survey_id, survey_tag,eboundary_id,source,yearmonth,questiongroup_id,questiongroup_name,gender ;


/* View for getting number of assessments per question group per student gender 
 * in a survey per boundary.
 * Number of assessment specific to the child gender, per question group,  
 * year month, survey id and boundary.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_questiongroup_gender_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_questiongroup_gender_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,boundary_id,source,questiongroup_id,gender,yearmonth) as id,
    survey_id,
    survey_tag,
    boundary_id,
    source,
    questiongroup_id,
    questiongroup_name,
    gender,
    yearmonth,
    count(ag_id) as num_assessments
from
    (select distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        b.id as boundary_id,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        ans1.answer as gender,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        ag.id as ag_id
    from assessments_answergroup_institution ag inner join assessments_answerinstitution ans1 on (ag.id=ans1.answergroup_id and ans1.question_id=291),
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
        schools_institution s,
        boundary_boundary b
    where
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and ans.question_id=q.id
        and q.is_featured=true
        and stmap.survey_id=qg.survey_id
        and qg.survey_id in (1,18)
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    group by ag.id,qg.survey_id,b.id,stmap.tag_id,yearmonth,source,qg.id, ans1.answer
    UNION
    select distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        b.id as boundary_id,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        ans1.answer as gender,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        ag.id as ag_id
    from assessments_answergroup_student ag inner join assessments_answerstudent ans1 on (ag.id=ans1.answergroup_id and ans1.question_id=291),
        assessments_answerstudent ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
        schools_institution s,
        schools_student stu,
        boundary_boundary b
    where
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and ans.question_id=q.id
        and q.is_featured=true
        and stmap.survey_id=qg.survey_id
        and qg.survey_id in (36)
        and ag.student_id = stu.id
        and stu.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    group by ag.id,qg.survey_id,b.id,stmap.tag_id,yearmonth,source,qg.id, ans1.answer)data
GROUP BY survey_id, survey_tag,boundary_id,source,yearmonth,questiongroup_id,questiongroup_name,gender ;


/* View for getting number of assessments per question group per student gender 
 * in a survey per institution.
 * Number of assessment specific to the child gender, per question group,  
 * year month, survey id and institution.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_questiongroup_gender_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_questiongroup_gender_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,source,questiongroup_id,gender,yearmonth) as id,
    survey_id,
    survey_tag,
    institution_id,
    source,
    questiongroup_id,
    questiongroup_name,
    gender,
    yearmonth,
    count(ag_id) as num_assessments
from
    (select distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        ag.institution_id as institution_id,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        ans1.answer as gender,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        ag.id as ag_id
    from assessments_answergroup_institution ag inner join assessments_answerinstitution ans1 on (ag.id=ans1.answergroup_id and ans1.question_id=291),
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q
    where
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and ans.question_id=q.id
        and q.is_featured=true
        and stmap.survey_id=qg.survey_id
        and qg.survey_id in (1,18)
    group by ag.id,qg.survey_id,stmap.tag_id,ag.institution_id,yearmonth,source,qg.id, ans1.answer)data
GROUP BY survey_id, survey_tag,institution_id,source,yearmonth,questiongroup_id,questiongroup_name,gender ;


/* View for getting number of assessments that were answered correctly for a
 * question key per survey for an election boundary.
 * Number of correct assessments, yearmonth, question key, survey_id and 
 * election boundary. 
 * For getting the correct answer the assessments_questiongroupkey table is 
 * used for student assessment type and for institution assessment type 
 * assessments_competencyquestionmap table is used. These table has the 
 * max_score per question group and question key.
 * An average of score is calulated and shown
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_eboundary_questionkey_correctans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_eboundary_questionkey_correctans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s', survey_id,survey_tag,eboundary_id,source,question_key,yearmonth) as id,
    survey_id, 
    survey_tag,
    eboundary_id,
    source,
    question_key,
    lang_question_key,
    yearmonth,
    agg.numcorrectans as numcorrect,
    agg.numtotalans as numtotal,
    agg.numcorrectans::decimal*100/agg.numtotalans as average
FROM
    (SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        eb.id as eboundary_id,
        qmap.key as question_key,
	    qmap.lang_key as lang_question_key,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
	    count(ans.id) filter (where answer in ('Yes','1')) as numcorrectans, 
	    count(ans.id) as numtotalans
    FROM 
        assessments_answergroup_institution ag,
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
        assessments_competencyquestionmap qmap, --table for storing max score
        schools_institution s,
        boundary_electionboundary eb
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and qg.id=qmap.questiongroup_id
        and ans.question_id=q.id
        and q.id = qmap.question_id
        and q.is_featured=true
        and stmap.survey_id=qg.survey_id
        and qg.type_id='assessment'
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.mp_id = eb.id or s.mla_id = eb.id or s.ward_id = eb.id or s.gp_id = eb.id) 
    GROUP BY qmap.key,qmap.lang_key,eb.id,qg.survey_id,stmap.tag_id,yearmonth,source)agg
GROUP BY survey_id,survey_tag,eboundary_id,source,yearmonth,question_key,lang_question_key,numcorrectans,numtotalans ;



/* View for getting number of assessments that were answered correctly for a
 * question key per survey for an boundary.
 * Number of correct assessments, yearmonth, question key, survey_id and 
 * boundary. 
 * For getting the correct answer the assessments_questiongroupkey table is 
 * used for student assessment type and for institution assessment type 
 * assessments_competencyquestionmap table is used. These table has the 
 * max_score per question group and question key.
 * A child's assessment for a question key is considered correct if the value 
 * of the child's answer for that question key is equal to or greater than the
 * answer specified in those tables.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 AGG for student and institutional assessments
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_questionkey_correctans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_questionkey_correctans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s', survey_id,survey_tag,boundary_id,source,question_key,yearmonth) as id,
    survey_id, 
    survey_tag,
    boundary_id,
    source,
    question_key,
    lang_question_key,
    yearmonth,
    agg.numcorrectans as numcorrect,
    agg.numtotalans as numtotal,
    agg.numcorrectans::decimal*100/agg.numtotalans as average
FROM
    (SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        b.id as boundary_id,
        qmap.key as question_key,
	qmap.lang_key as lang_question_key,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
	count(ans.id) filter (where answer in ('Yes','1')) as numcorrectans, 
	count(ans.id) as numtotalans
    FROM assessments_answergroup_institution ag,
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
        assessments_competencyquestionmap qmap, --table for scoring max score
        schools_institution s,
        boundary_boundary b
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and qg.id=qmap.questiongroup_id
        and ans.question_id=q.id
        and q.id = qmap.question_id
        and q.is_featured=true
        and stmap.survey_id=qg.survey_id
        and qg.type_id='assessment'
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY qmap.key,qmap.lang_key,b.id,qg.survey_id,stmap.tag_id,yearmonth,source
    UNION
    SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        b.id as boundary_id,
        qmap.key as question_key,
	qmap.lang_key as lang_question_key,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
	count(ans.id) filter (where answer in ('Yes','1')) as numcorrectans, 
	count(ans.id) as numtotalans
    FROM assessments_answergroup_student ag,
        assessments_answerstudent ans,
        schools_student stu,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
        assessments_competencyquestionmap qmap, --table for scoring max score
        schools_institution s,
        boundary_boundary b
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and qg.id=qmap.questiongroup_id
        and ans.question_id=q.id
        and q.id = qmap.question_id
        and q.is_featured=true
        and stmap.survey_id=qg.survey_id
        and qg.type_id='assessment'
        and ag.is_verified=true
        and ag.student_id = stu.id
        and stu.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY qmap.key,qmap.lang_key,b.id,qg.survey_id,stmap.tag_id,yearmonth,source
    )agg
GROUP BY survey_id,survey_tag,boundary_id,source,yearmonth,question_key,lang_question_key,numcorrectans,numtotalans ;


/* View for getting number of assessments that were answered correctly for a
 * question key per survey for an institution.
 * Number of correct assessments, yearmonth, question key, survey_id and 
 * institution. 
 * For getting the correct answer the assessments_questiongroupkey table is 
 * used for student assessment type and for institution assessment type 
 * assessments_competencyquestionmap table is used. These table has the 
 * max_score per question group and question key.
 * A child's assessment for a question key is considered correct if the value 
 * of the child's answer for that question key is equal to or greater than the
 * answer specified in those tables.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_questionkey_correctans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_questionkey_correctans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,source,question_key,yearmonth) as id,
    survey_id, 
    survey_tag,
    institution_id,
    source,
    question_key,
    lang_question_key,
    yearmonth,
    agg.numcorrectans as numcorrect,
    agg.numtotalans as numtotal,
    agg.numcorrectans::decimal*100/agg.numtotalans as average
FROM
    (SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        ag.institution_id as institution_id,
        qmap.key as question_key,
	qmap.lang_key as lang_question_key,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
	count(ans.id) filter (where answer in ('Yes','1')) as numcorrectans, 
	count(ans.id) as numtotalans
    FROM assessments_answergroup_institution ag,
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
        assessments_competencyquestionmap qmap --table for storing max score
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and qg.id=qmap.questiongroup_id
        and ans.question_id=q.id
        and q.id = qmap.question_id
        and q.is_featured=true
        and stmap.survey_id=qg.survey_id
        and qg.type_id='assessment'
        and ag.is_verified=true
    GROUP BY qmap.key,qmap.lang_key,ag.institution_id,qg.survey_id,stmap.tag_id,yearmonth,source)agg
GROUP BY survey_id,survey_tag,institution_id,source,yearmonth,question_key,lang_question_key,numcorrectans,numtotalans ;


/* View for getting number of assessments that were answered correctly for a
 * question key per question group per survey for an election boundary.
 * Number of correct assessments, yearmonth, question key, question group,
 * survey_id and election boundary. 
 * For getting the correct answer the assessments_questiongroupkey table is 
 * used for student assessment type and for institution assessment type 
 * assessments_competencyquestionmap table is used. These table has the 
 * max_score per question group and question key.
 * A child's assessment for a question key is considered correct if the value 
 * of the child's answer for that question key is equal to or greater than the
 * answer specified in those tables.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_eboundary_questiongroup_questionkey_correctans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_eboundary_questiongroup_questionkey_correctans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,eboundary_id,source,questiongroup_id,question_key,yearmonth) as id,
    survey_id, 
    survey_tag,
    eboundary_id,
    source,
    questiongroup_id,
    questiongroup_name,
    question_key,
    lang_question_key,
    yearmonth,
    agg.numcorrectans as numcorrect,
    agg.numtotalans as numtotal,
    agg.numcorrectans::decimal*100/agg.numtotalans as average
FROM
    (SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        eb.id as eboundary_id,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        qmap.key as question_key,
	qmap.lang_key as lang_question_key,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
	count(ans.id) filter (where answer in ('Yes','1')) as numcorrectans, 
	count(ans.id) as numtotalans
    FROM assessments_answergroup_institution ag,
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
        assessments_competencyquestionmap qmap, --table for max score
        schools_institution s,
        boundary_electionboundary eb
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and qg.id=qmap.questiongroup_id
        and ans.question_id=q.id
        and q.id = qmap.question_id
        and q.is_featured=true
        and stmap.survey_id=qg.survey_id
        and qg.type_id='assessment'
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.mp_id = eb.id or s.mla_id = eb.id or s.ward_id = eb.id or s.gp_id = eb.id) 
    GROUP BY qmap.key,qmap.lang_key,eb.id,qg.survey_id,stmap.tag_id,yearmonth,source,qg.id,qg.name)agg
GROUP BY survey_id, survey_tag,eboundary_id,source,yearmonth,question_key,lang_question_key,questiongroup_id,questiongroup_name,numcorrectans,numtotalans;


/* View for getting number of assessments that were answered correctly for a
 * question key per question group per survey for an boundary.
 * Number of correct assessments, yearmonth, question key, question group,
 * survey_id and boundary. 
 * For getting the correct answer the assessments_questiongroupkey table is 
 * used for student assessment type and for institution assessment type 
 * assessments_competencyquestionmap table is used. These table has the 
 * max_score per question group and question key.
 * A child's assessment for a question key is considered correct if the value 
 * of the child's answer for that question key is equal to or greater than the
 * answer specified in those tables.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_questiongroup_questionkey_correctans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_questiongroup_questionkey_correctans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,boundary_id,source,questiongroup_id,question_key,yearmonth) as id,
    survey_id, 
    survey_tag,
    boundary_id,
    source,
    questiongroup_id,
    questiongroup_name,
    question_key,
    lang_question_key,
    yearmonth,
    agg.numcorrectans as numcorrect,
    agg.numtotalans as numtotal,
    agg.numcorrectans::decimal*100/agg.numtotalans as average
FROM
    (SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        b.id as boundary_id,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        qmap.key as question_key,
	qmap.lang_key as lang_question_key,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
	count(ans.id) filter (where answer in ('Yes','1')) as numcorrectans, 
	count(ans.id) as numtotalans
    FROM assessments_answergroup_institution ag,
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
        assessments_competencyquestionmap qmap, --table for max score
        schools_institution s,
        boundary_boundary b
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and qg.id=qmap.questiongroup_id
        and ans.question_id=q.id
        and q.id = qmap.question_id
        and q.is_featured=true
        and stmap.survey_id=qg.survey_id
        and qg.type_id='assessment'
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY qmap.key,qmap.lang_key,b.id,qg.survey_id,stmap.tag_id,yearmonth,source,qg.id,qg.name
    UNION
    SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        b.id as boundary_id,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        qmap.key as question_key,
	qmap.lang_key as lang_question_key,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
	count(ans.id) filter (where answer in ('Yes','1')) as numcorrectans, 
	count(ans.id) as numtotalans
    FROM assessments_answergroup_student ag,
        assessments_answerstudent ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
        schools_student stu,
        assessments_competencyquestionmap qmap, --table for max score
        schools_institution s,
        boundary_boundary b
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and qg.id=qmap.questiongroup_id
        and ans.question_id=q.id
        and q.id = qmap.question_id
        and q.is_featured=true
        and stmap.survey_id=qg.survey_id
        and qg.type_id='assessment'
        and ag.is_verified=true
        and ag.student_id = stu.id
        and stu.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY qmap.key,qmap.lang_key,b.id,qg.survey_id,stmap.tag_id,yearmonth,source,qg.id,qg.name
    )agg
GROUP BY survey_id, survey_tag,boundary_id,source,yearmonth,question_key,lang_question_key,questiongroup_id,questiongroup_name,numcorrectans,numtotalans;


/* View for getting number of assessments that were answered correctly for a
 * question key per question group per survey for an institution.
 * Number of correct assessments, yearmonth, question key, question group,
 * survey_id and institution. 
 * For getting the correct answer the assessments_questiongroupkey table is 
 * used for student assessment type and for institution assessment type 
 * assessments_competencyquestionmap table is used. These table has the 
 * max_score per question group and question key.
 * A child's assessment for a question key is considered correct if the value 
 * of the child's answer for that question key is equal to or greater than the
 * answer specified in those tables.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_questiongroup_questionkey_correctans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_questiongroup_questionkey_correctans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,source,questiongroup_id,question_key,yearmonth) as id,
    survey_id, 
    survey_tag,
    institution_id,
    source,
    questiongroup_id,
    questiongroup_name,
    question_key,
    lang_question_key,
    yearmonth,
    agg.numcorrectans as numcorrect,
    agg.numtotalans as numtotal,
    agg.numcorrectans::decimal*100/agg.numtotalans as average
FROM
    (SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        ag.institution_id as institution_id,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        qmap.key as question_key,
	qmap.lang_key as lang_question_key,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
	count(ans.id) filter (where answer in ('Yes','1')) as numcorrectans, 
	count(ans.id) as numtotalans
    FROM assessments_answergroup_institution ag,
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
        assessments_competencyquestionmap qmap --table for storing max score
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and qg.id=qmap.questiongroup_id
        and ans.question_id=q.id
        and q.id = qmap.question_id
        and q.is_featured=true
        and stmap.survey_id=qg.survey_id
        and qg.type_id='assessment'
        and ag.is_verified=true
    GROUP BY qmap.key,qmap.lang_key,qg.survey_id,stmap.tag_id,yearmonth,source,qg.id,qg.name,ag.institution_id)agg
GROUP BY survey_id, survey_tag,institution_id,source,yearmonth,question_key,lang_question_key,questiongroup_id,questiongroup_name,numcorrectans,numtotalans;


/* View for getting number of students who answered with a particular answer 
 * option for a question, questiongroup, yearmonth, survey and election boundary
 * Number of answers of a particular answer option, per question, questiongroup,
 * survey, year month and election boundary.
 * There are unions between three queries:- There is a different logic for tlm
 * and group work. So there are 2 unions for school assessment and 1 for student
 * For tlm and group the math class happening has to be true. 
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_eboundary_questiongroup_ans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_eboundary_questiongroup_ans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,eboundary_id,source,questiongroup_id,question_id,answer_option,yearmonth) as id,
    survey_id,
    survey_tag,
    eboundary_id,
    source,
    questiongroup_id,
    yearmonth,
    question_id,
    question_desc,
    answer_option,
    num_answers
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        eb.id as eboundary_id,
        qg.source_id as source,
        qg.id as questiongroup_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        ans.question_id as question_id,
        case q.display_text when '' then q.question_text else q.display_text end as question_desc,
        ans.answer as answer_option,
        count(ans) as num_answers
    FROM assessments_survey survey,
        assessments_questiongroup as qg,
        assessments_answergroup_institution as ag,
        assessments_surveytagmapping as surveytag,
        assessments_question q,
        assessments_answerinstitution ans,
        schools_institution s,
        boundary_electionboundary eb
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and q.is_featured = true
        and q.key not in ('ivrss-gka-tlm-in-use','ivrss-group-work')
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.gp_id = eb.id or s.ward_id = eb.id or s.mla_id = eb.id or s.mp_id = eb.id) 
    GROUP BY survey.id,
        surveytag.tag_id,
        qg.source_id,
        eb.id,
        qg.id,
        q.display_text,
        q.question_text,
        ans.question_id,
        ans.answer,
        yearmonth)data
union 
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,eboundary_id,source,questiongroup_id,question_id,answer_option,yearmonth) as id,
    survey_id,
    survey_tag,
    eboundary_id,
    source,
    questiongroup_id,
    yearmonth,
    question_id,
    question_desc,
    answer_option,
    num_answers
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        eb.id as eboundary_id,
        qg.source_id as source,
        qg.id as questiongroup_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        ans.question_id as question_id,
        case q.display_text when '' then q.question_text else q.display_text end as question_desc,
        ans.answer as answer_option,
        count(ans) as num_answers
    FROM assessments_survey survey,
        assessments_questiongroup as qg,
        assessments_answergroup_institution as ag,
        assessments_surveytagmapping as surveytag,
        assessments_question q,
        assessments_answerinstitution ans inner join assessments_answerinstitution ans1 on ans.answergroup_id=ans1.answergroup_id and ans1.question_id in (select id from assessments_question where key='ivrss-math-class-happening') and ans1.answer in ('Yes','1'), -- only answers that have math class mapping set to Yes.
        schools_institution s,
        boundary_electionboundary eb
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and q.is_featured = true
        and q.key in ('ivrss-gka-tlm-in-use','ivrss-group-work') --For TLM and Group work 
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.gp_id = eb.id or s.ward_id = eb.id or s.mla_id = eb.id or s.mp_id = eb.id) 
    GROUP BY survey.id,
        surveytag.tag_id,
        qg.source_id,
        eb.id,
        qg.id,
        q.display_text,
        q.question_text,
        ans.question_id,
        ans.answer,
        yearmonth)data
;


/* View for getting number of students who answered with a particular answer 
 * option for a question, questiongroup, yearmonth, survey and boundary
 * Number of answers of a particular answer option, per question, questiongroup,
 * survey, year month and boundary.
 * There are unions between three queries:- There is a different logic for tlm
 * and group work. So there are 2 unions for school assessment and 1 for student
 * For tlm and group the math class happening has to be true. 
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_questiongroup_ans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_questiongroup_ans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,boundary_id,source,questiongroup_id,question_id,answer_option,yearmonth) as id,
    survey_id,
    survey_tag,
    boundary_id,
    source,
    questiongroup_id,
    yearmonth,
    question_id,
    question_desc,
    answer_option,
    num_answers
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        b.id as boundary_id,
        qg.source_id as source,
        qg.id as questiongroup_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        ans.question_id as question_id,
        case q.display_text when '' then q.question_text else q.display_text end as question_desc,
        ans.answer as answer_option,
        count(ans) as num_answers
    FROM assessments_survey survey,
        assessments_questiongroup as qg,
        assessments_answergroup_institution as ag,
        assessments_surveytagmapping as surveytag,
        assessments_question q,
        assessments_answerinstitution ans,
        schools_institution s,
        boundary_boundary b
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and q.is_featured = true
        and q.key not in ('ivrss-gka-tlm-in-use','ivrss-group-work')
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY survey.id,
        surveytag.tag_id,
        qg.source_id,
        b.id,
        qg.id,
        q.display_text,
        q.question_text,
        ans.question_id,
        ans.answer,
        yearmonth)data
union 
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,boundary_id,source,questiongroup_id,question_id,answer_option,yearmonth) as id,
    survey_id,
    survey_tag,
    boundary_id,
    source,
    questiongroup_id,
    yearmonth,
    question_id,
    question_desc,
    answer_option,
    num_answers
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        b.id as boundary_id,
        qg.source_id as source,
        qg.id as questiongroup_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        ans.question_id as question_id,
        case q.display_text when '' then q.question_text else q.display_text end as question_desc,
        ans.answer as answer_option,
        count(ans) as num_answers
    FROM assessments_survey survey,
        assessments_questiongroup as qg,
        assessments_answergroup_institution as ag,
        assessments_surveytagmapping as surveytag,
        assessments_question q,
        assessments_answerinstitution ans inner join assessments_answerinstitution ans1 on ans.answergroup_id=ans1.answergroup_id and ans1.question_id in (select id from assessments_question where key='ivrss-math-class-happening') and ans1.answer in ('Yes','1'), --Only assessments where Math Class was happening. 
        schools_institution s,
        boundary_boundary b
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and q.is_featured = true
        and ans.question_id = q.id
        and q.key in ('ivrss-gka-tlm-in-use','ivrss-group-work')--For TLM and group work
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY survey.id,
        surveytag.tag_id,
        qg.source_id,
        b.id,
        qg.id,
        q.display_text,
        q.question_text,
        ans.question_id,
        ans.answer,
        yearmonth)data
;


/* View for getting number of students who answered with a particular answer 
 * option for a question, questiongroup, yearmonth, survey and institution 
 * Number of answers of a particular answer option, per question, questiongroup,
 * survey, year month and institution.
 * There are unions between three queries:- There is a different logic for tlm
 * and group work. So there are 2 unions for school assessment and 1 for student
 * For tlm and group the math class happening has to be true. 
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_questiongroup_ans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_questiongroup_ans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,questiongroup_id,question_id,answer_option,yearmonth) as id,
    survey_id,
    survey_tag,
    institution_id,
    source,
    questiongroup_id,
    yearmonth,
    question_id,
    question_desc,
    lang_questiontext,
    answer_option,
    num_answers
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        s.id as institution_id,
        qg.source_id as source,
        qg.id as questiongroup_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        ans.question_id as question_id,
        case q.display_text when '' then q.question_text else q.display_text end as question_desc,
	q.lang_name as lang_questiontext,
        ans.answer as answer_option,
        count(ans) as num_answers
    FROM assessments_survey survey,
        assessments_questiongroup as qg,
        assessments_answergroup_institution as ag,
        assessments_surveytagmapping as surveytag,
        assessments_question q,
        assessments_answerinstitution ans,
        schools_institution s
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and q.is_featured = true
        and q.key not in ('ivrss-gka-tlm-in-use','ivrss-group-work')
        and ag.is_verified=true
        and ag.institution_id = s.id
    GROUP BY survey.id,
        surveytag.tag_id,
        s.id,
        qg.source_id,
        qg.id,
        q.display_text,
        q.question_text,
	q.lang_name,
        ans.question_id,
        ans.answer,
        yearmonth)data
union 
SELECT format('A%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,questiongroup_id,question_id,answer_option,yearmonth) as id,
    survey_id,
    survey_tag,
    institution_id,
    source,
    questiongroup_id,
    yearmonth,
    question_id,
    question_desc,
    lang_questiontext,
    answer_option,
    num_answers
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        s.id as institution_id,
        qg.source_id as source,
        qg.id as questiongroup_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        ans.question_id as question_id,
        case q.display_text when '' then q.question_text else q.display_text end as question_desc,
	q.lang_name as lang_questiontext,
        ans.answer as answer_option,
        count(ans) as num_answers
    FROM assessments_survey survey,
        assessments_questiongroup as qg,
        assessments_answergroup_institution as ag,
        assessments_surveytagmapping as surveytag,
        assessments_question q,
        assessments_answerinstitution ans inner join assessments_answerinstitution ans1 on ans.answergroup_id=ans1.answergroup_id and ans1.question_id in (select id from assessments_question where key='ivrss-math-class-happening') and ans1.answer in ('Yes','1'), --Assessments that have math class happening is Yes
        schools_institution s
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and q.is_featured = true
        and q.key in ('ivrss-gka-tlm-in-use','ivrss-group-work') --For TLM and group work
        and ag.is_verified=true
        and ag.institution_id = s.id
    GROUP BY survey.id,
        surveytag.tag_id,
        s.id,
        qg.source_id,
        qg.id,
        q.display_text,
        q.question_text,
	q.lang_name,
        ans.question_id,
        ans.answer,
        yearmonth)data
;

/* View for getting information for a questiongorup for a survey for a election
 * boundary:
 * It has:- Survey id, Survey tag, election boundary, Year Month (YYMM),
 * Number of assessments, Number of children assessed, Number of schools, 
 * Number of users and date of last assessment.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * In case of GP Contests (School assessment):
 *       the number of answer groups == number of children assessed.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */ 
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_eboundary_questiongroup_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_eboundary_questiongroup_agg AS
SELECT format('A%s_%s_%s_%s_%s', survey_id,survey_tag,eboundary_id,questiongroup_id,yearmonth) as id,
    survey_id,
    survey_tag,
    eboundary_id,
    questiongroup_id,
    yearmonth,
    num_assessments,
    num_schools,
    num_children,
    num_users,
    last_assessment
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        qg.id as questiongroup_id,
        eb.id as eboundary_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        count(distinct ag.id) as num_assessments,
        count(distinct ag.institution_id) as num_schools,
        case survey.id when 1 then count(distinct ag.id) when 18 then count(distinct ag.id) else 0 end as num_children, -- For GP contest
        count(distinct ag.created_by_id) as num_users,
        max(ag.date_of_visit) as last_assessment
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        schools_institution s,
        boundary_electionboundary eb
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        --and survey.id in (1, 2, 4, 5, 6, 7, 11)
        and ag.institution_id = s.id
        and (s.gp_id = eb.id or s.ward_id = eb.id or s.mla_id = eb.id or s.mp_id = eb.id) 
        and ag.is_verified=true
    GROUP BY survey.id,
        surveytag.tag_id,
        qg.id,
        ag.is_verified,
        eb.id,
        yearmonth)data
;


/* View for getting information for a questiongorup for a survey for a boundary:
 * It has:- Survey id, Survey tag, boundary, Year Month (YYMM),
 * Number of assessments, Number of children assessed, Number of schools, 
 * Number of users and date of last assessment.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * In case of GP Contests (School assessment):
 *       the number of answer groups == number of children assessed.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 AGG for both institution and student assessments. There's a union.
 */ 
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_questiongroup_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_questiongroup_agg AS
SELECT format('A%s_%s_%s_%s_%s', survey_id,survey_tag,boundary_id,questiongroup_id,yearmonth) as id,
    survey_id,
    survey_tag,
    boundary_id,
    questiongroup_id,
    yearmonth,
    num_assessments,
    num_schools,
    num_children,
    num_users,
    last_assessment
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        qg.id as questiongroup_id,
        b.id as boundary_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        count(distinct ag.id) as num_assessments,
        count(distinct ag.institution_id) as num_schools,
        case survey.id when 1 then count(distinct ag.id) when 18 then count(distinct ag.id) else 0 end as num_children, --For GP Contest
        count(distinct ag.created_by_id) as num_users,
        max(ag.date_of_visit) as last_assessment
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        schools_institution s,
        boundary_boundary b
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
        and ag.is_verified=true
    GROUP BY survey.id,
        surveytag.tag_id,
        qg.id,
        ag.is_verified,
        b.id,
        yearmonth
    UNION
      SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        qg.id as questiongroup_id,
        b.id as boundary_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        count(distinct ag.id) as num_assessments,
        count(distinct stu.institution_id) as num_schools,
        case survey.id when 1 then count(distinct ag.id) when 18 then count(distinct ag.id) else 0 end as num_children, --For GP Contest
        count(distinct ag.created_by_id) as num_users,
        max(ag.date_of_visit) as last_assessment
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_student ag,
        schools_student stu,
        assessments_surveytagmapping surveytag,
        schools_institution s,
        boundary_boundary b
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.student_id=stu.id
        and stu.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
        and ag.is_verified=true
    GROUP BY survey.id,
        surveytag.tag_id,
        qg.id,
        ag.is_verified,
        b.id,
        yearmonth
    )data
;


/* View for getting information for a questiongorup for a survey for an 
 * institution:
 * It has:- Survey id, Survey tag, Institution, Year Month (YYMM),
 * Number of assessments, Number of children assessed, Number of schools, 
 * Number of users and date of last assessment.
 * There are unions between two queries:- 1 for school asssessment and another
 * for student assessment.
 * In case of GP Contests (School assessment):
 *       the number of answer groups == number of children assessed.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */ 
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_questiongroup_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_questiongroup_agg AS
SELECT format('A%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,questiongroup_id,yearmonth) as id,
    survey_id,
    survey_tag,
    institution_id,
    questiongroup_id,
    yearmonth,
    num_assessments,
    num_children,
    num_users,
    last_assessment
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        qg.id as questiongroup_id,
        ag.institution_id as institution_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        count(distinct ag.id) as num_assessments,
        case survey.id when 1 then count(distinct ag.id) when 18 then count(distinct ag.id) else 0 end as num_children,
        count(distinct ag.created_by_id) as num_users,
        max(ag.date_of_visit) as last_assessment
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        --and survey.id in (1, 2, 4, 5, 6, 7, 11)
        and ag.is_verified=true
    GROUP BY survey.id,
        surveytag.tag_id,
        qg.id,
        ag.is_verified,
        ag.institution_id, 
        yearmonth)data
;


/* View for getting the number of schools and students that arre mapped to a 
 * survey in a boundary for an academic year.
 * assessments_surveytaginstitutionmapping is used for getting the institutions
 * that were mapped to the survey tag for a particular academic year and 
 * assessments_surveytagclassmapping for studentgroup that was mapped for that
 * year. 
 * These two tables are used to get the counts for different academic years.
 * For 1617 only academic year 1617 is used. 
 * For 1718 both the 1617 and 1718 is used.
 * For 1819: 1617, 1718 and 1819 is used.
 * For 1617 and 1718 academic years we did the GKA only in Karanataka where we
 * had the children data. Going forward we dont have the children data for the
 * schools in our database. So we need to get one more union in place which is 
 * there for academic year 1819, which counts schools that have no children 
 * associated with it too.
 * Note:- For new academic year the code of this view will have to be updated.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_tagmapping_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_tagmapping_agg AS
SELECT distinct format('A%s_%s_%s', instmap.tag_id, b.id, instmap.academic_year_id) as id,
    instmap.tag_id as survey_tag,
    b.id as boundary_id, 
    instmap.academic_year_id as academic_year_id,
    count(distinct instmap.institution_id) as num_schools,
    count(distinct stu.id) as num_students
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id  
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1617'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id 
    and stu.status_id !='DL'
GROUP BY
    instmap.tag_id,
    b.id,
    instmap.academic_year_id
union
SELECT distinct format('A%s_%s_%s', data.survey_tag, data.boundary_id, data.academic_year_id) as id,
    data.survey_tag as survey_tag,
    data.boundary_id as boundary_id, 
    data.academic_year_id as academic_year_id,
    count(distinct school_id) as num_schools,
    count(distinct student_id) as num_students
FROM
(
 SELECT distinct 
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id, 
    '1718' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM    
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id  
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1617'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id 
    and stu.status_id !='DL'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id, 
    instmap.academic_year_id as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id 
FROM    
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id  
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1718'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id 
    and stu.status_id !='DL'
)data
GROUP BY
data.survey_tag,
data.boundary_id,
data.academic_year_id
union
SELECT distinct format('A%s_%s_%s', data.survey_tag, data.boundary_id, data.academic_year_id) as id,
    data.survey_tag as survey_tag,
    data.boundary_id as boundary_id, 
    data.academic_year_id as academic_year_id,
    count(distinct school_id) as num_schools,
    count(case when student_id!=0 then student_id end) as num_students
FROM
(
 SELECT distinct 
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id, 
    '1819' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM    
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id  
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1617'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id 
    and stu.status_id !='DL'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id, 
    '1819' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id 
FROM    
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id  
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1718'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id 
    and stu.status_id !='DL'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id, 
    '1819' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id 
FROM    
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id  
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1819'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id 
    and stu.status_id !='DL'
union
 SELECT distinct
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id,
    '1819' as academic_year_id,
    instmap.institution_id as school_id,
    0 as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    boundary_boundary b
WHERE
    instmap.institution_id = s.id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and s.id not in (select distinct institution_id from schools_studentgroup)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1819'
)data
GROUP BY
data.survey_tag,
data.boundary_id,
data.academic_year_id
union
SELECT distinct format('A%s_%s_%s', data.survey_tag, data.boundary_id, data.academic_year_id) as id,
    data.survey_tag as survey_tag,
    data.boundary_id as boundary_id, 
    data.academic_year_id as academic_year_id,
    count(distinct school_id) as num_schools,
    count(case when student_id!=0 then student_id end) as num_students
FROM
(
 SELECT distinct 
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id, 
    '1920' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM    
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id  
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1617'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id 
    and stu.status_id !='DL'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id, 
    '1920' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id 
FROM    
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id  
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1718'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id 
    and stu.status_id !='DL'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id, 
    '1920' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id 
FROM    
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id  
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1819'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id 
    and stu.status_id !='DL'
union
 SELECT distinct
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id,
    '1920' as academic_year_id,
    instmap.institution_id as school_id,
    0 as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    boundary_boundary b
WHERE
    instmap.institution_id = s.id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and s.id not in (select distinct institution_id from schools_studentgroup)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1819'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id, 
    '1920' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id 
FROM    
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id  
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1920'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id 
    and stu.status_id !='DL'
union
 SELECT distinct
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id,
    '1920' as academic_year_id,
    instmap.institution_id as school_id,
    0 as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    boundary_boundary b
WHERE
    instmap.institution_id = s.id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and s.id not in (select distinct institution_id from schools_studentgroup)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1920'
)data
GROUP BY
data.survey_tag,
data.boundary_id,
data.academic_year_id

union
SELECT distinct format('A%s_%s_%s', data.survey_tag, data.boundary_id, data.academic_year_id) as id,
    data.survey_tag as survey_tag,
    data.boundary_id as boundary_id,
    data.academic_year_id as academic_year_id,
    count(distinct school_id) as num_schools,
    count(case when student_id!=0 then student_id end) as num_students
FROM
(
 SELECT distinct
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id,
    '2021' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1617'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
 union
 SELECT distinct
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id,
    '2021' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1718'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id,
    '2021' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1819'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id,
    '2021' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1920'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
union
 SELECT distinct
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id,
    '2021' as academic_year_id,
    instmap.institution_id as school_id,
    0 as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    boundary_boundary b
WHERE
    instmap.institution_id = s.id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and s.id not in (select distinct institution_id from schools_studentgroup)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1920'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id,
    '2021' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '2021'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
union
 SELECT distinct
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id,
    '2021' as academic_year_id,
    instmap.institution_id as school_id,
    0 as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    boundary_boundary b
WHERE
    instmap.institution_id = s.id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and s.id not in (select distinct institution_id from schools_studentgroup)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '2021'
)data
GROUP BY
data.survey_tag,
data.boundary_id,
data.academic_year_id

union
SELECT distinct format('A%s_%s_%s', data.survey_tag, data.boundary_id, data.academic_year_id) as id,
    data.survey_tag as survey_tag,
    data.boundary_id as boundary_id,
    data.academic_year_id as academic_year_id,
    count(distinct school_id) as num_schools,
    count(case when student_id!=0 then student_id end) as num_students
FROM
(
 SELECT distinct
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id,
    '2122' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1617'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
 union
 SELECT distinct
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id,
    '2122' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1718'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id,
    '2122' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1819'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id,
    '2122' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1920'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id,
    '2122' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '2021'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
union
 SELECT distinct
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id,
    '2122' as academic_year_id,
    instmap.institution_id as school_id,
    0 as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    boundary_boundary b
WHERE
    instmap.institution_id = s.id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and s.id not in (select distinct institution_id from schools_studentgroup)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '2021'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id,
    '2122' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '2122'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
union
 SELECT distinct
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id,
    '2122' as academic_year_id,
    instmap.institution_id as school_id,
    0 as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    boundary_boundary b
WHERE
    instmap.institution_id = s.id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and s.id not in (select distinct institution_id from schools_studentgroup)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '2122'
)data
GROUP BY
data.survey_tag,
data.boundary_id,
data.academic_year_id

union
SELECT distinct format('A%s_%s_%s', data.survey_tag, data.boundary_id, data.academic_year_id) as id,
    data.survey_tag as survey_tag,
    data.boundary_id as boundary_id,
    data.academic_year_id as academic_year_id,
    count(distinct school_id) as num_schools,
    count(case when student_id!=0 then student_id end) as num_students
FROM
(
 SELECT distinct
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id,
    '2223' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1617'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
 union
 SELECT distinct
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id,
    '2223' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1718'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id,
    '2223' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1819'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id,
    '2223' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '1920'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id,
    '2223' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '2021'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id,
    '2223' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '2122'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
union
 SELECT distinct
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id,
    '2223' as academic_year_id,
    instmap.institution_id as school_id,
    0 as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    boundary_boundary b
WHERE
    instmap.institution_id = s.id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and s.id not in (select distinct institution_id from schools_studentgroup)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '2122'
union
SELECT distinct
    instmap.tag_id as  survey_tag,
    b.id as boundary_id,
    '2223' as academic_year_id,
    instmap.institution_id as school_id,
    stu.id as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    schools_student stu,
    schools_studentstudentgrouprelation stusg,
    schools_studentgroup sg,
    boundary_boundary b,
    assessments_surveytagclassmapping sgmap
WHERE
    instmap.institution_id = s.id
    and s.id = sg.institution_id
    and sg.id = stusg.student_group_id
    and sgmap.academic_year_id = instmap.academic_year_id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '2223'
    and instmap.tag_id = sgmap.tag_id
    and stusg.academic_year_id = instmap.academic_year_id
    and sg.name = sgmap.sg_name
    and stusg.status_id !='DL' and stusg.student_id=stu.id
    and stu.status_id !='DL'
union
 SELECT distinct
    instmap.tag_id  as  survey_tag,
    b.id as boundary_id,
    '2223' as academic_year_id,
    instmap.institution_id as school_id,
    0 as student_id
FROM
    assessments_surveytaginstitutionmapping instmap,
    schools_institution s,
    boundary_boundary b
WHERE
    instmap.institution_id = s.id
    and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id)
    and s.id not in (select distinct institution_id from schools_studentgroup)
    and instmap.tag_id = 'gka'
    and instmap.academic_year_id = '2223'
)data
GROUP BY
data.survey_tag,
data.boundary_id,
data.academic_year_id
;


/* View for getting number of assessments that were answered correctly based
 * on child's gender, for GP contests for a an election boundary per yearmonth
 * All the child's answers have to be answered correctly for getting this count.
 * The score that the child gets should be equal to the max_score that is stored
 * in the questiongroup table.
 * Question id 291 is used for storing Gender of the child.
 * This is only for GP contests.
 * Note:- For new GP contests the survey ids will need to be added.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_eboundary_questiongroup_gender_correctans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_eboundary_questiongroup_gender_correctans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,eboundary_id,source,questiongroup_id,gender,yearmonth) as id,
    survey_id,
    survey_tag,
    eboundary_id,
    source,
    questiongroup_id,
    questiongroup_name,
    gender,
    yearmonth,
    count(ag_id) as num_assessments
FROM
    (SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        eb.id as eboundary_id,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        ans1.answer as gender,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        ag.id as ag_id
    FROM assessments_answergroup_institution ag inner join assessments_answerinstitution ans1 on (ag.id=ans1.answergroup_id and ans1.question_id=291),
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
        schools_institution s,
        boundary_electionboundary eb
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and ans.question_id=q.id
        and q.is_featured=true
        and stmap.survey_id=qg.survey_id
        and qg.survey_id in (1,18) --For GP contest
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.gp_id = eb.id or s.ward_id = eb.id or s.mla_id = eb.id or s.mp_id = eb.id) 
    GROUP BY ag.id,eb.id,qg.survey_id,stmap.tag_id,yearmonth,source,qg.id, ans1.answer,qg.name,qg.max_score
    having sum(case ans.answer when 'Yes'then 1 when 'No' then 0 when '1' then 1 when '0' then 0 end)=qg.max_score)correctanswers
GROUP BY survey_id, survey_tag,eboundary_id,source,yearmonth,questiongroup_id,questiongroup_name,gender ;


/* View for getting number of assessments that were answered correctly based
 * on child's gender, for GP contests for a an boundary per yearmonth
 * All the child's answers have to be answered correctly for getting this count.
 * The score that the child gets should be equal to the max_score that is stored
 * in the questiongroup table.
 * Question id 291 is used for storing Gender of the child.
 * This is only for GP contests.
 * Note:- For new GP contests the survey ids will need to be added.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_questiongroup_gender_correctans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_questiongroup_gender_correctans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,boundary_id,source,questiongroup_id,gender,yearmonth) as id,
    survey_id,
    survey_tag,
    boundary_id,
    source,
    questiongroup_id,
    questiongroup_name,
    gender,
    yearmonth,
    count(ag_id) as num_assessments
FROM
    (SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        b.id as boundary_id,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        ans1.answer as gender,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        ag.id as ag_id
    FROM assessments_answergroup_institution ag inner join assessments_answerinstitution ans1 on (ag.id=ans1.answergroup_id and ans1.question_id=80),
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
        schools_institution s,
        boundary_boundary b
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and ans.question_id=q.id
        and q.is_featured=true
        and stmap.survey_id=qg.survey_id
        and qg.survey_id in (1,18)
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY ag.id,b.id,qg.survey_id,stmap.tag_id,yearmonth,source,qg.id, ans1.answer,qg.name,qg.max_score
    having sum(case ans.answer when 'Yes'then 1 when 'No' then 0 when '1' then 1 when '0' then 0 end)=qg.max_score)correctanswers
GROUP BY survey_id, survey_tag,boundary_id,source,yearmonth,questiongroup_id,questiongroup_name,gender ;


/* View for getting number of assessments that were answered correctly based
 * on child's gender, for GP contests for a an institution per yearmonth
 * All the child's answers have to be answered correctly for getting this count.
 * The score that the child gets should be equal to the max_score that is stored
 * in the questiongroup table.
 * Question id 291 is used for storing Gender of the child.
 * This is only for GP contests.
 * Note:- For new GP contests the survey ids will need to be added.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_questiongroup_gender_correctans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_questiongroup_gender_correctans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,source,questiongroup_id,gender,yearmonth) as id,
    survey_id,
    survey_tag,
    institution_id,
    source,
    questiongroup_id,
    questiongroup_name,
    gender,
    yearmonth,
    count(ag_id) as num_assessments
FROM
    (SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        ag.institution_id as institution_id,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        ans1.answer as gender,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        ag.id as ag_id
    FROM assessments_answergroup_institution ag inner join assessments_answerinstitution ans1 on (ag.id=ans1.answergroup_id and ans1.question_id=80),
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and ans.question_id=q.id
        and q.is_featured=true
        and stmap.survey_id=qg.survey_id
        and qg.survey_id in (1,18) -- GP Contests
        and ag.is_verified=true
    GROUP BY ag.id,qg.survey_id,stmap.tag_id,yearmonth,source,qg.id, ans1.answer,qg.name,ag.institution_id,qg.max_score
    having sum(case ans.answer when 'Yes'then 1 when 'No' then 0 when '1' then 1 when '0' then 0 end)=qg.max_score)correctanswers
GROUP BY survey_id, survey_tag,source,yearmonth,questiongroup_id,questiongroup_name,gender,institution_id ;


/* View for getting the number of types of election boundary that was a part
 * of a survey for a boundary in a yearmonth.
 * Union of two queries one for getting student level assessments and one for
 * school assessments.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_electiontype_count CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_electiontype_count AS
SELECT format('A%s_%s_%s_%s_%s', survey_id,survey_tag,boundary_id,yearmonth,const_ward_type) as id,
    survey_id,
    survey_tag,
    boundary_id,
    yearmonth,
    const_ward_type,
    electionboundary_count
FROM(
    SELECT distinct 
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        b.id as boundary_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        eb.const_ward_type_id as const_ward_type,
	count(distinct eb.id) as electionboundary_count
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        schools_institution s,
        boundary_electionboundary eb,
        boundary_boundary b
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
        and (s.mp_id = eb.id or s.mla_id = eb.id or s.ward_id = eb.id or s.gp_id = eb.id) 
        and ag.is_verified=true
    GROUP BY
        survey.id, surveytag.tag_id, b.id, yearmonth, eb.const_ward_type_id
        )data
;


/* View for getting the number of assessments per all the question details:
 * (concept, microconcept_group, microconcept) for a election boundary per 
 * yearmonth.
 * Union between 2 queries, one for student assessment and other for institution
 * assessment.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_eboundary_qdetails_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_eboundary_qdetails_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,eboundary_id,source,concept, microconcept_group, microconcept, yearmonth) as id,
    survey_id,
    survey_tag,
    eboundary_id, 
    source,
    yearmonth,
    concept,
    microconcept_group,
    microconcept,
    num_assessments
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        eb.id as eboundary_id,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        q.concept_id as concept,
        q.microconcept_group_id as microconcept_group,
        q.microconcept_id as microconcept,
        count(distinct ag.id) as num_assessments
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        assessments_answerinstitution ans,
        assessments_question q,
        schools_institution s,
        boundary_electionboundary eb
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and survey.id in (1,18)
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and q.is_featured = true
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.gp_id = eb.id or s.ward_id = eb.id or s.mla_id = eb.id or s.mp_id = eb.id) 
    GROUP BY survey.id,
        surveytag.tag_id,
        eb.id,
        qg.source_id,
        q.concept_id,q.microconcept_group_id,q.microconcept_id,
        yearmonth)data
;


/* View for getting the number of assessments per all the question details:
 * (concept, microconcept_group, microconcept) for a boundary per yearmonth.
 * Union between 2 queries, one for student assessment and other for institution
 * assessment.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_qdetails_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_qdetails_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,boundary_id,source,concept, microconcept_group, microconcept, yearmonth) as id,
    survey_id,
    survey_tag,
    boundary_id, 
    source,
    yearmonth,
    concept,
    microconcept_group,
    microconcept,
    num_assessments
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        b.id as boundary_id,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        q.concept_id as concept,
        q.microconcept_group_id as microconcept_group,
        q.microconcept_id as microconcept,
        count(distinct ag.id) as num_assessments
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        assessments_answerinstitution ans,
        assessments_question q,
        schools_institution s,
        boundary_boundary b
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and survey.id in (1,18)
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and q.is_featured = true
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY survey.id,
        surveytag.tag_id,
        b.id,
        qg.source_id,
        q.concept_id,q.microconcept_group_id,q.microconcept_id,
        yearmonth)data
;


/* View for getting the number of assessments per all the question details:
 * (concept, microconcept_group, microconcept) for a institution per yearmonth.
 * Union between 2 queries, one for student assessment and other for institution
 * assessment.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_qdetails_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_qdetails_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,source,concept, microconcept_group, microconcept,yearmonth) as id,
    survey_id,
    survey_tag,
    institution_id,
    source,
    yearmonth,
    concept,
    microconcept_group,
    microconcept,
    num_assessments
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        ag.institution_id as institution_id,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        q.concept_id as concept,
        q.microconcept_group_id as microconcept_group,
        q.microconcept_id as microconcept,
        count(distinct ag.id) as num_assessments
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        assessments_answerinstitution ans,
        assessments_question q
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and survey.id in (1,18)
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and q.is_featured = true
        and ag.is_verified=true
    GROUP BY survey.id,
        ag.institution_id,
        surveytag.tag_id,
        qg.source_id,
        q.concept_id,q.microconcept_group_id,q.microconcept_id,
        yearmonth)data
;


/* View for getting the number of assessments per all the question details:
 * (concept, microconcept_group, microconcept) for question group per
 * election boundary per yearmonth.
 * Union between 2 queries, one for student assessment and other for institution
 * assessment.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_eboundary_questiongroup_qdetails_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_eboundary_questiongroup_qdetails_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,eboundary_id,source,questiongroup_id,concept,microconcept_group,microconcept,yearmonth) as id,
    survey_id,
    survey_tag,
    eboundary_id,
    source,
    questiongroup_id,
    questiongroup_name,
    yearmonth,
    concept,
    microconcept_group,
    microconcept,
    num_assessments
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        eb.id as eboundary_id,
        qg.source_id as source,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        q.concept_id as concept,
        q.microconcept_group_id as microconcept_group,
        q.microconcept_id as microconcept,
        count(distinct ag.id) as num_assessments
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        assessments_answerinstitution ans,
        assessments_question q,
        schools_institution s,
        boundary_electionboundary eb
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and survey.id in (1,18)
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and q.is_featured = true
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.gp_id = eb.id or s.ward_id = eb.id or s.mla_id = eb.id or s.mp_id = eb.id) 
    GROUP BY survey.id,
        surveytag.tag_id,
        eb.id,
        qg.source_id,
        qg.name,qg.id,
        q.concept_id,q.microconcept_group_id,q.microconcept_id,
        yearmonth)data
;


/* View for getting the number of assessments per all the question details:
 * (concept, microconcept_group, microconcept) for question group per
 * boundary per yearmonth.
 * Union between 2 queries, one for student assessment and other for institution
 * assessment.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_questiongroup_qdetails_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_questiongroup_qdetails_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,boundary_id,source,questiongroup_id,concept,microconcept_group,microconcept,yearmonth) as id,
    survey_id,
    survey_tag,
    boundary_id,
    source,
    questiongroup_id,
    questiongroup_name,
    yearmonth,
    concept,
    microconcept_group,
    microconcept,
    num_assessments
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        b.id as boundary_id,
        qg.source_id as source,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        q.concept_id as concept,
        q.microconcept_group_id as microconcept_group,
        q.microconcept_id as microconcept,
        count(distinct ag.id) as num_assessments
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        assessments_answerinstitution ans,
        assessments_question q,
        schools_institution s,
        boundary_boundary b
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and survey.id in (1,18)
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and q.is_featured = true
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY survey.id,
        surveytag.tag_id,
        b.id,
        qg.source_id,
        qg.name,qg.id,
        q.concept_id,q.microconcept_group_id,q.microconcept_id,
        yearmonth)data
;

/* View for getting the number of assessments per all the question details:
 * (concept, microconcept_group, microconcept) for question group per
 * institution per yearmonth.
 * Union between 2 queries, one for student assessment and other for institution
 * assessment.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_questiongroup_qdetails_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_questiongroup_qdetails_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,source,questiongroup_id,question_id,concept,microconcept_group,microconcept,yearmonth) as id,
    survey_id,
    survey_tag,
    institution_id,
    source,
    questiongroup_id,
    questiongroup_name,
    yearmonth,
    question_id,
    concept,
    microconcept_group,
    microconcept,
    num_assessments
FROM(
    SELECT
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        ag.institution_id as institution_id,
        qg.source_id as source,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        q.id as question_id,
        q.concept_id as concept,
        q.microconcept_group_id as microconcept_group,
        q.microconcept_id as microconcept,
        count(distinct ag.id) as num_assessments
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        assessments_answerinstitution ans,
        assessments_question q
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and survey.id in (1,18)
        and ag.id = ans.answergroup_id
        and ans.question_id = q.id
        and q.is_featured = true
        and ag.is_verified=true
    GROUP BY survey.id,
        surveytag.tag_id,
        ag.institution_id,
        qg.source_id,
        qg.name,qg.id,
        q.id,
        q.concept_id,q.microconcept_group_id,q.microconcept_id,
        yearmonth)data
;


/* View for getting number of assessments that were answered correctly for 
 * question details (concept, microconceptgroup, microconcept) per survey for an
 * election boundary.
 * Number of correct assessments, yearmonth, concept, microconcept group, 
 * microconcept, survey_id and election boundary. 
 * For getting the correct answer the table assessments_competencyquestionmap is 
 * used. This table has the passscore for the question id per question grp.
 * A child's assessment for a set of question details and question group  is 
 * considered correct if the value of the child's answer for those parameters
 * is equal to or greater than the pass score specified in 
 * assessments_competencyquestionmap table.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_eboundary_qdetails_correctans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_eboundary_qdetails_correctans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,eboundary_id,source,concept,microconcept_group,microconcept,yearmonth) as id,
    survey_id, 
    survey_tag,
    eboundary_id,
    source,
    concept,
    microconcept_group,
    microconcept,
    yearmonth,
    agg.numcorrectans as numcorrect,
    agg.numtotalans as numtotal,
    agg.numcorrectans::decimal*100/agg.numtotalans as average
FROM
    (SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        eb.id as eboundary_id,
        q.id as question_id,
        q.concept_id as concept,
        q.microconcept_group_id as microconcept_group,
        q.microconcept_id as microconcept,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
	count(ans.id) filter (where answer in ('Yes','1')) as numcorrectans, 
	count(ans.id) as numtotalans
    FROM assessments_answergroup_institution ag,
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
	assessments_competencyquestionmap qmap,
        schools_institution s,
        boundary_electionboundary eb
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and qg.survey_id in (1,18)
        and qg.id=qmap.questiongroup_id
        and ans.question_id=q.id
	and q.id = qmap.question_id
        and stmap.survey_id=qg.survey_id
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.gp_id = eb.id or s.ward_id = eb.id or s.mla_id = eb.id or s.mp_id = eb.id) 
    GROUP BY q.concept_id,q.id,q.microconcept_id,q.microconcept_group_id,eb.id,qg.survey_id,stmap.tag_id,yearmonth,source)agg
GROUP BY survey_id,survey_tag,eboundary_id,source,yearmonth,concept,microconcept_group,microconcept,numcorrectans,numtotalans;


/* View for getting number of assessments that were answered correctly for 
 * question details (concept, microconceptgroup, microconcept) per survey for a
 * boundary.
 * Number of correct assessments, yearmonth, concept, microconcept group, 
 * microconcept, survey_id and boundary. 
 * For getting the correct answer the table assessments_competencyquestionmap is 
 * used. This table has the score for the question ids per question grp.
 * A child's assessment for a set of question details and question group  is 
 * considered correct if the value of the child's answer for those parameters
 * is equal to or greater than the pass score specified in 
 * assessments_competencyquestionmap table.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_qdetails_correctans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_qdetails_correctans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,boundary_id,source,concept,microconcept_group,microconcept,yearmonth) as id,
    survey_id, 
    survey_tag,
    boundary_id,
    source,
    concept,
    microconcept_group,
    microconcept,
    yearmonth,
    agg.numcorrectans as numcorrect,
    agg.numtotalans as numtotal,
    agg.numcorrectans::decimal*100/agg.numtotalans as average
FROM
    (SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        b.id as boundary_id,
        q.concept_id as concept,
        q.microconcept_group_id as microconcept_group,
        q.microconcept_id as microconcept,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
	count(ans.id) filter (where answer in ('Yes','1')) as numcorrectans, 
	count(ans.id) as numtotalans
    FROM assessments_answergroup_institution ag,
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
	assessments_competencyquestionmap qmap,
        schools_institution s,
        boundary_boundary b
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and qg.survey_id in (1,18)
        and qg.id=qmap.questiongroup_id
        and ans.question_id=q.id
	and q.id = qmap.question_id
        and stmap.survey_id=qg.survey_id
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY q.concept_id,q.microconcept_id,q.microconcept_group_id,b.id,qg.survey_id,stmap.tag_id,yearmonth,source)agg
GROUP BY survey_id,survey_tag,boundary_id,source,yearmonth,concept,microconcept_group,microconcept,numcorrectans,numtotalans;


/* View for getting number of assessments that were answered correctly for 
 * question details (concept, microconceptgroup, microconcept) per survey for an
 * institution.
 * Number of correct assessments, yearmonth, concept, microconcept group, 
 * microconcept, survey_id and institution. 
 * For getting the correct answer the table assessments_competencyquestionmap is 
 * used. This table has the passscore for the question id per question grp.
 * A child's assessment for a set of question details and question group  is 
 * considered correct if the value of the child's answer for those parameters
 * is equal to or greater than the pass score specified in 
 * assessments_competencyquestionmap table.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_qdetails_correctans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_qdetails_correctans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,source,concept,microconcept_group,microconcept,yearmonth) as id,
    survey_id, 
    survey_tag,
    institution_id,
    source,
    concept,
    microconcept_group,
    microconcept,
    yearmonth,
    agg.numcorrectans as numcorrect,
    agg.numtotalans as numtotal,
    agg.numcorrectans::decimal*100/agg.numtotalans as average
FROM
    (SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        ag.institution_id as institution_id,
        q.concept_id as concept,
        q.microconcept_group_id as microconcept_group,
        q.microconcept_id as microconcept,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
	count(ans.id) filter (where answer in ('Yes','1')) as numcorrectans, 
	count(ans.id) as numtotalans
    FROM assessments_answergroup_institution ag,
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
	assessments_competencyquestionmap qmap 
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and qg.survey_id in (1,18)
        and qg.id=qmap.questiongroup_id
        and ans.question_id=q.id
	and q.id = qmap.question_id
        and stmap.survey_id=qg.survey_id
        and ag.is_verified=true
    GROUP BY q.concept_id,q.microconcept_group_id,q.microconcept_id,ag.institution_id,qg.survey_id,stmap.tag_id,yearmonth,source)agg
GROUP BY survey_id,survey_tag,institution_id,source,yearmonth,concept,microconcept_group,microconcept,numcorrectans,numtotalans;


/* View for getting number of assessments that were answered correctly for 
 * question details (concept, microconceptgroup, microconcept) per questiongroup
 * per survey for an election boundary.
 * Number of correct assessments, yearmonth, concept, microconcept group, 
 * microconcept, question group, survey_id and election boundary. 
 * For getting the correct answer the table assessments_competencyquestionmap is 
 * used. This table has the passscore for the question id per question grp.
 * A child's assessment for a set of question details and question group  is 
 * considered correct if the value of the child's answer for those parameters
 * is equal to or greater than the pass score specified in 
 * assessments_competencyquestionmap table.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_eboundary_questiongroup_qdetails_correctans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_eboundary_questiongroup_qdetails_correctans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,eboundary_id,source,questiongroup_id,concept,microconcept_group,microconcept,yearmonth) as id,
    survey_id, 
    survey_tag,
    eboundary_id,
    source,
    questiongroup_id,
    questiongroup_name,
    concept,
    microconcept_group,
    microconcept,
    yearmonth,
    agg.numcorrectans as numcorrect,
    agg.numtotalans as numtotal,
    agg.numcorrectans::decimal*100/agg.numtotalans as average
FROM
    (SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        eb.id as eboundary_id,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        q.concept_id as concept,
        q.microconcept_group_id as microconcept_group,
        q.microconcept_id as microconcept,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
	count(ans.id) filter (where answer in ('Yes','1')) as numcorrectans, 
	count(ans.id) as numtotalans
    FROM assessments_answergroup_institution ag,
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
	assessments_competencyquestionmap qmap,
        schools_institution s,
        boundary_electionboundary eb
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and qg.survey_id in (1,18)
        and qg.id=qmap.questiongroup_id
        and ans.question_id=q.id
	and q.id= qmap.question_id
        and stmap.survey_id=qg.survey_id
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.gp_id = eb.id or s.ward_id = eb.id or s.mla_id = eb.id or s.mp_id = eb.id) 
    GROUP BY q.concept_id,q.microconcept_group_id,q.microconcept_id,eb.id,qg.survey_id,stmap.tag_id,yearmonth,source,qg.id,qg.name)agg
GROUP BY survey_id, survey_tag,eboundary_id,source,yearmonth,concept,microconcept_group,microconcept,questiongroup_id,questiongroup_name,numcorrectans,numtotalans;


/* View for getting number of assessments that were answered correctly for 
 * question details (concept, microconceptgroup, microconcept) per questiongroup
 * per survey for a boundary.
 * Number of correct assessments, yearmonth, concept, microconcept group, 
 * microconcept, question group, survey_id and boundary. 
 * For getting the correct answer the table assessments_competencyquestionmap is 
 * used. This table has the passscore for the question id per question grp.
 * A child's assessment for a set of question details and question group  is 
 * considered correct if the value of the child's answer for those parameters
 * is equal to or greater than the pass score specified in 
 * assessments_competencyquestionmap table.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_boundary_questiongroup_qdetails_correctans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_boundary_questiongroup_qdetails_correctans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,boundary_id,source,questiongroup_id,concept,microconcept_group,microconcept,yearmonth) as id,
    survey_id, 
    survey_tag,
    boundary_id,
    source,
    questiongroup_id,
    questiongroup_name,
    concept,
    microconcept_group,
    microconcept,
    yearmonth,
    agg.numcorrectans as numcorrect,
    agg.numtotalans as numtotal,
    agg.numcorrectans::decimal*100/agg.numtotalans as average
FROM
    (SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        b.id as boundary_id,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        q.concept_id as concept,
        q.microconcept_group_id as microconcept_group,
        q.microconcept_id as microconcept,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
	count(ans.id) filter (where answer in ('Yes','1')) as numcorrectans, 
	count(ans.id) as numtotalans
    FROM assessments_answergroup_institution ag,
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
	assessments_competencyquestionmap qmap,
        schools_institution s,
        boundary_boundary b
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and qg.survey_id in (1,18)
        and qg.id=qmap.questiongroup_id
        and ans.question_id=q.id
	and q.id=qmap.question_id
        and stmap.survey_id=qg.survey_id
        and ag.is_verified=true
        and ag.institution_id = s.id
        and (s.admin0_id = b.id or s.admin1_id = b.id or s.admin2_id = b.id or s.admin3_id = b.id) 
    GROUP BY q.concept_id,q.microconcept_group_id,q.microconcept_id,b.id,qg.survey_id,stmap.tag_id,yearmonth,source,qg.id,qg.name)agg
GROUP BY survey_id, survey_tag,boundary_id,source,yearmonth,concept,microconcept_group,microconcept,questiongroup_id,questiongroup_name,numcorrectans,numtotalans;


/* View for getting number of assessments that were answered correctly for 
 * question details (concept, microconceptgroup, microconcept) per questiongroup
 * per survey for an institution.
 * Number of correct assessments, yearmonth, concept, microconcept group, 
 * microconcept, question group, survey_id and institution. 
 * For getting the correct answer the table assessments_competencyquestionmap is 
 * used. This table has the passscore for the question_id per question grp.
 * A child's assessment for a set of question details and question group  is 
 * considered correct if the value of the child's answer for those parameters
 * is equal to or greater than the pass score specified in 
 * assessments_competencyquestionmap table.
 * Please note that if same survey id has multiple survey tags that are used 
 * across sources then the survey_tag should be specified in the query else 
 * the count will be doubled.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_questiongroup_qdetails_correctans_agg CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_questiongroup_qdetails_correctans_agg AS
SELECT format('A%s_%s_%s_%s_%s_%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,source,questiongroup_id,question_id,concept,microconcept_group,microconcept,yearmonth) as id,
    survey_id, 
    survey_tag,
    institution_id,
    source,
    questiongroup_id,
    questiongroup_name,
    question_id,
    concept,
    microconcept_group,
    microconcept,
    yearmonth,
    agg.numcorrectans as numcorrect,
    agg.numtotalans as numtotal,
    agg.numcorrectans::decimal*100/agg.numtotalans as average
FROM
    (SELECT distinct
        qg.survey_id as survey_id, 
        stmap.tag_id as survey_tag, 
        ag.institution_id as institution_id,
        qg.id as questiongroup_id,
        qg.name as questiongroup_name,
        q.id as question_id,
        q.concept_id as concept,
        q.microconcept_group_id as microconcept_group,
        q.microconcept_id as microconcept,
        qg.source_id as source,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
	count(ans.id) filter (where answer in ('Yes','1')) as numcorrectans, 
	count(ans.id) as numtotalans
    FROM assessments_answergroup_institution ag,
        assessments_answerinstitution ans,
        assessments_surveytagmapping stmap,
        assessments_questiongroup qg,
        assessments_question q,
	assessments_competencyquestionmap qmap 
    WHERE
        ans.answergroup_id=ag.id
        and ag.questiongroup_id=qg.id
        and qg.survey_id in (1,18)
        and qg.id=qmap.questiongroup_id
        and ans.question_id=q.id
	    and q.id=qmap.question_id
        and stmap.survey_id=qg.survey_id
        and ag.is_verified=true
    GROUP BY q.concept_id,q.microconcept_group_id,q.microconcept_id,q.id,qg.survey_id,stmap.tag_id,yearmonth,source,qg.id,qg.name,ag.institution_id)agg
GROUP BY survey_id, survey_tag,institution_id,source,yearmonth,concept,microconcept_group,microconcept,question_id,questiongroup_id,questiongroup_name,numcorrectans,numtotalans;


/* View for getting the number of types of election boundary that was a part
 * of a survey for an election boundary in a yearmonth.
 * Union of two queries one for getting student level assessments and one for
 * school assessments.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_eboundary_electiontype_count CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_eboundary_electiontype_count AS
SELECT format('A%s_%s_%s_%s_%s', survey_id,survey_tag,eboundary_id,yearmonth,const_ward_type) as id,
    survey_id,
    survey_tag,
    eboundary_id,
    yearmonth,
    const_ward_type,
    electionboundary_count
FROM(
    SELECT distinct 
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        eb.id as eboundary_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        eb.const_ward_type_id as const_ward_type,
        1 as electionboundary_count
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        schools_institution s,
        boundary_electionboundary eb
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.institution_id = s.id
        and (s.mp_id = eb.id or s.mla_id = eb.id or s.ward_id = eb.id or s.gp_id = eb.id) 
        and ag.is_verified=true
        )data;


/* View for getting the number of types of election boundary that was a part
 * of a survey for a institution in a yearmonth.
 * Union of two queries one for getting student level assessments and one for
 * school assessments.
 */
DROP MATERIALIZED VIEW IF EXISTS mvw_survey_institution_electiontype_count CASCADE;
CREATE MATERIALIZED VIEW mvw_survey_institution_electiontype_count AS
SELECT format('A%s_%s_%s_%s_%s', survey_id,survey_tag,institution_id,yearmonth,const_ward_type) as id,
    survey_id,
    survey_tag,
    institution_id,
    yearmonth,
    const_ward_type,
    electionboundary_count
FROM(
    SELECT distinct 
        survey.id as survey_id,
        surveytag.tag_id as survey_tag,
        s.id as institution_id,
        to_char(ag.date_of_visit,'YYYYMM')::int as yearmonth,
        eb.const_ward_type_id as const_ward_type,
	count(distinct eb.id) as electionboundary_count
    FROM assessments_survey survey,
        assessments_questiongroup qg,
        assessments_answergroup_institution ag,
        assessments_surveytagmapping surveytag,
        schools_institution s,
        boundary_electionboundary eb
    WHERE 
        survey.id = qg.survey_id
        and qg.id = ag.questiongroup_id
        and survey.id = surveytag.survey_id
        and ag.institution_id = s.id
        and (s.mp_id = eb.id or s.mla_id = eb.id or s.ward_id = eb.id or s.gp_id = eb.id) 
        and ag.is_verified=true
    GROUP BY
        survey.id, surveytag.tag_id, s.id, yearmonth, eb.const_ward_type_id
        )data
;
