# CMS Content Management System Documentation

## Overview

This flexible CMS allows you to add rich, structured content to any page without code deployments. The system supports 9 different section types with full SEO optimization.

## Features

- **Zero-Code Updates**: Add/edit content via the CMS Admin interface
- **9 Section Types**: Rich text, FAQs, checklists, comparison tables, and more
- **SEO-Optimized**: Automatic structured data for FAQs and other content
- **Flexible**: Works with blog posts, categories, tags, and custom pages
- **Visual Admin**: User-friendly interface for managing content

## Accessing the CMS

Navigate to `/cms-admin` or click the "CMS" link in the header navigation.

## Using the CMS Admin

### 1. Select a Page

1. Choose the **Page Type** (e.g., "Blog Post")
2. Enter the **Page ID/Slug** (e.g., "example-post-1")
3. Click **Load Sections** to view existing content

### 2. Add New Section

1. Click **Add New Section**
2. Select a **Section Type** from the dropdown
3. Enter a **Title** (optional)
4. Add **Content** (supports Markdown)
5. Configure **Content Data** (JSON) for structured sections
6. Set **Sort Order** (use increments of 10 for easy reordering)
7. Click **Save Section**

### 3. Edit Existing Section

1. Click the **Edit** button on any section
2. Modify the fields as needed
3. Click **Save Section**

### 4. Manage Sections

- **Delete**: Remove a section permanently
- **Toggle Active/Inactive**: Show or hide a section without deleting it

## Section Types & Examples

### 1. Rich Text (`rich_text`)

Simple markdown content with optional title.

**Example Content Data:**
```json
{}
```

**Use Case**: Long-form explanations, guides, additional content

---

### 2. FAQ Accordion (`faq_accordion`)

Expandable Q&A sections with automatic SEO structured data.

**Example Content Data:**
```json
{
  "faqs": [
    {
      "question": "What is the annual fee?",
      "answer": "The annual fee is $120, waived in the first year."
    },
    {
      "question": "How do I apply?",
      "answer": "You can apply online through our secure application portal."
    }
  ]
}
```

**SEO Benefits**: Generates Google-compliant FAQ rich snippets

---

### 3. Callout Box (`callout_box`)

Highlighted information boxes in different styles.

**Example Content Data:**
```json
{
  "variant": "info",
  "callout_type": "info"
}
```

**Variants**: `info`, `warning`, `success`, `danger`

**Use Case**: Important notes, warnings, tips, highlights

---

### 4. Checklist (`checklist`)

Visual list with checkmarks.

**Example Content Data:**
```json
{
  "items": [
    "No foreign transaction fees",
    "Free airport lounge access",
    "Comprehensive travel insurance"
  ]
}
```

**Use Case**: Benefits, features, requirements

---

### 5. Numbered Steps (`numbered_steps`)

Step-by-step guide with numbers.

**Example Content Data:**
```json
{
  "steps": [
    {
      "title": "Check Eligibility",
      "content": "Review income and credit requirements before applying."
    },
    {
      "title": "Gather Documents",
      "content": "Prepare ID, proof of income, and recent statements."
    }
  ]
}
```

**Use Case**: How-to guides, processes, tutorials

---

### 6. Comparison Table (`comparison_table`)

Side-by-side feature comparison.

**Example Content Data:**
```json
{
  "headers": ["Feature", "Option A", "Option B"],
  "rows": [
    {
      "label": "Annual Fee",
      "values": ["$120", "$139"]
    },
    {
      "label": "Welcome Bonus",
      "values": ["25K points", "20K points"]
    }
  ]
}
```

**Use Case**: Product comparisons, pricing tables

---

### 7. Feature Highlights (`feature_highlights`)

Grid of features with icons.

**Example Content Data:**
```json
{
  "features": [
    {
      "title": "Zero FX Fees",
      "description": "Save 2.5% on international purchases",
      "icon": "💰"
    },
    {
      "title": "24/7 Support",
      "description": "Expert help whenever you need it",
      "icon": "🛟"
    }
  ]
}
```

**Use Case**: Key benefits, service features

---

### 8. Two Column Text (`two_column_text`)

Side-by-side content (great for pros/cons).

**Example Content Data:**
```json
{
  "left_column": "## Pros\n- High rewards rate\n- No annual fee\n- Great perks",
  "right_column": "## Cons\n- Requires good credit\n- Limited acceptance\n- Complex terms"
}
```

**Use Case**: Pros/cons, comparisons, split content

---

### 9. CTA Banner (`cta_banner`)

Call-to-action banner with buttons.

**Example Content Data:**
```json
{
  "primary_button_text": "Apply Now",
  "primary_button_url": "/apply",
  "secondary_button_text": "Learn More",
  "secondary_button_url": "/details"
}
```

**Use Case**: Conversion prompts, applications, sign-ups

---

## SEO Content Blocks

In addition to sections, you can add SEO-optimized intro and outro content:

- **Intro Text**: Opening paragraph (150-200 words)
- **Main Content**: Not currently used (reserved for future)
- **Bottom Content**: Closing SEO text (200-300 words)

*Note: SEO content management will be added to the CMS Admin in a future update.*

## Database Structure

### Tables

1. **`page_content_sections`**: Flexible content sections
2. **`page_seo_content`**: SEO intro/outro content
3. **`content_templates`**: Reusable content templates (future feature)

### Page Types

- `blog_post`: Blog post pages
- `blog_category`: Category listing pages
- `blog_tag`: Tag listing pages
- `blog_author`: Author profile pages
- `homepage`: Homepage
- `about`: About page
- `portfolio`: Portfolio page
- `custom`: Custom pages

## Best Practices

### Content Organization

1. **Use Sort Order Increments**: Use 10, 20, 30, etc. for easy reordering
2. **Group Related Content**: Keep related sections together
3. **Active/Inactive**: Use instead of deleting for seasonal content

### Writing Content

1. **Use Markdown**: Rich text sections support full Markdown
2. **Keep JSON Valid**: Test JSON in a validator before saving
3. **Write for SEO**: Use keywords naturally in titles and content

### Performance

1. **Minimize Sections**: 5-10 sections per page is ideal
2. **Optimize Images**: Use external CDN URLs for images
3. **Test Mobile**: Preview on mobile devices

## Troubleshooting

### "Invalid JSON in content data"

- Check for missing commas, quotes, or brackets
- Use a JSON validator like jsonlint.com
- Ensure all strings are in double quotes

### Sections Not Appearing

- Verify the page ID/slug is correct
- Check that the section is marked as "Active"
- Ensure the sort order is appropriate

### Build Errors

- Check browser console for errors
- Verify database connection is working
- Ensure all required fields are filled

## Security

- Only authenticated users can create/edit/delete content
- Public users can only read active content
- All database operations use Row Level Security (RLS)

## Future Enhancements

- Visual content template builder
- Drag-and-drop section reordering
- Content preview before publishing
- SEO content editor in admin UI
- Bulk section operations
- Content version history

---

## Example Usage

### Adding FAQ to a Blog Post

1. Go to `/cms-admin`
2. Select "Blog Post" and enter slug "example-post-1"
3. Click "Load Sections"
4. Click "Add New Section"
5. Select "FAQ Accordion"
6. Title: "Frequently Asked Questions"
7. Content Data:
```json
{
  "faqs": [
    {
      "question": "How does this work?",
      "answer": "It's simple! Just follow these steps..."
    }
  ]
}
```
8. Sort Order: 20
9. Click "Save Section"
10. Visit the blog post to see your FAQ with structured data!

---

For technical support or feature requests, please contact the development team.
