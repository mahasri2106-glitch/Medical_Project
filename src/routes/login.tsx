import { createFileRoute, useNavigate, Link } from "@tanstack/react-router";
import { useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card } from "@/components/ui/card";
import { Pill } from "lucide-react";
import { toast } from "sonner";

export const Route = createFileRoute("/login")({ component: Login });

function Login() {
  const nav = useNavigate();
  const [mode, setMode] = useState<"signin" | "signup">("signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const [loading, setLoading] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      if (mode === "signup") {
        const { error } = await supabase.auth.signUp({
          email, password,
          options: { data: { full_name: name }, emailRedirectTo: `${window.location.origin}/` },
        });
        if (error) throw error;
        toast.success("Account created! Check your email to verify.");
      } else {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
        toast.success("Welcome back!");
        nav({ to: "/" });
      }
    } catch (err) {
      toast.error((err as Error).message);
    } finally { setLoading(false); }
  };

  const google = async () => {
    const { lovable } = await import("@/integrations/lovable/index").catch(() => ({ lovable: null as never }));
    if (!lovable) { toast.error("Google sign-in not configured yet"); return; }
    await lovable.auth.signInWithOAuth("google", { redirect_uri: window.location.origin });
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-brand-soft to-background p-4">
      <Card className="w-full max-w-md p-8">
        <Link to="/" className="mb-6 flex items-center justify-center gap-2">
          <div className="flex size-10 items-center justify-center rounded-lg bg-brand text-brand-foreground"><Pill className="size-5" /></div>
          <span className="text-2xl font-bold text-brand">MedBill</span>
        </Link>
        <h1 className="mb-1 text-center text-xl font-bold">{mode === "signin" ? "Welcome back" : "Create account"}</h1>
        <p className="mb-6 text-center text-sm text-muted-foreground">{mode === "signin" ? "Login to continue" : "Sign up to start ordering"}</p>
        <form onSubmit={submit} className="space-y-3">
          {mode === "signup" && <Input placeholder="Full name" value={name} onChange={(e) => setName(e.target.value)} required />}
          <Input type="email" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} required />
          <Input type="password" placeholder="Password (min 6 chars)" value={password} onChange={(e) => setPassword(e.target.value)} minLength={6} required />
          <Button type="submit" className="w-full bg-brand hover:bg-brand/90" disabled={loading}>{loading ? "..." : mode === "signin" ? "Sign in" : "Create account"}</Button>
        </form>
        <Button variant="outline" className="mt-3 w-full" onClick={google}>Continue with Google</Button>
        <button className="mt-4 w-full text-sm text-brand" onClick={() => setMode(mode === "signin" ? "signup" : "signin")}>
          {mode === "signin" ? "New to MedBill? Create account" : "Already have an account? Sign in"}
        </button>
      </Card>
    </div>
  );
}
