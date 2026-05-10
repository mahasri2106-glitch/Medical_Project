import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { useCart } from "@/lib/cart-context";
import { useAuth } from "@/lib/auth-context";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Trash2, Plus, Minus } from "lucide-react";

export const Route = createFileRoute("/cart")({ component: Cart });

function Cart() {
  const { items, total, update, remove } = useCart();
  const { user } = useAuth();
  const nav = useNavigate();

  if (!user) {
    return (<div className="min-h-screen"><Header /><main className="mx-auto max-w-3xl p-8 text-center"><p className="mb-4">Please login to view your cart.</p><Link to="/login"><Button>Login</Button></Link></main></div>);
  }

  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main className="mx-auto max-w-4xl px-4 py-6">
        <h1 className="mb-6 text-2xl font-bold">Your Cart ({items.length})</h1>
        {items.length === 0 ? (
          <Card className="p-12 text-center">
            <p className="text-muted-foreground">Your cart is empty.</p>
            <Link to="/medicines"><Button className="mt-4 bg-brand">Browse medicines</Button></Link>
          </Card>
        ) : (
          <div className="grid gap-6 md:grid-cols-3">
            <div className="space-y-3 md:col-span-2">
              {items.map((i) => (
                <Card key={i.id} className="flex gap-4 p-3">
                  <div className="size-20 overflow-hidden rounded bg-muted">{i.product.image_url && <img src={i.product.image_url} className="size-full object-cover" alt="" />}</div>
                  <div className="flex-1">
                    <div className="text-xs text-muted-foreground">{i.product.brand}</div>
                    <div className="font-semibold">{i.product.name}</div>
                    <div className="mt-1 font-bold">₹{i.product.price}</div>
                    <div className="mt-2 flex items-center gap-2">
                      <div className="flex items-center rounded-md border">
                        <Button size="icon" variant="ghost" className="size-7" onClick={() => update(i.id, i.quantity - 1)}><Minus className="size-3" /></Button>
                        <span className="w-8 text-center text-sm">{i.quantity}</span>
                        <Button size="icon" variant="ghost" className="size-7" onClick={() => update(i.id, i.quantity + 1)}><Plus className="size-3" /></Button>
                      </div>
                      <Button size="icon" variant="ghost" onClick={() => remove(i.id)}><Trash2 className="size-4 text-destructive" /></Button>
                    </div>
                  </div>
                </Card>
              ))}
            </div>
            <Card className="h-fit p-4">
              <h3 className="mb-3 font-bold">Order Summary</h3>
              <div className="space-y-1 text-sm">
                <div className="flex justify-between"><span>Subtotal</span><span>₹{total.toFixed(2)}</span></div>
                <div className="flex justify-between"><span>Delivery</span><span className="text-success">FREE</span></div>
                <div className="mt-2 flex justify-between border-t pt-2 font-bold"><span>Total</span><span>₹{total.toFixed(2)}</span></div>
              </div>
              <Button className="mt-4 w-full bg-brand hover:bg-brand/90" onClick={() => nav({ to: "/checkout" })}>Proceed to checkout</Button>
            </Card>
          </div>
        )}
      </main>
      <Footer />
    </div>
  );
}
