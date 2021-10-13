create or replace view osallistujat
as
select distinct osallistuja from m;

create or replace view sessiot
as
select sessio, min(id) as num from m group by sessio order by id;

create or replace view sessiot_osallistujat
as
      select
        osallistujat.osallistuja,
        m.osallistuja mukana

      from osallistujat
      join sessiot

      -- liitä osallistumiset
      left outer join m as m
      on osallistujat.osallistuja = m.osallistuja
      and sessiot.sessio = m.sessio

      -- järjestä osallistujittain sessiot järjestykseen
      order by osallistujat.osallistuja, sessiot.num
;

delimiter ;;
create or replace procedure putket()
begin
  declare bDone INT;
  declare os varchar(10);
  declare mu varchar(10);
  declare prev varchar(10);
  declare putki int;
  declare putkimax int;
  declare curs cursor for select osallistuja, mukana from sessiot_osallistujat;
  declare continue handler for not found set bDone = 1;

  drop temporary table if exists p;
  create temporary table if not exists p (
    osallistuja varchar(256),
    putki int
  );

  open curs;

  set bDone = 0;
  set putki = 0;
  set putkimax = 1;
  set prev = NULL;
  repeat
    fetch curs into os,mu;
    if prev = os or prev is NULL then
      if mu is not NULL then
        set putki = putki + 1;
      else
        if putki > putkimax then
          set putkimax = putki;
        end if;
        set putki = 0;
      end if;
    else
      if putki > putkimax then
        set putkimax = putki;
      end if;
      insert into p values (prev, putkimax);
      set putki = 0;
      set putkimax = 1;
    end if;
    set prev = os;
    
  until bDone end repeat;
  insert into p values (prev, putkimax);

  close curs;
end;
;;
delimiter ;


call putket();
select * from p order by putki desc;
