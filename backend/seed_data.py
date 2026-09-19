"""Seed the demo accounts and portfolio content used by the provider screens.

Run after migrations with: python seed_data.py
All demo accounts use the password: homeserve-demo
"""
from datetime import date, datetime

from sqlalchemy import text

from app.services.auth import hash_password
from database import SessionLocal


ASSET = "/assets/profile_photos/{}"

CLIENTS = [
    (101, "Nusrat Jahan", "+8801700000101", "Dhanmondi, Dhaka", "person 13.png"),
    (102, "Farhan Tanvir", "+8801700000102", "Gulshan, Dhaka", "person 14.png"),
    (103, "Maliha Rahman", "+8801700000103", "Uttara, Dhaka", "person 12.png"),
]

PROVIDERS = [
    (201, "Rahul Hassan", "+8801800000201", "Electrician", "Dhanmondi, Dhaka", "person 5.png", 4.90, 184, "15-30 min", 800),
    (202, "Master Rahim C.", "+8801800000202", "Electrician, Plumber", "Mohammadpur, Dhaka", "person 6.png", 4.95, 312, "20-40 min", 700),
    (203, "Priya Sen", "+8801800000203", "Electrician, Appliance Repair", "Banani, Dhaka", "person 7.png", 4.80, 97, "30-45 min", 650),
    (204, "Tanvir Alam", "+8801800000204", "Electrician, Smart Home", "Mirpur, Dhaka", "person 8.png", 4.70, 64, "Tomorrow 10 AM", 600),
    (205, "Ava Morgan", "+8801800000205", "Appliance Repair", "Gulshan, Dhaka", "person 9.png", 4.85, 121, "25-40 min", 900),
    (206, "Sofia Karim", "+8801800000206", "Cleaning", "Uttara, Dhaka", "person 10.png", 4.88, 156, "20-35 min", 500),
    (207, "Rahim Uddin", "+8801800000207", "Plumber", "Bashundhara, Dhaka", "person 11.png", 4.76, 88, "40-60 min", 550),
    (208, "Maya Chen", "+8801800000208", "Painting", "Lalmatia, Dhaka", "person 12.png", 4.82, 73, "Tomorrow 9 AM", 750),
    (209, "John Smith", "+8801800000209", "HVAC Repair", "Tejgaon, Dhaka", "person 13.png", 4.91, 205, "30-45 min", 1000),
    (210, "Priya Ahmed", "+8801800000210", "Carpentry", "Badda, Dhaka", "person 14.png", 4.79, 119, "45-60 min", 850),
]

PORTFOLIO = [
    (201, "Main Distribution Board & IPS Synchronization", "Re-routed 16-way Schneider distribution board and synchronized 1.5kVA hybrid IPS line.", "person 5.png", "Electrical", date(2026, 9, 12)),
    (202, "Industrial Wiring and DB Box", "Completed a safe industrial wiring upgrade with labelled circuits and short-circuit protection.", "person 6.png", "Electrical", date(2026, 8, 27)),
    (203, "Home Appliance Safety Check", "Inspected kitchen appliances, switchboard connections and geyser safety controls.", "person 7.png", "Appliance Repair", date(2026, 8, 18)),
    (204, "Smart Home Lighting Setup", "Installed connected switches, dimmable lights and a clean ceiling-fan wiring layout.", "person 8.png", "Smart Home", date(2026, 7, 30)),
    (205, "Kitchen Appliance Repair", "Diagnosed and repaired a built-in appliance with a full post-service safety test.", "person 9.png", "Appliance Repair", date(2026, 7, 22)),
    (206, "Move-in Deep Clean", "Prepared a two-bedroom home for move-in with kitchen, bathroom and floor detailing.", "person 10.png", "Cleaning", date(2026, 8, 10)),
]

CATEGORIES = [
    ("Electrician", "/assets/category_icons/electrician.png", 800),
    ("Plumber", "/assets/category_icons/plumber.png", 700),
    ("Appliance Repair", "/assets/category_icons/ac_repair.png", 900),
    ("Cleaning", "/assets/category_icons/cleaning.png", 500),
    ("Painting", "/assets/category_icons/carpenter.png", 750),
    ("Carpentry", "/assets/category_icons/carpenter.png", 850),
]

REVIEWS = [
    (501, 101, 201, "Electrician", 5, "Rahul arrived within 25 minutes and fixed our tripped master circuit cleanly. Very polite and professional.", datetime(2026, 9, 15, 14, 30)),
    (502, 102, 201, "Electrician", 5, "Excellent DB breaker fix. He explained the load balancing issue clearly and completed the work safely.", datetime(2026, 9, 12, 11, 0)),
    (503, 103, 201, "Electrician", 4, "Good service and careful wiring work. The technician also tested every circuit before leaving.", datetime(2026, 9, 8, 16, 15)),
    (504, 101, 202, "Electrician", 5, "Industrial wiring was completed on time with neat labels and a clear handover.", datetime(2026, 9, 10, 13, 0)),
    (505, 102, 203, "Appliance Repair", 5, "Quick appliance diagnosis and a thorough safety check. Would book again.", datetime(2026, 9, 6, 10, 45)),
    (506, 103, 204, "Electrician", 4, "Smart lighting setup looks great and the wiring was kept very tidy.", datetime(2026, 9, 4, 15, 30)),
]


def _upsert_user(db, user_id, name, phone, password_hash):
    exists = db.execute(text("SELECT id FROM users WHERE id = :id"), {"id": user_id}).first()
    values = {"id": user_id, "name": name, "phone": phone, "password_hash": password_hash}
    if exists:
        db.execute(text("UPDATE users SET name = :name, phone = :phone, phone_verified = true, password_hash = :password_hash WHERE id = :id"), values)
    else:
        db.execute(text("INSERT INTO users (id, name, phone, phone_verified, password_hash) VALUES (:id, :name, :phone, true, :password_hash)"), values)


def seed() -> None:
    password_hash = hash_password("homeserve-demo")
    with SessionLocal.begin() as db:
        for name, icon, base_price in CATEGORIES:
            db.execute(text("""INSERT INTO service_categories (name, icon, base_price)
                VALUES (:name, :icon, :base_price)
                ON DUPLICATE KEY UPDATE icon = VALUES(icon), base_price = VALUES(base_price)"""),
                {"name": name, "icon": icon, "base_price": base_price})

        for user_id, name, phone, address, photo in CLIENTS:
            _upsert_user(db, user_id, name, phone, password_hash)
            db.execute(text("""INSERT INTO client_profiles (user_id, verified, profile_photo, address)
                VALUES (:user_id, true, :photo, :address)
                ON DUPLICATE KEY UPDATE verified = true, profile_photo = VALUES(profile_photo), address = VALUES(address)"""),
                {"user_id": user_id, "photo": ASSET.format(photo), "address": address})

        for user_id, name, phone, categories, location, photo, rating, jobs, response_time, price in PROVIDERS:
            _upsert_user(db, user_id, name, phone, password_hash)
            db.execute(text("""INSERT INTO provider_profiles
                (user_id, bio, skills, categories, status, verified, rating_avg, profile_photo, location,
                 years_experience, job_success_pct, response_time, starting_price)
                VALUES (:user_id, :bio, :skills, :categories, 'approved', true, :rating, :photo, :location,
                        5, :success, :response_time, :price)
                ON DUPLICATE KEY UPDATE bio = VALUES(bio), skills = VALUES(skills), categories = VALUES(categories),
                status = 'approved', verified = true, rating_avg = VALUES(rating_avg), profile_photo = VALUES(profile_photo),
                location = VALUES(location), response_time = VALUES(response_time), starting_price = VALUES(starting_price)"""),
                {"user_id": user_id, "bio": f"Verified {categories.split(',')[0].lower()} specialist serving homes across Dhaka.",
                 "skills": categories, "categories": categories, "rating": rating, "photo": ASSET.format(photo),
                 "location": location, "success": 98 if jobs > 100 else 96, "response_time": response_time, "price": price})

        for provider_id, title, description, photo, category, completed_at in PORTFOLIO:
            db.execute(text("""INSERT INTO portfolio_items
                (provider_id, title, description, image_url, category, completed_at, sort_order)
                VALUES (:provider_id, :title, :description, :image_url, :category, :completed_at, 0)
                ON DUPLICATE KEY UPDATE description = VALUES(description), image_url = VALUES(image_url),
                category = VALUES(category), completed_at = VALUES(completed_at)"""),
                {"provider_id": provider_id, "title": title, "description": description,
                 "image_url": ASSET.format(photo), "category": category, "completed_at": completed_at})

        for booking_id, client_id, provider_id, category_name, rating, comment, scheduled_at in REVIEWS:
            category_id = db.execute(
                text("SELECT id FROM service_categories WHERE name = :name"),
                {"name": category_name},
            ).scalar_one()
            price_estimate = base_price_for(db, category_id)
            db.execute(text("""INSERT INTO bookings
                (id, client_id, provider_id, category_id, status, scheduled_at, address, price_estimate, payment_status)
                VALUES (:id, :client_id, :provider_id, :category_id, 'completed', :scheduled_at,
                        :address, :price_estimate, 'paid')
                ON DUPLICATE KEY UPDATE client_id = VALUES(client_id), provider_id = VALUES(provider_id),
                category_id = VALUES(category_id), status = 'completed', scheduled_at = VALUES(scheduled_at),
                address = VALUES(address), price_estimate = VALUES(price_estimate), payment_status = 'paid'"""),
                {"id": booking_id, "client_id": client_id, "provider_id": provider_id, "category_id": category_id,
                 "scheduled_at": scheduled_at, "address": "Dhaka, Bangladesh", "price_estimate": price_estimate})
            db.execute(text("""INSERT INTO reviews (id, booking_id, rating, comment, created_at)
                VALUES (:id, :booking_id, :rating, :comment, :created_at)
                ON DUPLICATE KEY UPDATE rating = VALUES(rating), comment = VALUES(comment), created_at = VALUES(created_at)"""),
                {"id": booking_id, "booking_id": booking_id, "rating": rating, "comment": comment, "created_at": scheduled_at})

    print(f"Seeded {len(CLIENTS)} clients, {len(PROVIDERS)} providers, {len(PORTFOLIO)} portfolio items, and {len(REVIEWS)} reviews.")


def base_price_for(db, category_id: int):
    return db.execute(text("SELECT base_price FROM service_categories WHERE id = :id"), {"id": category_id}).scalar_one()


if __name__ == "__main__":
    seed()