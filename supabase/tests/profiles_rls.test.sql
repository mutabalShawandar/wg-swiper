begin;
create extension if not exists pgtap with schema extensions;
select plan(11);

select ok((select relrowsecurity from pg_class where oid = 'public.profiles'::regclass), 'RLS enabled on profiles');

insert into auth.users (id, instance_id, aud, role, email) values
  ('00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'a@example.test'),
  ('00000000-0000-0000-0000-00000000000b', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'b@example.test');

select is((select count(*)::int from public.profiles), 2, 'trigger created profiles for both users');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}', true);

select is((select count(*)::int from public.profiles), 1, 'A sees only one row');
select is((select id from public.profiles), '00000000-0000-0000-0000-00000000000a'::uuid, 'A sees own row');

select lives_ok($$update public.profiles set display_name = 'Alice' where id = '00000000-0000-0000-0000-00000000000a'$$, 'A updates own row');
update public.profiles set display_name = 'Hacked' where id = '00000000-0000-0000-0000-00000000000b';
select is((select count(*)::int from public.profiles where display_name = 'Hacked'), 0, 'A cannot update B (no rows affected)');

select throws_ok($$update public.profiles set birthdate = current_date - interval '17 years' where id = '00000000-0000-0000-0000-00000000000a'$$, '23514', null, 'under-18 birthdate rejected');
select lives_ok($$update public.profiles set birthdate = '1990-01-01' where id = '00000000-0000-0000-0000-00000000000a'$$, 'adult birthdate accepted');
select throws_ok($$insert into public.profiles (id) values ('00000000-0000-0000-0000-00000000000b')$$, '42501', null, 'A cannot insert row for B');
select throws_ok($$delete from public.profiles where id = '00000000-0000-0000-0000-00000000000a'$$, '42501', null, 'client delete denied');

reset role;
set local role anon;
select throws_ok($$select * from public.profiles$$, '42501', null, 'anon has no access');

select * from finish();
rollback;
