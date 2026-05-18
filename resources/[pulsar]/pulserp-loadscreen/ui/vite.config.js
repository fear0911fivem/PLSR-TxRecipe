import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "node:path";

export default defineConfig({
  plugins: [react()],
  base: "./",
  resolve: {
    alias: {
      containers: path.resolve(__dirname, "src/containers"),
      src: path.resolve(__dirname, "src"),
    },
  },
  build: {
    outDir: "html",
    emptyOutDir: true,
    assetsDir: "assets",
    sourcemap: false,
  },
});
