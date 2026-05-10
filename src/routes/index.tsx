import { createFileRoute, Link } from "@tanstack/react-router";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { Card } from "@/components/ui/card";
import { Pill, Stethoscope, FlaskConical, Heart, FileText, Shield, ScanLine, Sparkles, Baby, Activity, Brain, Eye, Bone, Smile, ChevronRight } from "lucide-react";

export const Route = createFileRoute("/")({ component: Home });

const services = [
  { to: "/medicines", icon: Pill, label: "Buy Medicines", color: "bg-emerald-500" },
  { to: "/doctors", icon: Stethoscope, label: "Find Doctors", color: "bg-blue-500" },
  { to: "/lab-tests", icon: FlaskConical, label: "Lab Tests", color: "bg-violet-500" },
  { to: "/circle", icon: Heart, label: "Circle Membership", color: "bg-pink-500" },
  { to: "/health-records", icon: FileText, label: "Health Records", color: "bg-orange-500" },
  { to: "/insurance", icon: Shield, label: "Buy Insurance", color: "bg-teal-600" },
  { to: "/prescription", icon: ScanLine, label: "AI Prescription", color: "bg-rose-500" },
];

const specialties = [
  { icon: Heart, label: "Cardiologist" },
  { icon: Brain, label: "Neurologist" },
  { icon: Baby, label: "Pediatrician" },
  { icon: Eye, label: "Ophthalmologist" },
  { icon: Bone, label: "Orthopedic" },
  { icon: Smile, label: "Dentist" },
  { icon: Activity, label: "General Physician" },
  { icon: Sparkles, label: "Dermatologist" },
];

const categories = ["Personal Care","Skin Care","Oral Care","Adult Diapers","Sanitary Pads","Sexual Wellness","Mens Grooming","Baby Care","Vitamins","Diabetes","Heart Care"];

function Home() {
  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main className="mx-auto max-w-7xl px-4 py-6">
        {/* Hero */}
        <section className="mb-8 overflow-hidden rounded-2xl bg-gradient-to-br from-brand to-emerald-600 p-6 text-white md:p-10">
          <div className="max-w-2xl">
            <div className="mb-2 inline-flex items-center gap-1 rounded-full bg-white/20 px-3 py-1 text-xs font-medium backdrop-blur"><Sparkles className="size-3" /> AI-powered prescription reader</div>
            <h1 className="text-3xl font-bold leading-tight md:text-5xl">Your health, delivered.</h1>
            <p className="mt-3 text-white/90 md:text-lg">Order medicines, consult doctors, book lab tests, and manage records — all in one MedBill app.</p>
            <div className="mt-5 flex flex-wrap gap-2">
              <Link to="/medicines" className="rounded-lg bg-white px-5 py-2.5 text-sm font-semibold text-brand hover:bg-white/90">Shop medicines</Link>
              <Link to="/prescription" className="rounded-lg border border-white/40 bg-white/10 px-5 py-2.5 text-sm font-semibold text-white backdrop-blur hover:bg-white/20">Upload prescription</Link>
            </div>
          </div>
        </section>

        {/* Services */}
        <section className="mb-10">
          <h2 className="mb-4 text-xl font-bold">Our services</h2>
          <div className="grid grid-cols-3 gap-3 md:grid-cols-7">
            {services.map((s) => (
              <Link key={s.to} to={s.to}>
                <Card className="flex flex-col items-center gap-2 p-4 text-center transition hover:shadow-md hover:-translate-y-0.5">
                  <div className={`flex size-12 items-center justify-center rounded-xl ${s.color} text-white`}><s.icon className="size-6" /></div>
                  <span className="text-xs font-medium">{s.label}</span>
                </Card>
              </Link>
            ))}
          </div>
        </section>

        {/* Specialties */}
        <section className="mb-10">
          <div className="mb-4 flex items-end justify-between">
            <h2 className="text-xl font-bold">Consult by specialty</h2>
            <Link to="/doctors" className="flex items-center gap-1 text-sm text-brand">View all <ChevronRight className="size-4" /></Link>
          </div>
          <div className="grid grid-cols-4 gap-3 md:grid-cols-8">
            {specialties.map((s) => (
              <Link key={s.label} to="/doctors" search={{ specialty: s.label } as never}>
                <Card className="flex flex-col items-center gap-2 p-3 text-center hover:bg-accent">
                  <s.icon className="size-7 text-brand" />
                  <span className="text-[11px] font-medium leading-tight">{s.label}</span>
                </Card>
              </Link>
            ))}
          </div>
        </section>

        {/* Categories */}
        <section className="mb-10">
          <h2 className="mb-4 text-xl font-bold">Shop by category</h2>
          <div className="flex flex-wrap gap-2">
            {categories.map((c) => (
              <Link key={c} to="/medicines" search={{ category: c } as never} className="rounded-full border bg-card px-4 py-2 text-sm hover:border-brand hover:text-brand">{c}</Link>
            ))}
          </div>
        </section>

        {/* Promo grid */}
        <section className="mb-10 grid gap-4 md:grid-cols-3">
          <Card className="bg-gradient-to-br from-blue-50 to-blue-100 p-6 dark:from-blue-950 dark:to-blue-900">
            <FlaskConical className="mb-2 size-8 text-blue-600" />
            <h3 className="text-lg font-bold">Lab Tests at home</h3>
            <p className="text-sm text-muted-foreground">Free sample collection from your address</p>
            <Link to="/lab-tests" className="mt-3 inline-block text-sm font-semibold text-blue-600">Book now →</Link>
          </Card>
          <Card className="bg-gradient-to-br from-pink-50 to-pink-100 p-6 dark:from-pink-950 dark:to-pink-900">
            <Heart className="mb-2 size-8 text-pink-600" />
            <h3 className="text-lg font-bold">MedBill Circle</h3>
            <p className="text-sm text-muted-foreground">Save up to 25% on every order</p>
            <Link to="/circle" className="mt-3 inline-block text-sm font-semibold text-pink-600">Join now →</Link>
          </Card>
          <Card className="bg-gradient-to-br from-teal-50 to-teal-100 p-6 dark:from-teal-950 dark:to-teal-900">
            <Shield className="mb-2 size-8 text-teal-600" />
            <h3 className="text-lg font-bold">Health Insurance</h3>
            <p className="text-sm text-muted-foreground">Compare and pick the right plan</p>
            <Link to="/insurance" className="mt-3 inline-block text-sm font-semibold text-teal-600">Explore →</Link>
          </Card>
        </section>
      </main>
      <Footer />
    </div>
  );
}
