-- QSC Reading System V1
-- Public reading content belongs in Supabase, per QSC_DATABASE_SCHEMA.md.

create table if not exists public.reading_books (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  author text not null default '',
  description text not null default '',
  language text not null default 'zh-TW',
  download_coin_cost integer not null default 0 check (download_coin_cost >= 0),
  status text not null default 'published' check (status in ('draft', 'published', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.reading_chapters (
  id uuid primary key default gen_random_uuid(),
  book_id uuid not null references public.reading_books(id) on delete cascade,
  chapter_order integer not null check (chapter_order > 0),
  title text not null,
  content text not null,
  word_count integer not null check (word_count >= 0),
  created_at timestamptz not null default now(),
  unique (book_id, chapter_order)
);

create index if not exists reading_books_published_language_idx
  on public.reading_books (language, title)
  where status = 'published';
create index if not exists reading_chapters_book_order_idx
  on public.reading_chapters (book_id, chapter_order);

alter table public.reading_books enable row level security;
alter table public.reading_chapters enable row level security;

create policy "Published reading books are public"
  on public.reading_books for select
  using (status = 'published');
create policy "Chapters of published books are public"
  on public.reading_chapters for select
  using (exists (
    select 1 from public.reading_books
    where reading_books.id = reading_chapters.book_id
      and reading_books.status = 'published'
  ));

-- Insert and update access remain service-role/admin only.
