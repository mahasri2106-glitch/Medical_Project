import { createFileRoute, useNavigate, Link } from "@tanstack/react-router";
import { useState } from "react";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { useCart } from "@/lib/cart-context";
import { useAuth } from "@/lib/auth-context";
import { supabase } from "@/integrations/supabase/client";
import { toast } from "sonner";

export const Route = createFileRoute("/checkout")({ component: Checkout });

function Checkout() {
  const { items, total, clear } = useCart();
  const { user } = useAuth();
  const nav = useNavigate();
  const [address, setAddress] = useState("");
  const [phone, setPhone] = useState("");
  const [loading, setLoading] = useState(false);

  if (!user) return <div className="p-8 text-center"><Link to="/login"><Button>Login</Button></Link></div>;

  const place = async () => {
    if (!address || !phone) { toast.error("Address and phone required"); return; }
    setLoading(true);
    const { error } = await supabase.from("orders").insert({
      user_id: user.id, total, address: `${address} (${phone})`,
      items: items.map((i) => ({ name: i.product.name, qty: i.quantity, price: i.product.price })),
    });
    if (error) { toast.error(error.message); setLoading(false); return; }
    await clear();
    toast.success("Order placed!");
    nav({ to: "/orders" });
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main className="mx-auto max-w-3xl px-4 py-6">
        <h1 className="mb-6 text-2xl font-bold">Checkout</h1>
        <Card className="p-6">
          <h3 className="mb-3 font-semibold">Delivery address</h3>
          <div className="space-y-3">
            <Input placeholder="Phone number" value={phone} onChange={(e) => setPhone(e.target.value)} />
            <Textarea placeholder="Full delivery address with pincode" value={address} onChange={(e) => setAddress(e.target.value)} rows={4} />
          </div>
          <div className="mt-4 border-t pt-4">
            <div className="flex justify-between text-sm"><span>Items ({items.length})</span><span>₹{total.toFixed(2)}</span></div>
            <div className="flex justify-between font-bold"><span>Total</span><span>₹{total.toFixed(2)}</span></div>
          </div>
          <Button className="mt-4 w-full bg-brand hover:bg-brand/90" disabled={loading || items.length === 0} onClick={place}>{loading ? "Placing..." : "Place order (Cash on delivery)"}</Button>
        </Card>
      </main>
      <Footer />
    </div>
  );
}
