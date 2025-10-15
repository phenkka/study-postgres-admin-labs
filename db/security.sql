do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'user1') then
    create role user1 login password 'user11' nosuperuser nocreatedb nocreaterole;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'user2') then
    create role user2 login password 'user22' nosuperuser nocreatedb nocreaterole;
  end if;
end$$;


alter table if exists author           add column if not exists created_by text;
alter table if exists employee         add column if not exists created_by text;
alter table if exists contract         add column if not exists created_by text;
alter table if exists contract_author  add column if not exists created_by text;
alter table if exists book             add column if not exists created_by text;
alter table if exists book_author      add column if not exists created_by text;
alter table if exists book_employee    add column if not exists created_by text;
alter table if exists customer         add column if not exists created_by text;
alter table if exists orders           add column if not exists created_by text;
alter table if exists orders_book      add column if not exists created_by text;

create or replace function set_created_by()
returns trigger language plpgsql as $$
begin
  if new.created_by is null then
    new.created_by := current_user;
  end if;
  return new;
end;$$;

do $$
declare t text;
begin
  for t in select unnest(array[
    'author','employee','contract','contract_author','book','book_author','book_employee','customer','orders','orders_book'
  ]) loop
    execute format('drop trigger if exists trg_set_created_by on %I', t);
    execute format('create trigger trg_set_created_by before insert on %I for each row execute function set_created_by()', t);
  end loop;
end$$;

do $$
declare t text;
begin
  for t in select unnest(array[
    'author','employee','contract','contract_author','book','book_author','book_employee','customer','orders','orders_book'
  ]) loop
    execute format('alter table %I enable row level security', t);
  end loop;
end$$;

do $$
declare t text;
begin
  for t in select unnest(array[
    'author','employee','contract','contract_author','book','book_author','book_employee','customer','orders','orders_book'
  ]) loop
    execute format('drop policy if exists p_owner on %I', t);
    execute format('drop policy if exists p_ins_u1 on %I', t);
    execute format('drop policy if exists p_ins_u2 on %I', t);
  end loop;
end$$;

create policy p_owner on book
  using (created_by = current_user)
  with check (created_by = current_user);
create policy p_ins_u1 on book for insert to user1 with check (true);

create policy p_owner on book_author
  using (created_by = current_user)
  with check (created_by = current_user);
create policy p_ins_u1 on book_author for insert to user1 with check (true);

create policy p_owner on book_employee
  using (created_by = current_user)
  with check (created_by = current_user);
create policy p_ins_u1 on book_employee for insert to user1 with check (true);

create policy p_owner on contract
  using (created_by = current_user)
  with check (created_by = current_user);
create policy p_ins_u2 on contract for insert to user2 with check (true);

create policy p_owner on contract_author
  using (created_by = current_user)
  with check (created_by = current_user);
create policy p_ins_u2 on contract_author for insert to user2 with check (true);

revoke all on schema public from public;
grant usage on schema public to user1, user2;

revoke all on author, employee, contract, contract_author, book, book_author, book_employee, customer, orders, orders_book from user1, user2;

grant select, insert, update, delete on book, book_author, book_employee to user1;
grant select, insert, update, delete on contract, contract_author to user2;

grant select on employee to user1, user2;
create policy employee_read on employee for select to user1, user2 using (true);

revoke all on all sequences in schema public from public;

do $$
declare s text;
begin
  if exists (select 1 from pg_class where relname = 'book_id_book_seq') then
    execute 'grant usage, select on sequence book_id_book_seq to user1';
  end if;
end$$;

do $$
begin
  if exists (select 1 from pg_class where relname = 'contract_id_contract_seq') then
    execute 'grant usage, select on sequence contract_id_contract_seq to user2';
  end if;
end$$;

alter default privileges in schema public grant usage, select on sequences to user1;
alter default privileges in schema public grant usage, select on sequences to user2;