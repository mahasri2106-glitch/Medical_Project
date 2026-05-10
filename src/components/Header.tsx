import { Link, useNavigate } from "@tanstack/react-router";
import { ShoppingCart, MapPin, User, LogOut, Search, Pill } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useAuth } from "@/lib/auth-context";
import { useCart } from "@/lib/cart-context";

export function Header() {
  const { user, signOut } = useAuth();
  const { count } = useCart();
  const navigate = useNavigate();

  return (
    <header className="sticky top-0 z-40 w-full border-b bg-background/95 backdrop-blur">
      <div className="mx-auto flex max-w-7xl items-center gap-4 px-4 py-3">
        <Link to="/" className="flex items-center gap-2 shrink-0">
          <div className="flex size-9 items-center justify-center rounded-lg bg-brand text-brand-foreground">
            <Pill className="size-5" />
          </div>
          <div className="flex flex-col leading-tight">
            <span className="text-lg font-bold text-brand">MedBill</span>
            <span className="hidden text-[10px] text-muted-foreground sm:block">Online Doctor & Medicines</span>
          </div>
        </Link>

        <button className="hidden items-center gap-1.5 text-xs md:flex" onClick={() => navigate({ to: "/profile" })}>
          <MapPin className="size-4 text-brand" />
          <span className="text-muted-foreground">Deliver to</span>
          <span className="font-medium">Select Address</span>
        </button>

        <form
          className="relative flex-1 max-w-xl"
          onSubmit={(e) => {
            e.preventDefault();
            const q = (e.currentTarget.elements.namedItem("q") as HTMLInputElement).value;
            navigate({ to: "/medicines", search: { q } as never });
          }}
        >
          <Search className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
          <Input name="q" placeholder="Search Medicines" className="pl-9" />
        </form>

        <Link to="/cart" className="relative">
          <Button variant="ghost" size="icon"><ShoppingCart className="size-5" /></Button>
          {count > 0 && (
            <span className="absolute -right-1 -top-1 flex size-5 items-center justify-center rounded-full bg-brand text-[10px] font-bold text-brand-foreground">{count}</span>
          )}
        </Link>

        {user ? (
          <div className="flex items-center gap-1">
            <Button variant="ghost" size="icon" onClick={() => navigate({ to: "/profile" })}><User className="size-5" /></Button>
            <Button variant="ghost" size="icon" onClick={() => signOut()}><LogOut className="size-5" /></Button>
          </div>
        ) : (
          <Link to="/login"><Button variant="default">Login</Button></Link>
        )}
      </div>

      <nav className="border-t">
        <div className="mx-auto flex max-w-7xl gap-1 overflow-x-auto px-4 py-2 text-sm">
          {[
            { to: "/medicines", label: "Buy Medicines" },
            { to: "/doctors", label: "Find Doctors" },
            { to: "/lab-tests", label: "Lab Tests" },
            { to: "/circle", label: "Circle Membership" },
            { to: "/health-records", label: "Health Records" },
            { to: "/insurance", label: "Buy Insurance", badge: "New" },
            { to: "/prescription", label: "Prescription Reader", badge: "AI" },
          ].map((l) => (
            <Link key={l.to} to={l.to} className="flex shrink-0 items-center gap-1.5 rounded-md px-3 py-1.5 hover:bg-accent">
              {l.label}
              {l.badge && <span className="rounded bg-brand px-1.5 py-0.5 text-[9px] font-bold text-brand-foreground">{l.badge}</span>}
            </Link>
          ))}
        </div>
      </nav>
    </header>
  );
}
