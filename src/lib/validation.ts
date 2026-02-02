export function sanitizeHtml(input: string): string {
  return input
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
    .replace(/\//g, '&#x2F;');
}

export function sanitizeString(input: string): string {
  return input.trim().replace(/[\x00-\x1F\x7F]/g, '');
}

export function validateUrl(url: string): boolean {
  try {
    const parsed = new URL(url);
    return ['http:', 'https:'].includes(parsed.protocol);
  } catch {
    return false;
  }
}

export function validateSlug(slug: string): boolean {
  return /^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug);
}

export function validatePageType(pageType: string): boolean {
  const validTypes = [
    'blog_post',
    'blog_category',
    'blog_tag',
    'blog_author',
    'homepage',
    'about',
    'portfolio',
    'custom'
  ];
  return validTypes.includes(pageType);
}

export function validateSectionType(sectionType: string): boolean {
  const validTypes = [
    'rich_text',
    'faq_accordion',
    'comparison_table',
    'callout_box',
    'checklist',
    'numbered_steps',
    'feature_highlights',
    'two_column_text',
    'cta_banner'
  ];
  return validTypes.includes(sectionType);
}

export function validateJson(jsonString: string): { valid: boolean; data?: any; error?: string } {
  try {
    const data = JSON.parse(jsonString);
    return { valid: true, data };
  } catch (error) {
    return {
      valid: false,
      error: error instanceof Error ? error.message : 'Invalid JSON'
    };
  }
}

export function sanitizeJsonData(data: any): any {
  if (typeof data === 'string') {
    return sanitizeString(data);
  }

  if (Array.isArray(data)) {
    return data.map(item => sanitizeJsonData(item));
  }

  if (typeof data === 'object' && data !== null) {
    const sanitized: any = {};
    for (const [key, value] of Object.entries(data)) {
      sanitized[key] = sanitizeJsonData(value);
    }
    return sanitized;
  }

  return data;
}

export function validateSortOrder(order: number): boolean {
  return Number.isInteger(order) && order >= 0 && order <= 10000;
}

export function validateContentLength(content: string, maxLength: number = 50000): boolean {
  return content.length <= maxLength;
}

export interface ValidationResult {
  valid: boolean;
  errors: string[];
}

export function validateSectionData(data: {
  pageType: string;
  pageId: string;
  sectionType: string;
  content?: string;
  contentData?: string;
  sortOrder: number;
}): ValidationResult {
  const errors: string[] = [];

  if (!validatePageType(data.pageType)) {
    errors.push('Invalid page type');
  }

  if (!data.pageId || data.pageId.length === 0) {
    errors.push('Page ID is required');
  }

  if (!validateSectionType(data.sectionType)) {
    errors.push('Invalid section type');
  }

  if (data.content && !validateContentLength(data.content)) {
    errors.push('Content exceeds maximum length');
  }

  if (data.contentData) {
    const jsonValidation = validateJson(data.contentData);
    if (!jsonValidation.valid) {
      errors.push(`Invalid JSON in content data: ${jsonValidation.error}`);
    }
  }

  if (!validateSortOrder(data.sortOrder)) {
    errors.push('Sort order must be a positive integer between 0 and 10000');
  }

  return {
    valid: errors.length === 0,
    errors
  };
}

export function preventSqlInjection(input: string): string {
  return input.replace(/['";\\]/g, '');
}

export function validateUuid(uuid: string): boolean {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  return uuidRegex.test(uuid);
}
