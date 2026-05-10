// Reads a prescription image with Lovable AI and returns extracted medicines.
import "https://deno.land/x/xhr@0.1.0/mod.ts";
import { serve } from "https://deno.land/std@0.190.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });
  try {
    const { imageBase64 } = await req.json();
    if (!imageBase64) return new Response(JSON.stringify({ error: "imageBase64 required" }), { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } });

    const apiKey = Deno.env.get("LOVABLE_API_KEY");
    if (!apiKey) throw new Error("LOVABLE_API_KEY missing");

    const res = await fetch("https://ai.gateway.lovable.dev/v1/chat/completions", {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${apiKey}` },
      body: JSON.stringify({
        model: "google/gemini-2.5-flash",
        messages: [
          { role: "system", content: "You are a pharmacy assistant. Extract medicines from prescription images. Always respond with the structured tool call." },
          { role: "user", content: [
            { type: "text", text: "Extract every medicine from this prescription. Return name, dosage (strength + frequency) and duration when visible." },
            { type: "image_url", image_url: { url: imageBase64 } },
          ]},
        ],
        tools: [{
          type: "function",
          function: {
            name: "extract_medicines",
            description: "Return the medicines parsed from the prescription.",
            parameters: {
              type: "object",
              properties: {
                medicines: {
                  type: "array",
                  items: { type: "object", properties: {
                    name: { type: "string" }, dosage: { type: "string" }, duration: { type: "string" },
                  }, required: ["name"] },
                },
                notes: { type: "string", description: "Doctor notes or warnings, optional" },
              },
              required: ["medicines"],
            },
          },
        }],
        tool_choice: { type: "function", function: { name: "extract_medicines" } },
      }),
    });

    if (!res.ok) {
      const t = await res.text();
      if (res.status === 429) return new Response(JSON.stringify({ error: "Rate limit. Try again shortly." }), { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } });
      if (res.status === 402) return new Response(JSON.stringify({ error: "AI credits exhausted. Add credits in workspace." }), { status: 402, headers: { ...corsHeaders, "Content-Type": "application/json" } });
      throw new Error(`AI gateway: ${res.status} ${t}`);
    }

    const data = await res.json();
    const args = data.choices?.[0]?.message?.tool_calls?.[0]?.function?.arguments;
    const parsed = args ? JSON.parse(args) : { medicines: [] };
    return new Response(JSON.stringify(parsed), { headers: { ...corsHeaders, "Content-Type": "application/json" } });
  } catch (e) {
    return new Response(JSON.stringify({ error: (e as Error).message }), { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } });
  }
});
