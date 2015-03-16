SELECT
	malaria_types_list.answer_concept_name AS 'Type of Malaria',
    SUM(IF(person.gender = 'F' && TIMESTAMPDIFF(YEAR, person.birthdate, visit.date_started) < 5, 1, 0)) AS 'Female, <5 years',
    SUM(IF(person.gender = 'M' && TIMESTAMPDIFF(YEAR, person.birthdate, visit.date_started) < 5, 1, 0)) AS 'Male, <5 years',
    SUM(IF(person.gender = 'F' && TIMESTAMPDIFF(YEAR, person.birthdate, visit.date_started) >= 5, 1, 0)) AS 'Female, >= 5 years',
    SUM(IF(person.gender = 'M' && TIMESTAMPDIFF(YEAR, person.birthdate, visit.date_started) >= 5, 1, 0)) AS 'Male, >=5 years'

FROM visit
INNER JOIN person ON visit.patient_id = person.person_id
	 AND DATE(visit.date_started) BETWEEN #startDate# AND #endDate#
INNER JOIN encounter ON visit.visit_id = encounter.visit_id
INNER JOIN coded_obs_view AS malaria_type ON encounter.encounter_id = malaria_type.encounter_id
	AND malaria_type.concept_full_name = 'Malaria, Finding'
 LEFT outer JOIN obs_view AS malaria_treatment ON malaria_treatment.obs_group_id = malaria_type.obs_group_id
 	AND malaria_treatment.concept_full_name = 'Malaria, Treatment Start Date'
    AND malaria_treatment.value_datetime IS NOT NULL 
RIGHT OUTER JOIN (select answer_concept_name from concept_answer_view where question_concept_name = 'Malaria, Finding' ) AS malaria_types_list ON malaria_type.value_concept_full_name = malaria_types_list.answer_concept_name
GROUP BY malaria_types_list.answer_concept_name;