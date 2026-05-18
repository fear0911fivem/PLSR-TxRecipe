/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {
      colors: {
        brand: {
          main: "#1C8292",
          light: "#44AABA",
          dark: "#005A6A",
        },
      },
      boxShadow: {
        "brand-main": "0 8px 24px rgba(28, 130, 146, 0.25)",
        "brand-main-sm": "0 4px 12px rgba(28, 130, 146, 0.20)",
      },
      keyframes: {
        "dot-bounce": {
          "0%, 80%, 100%": { transform: "translateY(0)", opacity: "0.45" },
          "40%": { transform: "translateY(-4px)", opacity: "1" },
        },
        "soft-float": {
          "0%, 100%": { transform: "translateY(0)" },
          "50%": { transform: "translateY(-6px)" },
        },
        blink: {
          "0%, 100%": { opacity: "1" },
          "50%": { opacity: "0" },
        },
      },
      animation: {
        "dot-1": "dot-bounce 1.2s infinite",
        "dot-2": "dot-bounce 1.2s infinite 0.15s",
        "dot-3": "dot-bounce 1.2s infinite 0.3s",
        "soft-float": "soft-float 6s ease-in-out infinite",
        blink: "blink 1s steps(1) infinite",
      },
    },
  },
  plugins: [],
};
