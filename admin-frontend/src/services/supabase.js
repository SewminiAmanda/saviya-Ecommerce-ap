import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://fbkovdupdbumqkqrzeys.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZia292ZHVwZGJ1bXFrcXJ6ZXlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTExOTk0NjksImV4cCI6MjA2Njc3NTQ2OX0.q0-ylimYskgsyy-bihpJgEmTI_I4lY5dutMbPH1TLrU';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);