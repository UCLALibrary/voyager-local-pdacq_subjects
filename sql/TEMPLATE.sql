set linesize 10;

/*  This template finds all pdacq records, as a starting point.
    Caling program appends search term(s) as needed before running query.
    As-is, this is NOT valid SQL.
    Calling program needs to append clauses, separated by OR.
    Calling program needs to append this to close the above OR clauses, plus the ORDER BY clause:
      ) order by b.bib_id;
*/
with bibs as (
  select
    bm.bib_id
  from bib_mfhd bm
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code = 'pdacq'
)
select 
  --distinct record_id as bib_id
  --count(distinct bs.record_id)
  distinct b.bib_id
from bibs b
inner join vger_subfields.ucladb_bib_subfield bs on b.bib_id = bs.record_id
where bs.tag in (
  select lower(fieldcode)
  from searchfields
  where searchcode = 'SKEY'
)
-- Calling program appends search term(s) below the next line.
and (
