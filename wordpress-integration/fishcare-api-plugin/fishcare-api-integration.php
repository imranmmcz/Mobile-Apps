<?php
/**
 * Plugin Name: FishCare API Integration
 * Plugin URI: https://fishcare.com.bd
 * Description: Custom REST API integration for FishCare Flutter App - Full CRUD operations for Fish, Medicine, Market Price, Posts, Pages, Users
 * Version: 1.0.0
 * Author: FishCare Team
 * Author URI: https://fishcare.com.bd
 * License: GPL v2 or later
 * Text Domain: fishcare-api
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Define plugin constants
define('FISHCARE_API_VERSION', '1.0.0');
define('FISHCARE_API_PLUGIN_DIR', plugin_dir_path(__FILE__));
define('FISHCARE_API_PLUGIN_URL', plugin_dir_url(__FILE__));

/**
 * Main FishCare API Integration Class
 */
class FishCare_API_Integration {
    
    private static $instance = null;
    
    public static function get_instance() {
        if (null === self::$instance) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    private function __construct() {
        // Register custom post types
        add_action('init', array($this, 'register_custom_post_types'));
        
        // Register REST API routes
        add_action('rest_api_init', array($this, 'register_rest_routes'));
        
        // Enable CORS for API
        add_action('rest_api_init', array($this, 'enable_cors'));
        
        // Add API settings page
        add_action('admin_menu', array($this, 'add_admin_menu'));
        
        // Generate API key on activation
        register_activation_hook(__FILE__, array($this, 'activate_plugin'));
    }
    
    /**
     * Plugin activation
     */
    public function activate_plugin() {
        // Generate API key if not exists
        if (!get_option('fishcare_api_key')) {
            $api_key = wp_generate_password(32, false);
            update_option('fishcare_api_key', $api_key);
        }
        
        // Flush rewrite rules
        flush_rewrite_rules();
    }
    
    /**
     * Register Custom Post Types
     */
    public function register_custom_post_types() {
        
        // Fish Products CPT
        register_post_type('fish_product', array(
            'labels' => array(
                'name' => __('Fish Products', 'fishcare-api'),
                'singular_name' => __('Fish Product', 'fishcare-api'),
            ),
            'public' => true,
            'show_in_rest' => true,
            'rest_base' => 'fish-products',
            'supports' => array('title', 'editor', 'thumbnail', 'custom-fields'),
            'has_archive' => true,
            'menu_icon' => 'dashicons-store',
        ));
        
        // Medicine Products CPT
        register_post_type('medicine', array(
            'labels' => array(
                'name' => __('Medicines', 'fishcare-api'),
                'singular_name' => __('Medicine', 'fishcare-api'),
            ),
            'public' => true,
            'show_in_rest' => true,
            'rest_base' => 'medicines',
            'supports' => array('title', 'editor', 'thumbnail', 'custom-fields'),
            'has_archive' => true,
            'menu_icon' => 'dashicons-medication',
        ));
        
        // Market Price CPT
        register_post_type('market_price', array(
            'labels' => array(
                'name' => __('Market Prices', 'fishcare-api'),
                'singular_name' => __('Market Price', 'fishcare-api'),
            ),
            'public' => true,
            'show_in_rest' => true,
            'rest_base' => 'market-prices',
            'supports' => array('title', 'editor', 'custom-fields'),
            'has_archive' => true,
            'menu_icon' => 'dashicons-chart-line',
        ));
    }
    
    /**
     * Enable CORS
     */
    public function enable_cors() {
        remove_filter('rest_pre_serve_request', 'rest_send_cors_headers');
        add_filter('rest_pre_serve_request', function($value) {
            header('Access-Control-Allow-Origin: *');
            header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
            header('Access-Control-Allow-Headers: Content-Type, Authorization, X-API-Key, X-User-Role');
            header('Access-Control-Allow-Credentials: true');
            return $value;
        });
    }
    
    /**
     * Verify API Key
     */
    private function verify_api_key($request) {
        $api_key = $request->get_header('X-API-Key');
        $stored_key = get_option('fishcare_api_key');
        
        if (!$api_key || $api_key !== $stored_key) {
            return new WP_Error('invalid_api_key', 'Invalid API Key', array('status' => 401));
        }
        
        return true;
    }
    
    /**
     * Check admin permission
     */
    private function check_admin_permission($request) {
        $user_role = $request->get_header('X-User-Role');
        
        if (!in_array($user_role, array('admin', 'manager'))) {
            return new WP_Error('insufficient_permission', 'Insufficient permissions', array('status' => 403));
        }
        
        return true;
    }
    
    /**
     * Register REST API Routes
     */
    public function register_rest_routes() {
        $namespace = 'fishcare/v1';
        
        // Fish Products Endpoints
        register_rest_route($namespace, '/fish-products', array(
            array(
                'methods' => 'GET',
                'callback' => array($this, 'get_fish_products'),
                'permission_callback' => array($this, 'verify_api_key'),
            ),
            array(
                'methods' => 'POST',
                'callback' => array($this, 'create_fish_product'),
                'permission_callback' => array($this, 'check_admin_permission'),
            ),
        ));
        
        register_rest_route($namespace, '/fish-products/(?P<id>\d+)', array(
            array(
                'methods' => 'GET',
                'callback' => array($this, 'get_fish_product'),
                'permission_callback' => array($this, 'verify_api_key'),
            ),
            array(
                'methods' => 'PUT',
                'callback' => array($this, 'update_fish_product'),
                'permission_callback' => array($this, 'check_admin_permission'),
            ),
            array(
                'methods' => 'DELETE',
                'callback' => array($this, 'delete_fish_product'),
                'permission_callback' => array($this, 'check_admin_permission'),
            ),
        ));
        
        // Medicine Endpoints
        register_rest_route($namespace, '/medicines', array(
            array(
                'methods' => 'GET',
                'callback' => array($this, 'get_medicines'),
                'permission_callback' => array($this, 'verify_api_key'),
            ),
            array(
                'methods' => 'POST',
                'callback' => array($this, 'create_medicine'),
                'permission_callback' => array($this, 'check_admin_permission'),
            ),
        ));
        
        register_rest_route($namespace, '/medicines/(?P<id>\d+)', array(
            array(
                'methods' => 'GET',
                'callback' => array($this, 'get_medicine'),
                'permission_callback' => array($this, 'verify_api_key'),
            ),
            array(
                'methods' => 'PUT',
                'callback' => array($this, 'update_medicine'),
                'permission_callback' => array($this, 'check_admin_permission'),
            ),
            array(
                'methods' => 'DELETE',
                'callback' => array($this, 'delete_medicine'),
                'permission_callback' => array($this, 'check_admin_permission'),
            ),
        ));
        
        // Market Price Endpoints
        register_rest_route($namespace, '/market-prices', array(
            array(
                'methods' => 'GET',
                'callback' => array($this, 'get_market_prices'),
                'permission_callback' => array($this, 'verify_api_key'),
            ),
            array(
                'methods' => 'POST',
                'callback' => array($this, 'create_market_price'),
                'permission_callback' => array($this, 'check_admin_permission'),
            ),
        ));
        
        // Posts Management Endpoints
        register_rest_route($namespace, '/posts', array(
            array(
                'methods' => 'GET',
                'callback' => array($this, 'get_posts_custom'),
                'permission_callback' => array($this, 'verify_api_key'),
            ),
            array(
                'methods' => 'POST',
                'callback' => array($this, 'create_post_custom'),
                'permission_callback' => array($this, 'check_admin_permission'),
            ),
        ));
        
        // Pages Management Endpoints
        register_rest_route($namespace, '/pages', array(
            array(
                'methods' => 'GET',
                'callback' => array($this, 'get_pages_custom'),
                'permission_callback' => array($this, 'verify_api_key'),
            ),
            array(
                'methods' => 'POST',
                'callback' => array($this, 'create_page_custom'),
                'permission_callback' => array($this, 'check_admin_permission'),
            ),
        ));
        
        // Users Management Endpoints
        register_rest_route($namespace, '/users', array(
            array(
                'methods' => 'GET',
                'callback' => array($this, 'get_users_custom'),
                'permission_callback' => array($this, 'check_admin_permission'),
            ),
            array(
                'methods' => 'POST',
                'callback' => array($this, 'create_user_custom'),
                'permission_callback' => array($this, 'check_admin_permission'),
            ),
        ));
        
        // Settings Endpoint
        register_rest_route($namespace, '/settings', array(
            array(
                'methods' => 'GET',
                'callback' => array($this, 'get_settings'),
                'permission_callback' => array($this, 'verify_api_key'),
            ),
            array(
                'methods' => 'POST',
                'callback' => array($this, 'update_settings'),
                'permission_callback' => array($this, 'check_admin_permission'),
            ),
        ));
    }
    
    // ==================== FISH PRODUCTS CRUD ====================
    
    /**
     * Get all fish products
     */
    public function get_fish_products($request) {
        $args = array(
            'post_type' => 'fish_product',
            'posts_per_page' => -1,
            'post_status' => 'publish',
        );
        
        $category = $request->get_param('category');
        if ($category) {
            $args['meta_query'] = array(
                array(
                    'key' => 'category',
                    'value' => $category,
                    'compare' => '='
                )
            );
        }
        
        $posts = get_posts($args);
        $fish_products = array();
        
        foreach ($posts as $post) {
            $fish_products[] = $this->format_fish_product($post);
        }
        
        return rest_ensure_response($fish_products);
    }
    
    /**
     * Get single fish product
     */
    public function get_fish_product($request) {
        $id = $request['id'];
        $post = get_post($id);
        
        if (!$post || $post->post_type !== 'fish_product') {
            return new WP_Error('not_found', 'Fish product not found', array('status' => 404));
        }
        
        return rest_ensure_response($this->format_fish_product($post));
    }
    
    /**
     * Create fish product
     */
    public function create_fish_product($request) {
        $params = $request->get_json_params();
        
        $post_id = wp_insert_post(array(
            'post_title' => sanitize_text_field($params['name_bengali']),
            'post_content' => sanitize_textarea_field($params['description'] ?? ''),
            'post_type' => 'fish_product',
            'post_status' => 'publish',
        ));
        
        if (is_wp_error($post_id)) {
            return $post_id;
        }
        
        // Update meta fields
        update_post_meta($post_id, 'name_bengali', sanitize_text_field($params['name_bengali']));
        update_post_meta($post_id, 'name_english', sanitize_text_field($params['name_english'] ?? ''));
        update_post_meta($post_id, 'category', sanitize_text_field($params['category'] ?? ''));
        update_post_meta($post_id, 'price_per_kg', floatval($params['price_per_kg'] ?? 0));
        update_post_meta($post_id, 'stock_kg', floatval($params['stock_kg'] ?? 0));
        update_post_meta($post_id, 'image_url', esc_url($params['image_url'] ?? ''));
        update_post_meta($post_id, 'last_updated', current_time('mysql'));
        
        $post = get_post($post_id);
        return rest_ensure_response($this->format_fish_product($post));
    }
    
    /**
     * Update fish product
     */
    public function update_fish_product($request) {
        $id = $request['id'];
        $params = $request->get_json_params();
        
        $post = get_post($id);
        if (!$post || $post->post_type !== 'fish_product') {
            return new WP_Error('not_found', 'Fish product not found', array('status' => 404));
        }
        
        wp_update_post(array(
            'ID' => $id,
            'post_title' => sanitize_text_field($params['name_bengali']),
            'post_content' => sanitize_textarea_field($params['description'] ?? ''),
        ));
        
        // Update meta fields
        update_post_meta($id, 'name_bengali', sanitize_text_field($params['name_bengali']));
        update_post_meta($id, 'name_english', sanitize_text_field($params['name_english'] ?? ''));
        update_post_meta($id, 'category', sanitize_text_field($params['category'] ?? ''));
        update_post_meta($id, 'price_per_kg', floatval($params['price_per_kg'] ?? 0));
        update_post_meta($id, 'stock_kg', floatval($params['stock_kg'] ?? 0));
        update_post_meta($id, 'image_url', esc_url($params['image_url'] ?? ''));
        update_post_meta($id, 'last_updated', current_time('mysql'));
        
        $post = get_post($id);
        return rest_ensure_response($this->format_fish_product($post));
    }
    
    /**
     * Delete fish product
     */
    public function delete_fish_product($request) {
        $id = $request['id'];
        $post = get_post($id);
        
        if (!$post || $post->post_type !== 'fish_product') {
            return new WP_Error('not_found', 'Fish product not found', array('status' => 404));
        }
        
        $result = wp_delete_post($id, true);
        
        if (!$result) {
            return new WP_Error('delete_failed', 'Failed to delete fish product', array('status' => 500));
        }
        
        return rest_ensure_response(array('success' => true, 'message' => 'Fish product deleted'));
    }
    
    /**
     * Format fish product response
     */
    private function format_fish_product($post) {
        return array(
            'id' => $post->ID,
            'name_bengali' => get_post_meta($post->ID, 'name_bengali', true),
            'name_english' => get_post_meta($post->ID, 'name_english', true),
            'category' => get_post_meta($post->ID, 'category', true),
            'price_per_kg' => floatval(get_post_meta($post->ID, 'price_per_kg', true)),
            'stock_kg' => floatval(get_post_meta($post->ID, 'stock_kg', true)),
            'description' => $post->post_content,
            'image_url' => get_post_meta($post->ID, 'image_url', true),
            'last_updated' => get_post_meta($post->ID, 'last_updated', true),
        );
    }
    
    // ==================== MEDICINE CRUD ====================
    
    /**
     * Get all medicines
     */
    public function get_medicines($request) {
        $args = array(
            'post_type' => 'medicine',
            'posts_per_page' => -1,
            'post_status' => 'publish',
        );
        
        $posts = get_posts($args);
        $medicines = array();
        
        foreach ($posts as $post) {
            $medicines[] = $this->format_medicine($post);
        }
        
        return rest_ensure_response($medicines);
    }
    
    /**
     * Get single medicine
     */
    public function get_medicine($request) {
        $id = $request['id'];
        $post = get_post($id);
        
        if (!$post || $post->post_type !== 'medicine') {
            return new WP_Error('not_found', 'Medicine not found', array('status' => 404));
        }
        
        return rest_ensure_response($this->format_medicine($post));
    }
    
    /**
     * Create medicine
     */
    public function create_medicine($request) {
        $params = $request->get_json_params();
        
        $post_id = wp_insert_post(array(
            'post_title' => sanitize_text_field($params['name_bengali']),
            'post_content' => sanitize_textarea_field($params['dosage_info'] ?? ''),
            'post_type' => 'medicine',
            'post_status' => 'publish',
        ));
        
        if (is_wp_error($post_id)) {
            return $post_id;
        }
        
        // Update meta fields
        update_post_meta($post_id, 'name_bengali', sanitize_text_field($params['name_bengali']));
        update_post_meta($post_id, 'name_english', sanitize_text_field($params['name_english'] ?? ''));
        update_post_meta($post_id, 'category', sanitize_text_field($params['category'] ?? ''));
        update_post_meta($post_id, 'price_per_unit', floatval($params['price_per_unit'] ?? 0));
        update_post_meta($post_id, 'stock_quantity', intval($params['stock_quantity'] ?? 0));
        update_post_meta($post_id, 'dosage_info', sanitize_text_field($params['dosage_info'] ?? ''));
        update_post_meta($post_id, 'manufacturer', sanitize_text_field($params['manufacturer'] ?? ''));
        update_post_meta($post_id, 'expiry_date', sanitize_text_field($params['expiry_date'] ?? ''));
        update_post_meta($post_id, 'last_updated', current_time('mysql'));
        
        $post = get_post($post_id);
        return rest_ensure_response($this->format_medicine($post));
    }
    
    /**
     * Update medicine
     */
    public function update_medicine($request) {
        $id = $request['id'];
        $params = $request->get_json_params();
        
        $post = get_post($id);
        if (!$post || $post->post_type !== 'medicine') {
            return new WP_Error('not_found', 'Medicine not found', array('status' => 404));
        }
        
        wp_update_post(array(
            'ID' => $id,
            'post_title' => sanitize_text_field($params['name_bengali']),
            'post_content' => sanitize_textarea_field($params['dosage_info'] ?? ''),
        ));
        
        // Update meta fields
        update_post_meta($id, 'name_bengali', sanitize_text_field($params['name_bengali']));
        update_post_meta($id, 'name_english', sanitize_text_field($params['name_english'] ?? ''));
        update_post_meta($id, 'category', sanitize_text_field($params['category'] ?? ''));
        update_post_meta($id, 'price_per_unit', floatval($params['price_per_unit'] ?? 0));
        update_post_meta($id, 'stock_quantity', intval($params['stock_quantity'] ?? 0));
        update_post_meta($id, 'dosage_info', sanitize_text_field($params['dosage_info'] ?? ''));
        update_post_meta($id, 'manufacturer', sanitize_text_field($params['manufacturer'] ?? ''));
        update_post_meta($id, 'expiry_date', sanitize_text_field($params['expiry_date'] ?? ''));
        update_post_meta($id, 'last_updated', current_time('mysql'));
        
        $post = get_post($id);
        return rest_ensure_response($this->format_medicine($post));
    }
    
    /**
     * Delete medicine
     */
    public function delete_medicine($request) {
        $id = $request['id'];
        $post = get_post($id);
        
        if (!$post || $post->post_type !== 'medicine') {
            return new WP_Error('not_found', 'Medicine not found', array('status' => 404));
        }
        
        $result = wp_delete_post($id, true);
        
        if (!$result) {
            return new WP_Error('delete_failed', 'Failed to delete medicine', array('status' => 500));
        }
        
        return rest_ensure_response(array('success' => true, 'message' => 'Medicine deleted'));
    }
    
    /**
     * Format medicine response
     */
    private function format_medicine($post) {
        return array(
            'id' => $post->ID,
            'name_bengali' => get_post_meta($post->ID, 'name_bengali', true),
            'name_english' => get_post_meta($post->ID, 'name_english', true),
            'category' => get_post_meta($post->ID, 'category', true),
            'price_per_unit' => floatval(get_post_meta($post->ID, 'price_per_unit', true)),
            'stock_quantity' => intval(get_post_meta($post->ID, 'stock_quantity', true)),
            'dosage_info' => get_post_meta($post->ID, 'dosage_info', true),
            'manufacturer' => get_post_meta($post->ID, 'manufacturer', true),
            'expiry_date' => get_post_meta($post->ID, 'expiry_date', true),
            'last_updated' => get_post_meta($post->ID, 'last_updated', true),
        );
    }
    
    // ==================== MARKET PRICE CRUD ====================
    
    /**
     * Get market prices
     */
    public function get_market_prices($request) {
        $args = array(
            'post_type' => 'market_price',
            'posts_per_page' => -1,
            'post_status' => 'publish',
            'orderby' => 'date',
            'order' => 'DESC',
        );
        
        $posts = get_posts($args);
        $prices = array();
        
        foreach ($posts as $post) {
            $prices[] = array(
                'id' => $post->ID,
                'product_name' => $post->post_title,
                'price' => floatval(get_post_meta($post->ID, 'price', true)),
                'unit' => get_post_meta($post->ID, 'unit', true),
                'market' => get_post_meta($post->ID, 'market', true),
                'date' => $post->post_date,
            );
        }
        
        return rest_ensure_response($prices);
    }
    
    /**
     * Create market price
     */
    public function create_market_price($request) {
        $params = $request->get_json_params();
        
        $post_id = wp_insert_post(array(
            'post_title' => sanitize_text_field($params['product_name']),
            'post_type' => 'market_price',
            'post_status' => 'publish',
        ));
        
        if (is_wp_error($post_id)) {
            return $post_id;
        }
        
        update_post_meta($post_id, 'price', floatval($params['price'] ?? 0));
        update_post_meta($post_id, 'unit', sanitize_text_field($params['unit'] ?? 'kg'));
        update_post_meta($post_id, 'market', sanitize_text_field($params['market'] ?? ''));
        
        return rest_ensure_response(array('success' => true, 'id' => $post_id));
    }
    
    // ==================== POSTS & PAGES CRUD ====================
    
    /**
     * Get posts
     */
    public function get_posts_custom($request) {
        $args = array(
            'post_type' => 'post',
            'posts_per_page' => 50,
            'post_status' => 'publish',
        );
        
        $posts = get_posts($args);
        $result = array();
        
        foreach ($posts as $post) {
            $result[] = array(
                'id' => $post->ID,
                'title' => $post->post_title,
                'content' => $post->post_content,
                'excerpt' => $post->post_excerpt,
                'date' => $post->post_date,
                'author' => get_the_author_meta('display_name', $post->post_author),
                'featured_image' => get_the_post_thumbnail_url($post->ID, 'full'),
            );
        }
        
        return rest_ensure_response($result);
    }
    
    /**
     * Create post
     */
    public function create_post_custom($request) {
        $params = $request->get_json_params();
        
        $post_id = wp_insert_post(array(
            'post_title' => sanitize_text_field($params['title']),
            'post_content' => wp_kses_post($params['content']),
            'post_excerpt' => sanitize_textarea_field($params['excerpt'] ?? ''),
            'post_status' => 'publish',
            'post_type' => 'post',
        ));
        
        if (is_wp_error($post_id)) {
            return $post_id;
        }
        
        return rest_ensure_response(array('success' => true, 'id' => $post_id));
    }
    
    /**
     * Get pages
     */
    public function get_pages_custom($request) {
        $args = array(
            'post_type' => 'page',
            'posts_per_page' => -1,
            'post_status' => 'publish',
        );
        
        $pages = get_posts($args);
        $result = array();
        
        foreach ($pages as $page) {
            $result[] = array(
                'id' => $page->ID,
                'title' => $page->post_title,
                'content' => $page->post_content,
                'slug' => $page->post_name,
                'date' => $page->post_date,
            );
        }
        
        return rest_ensure_response($result);
    }
    
    /**
     * Create page
     */
    public function create_page_custom($request) {
        $params = $request->get_json_params();
        
        $post_id = wp_insert_post(array(
            'post_title' => sanitize_text_field($params['title']),
            'post_content' => wp_kses_post($params['content']),
            'post_status' => 'publish',
            'post_type' => 'page',
        ));
        
        if (is_wp_error($post_id)) {
            return $post_id;
        }
        
        return rest_ensure_response(array('success' => true, 'id' => $post_id));
    }
    
    // ==================== USERS CRUD ====================
    
    /**
     * Get users
     */
    public function get_users_custom($request) {
        $users = get_users(array('number' => 100));
        $result = array();
        
        foreach ($users as $user) {
            $result[] = array(
                'id' => $user->ID,
                'username' => $user->user_login,
                'email' => $user->user_email,
                'display_name' => $user->display_name,
                'role' => implode(', ', $user->roles),
            );
        }
        
        return rest_ensure_response($result);
    }
    
    /**
     * Create user
     */
    public function create_user_custom($request) {
        $params = $request->get_json_params();
        
        $user_id = wp_create_user(
            sanitize_user($params['username']),
            $params['password'],
            sanitize_email($params['email'])
        );
        
        if (is_wp_error($user_id)) {
            return $user_id;
        }
        
        if (isset($params['role'])) {
            $user = new WP_User($user_id);
            $user->set_role($params['role']);
        }
        
        return rest_ensure_response(array('success' => true, 'id' => $user_id));
    }
    
    // ==================== SETTINGS ====================
    
    /**
     * Get settings
     */
    public function get_settings($request) {
        return rest_ensure_response(array(
            'site_title' => get_bloginfo('name'),
            'site_description' => get_bloginfo('description'),
            'site_url' => get_site_url(),
            'admin_email' => get_option('admin_email'),
        ));
    }
    
    /**
     * Update settings
     */
    public function update_settings($request) {
        $params = $request->get_json_params();
        
        if (isset($params['site_title'])) {
            update_option('blogname', sanitize_text_field($params['site_title']));
        }
        
        if (isset($params['site_description'])) {
            update_option('blogdescription', sanitize_text_field($params['site_description']));
        }
        
        return rest_ensure_response(array('success' => true, 'message' => 'Settings updated'));
    }
    
    // ==================== ADMIN MENU ====================
    
    /**
     * Add admin menu
     */
    public function add_admin_menu() {
        add_menu_page(
            'FishCare API',
            'FishCare API',
            'manage_options',
            'fishcare-api',
            array($this, 'admin_page'),
            'dashicons-rest-api',
            80
        );
    }
    
    /**
     * Admin page
     */
    public function admin_page() {
        $api_key = get_option('fishcare_api_key');
        ?>
        <div class="wrap">
            <h1>FishCare API Settings</h1>
            <div class="card" style="max-width: 800px;">
                <h2>API Configuration</h2>
                <p><strong>API Base URL:</strong> <code><?php echo get_rest_url(null, 'fishcare/v1'); ?></code></p>
                <p><strong>API Key:</strong> <code><?php echo esc_html($api_key); ?></code></p>
                <p style="color: #d63638;"><strong>⚠️ Keep this API key secure! Use it in your Flutter app headers.</strong></p>
                
                <h3>Available Endpoints:</h3>
                <ul style="font-family: monospace; font-size: 13px;">
                    <li>GET /fish-products - Get all fish products</li>
                    <li>POST /fish-products - Create fish product</li>
                    <li>GET /fish-products/{id} - Get single fish product</li>
                    <li>PUT /fish-products/{id} - Update fish product</li>
                    <li>DELETE /fish-products/{id} - Delete fish product</li>
                    <li>GET /medicines - Get all medicines</li>
                    <li>POST /medicines - Create medicine</li>
                    <li>GET /market-prices - Get market prices</li>
                    <li>GET /posts - Get all posts</li>
                    <li>POST /posts - Create post</li>
                    <li>GET /pages - Get all pages</li>
                    <li>POST /pages - Create page</li>
                    <li>GET /users - Get all users</li>
                    <li>GET /settings - Get settings</li>
                </ul>
                
                <h3>Authentication:</h3>
                <p>Add these headers to all API requests:</p>
                <ul>
                    <li><code>X-API-Key: <?php echo esc_html($api_key); ?></code></li>
                    <li><code>X-User-Role: admin</code> (for write operations)</li>
                </ul>
            </div>
        </div>
        <?php
    }
}

// Initialize the plugin
FishCare_API_Integration::get_instance();
