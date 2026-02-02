import { marked } from 'marked';

marked.setOptions({
  gfm: true,
  breaks: true,
});

export async function parseMarkdown(content: string): Promise<string> {
  try {
    const html = await marked.parse(content);
    return html;
  } catch (error) {
    console.error('Error parsing markdown:', error);
    return `<p>Error rendering content</p>`;
  }
}

export function generateSlug(text: string): string {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_-]+/g, '-')
    .replace(/^-+|-+$/g, '');
}
