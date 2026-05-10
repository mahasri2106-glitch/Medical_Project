import { createFileRoute } from "@tanstack/react-router";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Shield, Check } from "lucide-react";

export const Route = createFileRoute("/insurance")({ component: Insurance });

const plans = [
  { name: "Family Floater Health", cover: "₹10 Lakh", premium: 8500, tag: "Most popular", perks: ["Cashless 10,000+ hospitals","No pre-policy check upto 50yrs","Free annual health check"] },
  { name: "Senior Citizen Care", cover: "₹5 Lakh", premium: 12000, tag: "60+ years", perks: ["Pre-existing disease cover","Domiciliary treatment","Day care 500+ procedures"] },
  { name: "Critical Illness", cover: "₹25 Lakh", premium: 6200, tag: "Cancer & heart", perks: ["Lump-sum on diagnosis","36 critical illnesses","Tax benefit u/s 80D"] },
  { name: "Personal Accident", cover: "₹15 Lakh", premium: 2400, tag: "Best value", perks: ["24x7 worldwide cover","Permanent disability cover","Education grant for kids"] },
  { name: "Top-Up Health", cover: "₹50 Lakh", premium: 4900, tag: "Add-on", perks: ["Activates above ₹3L base","Low premium high cover","Includes maternity"] },
  { name: "Diabetes Safe", cover: "₹7 Lakh", premium: 9800, tag: "For diabetics", perks: ["Day-1 cover for diabetes","Wellness rewards","Free HbA1c yearly"] },
];

function Insurance() {
  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main className="mx-auto max-w-7xl px-4 py-6">
        <div className="mb-6 flex items-center gap-3"><Shield className="size-8 text-brand" /><div><h1 className="text-2xl font-bold">Buy Insurance</h1><p className="text-sm text-muted-foreground">Compare. Choose. Get insured in minutes.</p></div></div>

        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {plans.map((p) => (
            <Card key={p.name} className="flex flex-col p-5">
              <span className="mb-2 inline-block w-fit rounded bg-brand-soft px-2 py-0.5 text-xs font-semibold text-brand">{p.tag}</span>
              <h3 className="text-lg font-bold">{p.name}</h3>
              <div className="mt-2 grid grid-cols-2 gap-2 rounded-lg bg-muted p-3">
                <div><div className="text-[10px] text-muted-foreground">Cover</div><div className="font-bold">{p.cover}</div></div>
                <div><div className="text-[10px] text-muted-foreground">Premium</div><div className="font-bold">₹{p.premium}/yr</div></div>
              </div>
              <ul className="mt-3 flex-1 space-y-1.5 text-sm">
                {p.perks.map((x) => <li key={x} className="flex gap-1.5"><Check className="size-4 shrink-0 text-success" />{x}</li>)}
              </ul>
              <Button className="mt-4 bg-brand hover:bg-brand/90">Buy now</Button>
            </Card>
          ))}
        </div>
      </main>
      <Footer />
    </div>
  );
}
