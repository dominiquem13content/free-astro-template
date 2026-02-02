import rss from '@astrojs/rss';
import { SITE_DESCRIPTION, SITE_TITLE } from '../consts';
import { supabase } from '../lib/supabase';

export async function GET(context) {
	const { data: posts } = await supabase
		.from('posts')
		.select('*')
		.eq('published', true)
		.order('published_at', { ascending: false });

	return rss({
		title: SITE_TITLE,
		description: SITE_DESCRIPTION,
		site: context.site,
		items: (posts || []).map((post) => ({
			title: post.title,
			description: post.excerpt || '',
			pubDate: new Date(post.published_at || post.created_at),
			link: `/blog/${post.slug}/`,
		})),
	});
}
