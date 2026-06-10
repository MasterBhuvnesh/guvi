/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      fontFamily: {
        "product-sans": ["ProductSansRegular"],
        "product-sans-bold": ["ProductSansBold"],
      },
    },
  },
  plugins: [],
};
