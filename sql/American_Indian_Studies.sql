set linesize 10;

with bibs as (
  select
    bm.bib_id
  from bib_mfhd bm
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code = 'pdacq'
  -- 45775
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
and upper(bs.subfield) like '%INDIANS OF NORTH AMERICA%'
order by b.bib_id
;
