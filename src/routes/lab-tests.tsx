import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useAuth } from "@/lib/auth-context";
import { Search, Home, FlaskConical } from "lucide-react";

export const Route = createFileRoute("/lab-tests")({ component: LabTests });

const tests = [
  { name: "Complete Blood Count (CBC)", category: "Blood", price: 350, mrp: 500, fasting: false },
  { name: "Lipid Profile", category: "Heart", price: 600, mrp: 900, fasting: true },
  { name: "Thyroid Profile (T3 T4 TSH)", category: "Hormone", price: 500, mrp: 750, fasting: false },
  { name: "Diabetes - HbA1c", category: "Diabetes", price: 400, mrp: 600, fasting: false },
  { name: "Vitamin D Total", category: "Vitamin", price: 1200, mrp: 1800, fasting: false },
  { name: "Liver Function Test (LFT)", category: "Liver", price: 700, mrp: 1000, fasting: true },
  { name: "Kidney Function Test", category: "Kidney", price: 750, mrp: 1100, fasting: false },
  { name: "COVID-19 RT-PCR", category: "Infection", price: 500, mrp: 800, fasting: false },
];

const categories = ["Blood","Heart","Hormone","Diabetes","Vitamin","Liver","Kidney","Infection"];

function LabTests() {
  const { user } = useAuth();
  const [search, setSearch] = useState("");
  const [cat, setCat] = useState("");
  const [address] = useState(user ? "Will use your saved address" : "Add your address at checkout");
  const list = tests.filter((t) => (!cat || t.category === cat) && (!search || t.name.toLowerCase().includes(search.toLowerCase())));

  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main className="mx-auto max-w-7xl px-4 py-6">
        <h1 className="mb-2 text-2xl font-bold">Lab Tests</h1>
        <p className="mb-6 text-sm text-muted-foreground">Free home sample collection · Reports in 24 hrs</p>

        <Card className="mb-6 flex items-center gap-3 bg-brand-soft p-4">
          <Home className="size-6 text-brand" />
          <div className="flex-1 text-sm"><span className="font-semibold">Collect sample from:</span> {address}</div>
        </Card>

        <div className="relative mb-4 max-w-md">
          <Search className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
          <Input placeholder="Search lab tests" value={search} onChange={(e) => setSearch(e.target.value)} className="pl-9" />
        </div>

        <div className="mb-6 flex flex-wrap gap-2">
          <button onClick={() => setCat("")} className={`rounded-full border px-3 py-1.5 text-sm ${!cat ? "border-brand bg-brand text-brand-foreground" : ""}`}>All</button>
          {categories.map((c) => (
            <button key={c} onClick={() => setCat(c)} className={`rounded-full border px-3 py-1.5 text-sm ${cat === c ? "border-brand bg-brand text-brand-foreground" : "hover:border-brand"}`}>{c}</button>
          ))}
        </div>

        <div className="grid gap-3 md:grid-cols-2">
          {list.map((t) => (
            <Card key={t.name} className="flex items-center gap-3 p-4">
              <div className="flex size-12 items-center justify-center rounded-lg bg-violet-100 text-violet-600 dark:bg-violet-950"><FlaskConical className="size-6" /></div>
              <div className="flex-1">
                <div className="font-semibold">{t.name}</div>
                <div className="text-xs text-muted-foreground">{t.category}{t.fasting && " · Fasting required"}</div>
                <div className="mt-1"><span className="font-bold">₹{t.price}</span> <span className="text-xs text-muted-foreground line-through">₹{t.mrp}</span></div>
              </div>
              <Button size="sm" className="bg-brand hover:bg-brand/90">Book</Button>
            </Card>
          ))}
        </div>
      </main>
      <Footer />
    </div>
  );
}
