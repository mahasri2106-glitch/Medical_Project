import { createFileRoute, Link } from "@tanstack/react-router";
import { useState } from "react";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/lib/auth-context";
import { useCart } from "@/lib/cart-context";
import { Upload, Sparkles, Loader2, Pill } from "lucide-react";
import { toast } from "sonner";

export const Route = createFileRoute("/prescription")({ component: Prescription });

type Extracted = { medicines: { name: string; dosage?: string; duration?: string }[]; notes?: string };
type Match = { id: string; name: string; brand: string | null; price: number; image_url: string | null };

function Prescription() {
  const { user } = useAuth();
  const { add } = useCart();
  const [file, setFile] = useState<File | null>(null);
  const [preview, setPreview] = useState<string>("");
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<Extracted | null>(null);
  const [matches, setMatches] = useState<Record<string, Match[]>>({});

  const onFile = (f: File) => {
    setFile(f);
    setPreview(URL.createObjectURL(f));
    setResult(null);
    setMatches({});
  };

  const analyze = async () => {
    if (!file) return;
    setLoading(true);
    try {
      const reader = new FileReader();
      const dataUrl: string = await new Promise((res, rej) => {
        reader.onload = () => res(reader.result as string);
        reader.onerror = rej;
        reader.readAsDataURL(file);
      });
      const { data, error } = await supabase.functions.invoke("read-prescription", { body: { imageBase64: dataUrl } });
      if (error) throw error;
      const ext = data as Extracted;
      setResult(ext);

      // search matches per medicine
      const out: Record<string, Match[]> = {};
      for (const m of ext.medicines) {
        const term = m.name.split(/\s+/)[0];
        const { data: prods } = await supabase.from("products").select("id, name, brand, price, image_url").ilike("name", `%${term}%`).limit(3);
        out[m.name] = (prods as never) ?? [];
      }
      setMatches(out);

      if (user) await supabase.from("prescriptions").insert({ user_id: user.id, extracted: ext as never });
      toast.success(`Found ${ext.medicines.length} medicine(s)`);
    } catch (e) {
      toast.error((e as Error).message || "Failed to read prescription");
    } finally { setLoading(false); }
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main className="mx-auto max-w-5xl px-4 py-6">
        <div className="mb-6 flex items-center gap-2">
          <span className="rounded-full bg-brand-soft px-3 py-1 text-xs font-semibold text-brand"><Sparkles className="mr-1 inline size-3" />AI-powered</span>
        </div>
        <h1 className="text-2xl font-bold">Prescription Reader</h1>
        <p className="mb-6 text-sm text-muted-foreground">Upload your doctor's prescription. Our AI extracts medicines and suggests matching products.</p>

        {!user && <Card className="mb-4 bg-amber-50 p-3 text-sm dark:bg-amber-950"><Link to="/login" className="font-semibold text-brand">Login</Link> to save extracted prescriptions.</Card>}

        <div className="grid gap-6 md:grid-cols-2">
          <Card className="p-4">
            <label className="block">
              <div className="flex aspect-[4/5] cursor-pointer flex-col items-center justify-center rounded-lg border-2 border-dashed bg-muted/40 hover:border-brand hover:bg-brand-soft/30">
                {preview ? <img src={preview} className="size-full rounded-md object-contain" alt="" /> : (
                  <><Upload className="mb-2 size-10 text-muted-foreground" /><span className="text-sm font-medium">Click to upload prescription</span><span className="text-xs text-muted-foreground">JPG or PNG</span></>
                )}
              </div>
              <input type="file" accept="image/*" className="hidden" onChange={(e) => e.target.files?.[0] && onFile(e.target.files[0])} />
            </label>
            <Button className="mt-3 w-full bg-brand hover:bg-brand/90" disabled={!file || loading} onClick={analyze}>
              {loading ? <><Loader2 className="size-4 animate-spin" /> Analyzing...</> : <><Sparkles className="size-4" /> Extract medicines</>}
            </Button>
          </Card>

          <div>
            {!result && <Card className="flex h-full items-center justify-center p-8 text-center text-sm text-muted-foreground">Extracted medicines will appear here.</Card>}
            {result && (
              <div className="space-y-3">
                {result.medicines.map((m, i) => (
                  <Card key={i} className="p-4">
                    <div className="flex items-start gap-2"><Pill className="mt-0.5 size-5 text-brand" /><div className="flex-1"><div className="font-semibold">{m.name}</div>{m.dosage && <div className="text-xs text-muted-foreground">{m.dosage}{m.duration ? ` · ${m.duration}` : ""}</div>}</div></div>
                    {matches[m.name]?.length ? (
                      <div className="mt-3 space-y-2 border-t pt-2">
                        <div className="text-xs font-semibold text-muted-foreground">Available in MedBill:</div>
                        {matches[m.name].map((p) => (
                          <div key={p.id} className="flex items-center gap-2 rounded border p-2">
                            {p.image_url && <img src={p.image_url} className="size-10 rounded object-cover" alt="" />}
                            <div className="flex-1 text-sm"><div className="font-medium">{p.name}</div><div className="text-xs">₹{p.price}</div></div>
                            <Button size="sm" variant="outline" disabled={!user} onClick={() => { add(p.id); toast.success("Added"); }}>Add</Button>
                          </div>
                        ))}
                      </div>
                    ) : <div className="mt-2 text-xs text-muted-foreground">No exact match found in catalog.</div>}
                  </Card>
                ))}
                {result.notes && <Card className="bg-muted p-3 text-sm">{result.notes}</Card>}
              </div>
            )}
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}
