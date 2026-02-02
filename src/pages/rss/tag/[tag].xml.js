import rss from '@astrojs/rss';
import { supabase } from '../../../lib/supabase';

export async function getStaticPaths() {
  const { data: tags } = await supabase
    .from('tags')
    .select('slug');

  return (tags || []).map((t) => ({ params: { tag: t.slug } }));
}

export async function GET(context) {
  const { tag } = context.params;

  const { data: tagData } = await supabase
    .from('tags')
    .select('*')
    .eq('slug', tag)
    .single();

  const { data: postTags } = await supabase
    .from('post_tags')
    .select('post_id')
    .eq('tag_id', tagData?.id);

  const postIds = postTags?.map(pt => pt.post_id) || [];

  const { data: posts } = await supabase
    .from('posts')
    .select('*')
    .in('id', postIds)
    .eq('published', true)
    .order('published_at', { ascending: false });

  return rss({
    title: `Tag: ${tagData?.name || tag}`,
    description: `Latest posts tagged ${tagData?.name || tag}`,
    site: context.site,
    items: (posts || []).map((post) => ({
      title: post.title,
      description: post.excerpt || '',
      pubDate: new Date(post.published_at || post.created_at),
      link: `/blog/${post.slug}/`,
    })),
  });
}


