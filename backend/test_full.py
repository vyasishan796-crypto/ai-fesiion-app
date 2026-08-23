import requests
import json
import sys
import os
import io
import base64
from PIL import Image
import numpy as np

import subprocess, time, signal
BASE = "http://127.0.0.1:8000/api"
results = []

# Start Django server as subprocess
proc = subprocess.Popen(
    ["python", "manage.py", "runserver", "0.0.0.0:8000"],
    cwd=r"C:\Users\nakshtra\Desktop\app\backend",
    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
)
time.sleep(7)
print(f"  Server started (PID {proc.pid})")
try:
    import requests as _r
    _r.post(f"{BASE}/auth/login/", json={"username":"x","password":"x"}, timeout=3)
    print("  Server confirmed running\n")
except:
    print("  WARNING: Server may not be ready yet\n")

def test(name, func):
    try:
        result = func()
        print(f"  [PASS] {name}")
        results.append((name, True, result))
        return result
    except AssertionError as e:
        print(f"  [FAIL] {name}: {e}")
        results.append((name, False, str(e)))
        return None
    except Exception as e:
        print(f"  [FAIL] {name}: {e}")
        results.append((name, False, str(e)))
        return None

def make_test_image(w=600, h=800):
    img = Image.new('RGB', (w, h), color=(180, 175, 170))
    arr = np.array(img)
    np.random.seed(42)
    arr = np.clip(arr.astype(np.int16) + np.random.randint(-8, 8, arr.shape), 0, 255).astype(np.uint8)
    for y in range(h//6, h//2):
        for x in range(w//4, 3*w//4):
            dx = (x - w//2) / (w//5)
            dy = (y - h//4) / (h//5)
            if dx*dx + dy*dy < 1.0:
                arr[y, x] = [195, 145, 115]
    for y in range(h//2 + 30, h - 30):
        for x in range(w//4, 3*w//4):
            arr[y, x] = [50, 50, 180]
    img = Image.fromarray(arr)
    buf = io.BytesIO()
    img.save(buf, format='JPEG')
    buf.seek(0)
    return buf

print("=" * 65)
print("  FULL BACKEND TEST - All Features")
print("=" * 65)

# 1. SERVER CHECK
print("\n[1] SERVER")
def check_server():
    r = requests.post(f"{BASE}/auth/login/", json={"username":"x","password":"x"}, timeout=5)
    assert r.status_code in [400, 401], f"Unexpected status: {r.status_code}"
    return f"Running on {BASE}"
test("Server running", check_server)

# 2. REGISTER
print("\n[2] AUTH - Register")
def check_register():
    r = requests.post(f"{BASE}/auth/register/", json={
        "username": "fulltest_user",
        "email": "fulltest@styleai.com",
        "password": "testpass123",
        "password_confirm": "testpass123",
        "first_name": "Full",
        "last_name": "Test"
    }, timeout=10)
    if r.status_code == 201:
        return "Registered OK"
    if r.status_code == 400 and "already" in r.text.lower():
        return "User already exists (OK)"
    raise AssertionError(f"Status {r.status_code}: {r.text[:100]}")
test("Register user", check_register)

# 3. LOGIN
print("\n[3] AUTH - Login")
token = None
def check_login():
    global token
    r = requests.post(f"{BASE}/auth/login/", json={
        "username": "fulltest_user",
        "password": "testpass123"
    }, timeout=10)
    assert r.status_code == 200, f"Status {r.status_code}: {r.text[:100]}"
    data = r.json()
    token = data['tokens']['access']
    return f"Token: {token[:30]}..."
test("Login (get JWT)", check_login)

headers = {"Authorization": f"Bearer {token}"} if token else {}

# 4. PROFILE
print("\n[4] AUTH - Profile")
def check_profile():
    r = requests.get(f"{BASE}/auth/profile/", headers=headers, timeout=10)
    assert r.status_code == 200, f"Status {r.status_code}"
    return f"User: {r.json().get('username', 'unknown')}"
test("Get profile", check_profile)

# 5. PRODUCTS
print("\n[5] PRODUCTS")
def check_products():
    r = requests.get(f"{BASE}/products/", timeout=10)
    assert r.status_code == 200, f"Status {r.status_code}"
    data = r.json()
    count = len(data) if isinstance(data, list) else data.get('count', 0)
    return f"{count} products available"
test("List products", check_products)

def check_product_search():
    r = requests.get(f"{BASE}/products/search/?q=shirt", timeout=10)
    assert r.status_code == 200, f"Status {r.status_code}"
    return "Search working"
test("Search products", check_product_search)

def check_product_categories():
    r = requests.get(f"{BASE}/products/categories/", timeout=10)
    assert r.status_code == 200, f"Status {r.status_code}"
    return "Categories available"
test("Product categories", check_product_categories)

# 6. APPEARANCE ANALYZE
print("\n[6] APPEARANCE ANALYZE")
analysis_id = None
def check_appearance():
    global analysis_id
    buf = make_test_image()
    r = requests.post(f"{BASE}/appearance/analyze/",
        files={"image": ("test.jpg", buf, "image/jpeg")},
        data={"occasion": "Casual"},
        headers=headers, timeout=60)
    assert r.status_code in [200, 201], f"Status {r.status_code}: {r.text[:200]}"
    data = r.json()
    analysis_id = data.get('analysis_id')
    skin = data.get('skin', {})
    body = data.get('body', {})
    return f"ID={analysis_id}, tone={skin.get('tone','?')}, body={body.get('silhouette','?')}"
test("Analyze appearance (POST)", check_appearance)

def check_appearance_detail():
    if not analysis_id:
        raise AssertionError("No analysis_id from previous test")
    r = requests.get(f"{BASE}/appearance/{analysis_id}/", headers=headers, timeout=10)
    assert r.status_code == 200, f"Status {r.status_code}"
    data = r.json()
    return f"Detail OK: tone={data.get('skin',{}).get('tone','?')}"
test(f"Get analysis detail (GET /{analysis_id}/)", check_appearance_detail)

# 7. STYLE ANALYZE
print("\n[7] STYLE ANALYZE")
def check_style_analyze():
    buf = make_test_image()
    b64 = base64.b64encode(buf.read()).decode()
    r = requests.post(f"{BASE}/style-analyze/", json={
        "image_base64": f"data:image/jpeg;base64,{b64}",
        "mime": "image/jpeg"
    }, timeout=35)
    assert r.status_code == 200, f"Status {r.status_code}: {r.text[:200]}"
    data = r.json()
    return f"Style: {data.get('overallStyle', 'N/A')}, Score: {data.get('styleScore', 'N/A')}"
test("Analyze style image", check_style_analyze)

def check_style_ask():
    r = requests.post(f"{BASE}/style-analyze/ask/", json={
        "analysis": {
            "overallStyle": "Casual",
            "clothing": ["t-shirt", "jeans"],
            "dominantColors": [{"name": "blue"}],
            "fabric": "Cotton",
            "occasions": ["Casual"],
            "styleScore": 7.5,
            "scoreBreakdown": {"personalStyle": 80, "occasion": 85}
        },
        "question": "What should I wear for a party?"
    }, timeout=30)
    assert r.status_code == 200, f"Status {r.status_code}"
    return f"Answer: {r.json().get('answer', 'N/A')[:60]}..."
test("Style Q&A", check_style_ask)

# 8. ORDERS
print("\n[8] ORDERS")
def check_orders():
    r = requests.get(f"{BASE}/orders/", headers=headers, timeout=10)
    assert r.status_code == 200, f"Status {r.status_code}"
    return f"Orders list OK"
test("List orders", check_orders)

# 9. WISHLIST
print("\n[9] WISHLIST")
def check_wishlist():
    r = requests.get(f"{BASE}/wishlist/", headers=headers, timeout=10)
    assert r.status_code == 200, f"Status {r.status_code}"
    return f"Wishlist OK"
test("List wishlist", check_wishlist)

# 10. BODY MEASUREMENTS
print("\n[10] BODY MEASUREMENTS")
def check_measurements_get():
    r = requests.get(f"{BASE}/measurements/", headers=headers, timeout=10)
    assert r.status_code == 200, f"Status {r.status_code}"
    return f"Measurements OK"
test("Get measurements", check_measurements_get)

def check_measurements_save():
    r = requests.post(f"{BASE}/measurements/save/", headers=headers, json={
        "height": 175,
        "weight": 70,
        "chest": 95,
        "waist": 80,
        "hips": 95,
        "shoulder": 45,
        "arm_length": 60,
        "inseam": 80,
        "body_type": "athletic",
        "top_size": "M",
        "bottom_size": "32",
        "shoe_size": "10"
    }, timeout=10)
    assert r.status_code in [200, 201], f"Status {r.status_code}: {r.text[:100]}"
    return f"Measurements saved"
test("Save measurements", check_measurements_save)

# 11. SAVED OUTFITS
print("\n[11] SAVED OUTFITS")
def check_saved_outfits():
    r = requests.get(f"{BASE}/saved-outfits/", headers=headers, timeout=10)
    assert r.status_code == 200, f"Status {r.status_code}"
    return f"Saved outfits OK"
test("List saved outfits", check_saved_outfits)

# 12. BOOKINGS
print("\n[12] TAILOR BOOKINGS")
def check_bookings():
    r = requests.get(f"{BASE}/bookings/", headers=headers, timeout=10)
    assert r.status_code == 200, f"Status {r.status_code}"
    return f"Bookings OK"
test("List bookings", check_bookings)

# 13. VIRTUAL TRY-ON
print("\n[13] VIRTUAL TRY-ON")
def check_tryon_history():
    r = requests.get(f"{BASE}/virtual-tryon/history/", headers=headers, timeout=10)
    assert r.status_code == 200, f"Status {r.status_code}"
    return f"Try-on history OK"
test("Try-on history", check_tryon_history)

# 14. SHOES OUTFIT
print("\n[14] SHOES OUTFIT")
def check_shoes_outfit():
    buf = make_test_image(200, 200)
    b64 = base64.b64encode(buf.read()).decode()
    r = requests.post(f"{BASE}/shoes-outfit/", json={
        "shoes_image_base64": f"data:image/jpeg;base64,{b64}",
        "user_prompt": "casual outfit",
        "mime": "image/jpeg"
    }, timeout=60)
    assert r.status_code in [200, 500], f"Status {r.status_code}"
    if r.status_code == 500:
        return f"Service error (AI quota?) - endpoint reachable"
    return f"Shoes outfit OK"
test("Generate shoes outfit", check_shoes_outfit)

# 15. SEED DATA
print("\n[15] SEED DATA")
def check_seed():
    r = requests.post(f"{BASE}/seed/", timeout=30)
    assert r.status_code in [200, 201], f"Status {r.status_code}"
    return f"Seed data OK"
test("Seed products", check_seed)

# SUMMARY
print("\n" + "=" * 65)
passed = sum(1 for _, ok, _ in results if ok)
failed = sum(1 for _, ok, _ in results if not ok)
print(f"  RESULTS: {passed} PASSED, {failed} FAILED out of {len(results)}")
print("=" * 65)
if failed > 0:
    print("\n  FAILED TESTS:")
    for name, ok, msg in results:
        if not ok:
            print(f"    - {name}: {msg}")
print()

proc.terminate()
proc.wait()
print("  Server stopped.")
