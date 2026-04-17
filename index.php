<?php
if (!defined('ABSPATH')) {
  exit;
}
?>
<!doctype html>
<html <?php language_attributes(); ?>>

<head>
  <meta charset="<?php bloginfo('charset'); ?>">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <?php wp_head(); ?>
</head>

<body <?php body_class(); ?>>
  <?php wp_body_open(); ?>
  <main>
    <h1><?php bloginfo('name'); ?></h1>
    <p>
      <?php bloginfo('description'); ?>
    </p>
    <?php if (have_posts()): ?>
      <?php while (have_posts()):
        the_post(); ?>
        <h2>
          <a href="<?php the_permalink(); ?>">
            <?php the_title(); ?>
          </a>
        </h2>
        <div>
          <?php if (is_home() || is_front_page()): ?>
            <?php the_excerpt(); ?>
          <?php else: ?>
            <?php the_content(); ?>
          <?php endif; ?>
        </div>
      <?php endwhile; ?>
    <?php endif; ?>
  </main>
  <?php wp_footer(); ?>
</body>

</html>