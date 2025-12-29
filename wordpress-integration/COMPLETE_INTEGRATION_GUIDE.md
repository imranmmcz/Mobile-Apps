# FishCare WordPress + Flutter App - Complete Integration Guide

## 📋 Overview

This guide provides step-by-step instructions to integrate your WordPress website (fishcare.com.bd) with your Flutter FishCare app, enabling centralized content management from the mobile app's Admin Panel.

---

## 🎯 Integration Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter FishCare App                 │
│  ┌──────────────────────────────────────────────────┐  │
│  │          Admin Panel (CMS Interface)             │  │
│  │  - Fish Products Management                      │  │
│  │  - Medicine Inventory Management                 │  │
│  │  - Posts & Pages Creation/Editing                │  │
│  │  - User Management                               │  │
│  │  - Real-time Data Sync                           │  │
│  └───────────────────┬──────────────────────────────┘  │
└────────────────────────┼────────────────────────────────┘
                         │
                    REST API
                (HTTPS Encrypted)
                         │
┌────────────────────────┼────────────────────────────────┐
│                        ▼                                │
│         WordPress Site (fishcare.com.bd)                │
│  ┌──────────────────────────────────────────────────┐  │
│  │        FishCare API Integration Plugin           │  │
│  │  - Custom REST API Endpoints                     │  │
│  │  - API Key Authentication                        │  │
│  │  - Custom Post Types (Fish, Medicine)            │  │
│  │  - CORS & Security                               │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │              WordPress Database                   │  │
│  │  - wp_posts (Fish Products, Medicines)           │  │
│  │  - wp_postmeta (Product Details)                 │  │
│  │  - wp_users (User Management)                    │  │
│  │  - Standard Posts & Pages                        │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 📦 Step 1: Install WordPress Plugin

### 1.1 Prepare Plugin Files

You have received the following plugin folder:
```
fishcare-api-plugin/
├── fishcare-api-integration.php (Main plugin file)
└── README.md (Documentation)
```

### 1.2 Upload to WordPress (Method 1: WordPress Admin)

1. **Compress the plugin folder:**
   - Right-click on `fishcare-api-plugin` folder
   - Create ZIP archive: `fishcare-api-plugin.zip`

2. **Upload via WordPress Admin:**
   - Login to https://fishcare.com.bd/wp-admin
   - Navigate to **Plugins → Add New → Upload Plugin**
   - Click "Choose File" and select `fishcare-api-plugin.zip`
   - Click "Install Now"
   - Click "Activate Plugin"

### 1.3 Upload to WordPress (Method 2: Hostinger File Manager)

1. **Login to Hostinger:**
   - Go to https://hpanel.hostinger.com
   - Login with your Hostinger credentials

2. **Open File Manager:**
   - Select your FishCare website
   - Click "File Manager"

3. **Navigate to plugins directory:**
   - Go to `/public_html/wp-content/plugins/`

4. **Upload plugin:**
   - Click "Upload" button
   - Upload the `fishcare-api-plugin` folder (or ZIP and extract)
   - Ensure folder structure is correct:
     ```
     /public_html/wp-content/plugins/fishcare-api-plugin/
     └── fishcare-api-integration.php
     ```

5. **Activate in WordPress:**
   - Go to WordPress Admin → Plugins
   - Find "FishCare API Integration"
   - Click "Activate"

---

## 🔑 Step 2: Get WordPress API Key

### 2.1 Access Plugin Settings

1. After activation, look for **"FishCare API"** in WordPress Admin left menu
2. Click on it to open the settings page

### 2.2 Copy API Key

You'll see a page like this:

```
╔════════════════════════════════════════════════════════╗
║           FishCare API Settings                        ║
╠════════════════════════════════════════════════════════╣
║ API Base URL: https://fishcare.com.bd/wp-json/        ║
║                fishcare/v1                             ║
║                                                        ║
║ API Key: Hx7d9KmP2vL4qN8jR3tY6wZ1cF5gB0sA             ║
║                                                        ║
║ ⚠️ Keep this API key secure!                          ║
╚════════════════════════════════════════════════════════╝
```

3. **Copy the API Key** (the long random string)
4. **Save it securely** - you'll need it for the Flutter app

---

## 🧪 Step 3: Test WordPress API

### 3.1 Test with Browser

Open your browser and visit:
```
https://fishcare.com.bd/wp-json/fishcare/v1/fish-products
```

**Without API Key:** You should see an error:
```json
{
  "code": "invalid_api_key",
  "message": "Invalid API Key",
  "data": {
    "status": 401
  }
}
```

This confirms the API is protected ✅

### 3.2 Test with Postman (Optional)

1. **Download Postman:** https://www.postman.com/downloads/
2. **Create GET Request:**
   - URL: `https://fishcare.com.bd/wp-json/fishcare/v1/fish-products`
   - Headers:
     ```
     X-API-Key: YOUR_API_KEY_HERE
     ```
3. **Send Request**

**Expected Success Response:**
```json
[]
```
(Empty array because no fish products yet - this is correct!)

---

## 📱 Step 4: Configure Flutter App

### 4.1 Open FishCare App

1. Install the latest APK on your Android device
2. Login as **Admin** user

### 4.2 Navigate to Admin Panel

1. Open app drawer (left side menu)
2. Scroll down to find **"Admin Panel"**
3. Tap on Admin Panel

### 4.3 Open WordPress Manager

1. In Admin Panel, you'll see a blue card: **"WordPress Website"**
2. Tap **"WordPress Manager খুলুন"** button
3. WordPress Content Manager screen will open

### 4.4 Configure API Key

1. You'll see **"WordPress: Not Configured"** status bar at top
2. Tap **"Configure"** button or the settings icon (⚙️) in app bar
3. Dialog will open: **"WordPress API Key"**
4. Paste the API Key you copied from WordPress
5. Tap **"Save"**

### 4.5 Verify Connection

After saving the API key:
- Status bar should turn GREEN
- Show: **"WordPress: Connected"** ✅
- If connection fails, check:
  - API key is correct
  - Website URL is accessible
  - Internet connection is working

---

## 🔄 Step 5: Sync Data to WordPress

### 5.1 Initial Data Sync

1. In **WordPress Content Manager**, go to **"Sync"** tab
2. You'll see current local data count (fish, medicines)
3. Tap **"Sync All Data to WordPress"** button
4. Wait for sync to complete

**What this does:**
- Uploads all existing fish data from app to WordPress
- Uploads all existing medicine data from app to WordPress
- Creates corresponding entries in WordPress database
- Enables website to display this data

### 5.2 Verify Sync

After sync completes:

1. **Check in WordPress Admin:**
   - Go to WordPress Admin Dashboard
   - Look for **"Fish Products"** menu item
   - Look for **"Medicines"** menu item
   - Click each to see synced data

2. **Check in App:**
   - Go to **"Fish"** tab in WordPress Manager
   - Go to **"Medicine"** tab in WordPress Manager
   - You should see all your data listed

---

## ✏️ Step 6: Test CRUD Operations

### 6.1 Create New Fish Product from App

1. In WordPress Content Manager, go to **"Fish"** tab
2. Currently, there's no "Add" button (we'll add this next)
3. Data displayed here comes directly from WordPress

### 6.2 Edit Fish Product

1. Tap on any fish product in the list
2. Three-dot menu appears
3. Select **"Edit"**
4. Modify price, stock, or other details
5. Save changes
6. Check WordPress Admin to confirm updates

### 6.3 Delete Fish Product

1. Tap three-dot menu on any fish product
2. Select **"Delete"**
3. Confirm deletion
4. Product removed from both app and WordPress

---

## 🌐 Step 7: Display WordPress Data on Website

### 7.1 Create WordPress Page for Fish Products

1. **Login to WordPress Admin**
2. **Go to Pages → Add New**
3. **Page Title:** Fish Products
4. **Add Custom HTML Block:**

```html
<div id="fishcare-products"></div>

<script>
// Fetch fish products from API
fetch('https://fishcare.com.bd/wp-json/fishcare/v1/fish-products', {
  headers: {
    'X-API-Key': 'YOUR_API_KEY_HERE'
  }
})
.then(response => response.json())
.then(data => {
  const container = document.getElementById('fishcare-products');
  container.innerHTML = data.map(fish => `
    <div class="fish-product">
      <h3>${fish.name_bengali}</h3>
      <p>${fish.name_english}</p>
      <p><strong>Category:</strong> ${fish.category}</p>
      <p><strong>Price:</strong> ৳${fish.price_per_kg}/kg</p>
      <p><strong>Stock:</strong> ${fish.stock_kg} kg</p>
    </div>
  `).join('');
});
</script>

<style>
.fish-product {
  border: 1px solid #ddd;
  padding: 15px;
  margin: 10px 0;
  border-radius: 5px;
}
.fish-product h3 {
  margin-top: 0;
  color: #2271b1;
}
</style>
```

**⚠️ IMPORTANT:** Replace `YOUR_API_KEY_HERE` with your actual API key

5. **Publish the page**
6. **Visit:** https://fishcare.com.bd/fish-products/

---

## 🎨 Step 8: WordPress Theme Integration (Optional)

### 8.1 Create Custom Theme Template

If you want better integration with your theme:

1. **Access theme files** via Hostinger File Manager
2. **Navigate to:** `/public_html/wp-content/themes/your-theme/`
3. **Create new file:** `page-fish-products.php`
4. **Add this code:**

```php
<?php
/**
 * Template Name: Fish Products Page
 */

get_header(); ?>

<div class="fish-products-container">
    <h1><?php the_title(); ?></h1>
    
    <div id="fishcare-fish-list"></div>
    
    <script>
    jQuery(document).ready(function($) {
        $.ajax({
            url: 'https://fishcare.com.bd/wp-json/fishcare/v1/fish-products',
            headers: {
                'X-API-Key': '<?php echo get_option('fishcare_api_key'); ?>'
            },
            success: function(data) {
                var html = '';
                data.forEach(function(fish) {
                    html += '<div class="fish-card">';
                    html += '<h3>' + fish.name_bengali + '</h3>';
                    html += '<p>' + fish.name_english + '</p>';
                    html += '<p><strong>Price:</strong> ৳' + fish.price_per_kg + '/kg</p>';
                    html += '<p><strong>Stock:</strong> ' + fish.stock_kg + ' kg</p>';
                    html += '</div>';
                });
                $('#fishcare-fish-list').html(html);
            }
        });
    });
    </script>
</div>

<?php get_footer(); ?>
```

5. **Create a new page** in WordPress
6. **Select template:** "Fish Products Page"
7. **Publish**

---

## 🔐 Step 9: Security Best Practices

### 9.1 Secure API Key

**Never expose API key in public code!**

✅ **Correct (Server-side):**
```php
// In WordPress theme/plugin
$api_key = get_option('fishcare_api_key');
```

❌ **Wrong (Client-side):**
```javascript
// DON'T DO THIS in public HTML/JS
headers: {'X-API-Key': 'Hx7d9KmP2vL4qN8jR3tY6wZ1cF5gB0sA'}
```

### 9.2 Use WordPress REST API Proxy

Create a custom WordPress endpoint that proxies requests:

```php
// Add to theme's functions.php
add_action('rest_api_init', function() {
    register_rest_route('fishcare-public/v1', '/fish-products', array(
        'methods' => 'GET',
        'callback' => function() {
            // Internal call with API key
            $api_key = get_option('fishcare_api_key');
            $response = wp_remote_get('https://fishcare.com.bd/wp-json/fishcare/v1/fish-products', array(
                'headers' => array('X-API-Key' => $api_key)
            ));
            return json_decode(wp_remote_retrieve_body($response));
        },
        'permission_callback' => '__return_true',
    ));
});
```

Then in frontend JavaScript:
```javascript
// Public endpoint - no API key needed
fetch('/wp-json/fishcare-public/v1/fish-products')
    .then(response => response.json())
    .then(data => console.log(data));
```

### 9.3 Enable HTTPS (SSL Certificate)

Ensure your Hostinger site has SSL enabled:
1. Login to Hostinger hPanel
2. Go to **SSL** section
3. Ensure SSL certificate is active
4. Force HTTPS in WordPress settings

---

## 📊 Step 10: Database Schema Mapping

### WordPress Database Tables:

```
wp_posts
├── ID (Primary Key)
├── post_title (Fish/Medicine name)
├── post_content (Description)
├── post_type ('fish_product', 'medicine', 'market_price')
└── post_status ('publish', 'draft')

wp_postmeta
├── meta_id (Primary Key)
├── post_id (Foreign Key → wp_posts.ID)
├── meta_key (Field name: 'name_bengali', 'price_per_kg', etc.)
└── meta_value (Field value)
```

### Custom Post Type: Fish Products

| Meta Key        | Data Type | Description              |
|----------------|-----------|--------------------------|
| name_bengali   | String    | Bengali name             |
| name_english   | String    | English name             |
| category       | String    | Fish category            |
| price_per_kg   | Float     | Price per kilogram       |
| stock_kg       | Float     | Stock quantity in kg     |
| image_url      | String    | Product image URL        |
| last_updated   | DateTime  | Last modification time   |

### Custom Post Type: Medicines

| Meta Key        | Data Type | Description              |
|----------------|-----------|--------------------------|
| name_bengali   | String    | Bengali name             |
| name_english   | String    | English name             |
| category       | String    | Medicine category        |
| price_per_unit | Float     | Price per unit           |
| stock_quantity | Integer   | Stock quantity           |
| dosage_info    | String    | Dosage information       |
| manufacturer   | String    | Manufacturer name        |
| expiry_date    | DateTime  | Expiry date              |
| last_updated   | DateTime  | Last modification time   |

---

## 🚀 Step 11: Deploy Updated Flutter App

### 11.1 Build Updated APK

The WordPress integration is already included in your Flutter app code. To deploy:

1. **Get latest APK** from your development environment
2. **Test on Android device:**
   - Install APK
   - Login as Admin
   - Open Admin Panel → WordPress Manager
   - Configure API key
   - Test all CRUD operations

### 11.2 Verify Integration Features

✅ **Test Checklist:**
- [ ] API key configuration works
- [ ] Connection status shows "Connected"
- [ ] Fish products list loads from WordPress
- [ ] Medicine list loads from WordPress
- [ ] Data sync works (local → WordPress)
- [ ] Can view posts from WordPress
- [ ] Can view pages from WordPress
- [ ] Can view users (Admin only)
- [ ] Changes in app reflect on website immediately

---

## 🔄 Step 12: Ongoing Management Workflow

### Daily Operations:

1. **Add new fish product:**
   - Open FishCare App
   - Go to Medicine Management or Fish Sales screen
   - Add product in app (stored locally + synced to WordPress)
   - Product automatically appears on website

2. **Update prices:**
   - Edit price in app
   - Sync data
   - Website shows updated price immediately

3. **Create blog post:**
   - Open Admin Panel → WordPress Manager
   - Go to Posts tab
   - Create new post
   - Post appears on website

### Automated Sync (Future Enhancement):

Consider implementing:
- Auto-sync on app startup
- Periodic background sync every hour
- Webhook notifications for real-time updates

---

## 🛠️ Troubleshooting

### Issue 1: "Connection Failed" in app

**Symptoms:** Status shows "Connection Failed" in red

**Solutions:**
1. Verify API key is correct
2. Check WordPress site is accessible: https://fishcare.com.bd
3. Ensure plugin is activated in WordPress
4. Check internet connection on device
5. Verify CORS is enabled (plugin handles this)

### Issue 2: "Invalid API Key" error

**Symptoms:** API requests return 401 error

**Solutions:**
1. Re-copy API key from WordPress Admin → FishCare API
2. Delete and re-enter API key in app
3. Check for extra spaces or hidden characters
4. Regenerate API key: Deactivate and reactivate plugin

### Issue 3: Data not syncing

**Symptoms:** Changes in app don't appear on website

**Solutions:**
1. Manually trigger sync from Sync tab
2. Check user role (must be Admin or Manager)
3. Verify X-User-Role header is set to 'admin'
4. Check WordPress error logs in cPanel

### Issue 4: CORS errors in browser console

**Symptoms:** Browser shows "CORS policy" error

**Solutions:**
1. Verify plugin is activated
2. Add to .htaccess if needed (see Security section)
3. Check server allows custom headers
4. Contact Hostinger support if persists

### Issue 5: Plugin causes WordPress errors

**Symptoms:** WordPress site shows errors after activation

**Solutions:**
1. Deactivate plugin temporarily
2. Check PHP version (requires 7.4+)
3. Increase PHP memory limit
4. Check error logs in Hostinger cPanel
5. Ensure WordPress is updated (5.0+)

---

## 📈 Performance Optimization

### For Large Datasets:

1. **Implement Pagination:**
   - Modify API to support `?page=1&per_page=20`
   - Update Flutter app to load data in batches

2. **Add Caching:**
   - Use WordPress transients for frequent queries
   - Cache API responses in Flutter app

3. **Database Indexing:**
   - Add indexes to frequently queried meta_keys

4. **CDN Integration:**
   - Use Hostinger CDN for static assets
   - Optimize images before upload

---

## 🎓 Next Steps & Future Enhancements

### Phase 2 Enhancements:

1. **Image Upload:**
   - Allow uploading fish/medicine images from app
   - Store in WordPress Media Library

2. **Real-time Notifications:**
   - Push notifications when data changes on website
   - Webhook integration

3. **Advanced Filtering:**
   - Search by name, category, price range
   - Sort by various fields

4. **Bulk Operations:**
   - Bulk edit/delete products
   - Export/import CSV

5. **Analytics Dashboard:**
   - Track most viewed products
   - Monitor stock levels
   - Sales reports integration

---

## 📞 Support & Resources

### Documentation:
- WordPress REST API: https://developer.wordpress.org/rest-api/
- Flutter HTTP Package: https://pub.dev/packages/http
- FishCare API Plugin README: See `/wordpress-integration/fishcare-api-plugin/README.md`

### Hostinger Resources:
- Hostinger Help Center: https://support.hostinger.com
- WordPress on Hostinger: https://www.hostinger.com/tutorials/wordpress

### Contact:
For integration issues or custom development:
- Email: support@fishcare.com.bd
- Phone: +880 1712-345678

---

## ✅ Integration Completion Checklist

### WordPress Setup:
- [ ] Plugin uploaded to `/wp-content/plugins/`
- [ ] Plugin activated in WordPress admin
- [ ] API key copied from FishCare API settings page
- [ ] Test API endpoint in browser/Postman
- [ ] Custom Post Types visible in admin menu

### Flutter App Setup:
- [ ] Latest APK installed on device
- [ ] Logged in as Admin user
- [ ] API key configured in WordPress Manager
- [ ] Connection status shows "Connected"
- [ ] Can view fish products from WordPress
- [ ] Can view medicines from WordPress

### Data Sync:
- [ ] Initial data sync completed
- [ ] Fish products visible in WordPress admin
- [ ] Medicines visible in WordPress admin
- [ ] Test create new product from app
- [ ] Test edit product from app
- [ ] Test delete product from app

### Website Integration:
- [ ] Fish products page created
- [ ] Medicine products page created
- [ ] Data displays correctly on website
- [ ] Real-time updates working
- [ ] API key secured (not exposed publicly)

### Security:
- [ ] HTTPS/SSL enabled
- [ ] API key kept secure
- [ ] CORS properly configured
- [ ] User role checks working
- [ ] WordPress and plugins updated

---

**Congratulations! 🎉 Your FishCare WordPress + Flutter App integration is complete!**

You now have a fully integrated system where:
- ✅ WordPress website and Flutter app share the same database
- ✅ Changes in app instantly appear on website
- ✅ Centralized content management from mobile app
- ✅ Secure API communication
- ✅ Scalable architecture for future growth

**Ready for production deployment!** 🚀
