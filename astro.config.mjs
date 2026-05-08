import { defineConfig } from "astro/config";

/** @see https://astro.build/config */
export default defineConfig({
  output: "static",
  compressHTML: true,
  // Set when you have a production URL (helps canonical / RSS later):
  // site: "https://opsforgelabs.in",
});
