drop type if exists booking_status cascade;
create type booking_status as enum ('pending', 'confirmed', 'cancelled');

drop table if exists booking cascade;
create table booking (
  id uuid primary key default gen_random_uuid(),
  status booking_status not null default 'pending',
  tags text[],
  period daterange
);

insert into booking (status, tags, period) values
  ('pending', array['vip'], daterange('2024-01-05', '2024-01-10')),
  ('confirmed', array['grupo'], daterange('2024-01-12', '2024-01-15')),
  ('pending', array['vip', 'prioritario'], daterange('2024-01-08', '2024-01-09'));


create table reservas (
  id serial primary key,
  periodo daterange
);

insert into reservas (periodo) values
  (daterange('2024-01-05', '2024-01-10')),
  (daterange('2024-01-15', '2024-01-20')),
  (daterange('2024-01-08', '2024-01-12', '()'));  -- aberto nos dois lados

select * from reservas
where periodo && daterange('2024-01-09', '2024-01-11');

select * from reservas
where periodo @> date '2024-01-06';

select * from reservas
where daterange('2024-01-06', '2024-01-07') <@ periodo;

create index on reservas using gist (periodo);

select
  id,
  lower(periodo) as inicio,
  upper(periodo) as fim,
  lower_inc(periodo) as inicio_inclusivo,
  upper_inc(periodo) as fim_inclusivo
from reservas;


drop table if exists pagamentos cascade;
create table pagamentos (
  id serial primary key,
  user_id int,
  valor numeric,
  data timestamp
);

insert into pagamentos (user_id, valor, data) values
  (1, 150.00, now() - interval '10 days'),
  (1, 200.00, now() - interval '5 days'),
  (2, 900.00, now() - interval '31 days'),
  (2, 200.00, now() - interval '2 days');




create or replace view clientes_top as
select user_id, sum(valor) as total
  from pagamentos
 where data >= now() - interval '30 days'
 group by user_id
with check option;


drop table if exists pedidos cascade;
create table pedidos (
  id serial primary key,
  dados jsonb
);

insert into pedidos (dados) values (
  '{
    "cliente": {
      "nome": "João"
    },
    "status": "confirmado",
    "endereco": {
      "cidade": "Blumenau"
    },
    "itens": [
      { "produto": "Notebook", "quantidade": 1 },
      { "produto": "Mouse", "quantidade": 2 }
    ]
  }'
);

drop table if exists funcionarios cascade;
create table funcionarios (
  id serial primary key,
  nome text not null,
  departamento text not null,
  cargo text not null,
  salario numeric not null
);

insert into funcionarios (nome, departamento, cargo, salario) values
  ('Alice', 'TI', 'Desenvolvimento', 8000),
  ('Bob', 'TI', 'Analista', 7000),
  ('Carol', 'RH', 'Desenvolvimento', 7500);

create or replace view funcionarios_ti as
select * from funcionarios where departamento = 'TI'
with check option;

create or replace view desenvolvimento as
select * from funcionarios_ti where cargo = 'Desenvolvimento'
with check option;
