import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "./auth-context";

type CartItem = {
  id: string;
  product_id: string;
  quantity: number;
  product: { id: string; name: string; brand: string | null; price: number; image_url: string | null };
};

type Ctx = {
  items: CartItem[];
  count: number;
  total: number;
  add: (productId: string, qty?: number) => Promise<void>;
  update: (id: string, qty: number) => Promise<void>;
  remove: (id: string) => Promise<void>;
  clear: () => Promise<void>;
  refresh: () => Promise<void>;
};

const CartCtx = createContext<Ctx>(null as never);

export function CartProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  const [items, setItems] = useState<CartItem[]>([]);

  const refresh = async () => {
    if (!user) { setItems([]); return; }
    const { data } = await supabase.from("cart_items").select("id, product_id, quantity, product:products(id, name, brand, price, image_url)").eq("user_id", user.id);
    setItems((data as never) ?? []);
  };

  useEffect(() => { refresh(); }, [user?.id]);

  const add = async (productId: string, qty = 1) => {
    if (!user) return;
    const existing = items.find((i) => i.product_id === productId);
    if (existing) {
      await supabase.from("cart_items").update({ quantity: existing.quantity + qty }).eq("id", existing.id);
    } else {
      await supabase.from("cart_items").insert({ user_id: user.id, product_id: productId, quantity: qty });
    }
    refresh();
  };
  const update = async (id: string, qty: number) => {
    if (qty <= 0) return remove(id);
    await supabase.from("cart_items").update({ quantity: qty }).eq("id", id);
    refresh();
  };
  const remove = async (id: string) => { await supabase.from("cart_items").delete().eq("id", id); refresh(); };
  const clear = async () => { if (!user) return; await supabase.from("cart_items").delete().eq("user_id", user.id); refresh(); };

  const count = items.reduce((s, i) => s + i.quantity, 0);
  const total = items.reduce((s, i) => s + i.quantity * Number(i.product.price), 0);

  return <CartCtx.Provider value={{ items, count, total, add, update, remove, clear, refresh }}>{children}</CartCtx.Provider>;
}

export const useCart = () => useContext(CartCtx);
