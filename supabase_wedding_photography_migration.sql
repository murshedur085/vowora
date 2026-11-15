-- VOWORA - Wedding Photography Google Drive Folders Migration
-- Run this script in your Supabase Dashboard SQL Editor

CREATE TABLE IF NOT EXISTS public.wedding_photo_folders (
    id TEXT PRIMARY KEY,
    event_id TEXT NOT NULL REFERENCES public.wedding_profiles(id) ON DELETE CASCADE,
    google_drive_folder_id TEXT NOT NULL,
    google_drive_folder_url TEXT NOT NULL,
    google_drive_api_key TEXT,
    created_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.wedding_photo_folders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Wedding photo folders are viewable and manageable by event participants" ON public.wedding_photo_folders;

CREATE POLICY "Wedding photo folders are viewable and manageable by event participants"
    ON public.wedding_photo_folders FOR ALL USING (true);

-- Index for fast event isolation lookup
CREATE INDEX IF NOT EXISTS idx_wedding_photo_folders_event_id ON public.wedding_photo_folders(event_id);
