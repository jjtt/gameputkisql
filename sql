select *
from

-- osallistujat
(
  select distinct osallistuja from m
) as osallistujat

-- sessiot järjestyksessä
join
(
  select sessio, rownum() as num
  from (
    select distinct sessio from m order by id
  ) as t
) as sessiot

-- liitä osallistumiset
left outer join m as m
on osallistujat.osallistuja = m.osallistuja
and sessiot.sessio = m.sessio

-- järjestä osallistujittain sessiot järjestykseen
order by osallistujat.osallistuja, sessiot.num
;
