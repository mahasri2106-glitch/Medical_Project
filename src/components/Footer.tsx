export function Footer() {
  return (
    <footer className="mt-16 border-t bg-muted/40">
      <div className="mx-auto max-w-7xl px-4 py-8 text-sm text-muted-foreground">
        <div className="grid gap-6 md:grid-cols-4">
          <div>
            <div className="mb-2 text-base font-bold text-brand">MedBill</div>
            <p>Your trusted online pharmacy & healthcare partner.</p>
          </div>
          <div><div className="mb-2 font-semibold text-foreground">Shop</div><ul className="space-y-1"><li>Medicines</li><li>Personal Care</li><li>Vitamins</li></ul></div>
          <div><div className="mb-2 font-semibold text-foreground">Services</div><ul className="space-y-1"><li>Doctors</li><li>Lab Tests</li><li>Health Records</li></ul></div>
          <div><div className="mb-2 font-semibold text-foreground">Help</div><ul className="space-y-1"><li>helpdesk@medbill.com</li><li>Privacy</li><li>Terms</li></ul></div>
        </div>
        <div className="mt-6 border-t pt-4 text-xs">© {new Date().getFullYear()} MedBill. All rights reserved.</div>
      </div>
    </footer>
  );
}
