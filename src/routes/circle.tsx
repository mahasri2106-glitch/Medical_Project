import { createFileRoute } from "@tanstack/react-router";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Heart, Check } from "lucide-react";

export const Route = createFileRoute("/circle")({ component: Circle });

const benefits = ["Up to 25% off on medicines","Free unlimited delivery","20% off on lab tests","Free doctor consultations","Exclusive Circle deals","Priority customer support"];

function Circle() {
  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main className="mx-auto max-w-4xl px-4 py-6">
        <Card className="overflow-hidden bg-gradient-to-br from-pink-500 to-rose-600 p-8 text-white">
          <Heart className="mb-3 size-10" />
          <h1 className="text-3xl font-bold">MedBill Circle</h1>
          <p className="mt-2 text-white/90">Save more on every order with our annual membership.</p>
          <div className="mt-6 flex items-baseline gap-2"><span className="text-4xl font-bold">₹399</span><span className="text-white/80">/ year</span></div>
        </Card>

        <Card className="mt-6 p-6">
          <h3 className="mb-4 font-bold">Membership benefits</h3>
          <ul className="grid gap-3 md:grid-cols-2">
            {benefits.map((b) => (
              <li key={b} className="flex gap-2 text-sm"><Check className="size-5 shrink-0 text-success" />{b}</li>
            ))}
          </ul>
          <Button className="mt-6 w-full bg-brand hover:bg-brand/90">Become a Circle member</Button>
        </Card>
      </main>
      <Footer />
    </div>
  );
}
