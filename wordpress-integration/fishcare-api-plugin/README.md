# FishCare API Integration Plugin

## WordPress + Flutter App Full Integration Solution

### 📋 Plugin Overview

This plugin creates a complete REST API integration between your WordPress site (fishcare.com.bd) and your Flutter FishCare app. It enables:

- ✅ Full CRUD operations for Fish Products, Medicines, Market Prices
- ✅ WordPress Posts, Pages, and Users management from Flutter app
- ✅ Secure API authentication with API keys
- ✅ Real-time data synchronization
- ✅ Admin Panel CMS capabilities in Flutter app

---

## 🚀 Installation Instructions (Hostinger)

### Step 1: Upload Plugin to WordPress

1. **Download the plugin folder** `fishcare-api-plugin`
2. **Compress it as ZIP**: `fishcare-api-plugin.zip`
3. **Login to your WordPress Admin**: https://fishcare.com.bd/wp-admin
4. Go to **Plugins → Add New → Upload Plugin**
5. Choose `fishcare-api-plugin.zip` and click **Install Now**
6. Click **Activate Plugin**

**Alternative (FTP/File Manager):**
1. Login to Hostinger cPanel
2. Open **File Manager**
3. Navigate to `/public_html/wp-content/plugins/`
4. Upload the `fishcare-api-plugin` folder
5. Go to WordPress Admin → Plugins → Activate "FishCare API Integration"

---

### Step 2: Get Your API Key

After activation:
1. Go to WordPress Admin Dashboard
2. Find **"FishCare API"** in the left menu
3. **Copy the API Key** displayed on the page
4. **Save this key securely** - you'll need it in your Flutter app

Example API Key: `Hx7d9KmP2vL4qN8jR3tY6wZ1cF5gB0sA`

---

### Step 3: Test API Endpoints

Open your browser or Postman and test:

```
GET https://fishcare.com.bd/wp-json/fishcare/v1/fish-products
Headers:
  X-API-Key: YOUR_API_KEY_HERE
```

**Expected Response:**
```json
[
  {
    "id": 1,
    "name_bengali": "রুই মাছ",
    "name_english": "Rohu Fish",
    "category": "Freshwater",
    "price_per_kg": 350,
    "stock_kg": 50
  }
]
```

---

## 📡 Available API Endpoints

### Base URL
```
https://fishcare.com.bd/wp-json/fishcare/v1
```

### Fish Products
- `GET /fish-products` - Get all fish products
- `POST /fish-products` - Create new fish product
- `GET /fish-products/{id}` - Get single fish product
- `PUT /fish-products/{id}` - Update fish product
- `DELETE /fish-products/{id}` - Delete fish product

### Medicines
- `GET /medicines` - Get all medicines
- `POST /medicines` - Create medicine
- `GET /medicines/{id}` - Get single medicine
- `PUT /medicines/{id}` - Update medicine
- `DELETE /medicines/{id}` - Delete medicine

### Market Prices
- `GET /market-prices` - Get all market prices
- `POST /market-prices` - Create market price

### Posts & Pages
- `GET /posts` - Get all blog posts
- `POST /posts` - Create new post
- `GET /pages` - Get all pages
- `POST /pages` - Create new page

### Users
- `GET /users` - Get all users (Admin only)
- `POST /users` - Create new user (Admin only)

### Settings
- `GET /settings` - Get site settings
- `POST /settings` - Update site settings (Admin only)

---

## 🔐 Authentication

### Required Headers

**For Read Operations (GET):**
```
X-API-Key: YOUR_API_KEY
```

**For Write Operations (POST, PUT, DELETE):**
```
X-API-Key: YOUR_API_KEY
X-User-Role: admin
```

---

## 📊 Example API Requests

### Create Fish Product

**Request:**
```bash
POST https://fishcare.com.bd/wp-json/fishcare/v1/fish-products
Headers:
  Content-Type: application/json
  X-API-Key: YOUR_API_KEY
  X-User-Role: admin

Body:
{
  "name_bengali": "কাতলা মাছ",
  "name_english": "Catla Fish",
  "category": "Freshwater",
  "price_per_kg": 380,
  "stock_kg": 75,
  "description": "High-quality Catla fish",
  "image_url": "https://example.com/image.jpg"
}
```

**Response:**
```json
{
  "id": 15,
  "name_bengali": "কাতলা মাছ",
  "name_english": "Catla Fish",
  "category": "Freshwater",
  "price_per_kg": 380,
  "stock_kg": 75,
  "description": "High-quality Catla fish",
  "image_url": "https://example.com/image.jpg",
  "last_updated": "2025-01-15 10:30:00"
}
```

### Update Medicine

**Request:**
```bash
PUT https://fishcare.com.bd/wp-json/fishcare/v1/medicines/10
Headers:
  Content-Type: application/json
  X-API-Key: YOUR_API_KEY
  X-User-Role: admin

Body:
{
  "name_bengali": "অক্সিটেট্রাসাইক্লিন",
  "name_english": "Oxytetracycline",
  "category": "অ্যান্টিবায়োটিক",
  "price_per_unit": 450,
  "stock_quantity": 200,
  "dosage_info": "50-75 mg/kg body weight",
  "manufacturer": "Acme Pharmaceuticals",
  "expiry_date": "2025-12-31"
}
```

---

## 🛡️ Security Features

1. **API Key Authentication**: Unique key generated on activation
2. **Role-Based Access Control**: Admin/Manager roles for write operations
3. **CORS Enabled**: Allows Flutter app to communicate securely
4. **Input Sanitization**: All data is sanitized before storage
5. **Rate Limiting**: Prevents API abuse

---

## 🔧 Hostinger-Specific Configuration

### Enable REST API (if disabled)

Add to `wp-config.php`:
```php
define('REST_API_ENABLED', true);
```

### Allow CORS (if needed)

The plugin automatically handles CORS, but if you face issues, add to `.htaccess`:
```apache
<IfModule mod_headers.c>
    Header set Access-Control-Allow-Origin "*"
    Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header set Access-Control-Allow-Headers "Content-Type, Authorization, X-API-Key, X-User-Role"
</IfModule>
```

### Increase PHP Memory (if needed)

Add to `wp-config.php`:
```php
define('WP_MEMORY_LIMIT', '256M');
```

---

## 📱 Flutter App Integration (Next Step)

After installing this plugin, you'll integrate it with your Flutter app using the `WordPressService` class (provided in the next phase).

---

## 🧪 Testing Checklist

- [ ] Plugin activated successfully
- [ ] API Key copied from admin page
- [ ] Test GET request to `/fish-products`
- [ ] Test POST request to create fish product
- [ ] Test GET request to `/medicines`
- [ ] Verify data shows in WordPress admin
- [ ] Check Custom Post Types created (Fish Products, Medicines, Market Prices)

---

## 📞 Support

For issues or questions:
- Check WordPress admin → FishCare API page
- Verify API key is correct
- Ensure HTTPS is enabled on Hostinger
- Check WordPress error logs in cPanel

---

## 🎯 Next Steps

1. ✅ Install and activate this plugin
2. ⏳ Get API Key from admin page
3. ⏳ Integrate Flutter app with WordPress API
4. ⏳ Test CRUD operations from Flutter app
5. ⏳ Deploy and go live!

---

**Plugin Version:** 1.0.0  
**WordPress Compatibility:** 5.0+  
**PHP Version:** 7.4+  
**Author:** FishCare Team
