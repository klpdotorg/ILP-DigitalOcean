--Creating GP for Kotabagi 
SELECT MAX(id) FROM boundary_electionboundary;
SELECT nextval('boundary_electionboundary_id_seq');
BEGIN;
LOCK TABLE boundary_electionboundary IN EXCLUSIVE MODE;
SELECT setval('boundary_electionboundary_id_seq', COALESCE((SELECT MAX(id)+1 FROM boundary_electionboundary), 1), false);
COMMIT;
insert into boundary_electionboundary(const_ward_name, const_ward_type_id, state_id, status_id, dise_slug) values('Kotabagi', 'GP',2,'AC', '');
update schools_institution set gp_id=(select currval('boundary_electionboundary_id_seq')) where admin1_id=442 and admin2_id=641 and gp_id=3787;
