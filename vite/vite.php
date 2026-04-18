<?php
if (!defined('ABSPATH')) {
  exit;
}

const VS_VITE_ENTRY = 'src/main.js';

function vs_vite_server_url(): ?string
{
  $hot_path = get_theme_file_path('/vite/.hot');
  if (!file_exists($hot_path)) {
    return null;
  }

  $url = trim((string) file_get_contents($hot_path));
  return $url !== '' ? untrailingslashit($url) : null;
}

function vs_vite_manifest_path(): string
{
  $vite_manifest = get_theme_file_path('/vite/dist/.vite/manifest.json');
  if (file_exists($vite_manifest)) {
    return $vite_manifest;
  }

  return get_theme_file_path('/vite/dist/manifest.json');
}

add_action('after_setup_theme', static function (): void {
  add_theme_support('title-tag');
});

add_action('wp_enqueue_scripts', static function (): void {
  $server = vs_vite_server_url();
  if ($server !== null) {
    wp_enqueue_script('vs-vite-client', $server . '/@vite/client', [], null, true);
    wp_enqueue_script('vs-main', $server . '/' . VS_VITE_ENTRY, [], null, true);
    return;
  }

  $manifest_path = vs_vite_manifest_path();
  if (!file_exists($manifest_path)) {
    return;
  }

  $manifest = json_decode((string) file_get_contents($manifest_path), true);
  if (!is_array($manifest) || empty($manifest[VS_VITE_ENTRY]['file'])) {
    return;
  }

  $entry = $manifest[VS_VITE_ENTRY];

  if (!empty($entry['file'])) {
    wp_enqueue_script('vs-main', get_theme_file_uri('/vite/dist/' . $entry['file']), [], null, true);
  }

  if (!empty($entry['css']) && is_array($entry['css'])) {
    foreach ($entry['css'] as $i => $css_file) {
      wp_enqueue_style('vs-style-' . $i, get_theme_file_uri('/vite/dist/' . $css_file), [], null);
    }
  }
}, 20);

add_filter('script_loader_tag', static function (string $tag, string $handle, string $src): string {
  if (in_array($handle, ['vs-vite-client', 'vs-main'], true)) {
    return '<script type="module" src="' . esc_url($src) . '"></script>';
  }

  return $tag;
}, 10, 3);
