with putket as
(

  -- laske putkien pituudet
  select
    osallistuja,
    count(osallistuja) pituus
  from
  (

    -- numeroi putket
    select
      osallistuja,
      sum(case when mukana = edellinen then 0 else 1 end) over(order by osallistuja, num) as putki
    from
    (

      -- etsi putkien rajat LAG-funktiolla
      select
        osallistujat.osallistuja,
        sessiot.num,
        m.osallistuja mukana,
        lag(m.osallistuja) over (order by osallistujat.osallistuja, sessiot.num) as edellinen

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

    ) as t2

  ) as t3
  group by osallistuja, putki

)
select distinct
  putket.osallistuja,
  putket.pituus
from putket
where putket.pituus = (select max(pituus) from putket as p where p.osallistuja=putket.osallistuja)
order by putket.pituus desc

;
