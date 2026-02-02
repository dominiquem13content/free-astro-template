export type PageType =
  | 'blog_post'
  | 'blog_category'
  | 'blog_tag'
  | 'blog_author'
  | 'homepage'
  | 'about'
  | 'portfolio'
  | 'custom';

export type SectionType =
  | 'rich_text'
  | 'faq_accordion'
  | 'comparison_table'
  | 'callout_box'
  | 'checklist'
  | 'numbered_steps'
  | 'feature_highlights'
  | 'two_column_text'
  | 'cta_banner';

export type CalloutVariant = 'info' | 'warning' | 'success' | 'danger';

export interface FAQ {
  question: string;
  answer: string;
}

export interface FAQAccordionData {
  faqs: FAQ[];
}

export interface ComparisonTableData {
  headers: string[];
  rows: Array<{
    label: string;
    values: string[];
  }>;
}

export interface CalloutBoxData {
  variant: CalloutVariant;
  callout_type: CalloutVariant;
}

export interface ChecklistData {
  items: string[];
}

export interface NumberedStep {
  title: string;
  content: string;
}

export interface NumberedStepsData {
  steps: NumberedStep[];
}

export interface Feature {
  title: string;
  description: string;
  icon?: string;
}

export interface FeatureHighlightsData {
  features: Feature[];
}

export interface TwoColumnTextData {
  left_column: string;
  right_column: string;
}

export interface CTABannerData {
  primary_button_text: string;
  primary_button_url: string;
  secondary_button_text?: string;
  secondary_button_url?: string;
}

export type ContentData =
  | FAQAccordionData
  | ComparisonTableData
  | CalloutBoxData
  | ChecklistData
  | NumberedStepsData
  | FeatureHighlightsData
  | TwoColumnTextData
  | CTABannerData
  | Record<string, never>;

export interface ContentSection {
  id: string;
  page_type: PageType;
  page_id: string;
  section_type: SectionType;
  title: string | null;
  content: string | null;
  content_data: ContentData;
  sort_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface PageSEOContent {
  id: string;
  page_type: PageType;
  page_id: string;
  intro_text: string | null;
  main_content: string | null;
  bottom_content: string | null;
  created_at: string;
  updated_at: string;
}

export interface ContentTemplate {
  id: string;
  template_name: string;
  page_type: PageType;
  sections: any[];
  description: string | null;
  is_public: boolean;
  created_at: string;
}
