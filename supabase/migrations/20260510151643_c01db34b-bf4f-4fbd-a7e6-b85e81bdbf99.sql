
-- Roles
CREATE TYPE public.app_role AS ENUM ('admin', 'customer');

CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  full_name TEXT,
  phone TEXT,
  address TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "self read profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "self update profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "self insert profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users ON DELETE CASCADE,
  role app_role NOT NULL,
  UNIQUE (user_id, role)
);
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "self read roles" ON public.user_roles FOR SELECT USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role app_role)
RETURNS BOOLEAN LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role)
$$;

-- Auto create profile + customer role
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name');
  INSERT INTO public.user_roles (user_id, role) VALUES (NEW.id, 'customer');
  RETURN NEW;
END; $$;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Products
CREATE TABLE public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  brand TEXT,
  category TEXT NOT NULL,
  description TEXT,
  price NUMERIC(10,2) NOT NULL,
  mrp NUMERIC(10,2),
  image_url TEXT,
  prescription_required BOOLEAN DEFAULT false,
  stock INTEGER DEFAULT 100,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anyone view products" ON public.products FOR SELECT USING (true);
CREATE POLICY "admin manage products" ON public.products FOR ALL USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));

-- Cart
CREATE TABLE public.cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, product_id)
);
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own cart" ON public.cart_items FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Orders
CREATE TABLE public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users ON DELETE CASCADE,
  total NUMERIC(10,2) NOT NULL,
  address TEXT,
  status TEXT NOT NULL DEFAULT 'placed',
  items JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own orders read" ON public.orders FOR SELECT USING (auth.uid() = user_id OR public.has_role(auth.uid(),'admin'));
CREATE POLICY "own orders insert" ON public.orders FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Prescriptions
CREATE TABLE public.prescriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users ON DELETE CASCADE,
  image_url TEXT,
  extracted JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.prescriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own prescriptions" ON public.prescriptions FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Health records
CREATE TABLE public.health_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users ON DELETE CASCADE,
  title TEXT NOT NULL,
  record_type TEXT NOT NULL,
  notes TEXT,
  file_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.health_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own records" ON public.health_records FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Seed products
INSERT INTO public.products (name, brand, category, description, price, mrp, prescription_required, image_url) VALUES
('Paracetamol 500mg', 'MedBill', 'Fever & Pain', 'Pack of 10 tablets', 25, 30, false, 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400'),
('Azithromycin 500mg', 'MedBill', 'Antibiotics', 'Pack of 5 tablets', 90, 110, true, 'https://images.unsplash.com/photo-1550572017-edd951b55104?w=400'),
('Cetirizine 10mg', 'MedBill', 'Allergy', 'Pack of 10 tablets', 35, 42, false, 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400'),
('Vitamin D3 60K', 'MedBill', 'Vitamins', 'Pack of 4 sachets', 120, 150, false, 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400'),
('Pantoprazole 40mg', 'MedBill', 'Acidity', 'Pack of 15 tablets', 75, 95, false, 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=400'),
('Insulin Glargine', 'MedBill', 'Diabetes', '3ml cartridge', 850, 950, true, 'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=400'),
('Amlodipine 5mg', 'MedBill', 'Blood Pressure', 'Pack of 10 tablets', 45, 55, true, 'https://images.unsplash.com/photo-1576602976047-174e57a47881?w=400'),
('Multivitamin', 'MedBill', 'Vitamins', 'Pack of 30 tablets', 220, 280, false, 'https://images.unsplash.com/photo-1626716493137-b67fe9501e76?w=400'),
('Cough Syrup', 'MedBill', 'Cold & Cough', '100ml bottle', 95, 120, false, 'https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=400'),
('ORS Sachet', 'MedBill', 'Hydration', 'Pack of 5 sachets', 50, 60, false, 'https://images.unsplash.com/photo-1626716493137-b67fe9501e76?w=400');

-- Storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES ('prescriptions', 'prescriptions', false);
CREATE POLICY "users upload own prescriptions" ON storage.objects FOR INSERT WITH CHECK (bucket_id='prescriptions' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "users read own prescriptions" ON storage.objects FOR SELECT USING (bucket_id='prescriptions' AND auth.uid()::text = (storage.foldername(name))[1]);
