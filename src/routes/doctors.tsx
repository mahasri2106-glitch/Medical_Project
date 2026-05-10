import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Search, Stethoscope, Video, MapPin } from "lucide-react";

export const Route = createFileRoute("/doctors")({
  validateSearch: (s: Record<string, unknown>) => ({ specialty: (s.specialty as string) || "" }),
  component: Doctors,
});

const specialties = ["Cardiologist","ENT","Pediatrician","Dermatologist","Neurologist","Orthopedic","Dentist","Gynecologist","General Physician","Psychiatrist"];

const doctors = [
  { name: "Dr. Aditi Sharma", specialty: "Cardiologist", exp: 12, rating: 4.8, fee: 600, city: "Bangalore" },
  { name: "Dr. Rohan Patel", specialty: "ENT", exp: 8, rating: 4.6, fee: 400, city: "Mumbai" },
  { name: "Dr. Nisha Reddy", specialty: "Pediatrician", exp: 15, rating: 4.9, fee: 500, city: "Hyderabad" },
  { name: "Dr. Vikram Singh", specialty: "Dermatologist", exp: 10, rating: 4.7, fee: 550, city: "Delhi" },
  { name: "Dr. Meera Iyer", specialty: "Neurologist", exp: 18, rating: 4.9, fee: 800, city: "Chennai" },
  { name: "Dr. Arjun Mehta", specialty: "Orthopedic", exp: 14, rating: 4.7, fee: 650, city: "Pune" },
  { name: "Dr. Kavya Nair", specialty: "Dentist", exp: 9, rating: 4.8, fee: 350, city: "Kochi" },
  { name: "Dr. Sanjay Rao", specialty: "General Physician", exp: 20, rating: 4.8, fee: 300, city: "Bangalore" },
];

const diseaseMap: Record<string, string> = {
  "fever": "General Physician", "headache": "Neurologist", "rash": "Dermatologist",
  "chest pain": "Cardiologist", "tooth": "Dentist", "child": "Pediatrician", "ear": "ENT", "joint": "Orthopedic",
};

function Doctors() {
  const { specialty } = Route.useSearch();
  const [filter, setFilter] = useState(specialty);
  const [disease, setDisease] = useState("");
  const suggestion = disease ? Object.entries(diseaseMap).find(([k]) => disease.toLowerCase().includes(k))?.[1] : null;
  const list = doctors.filter((d) => !filter || d.specialty === filter);

  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main className="mx-auto max-w-7xl px-4 py-6">
        <h1 className="mb-2 text-2xl font-bold">Find Doctors</h1>
        <p className="mb-6 text-sm text-muted-foreground">Consult top specialists online or visit nearby</p>

        <Card className="mb-6 p-4">
          <label className="mb-2 block text-sm font-medium">Tell us your symptom (we'll suggest a doctor)</label>
          <div className="relative">
            <Search className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
            <Input placeholder="e.g. fever, headache, chest pain, tooth ache" value={disease} onChange={(e) => setDisease(e.target.value)} className="pl-9" />
          </div>
          {suggestion && (
            <div className="mt-3 rounded-md bg-brand-soft p-3 text-sm">
              Suggested specialty: <button className="font-bold text-brand underline" onClick={() => setFilter(suggestion)}>{suggestion}</button>
            </div>
          )}
        </Card>

        <div className="mb-6 flex flex-wrap gap-2">
          <button onClick={() => setFilter("")} className={`rounded-full border px-3 py-1.5 text-sm ${!filter ? "border-brand bg-brand text-brand-foreground" : ""}`}>All</button>
          {specialties.map((s) => (
            <button key={s} onClick={() => setFilter(s)} className={`rounded-full border px-3 py-1.5 text-sm ${filter === s ? "border-brand bg-brand text-brand-foreground" : "hover:border-brand"}`}>{s}</button>
          ))}
        </div>

        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {list.map((d) => (
            <Card key={d.name} className="p-4">
              <div className="flex gap-3">
                <div className="flex size-14 shrink-0 items-center justify-center rounded-full bg-brand-soft text-brand"><Stethoscope className="size-7" /></div>
                <div className="flex-1">
                  <div className="font-semibold">{d.name}</div>
                  <div className="text-xs text-muted-foreground">{d.specialty} · {d.exp} yrs exp</div>
                  <div className="mt-1 flex items-center gap-2 text-xs"><span className="text-amber-500">★ {d.rating}</span><MapPin className="size-3" />{d.city}</div>
                </div>
              </div>
              <div className="mt-3 flex items-center justify-between">
                <span className="text-sm font-bold">₹{d.fee}</span>
                <Button size="sm" className="bg-brand hover:bg-brand/90"><Video className="size-3" /> Consult</Button>
              </div>
            </Card>
          ))}
        </div>
      </main>
      <Footer />
    </div>
  );
}
