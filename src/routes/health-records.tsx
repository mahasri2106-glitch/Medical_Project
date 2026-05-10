import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/lib/auth-context";
import { FileText, Plus, Shield, ChevronRight } from "lucide-react";
import { toast } from "sonner";

type Record = { id: string; title: string; record_type: string; notes: string | null; created_at: string };

export const Route = createFileRoute("/health-records")({ component: HealthRecords });

const insurancePicks = [
  { name: "Family Floater Health", cover: "₹10 Lakh", premium: "₹8,500/yr", tag: "Most popular" },
  { name: "Senior Citizen Care", cover: "₹5 Lakh", premium: "₹12,000/yr", tag: "60+ years" },
  { name: "Critical Illness", cover: "₹25 Lakh", premium: "₹6,200/yr", tag: "Cancer & heart" },
  { name: "Personal Accident", cover: "₹15 Lakh", premium: "₹2,400/yr", tag: "Best value" },
];

function HealthRecords() {
  const { user } = useAuth();
  const [records, setRecords] = useState<Record[]>([]);
  const [open, setOpen] = useState(false);
  const [title, setTitle] = useState("");
  const [type, setType] = useState("Prescription");
  const [notes, setNotes] = useState("");

  const load = () => {
    if (!user) return;
    supabase.from("health_records").select("*").order("created_at", { ascending: false }).then(({ data }) => setRecords((data as never) ?? []));
  };
  useEffect(load, [user?.id]);

  const save = async () => {
    if (!user) return;
    const { error } = await supabase.from("health_records").insert({ user_id: user.id, title, record_type: type, notes });
    if (error) { toast.error(error.message); return; }
    toast.success("Record added");
    setOpen(false); setTitle(""); setNotes(""); load();
  };

  if (!user) return <div className="min-h-screen"><Header /><main className="p-8 text-center"><p className="mb-4">Login to manage your private health records.</p><Link to="/login"><Button>Login</Button></Link></main></div>;

  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main className="mx-auto max-w-5xl px-4 py-6">
        <div className="mb-6 flex items-center justify-between">
          <div><h1 className="text-2xl font-bold">Health Records</h1><p className="text-sm text-muted-foreground">Securely stored. Only you can access them.</p></div>
          <Button className="bg-brand hover:bg-brand/90" onClick={() => setOpen(true)}><Plus className="size-4" /> Add record</Button>
        </div>

        {open && (
          <Card className="mb-6 space-y-3 p-4">
            <Input placeholder="Title (e.g. Blood test - May 2026)" value={title} onChange={(e) => setTitle(e.target.value)} />
            <Select value={type} onValueChange={setType}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>{["Prescription","Lab Report","Discharge Summary","Vaccination","Insurance","Other"].map((t) => <SelectItem key={t} value={t}>{t}</SelectItem>)}</SelectContent>
            </Select>
            <Textarea placeholder="Notes" value={notes} onChange={(e) => setNotes(e.target.value)} rows={3} />
            <div className="flex gap-2"><Button onClick={save} className="bg-brand">Save</Button><Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button></div>
          </Card>
        )}

        {records.length === 0 ? (
          <Card className="p-8 text-center text-muted-foreground"><FileText className="mx-auto mb-2 size-10" />No records yet.</Card>
        ) : (
          <div className="grid gap-3 md:grid-cols-2">
            {records.map((r) => (
              <Card key={r.id} className="p-4">
                <div className="flex items-start gap-3">
                  <FileText className="size-5 text-brand" />
                  <div className="flex-1">
                    <div className="font-semibold">{r.title}</div>
                    <div className="text-xs text-muted-foreground">{r.record_type} · {new Date(r.created_at).toLocaleDateString()}</div>
                    {r.notes && <p className="mt-1 text-sm">{r.notes}</p>}
                  </div>
                </div>
              </Card>
            ))}
          </div>
        )}

        {/* Insurance section */}
        <section className="mt-10">
          <div className="mb-3 flex items-center justify-between">
            <h2 className="flex items-center gap-2 text-xl font-bold"><Shield className="size-5 text-brand" /> Insurance — More like this</h2>
            <Link to="/insurance" className="flex items-center gap-1 text-sm text-brand">See all <ChevronRight className="size-4" /></Link>
          </div>
          <p className="mb-4 text-sm text-muted-foreground">Plans matched to your records. Tap to compare and buy.</p>
          <div className="grid gap-3 md:grid-cols-2 lg:grid-cols-4">
            {insurancePicks.map((p) => (
              <Card key={p.name} className="p-4 transition hover:border-brand hover:shadow-md">
                <span className="inline-block rounded bg-brand-soft px-2 py-0.5 text-[10px] font-semibold text-brand">{p.tag}</span>
                <h3 className="mt-2 font-semibold">{p.name}</h3>
                <div className="mt-2 text-xs text-muted-foreground">Cover</div>
                <div className="font-bold">{p.cover}</div>
                <div className="mt-1 text-xs text-muted-foreground">Premium</div>
                <div className="text-sm">{p.premium}</div>
                <Link to="/insurance"><Button size="sm" variant="outline" className="mt-3 w-full">View plan</Button></Link>
              </Card>
            ))}
          </div>
        </section>
      </main>
      <Footer />
    </div>
  );
}
