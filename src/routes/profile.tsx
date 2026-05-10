import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { useAuth } from "@/lib/auth-context";
import { supabase } from "@/integrations/supabase/client";
import { toast } from "sonner";

export const Route = createFileRoute("/profile")({ component: Profile });

function Profile() {
  const { user, signOut, isAdmin } = useAuth();
  const [full_name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [address, setAddress] = useState("");

  useEffect(() => {
    if (!user) return;
    supabase.from("profiles").select("*").eq("id", user.id).maybeSingle().then(({ data }) => {
      if (data) { setName(data.full_name ?? ""); setPhone(data.phone ?? ""); setAddress(data.address ?? ""); }
    });
  }, [user?.id]);

  if (!user) return <div className="min-h-screen"><Header /><main className="p-8 text-center"><Link to="/login"><Button>Login</Button></Link></main></div>;

  const save = async () => {
    const { error } = await supabase.from("profiles").upsert({ id: user.id, full_name, phone, address });
    if (error) toast.error(error.message); else toast.success("Profile saved");
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main className="mx-auto max-w-2xl px-4 py-6">
        <h1 className="mb-1 text-2xl font-bold">My Profile</h1>
        <p className="mb-6 text-sm text-muted-foreground">{user.email}{isAdmin && <span className="ml-2 rounded bg-brand px-2 py-0.5 text-xs text-brand-foreground">Admin</span>}</p>
        <Card className="space-y-3 p-6">
          <div><label className="mb-1 block text-sm font-medium">Full name</label><Input value={full_name} onChange={(e) => setName(e.target.value)} /></div>
          <div><label className="mb-1 block text-sm font-medium">Phone</label><Input value={phone} onChange={(e) => setPhone(e.target.value)} /></div>
          <div><label className="mb-1 block text-sm font-medium">Delivery address</label><Textarea value={address} onChange={(e) => setAddress(e.target.value)} rows={3} /></div>
          <div className="flex gap-2 pt-2"><Button onClick={save} className="bg-brand hover:bg-brand/90">Save</Button><Link to="/orders"><Button variant="outline">My orders</Button></Link><Button variant="outline" onClick={() => signOut()}>Sign out</Button></div>
        </Card>
      </main>
      <Footer />
    </div>
  );
}
