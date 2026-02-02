import { supabase } from './supabase';
import type { ContentSection, PageSEOContent, PageType } from './cms-types';

export async function getPageContentSections(
  pageType: PageType,
  pageId: string
): Promise<ContentSection[]> {
  const { data, error } = await supabase
    .from('page_content_sections')
    .select('*')
    .eq('page_type', pageType)
    .eq('page_id', pageId)
    .eq('is_active', true)
    .order('sort_order', { ascending: true });

  if (error) {
    console.error('Error fetching content sections:', error);
    return [];
  }

  return (data as ContentSection[]) || [];
}

export async function getPageSEOContent(
  pageType: PageType,
  pageId: string
): Promise<PageSEOContent | null> {
  const { data, error } = await supabase
    .from('page_seo_content')
    .select('*')
    .eq('page_type', pageType)
    .eq('page_id', pageId)
    .maybeSingle();

  if (error) {
    console.error('Error fetching SEO content:', error);
    return null;
  }

  return data as PageSEOContent | null;
}

export async function createContentSection(section: Partial<ContentSection>): Promise<ContentSection | null> {
  const { data, error } = await supabase
    .from('page_content_sections')
    .insert(section)
    .select()
    .single();

  if (error) {
    console.error('Error creating content section:', error);
    return null;
  }

  return data as ContentSection;
}

export async function updateContentSection(
  id: string,
  updates: Partial<ContentSection>
): Promise<ContentSection | null> {
  const { data, error } = await supabase
    .from('page_content_sections')
    .update(updates)
    .eq('id', id)
    .select()
    .single();

  if (error) {
    console.error('Error updating content section:', error);
    return null;
  }

  return data as ContentSection;
}

export async function deleteContentSection(id: string): Promise<boolean> {
  const { error } = await supabase
    .from('page_content_sections')
    .delete()
    .eq('id', id);

  if (error) {
    console.error('Error deleting content section:', error);
    return false;
  }

  return true;
}

export async function upsertPageSEOContent(
  seoContent: Partial<PageSEOContent>
): Promise<PageSEOContent | null> {
  const { data, error } = await supabase
    .from('page_seo_content')
    .upsert(seoContent, {
      onConflict: 'page_type,page_id'
    })
    .select()
    .single();

  if (error) {
    console.error('Error upserting SEO content:', error);
    return null;
  }

  return data as PageSEOContent;
}
