-- =========================================================
-- Simple Café App Database Schema (PostgreSQL)
-- "Foodpanda for cafés" style app
-- =========================================================

-- ============================
-- 1. USERS (CUSTOMERS)
-- ============================
CREATE TABLE app_user (
    id              BIGSERIAL PRIMARY KEY,
    email           TEXT UNIQUE NOT NULL,
    password_hash   TEXT NOT NULL,           -- or null if using Firebase Auth later
    display_name    TEXT NOT NULL,
    photo_url       TEXT,                    -- Firebase Storage URL
    preferences     JSONB DEFAULT '{}'::jsonb, -- e.g. {"coffee_strength": "strong"}
    reward_points   INT DEFAULT 0,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================
-- 2. CAFE ADMINS (OWNERS / MANAGERS)
-- separate from customers
-- ============================
CREATE TABLE cafe_admin (
    id              BIGSERIAL PRIMARY KEY,
    email           TEXT UNIQUE NOT NULL,
    password_hash   TEXT NOT NULL,
    full_name       TEXT NOT NULL,
    photo_url       TEXT,                    -- optional avatar
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================
-- 3. CAFES
-- ============================
CREATE TABLE cafe (
    id              BIGSERIAL PRIMARY KEY,
    owner_admin_id  BIGINT REFERENCES cafe_admin(id) ON DELETE SET NULL,
    name            TEXT NOT NULL,
    description     TEXT,
    address         TEXT,
    city            TEXT,
    latitude        NUMERIC(9,6) NOT NULL,
    longitude       NUMERIC(9,6) NOT NULL,
    image_url       TEXT,                    -- Firebase Storage URL
    avg_rating      NUMERIC(2,1),
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);



-- ============================
-- 5. MENU ITEMS
-- ============================
CREATE TABLE menu_item (
    id              BIGSERIAL PRIMARY KEY,
    cafe_id         BIGINT NOT NULL REFERENCES cafe(id) ON DELETE CASCADE,

    category        TEXT NOT NULL CHECK (category IN ('coffee', 'drink', 'food', 'dessert')),

    -- new: a type/variant within the category
    subcategory     TEXT NOT NULL,
    CHECK (
      (category = 'coffee'  AND subcategory IN ('black coffee','espresso','latte','cappuccino','americano','mocha')) OR
      (category = 'drink'   AND subcategory IN ('smoothie','juice','soda')) OR
      (category = 'food'    AND subcategory IN ('sandwich','cake','pastry')) OR
      (category = 'dessert' AND subcategory IN ('brownie','muffin','ice-cream'))
    ),

    name            TEXT NOT NULL,
    description     TEXT,
    base_price      NUMERIC(10,2) NOT NULL,

    image_url       TEXT,                    -- imagekit link
    is_available    BOOLEAN DEFAULT TRUE,

    -- coffee-specific fields (nullable for non-coffee rows)
    strength        TEXT,                    -- 'light' | 'medium' | 'strong'
    CHECK (
      (category = 'coffee' AND (strength IS NULL OR strength IN ('light','medium','strong')))
      OR (category <> 'coffee' AND strength IS NULL)
    ),

    taste_profile   TEXT[],                  -- array of strings, multiple allowed
    CHECK (
      (category = 'coffee' AND (taste_profile IS NULL OR ARRAY['sweet','bitter','creamy','chocolatey','fruity','nutty','spicy','sour']::text[] @> taste_profile))
      OR (category <> 'coffee' AND (taste_profile IS NULL OR taste_profile = '{}'))
    ),

    best_time       TEXT[],                  -- array of strings: morning/afternoon/evening/night
    CHECK (
      (category = 'coffee' AND (best_time IS NULL OR ARRAY['morning','afternoon','evening','night']::text[] @> best_time))
      OR (category <> 'coffee' AND (best_time IS NULL OR best_time = '{}'))
    ),

    ai_summary      TEXT,                    -- for RAG / recommendations

    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);


-- ============================
-- 6. ORDERS (DINE-IN / PICKUP, MANUAL / AI)
-- ============================
CREATE TABLE customer_order (
    id                  BIGSERIAL PRIMARY KEY,
    user_id             BIGINT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    cafe_id             BIGINT NOT NULL REFERENCES cafe(id) ON DELETE CASCADE,
    order_mode          TEXT NOT NULL CHECK (order_mode IN ('dine_in', 'pickup')),
    order_source        TEXT NOT NULL CHECK (order_source IN ('manual', 'ai_chat')),
    status              TEXT NOT NULL CHECK (status IN (
                            'pending', 'accepted', 'preparing', 'ready', 'completed', 'cancelled'
                        )),
    special_notes       TEXT,
    table_number        TEXT,                -- for dine-in
    total_amount        NUMERIC(10,2) DEFAULT 0,
    reward_points_earned INT DEFAULT 0,
    reward_points_spent  INT DEFAULT 0,      -- used for redemption
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE order_item (
    id                      BIGSERIAL PRIMARY KEY,
    order_id                BIGINT NOT NULL REFERENCES customer_order(id) ON DELETE CASCADE,
    menu_item_id            BIGINT NOT NULL REFERENCES menu_item(id),
    quantity                INT NOT NULL CHECK (quantity > 0),
    unit_price              NUMERIC(10,2) NOT NULL,
    total_price             NUMERIC(10,2) NOT NULL,
    customizations          JSONB DEFAULT '{}'::jsonb, -- {"size": "L", "milk": "oat"}
    from_ai_recommendation  BOOLEAN DEFAULT FALSE
);

-- ============================
-- 7. REVIEWS (CAFÉ + ITEMS)
-- ============================
CREATE TABLE cafe_review (
    id          BIGSERIAL PRIMARY KEY,
    cafe_id     BIGINT NOT NULL REFERENCES cafe(id) ON DELETE CASCADE,
    user_id     BIGINT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment     TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE menu_item_review (
    id          BIGSERIAL PRIMARY KEY,
    cafe_id     BIGINT NOT NULL REFERENCES cafe(id) ON DELETE CASCADE,
    menu_item_id BIGINT NOT NULL REFERENCES menu_item(id) ON DELETE CASCADE,
    user_id     BIGINT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment     TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================
-- 8. REWARD POINTS / TRANSACTIONS
-- ============================
CREATE TABLE reward_transaction (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    source_type     TEXT NOT NULL CHECK (source_type IN (
                        'order',
                        'cafe_review',
                        'menu_item_review',
                        'community_message',
                        'manual_adjust',
                        'redeem'
                    )),
    source_id       BIGINT,                 -- e.g. order id, review id, message id
    points_change   INT NOT NULL,           -- + earn, - redeem
    description     TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================
-- 9. COMMUNITY LIVE CHAT
-- ============================
CREATE TABLE community_message (
    id                  BIGSERIAL PRIMARY KEY,
    user_id             BIGINT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    cafe_id             BIGINT REFERENCES cafe(id) ON DELETE SET NULL,
    menu_item_id        BIGINT REFERENCES menu_item(id) ON DELETE SET NULL,
    parent_message_id   BIGINT REFERENCES community_message(id) ON DELETE SET NULL,
    content             TEXT NOT NULL,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================
-- 10. AI CHAT SESSIONS & MESSAGES
-- ============================
CREATE TABLE ai_chat_session (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    cafe_id     BIGINT REFERENCES cafe(id) ON DELETE SET NULL,  -- optional focus café
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    ended_at    TIMESTAMPTZ
);

CREATE TABLE ai_chat_message (
    id                      BIGSERIAL PRIMARY KEY,
    session_id              BIGINT NOT NULL REFERENCES ai_chat_session(id) ON DELETE CASCADE,
    sender_type             TEXT NOT NULL CHECK (sender_type IN ('user', 'assistant', 'system')),
    message_text            TEXT NOT NULL,
    related_menu_item_id    BIGINT REFERENCES menu_item(id) ON DELETE SET NULL,
    related_order_id        BIGINT REFERENCES customer_order(id) ON DELETE SET NULL,
    is_recommendation       BOOLEAN DEFAULT FALSE,
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

-- ============================
-- 11. (OPTIONAL) CAFE DAILY STATS
-- for trending cafés / heatmap support
-- ============================
CREATE TABLE cafe_daily_stats (
    cafe_id         BIGINT NOT NULL REFERENCES cafe(id) ON DELETE CASCADE,
    date            DATE NOT NULL,
    orders_count    INT DEFAULT 0,
    reviews_count   INT DEFAULT 0,
    avg_rating      NUMERIC(2,1),
    PRIMARY KEY (cafe_id, date)
);
