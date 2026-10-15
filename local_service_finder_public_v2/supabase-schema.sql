-- Run this in Supabase Dashboard -> SQL Editor.
-- Security model: the public can read only published services and submit suggestions.
-- Only user IDs explicitly inserted into public.admin_users can manage records.

create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.services (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 1 and 120),
  category text not null check (category in ('Hospital','Clinic','Ambulance','Police station','Fire station','Emergency department','Other emergency service')),
  address text not null check (length(trim(address)) between 1 and 500),
  area text not null check (length(trim(area)) between 1 and 120),
  phone text,
  latitude double precision check (latitude is null or latitude between -90 and 90),
  longitude double precision check (longitude is null or longitude between -180 and 180),
  verification_status text not null check (verification_status in ('Field verified','Contact verified','Field and contact verified','Needs recheck')),
  verification_notes text not null,
  survey_date date,
  published boolean not null default false,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check ((latitude is null and longitude is null) or (latitude is not null and longitude is not null))
);

create table if not exists public.suggestions (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 1 and 120),
  category text not null check (category in ('Hospital','Clinic','Ambulance','Police station','Fire station','Emergency department','Other emergency service')),
  address text not null check (length(trim(address)) between 1 and 500),
  area text not null check (length(trim(area)) between 1 and 120),
  phone text,
  latitude double precision check (latitude is null or latitude between -90 and 90),
  longitude double precision check (longitude is null or longitude between -180 and 180),
  source_details text not null check (length(trim(source_details)) between 1 and 1000),
  notes text,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  check ((latitude is null and longitude is null) or (latitude is not null and longitude is not null))
);

create or replace function public.is_lsf_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.admin_users where user_id = auth.uid());
$$;

revoke all on function public.is_lsf_admin() from public;
grant execute on function public.is_lsf_admin() to anon, authenticated;

grant select on public.services to anon, authenticated;
grant insert, update, delete on public.services to authenticated;
grant insert on public.suggestions to anon, authenticated;
grant select, update, delete on public.suggestions to authenticated;
grant select on public.admin_users to authenticated;

alter table public.admin_users enable row level security;
alter table public.services enable row level security;
alter table public.suggestions enable row level security;

drop policy if exists "admins can read own admin record" on public.admin_users;
create policy "admins can read own admin record" on public.admin_users
  for select to authenticated using (user_id = auth.uid());

-- Public visitors only see published services. Admins can also see unpublished records.
drop policy if exists "public reads published services and admins read all" on public.services;
create policy "public reads published services and admins read all" on public.services
  for select to anon, authenticated using (published = true or public.is_lsf_admin());
drop policy if exists "admins insert services" on public.services;
create policy "admins insert services" on public.services
  for insert to authenticated with check (public.is_lsf_admin());
drop policy if exists "admins update services" on public.services;
create policy "admins update services" on public.services
  for update to authenticated using (public.is_lsf_admin()) with check (public.is_lsf_admin());
drop policy if exists "admins delete services" on public.services;
create policy "admins delete services" on public.services
  for delete to authenticated using (public.is_lsf_admin());

-- Public can submit pending suggestions, but cannot read, approve, or delete submissions.
drop policy if exists "public submits pending suggestions" on public.suggestions;
create policy "public submits pending suggestions" on public.suggestions
  for insert to anon, authenticated with check (status = 'pending' and reviewed_at is null and reviewed_by is null);
drop policy if exists "admins read suggestions" on public.suggestions;
create policy "admins read suggestions" on public.suggestions
  for select to authenticated using (public.is_lsf_admin());
drop policy if exists "admins review suggestions" on public.suggestions;
create policy "admins review suggestions" on public.suggestions
  for update to authenticated using (public.is_lsf_admin()) with check (public.is_lsf_admin());
drop policy if exists "admins delete suggestions" on public.suggestions;
create policy "admins delete suggestions" on public.suggestions
  for delete to authenticated using (public.is_lsf_admin());
