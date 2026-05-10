import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/lib/auth-context";

type Order = { id: string; total: number; address: string; status: string; items: { name: string; qty: number; price: number }[]; created_at: string };

export const Route = createFileRoute("/orders")({ component: Orders });

function Orders() {
  const { user } = useAuth();
  const [orders, setOrders] = useState<Order[]>([]);

  useEffect(() => {
    if (!user) return;
    supabase.from("orders").select("*").order("created_at", { ascending: false }).then(({ data }) => setOrders((data as never) ?? []));
  }, [user?.id]);

  if (!user) return <div className="p-8 text-center"><Link to="/login"><Button>Login</Button></Link></div>;

  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main className="mx-auto max-w-4xl px-4 py-6">
        <h1 className="mb-6 text-2xl font-bold">My Orders</h1>
        {orders.length === 0 ? <Card className="p-8 text-center text-muted-foreground">No orders yet.</Card> : (
          <div className="space-y-3">
            {orders.map((o) => (
              <Card key={o.id} className="p-4">
                <div className="flex justify-between text-sm"><span className="text-muted-foreground">#{o.id.slice(0, 8)}</span><span className="font-semibold capitalize text-brand">{o.status}</span></div>
                <div className="mt-2 text-sm">{o.items.map((i, k) => <div key={k}>{i.name} × {i.qty}</div>)}</div>
                <div className="mt-2 flex justify-between border-t pt-2"><span className="text-xs text-muted-foreground">{new Date(o.created_at).toLocaleString()}</span><span className="font-bold">₹{o.total}</span></div>
              </Card>
            ))}
          </div>
        )}
      </main>
      <Footer />
    </div>
  );
}
