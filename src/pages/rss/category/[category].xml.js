import rss from '@astrojs/rss';
import { supabase } from '../../../lib/supabase';

export async function getStaticPaths() {
  const { data: categories } = await supabase
    .from('categories')
    .select('slug');

  return (categories || []).map((cat) => ({ params: { category: cat.slug } }));
}

export async function GET(context) {
  const { category } = context.params;

  const { data: categoryData } = await supabase
    .from('categories')
    .select('*')
    .eq('slug', category)
    .single();

  const { data: posts } = await supabase
    .from('posts')
    .select('*')
    .eq('category_id', categoryData?.id)
    .eq('published', true)
    .order('published_at', { ascending: false });

  return rss({
    title: `Category: ${categoryData?.name || category}`,
    description: `Latest posts in ${categoryData?.name || category}`,
    site: context.site,
    items: (posts || []).map((post) => ({
      title: post.title,
      description: post.excerpt || '',
      pubDate: new Date(post.published_at || post.created_at),
      link: `/blog/${post.slug}/`,
    })),
  });
}


