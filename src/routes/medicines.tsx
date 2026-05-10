import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { supabase } from "@/integrations/supabase/client";
import { useCart } from "@/lib/cart-context";
import { useAuth } from "@/lib/auth-context";
import { Search, Plus, Minus, FileText } from "lucide-react";
import { toast } from "sonner";

type Product = { id: string; name: string; brand: string | null; category: string; description: string | null; price: number; mrp: number | null; image_url: string | null; prescription_required: boolean };

export const Route = createFileRoute("/medicines")({
  validateSearch: (s: Record<string, unknown>) => ({ q: (s.q as string) || "", category: (s.category as string) || "" }),
  component: Medicines,
});

function Medicines() {
  const { q, category } = Route.useSearch();
  const [products, setProducts] = useState<Product[]>([]);
  const [search, setSearch] = useState(q);
  const { add, items, update } = useCart();
  const { user } = useAuth();

  useEffect(() => {
    let query = supabase.from("products").select("*").order("name");
    if (category) query = query.eq("category", category);
    query.then(({ data }) => setProducts((data as never) ?? []));
  }, [category]);

  const filtered = products.filter((p) =>
    !search || p.name.toLowerCase().includes(search.toLowerCase()) || p.category.toLowerCase().includes(search.toLowerCase())
  );

  const qtyOf = (pid: string) => items.find((i) => i.product_id === pid)?.quantity ?? 0;
  const cartLine = (pid: string) => items.find((i) => i.product_id === pid);

  const handleAdd = (p: Product) => {
    if (!user) { toast.error("Please login to add items"); return; }
    add(p.id);
    toast.success(`${p.name} added to cart`);
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main className="mx-auto max-w-7xl px-4 py-6">
        <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
          <div>
            <h1 className="text-2xl font-bold">Medicines{category && <span className="text-muted-foreground"> · {category}</span>}</h1>
            <p className="text-sm text-muted-foreground">{filtered.length} products</p>
          </div>
          <Link to="/prescription"><Button variant="outline"><FileText className="size-4" /> Upload prescription</Button></Link>
        </div>

        <div className="relative mb-6 max-w-md">
          <Search className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
          <Input placeholder="Search medicines" value={search} onChange={(e) => setSearch(e.target.value)} className="pl-9" />
        </div>

        <div className="grid grid-cols-2 gap-4 md:grid-cols-4 lg:grid-cols-5">
          {filtered.map((p) => {
            const line = cartLine(p.id);
            const q = qtyOf(p.id);
            return (
              <Card key={p.id} className="flex flex-col overflow-hidden p-3">
                <div className="aspect-square overflow-hidden rounded-md bg-muted">
                  {p.image_url && <img src={p.image_url} alt={p.name} className="size-full object-cover" loading="lazy" />}
                </div>
                <div className="mt-2 flex-1">
                  <div className="text-xs text-muted-foreground">{p.brand}</div>
                  <div className="line-clamp-2 text-sm font-semibold">{p.name}</div>
                  <div className="text-[11px] text-muted-foreground">{p.category}</div>
                  {p.prescription_required && <span className="mt-1 inline-block rounded bg-amber-100 px-1.5 py-0.5 text-[10px] font-medium text-amber-800">Rx required</span>}
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="font-bold">₹{p.price}</span>
                    {p.mrp && Number(p.mrp) > Number(p.price) && <span className="text-xs text-muted-foreground line-through">₹{p.mrp}</span>}
                  </div>
                </div>
                {q === 0 ? (
                  <Button size="sm" className="mt-2 w-full bg-brand hover:bg-brand/90" onClick={() => handleAdd(p)}>Add</Button>
                ) : (
                  <div className="mt-2 flex items-center justify-between rounded-md border">
                    <Button size="icon" variant="ghost" className="size-8" onClick={() => line && update(line.id, q - 1)}><Minus className="size-3" /></Button>
                    <span className="text-sm font-semibold">{q}</span>
                    <Button size="icon" variant="ghost" className="size-8" onClick={() => line && update(line.id, q + 1)}><Plus className="size-3" /></Button>
                  </div>
                )}
              </Card>
            );
          })}
        </div>
      </main>
      <Footer />
    </div>
  );
}
