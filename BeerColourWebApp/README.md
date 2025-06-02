# Beer EBC Color Detector

A WebAssembly-powered web application that detects beer EBC (European Brewery Convention) color values from images using Rust and wasm-bindgen.

## Features

- Upload beer images from your device
- Use phone camera to capture beer photos directly
- Real-time EBC color analysis
- Beer color classification (Pale Straw to Black)
- Confidence scoring for accuracy assessment

## Setup

1. Install Rust and wasm-pack:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
```

2. Build the WebAssembly module:
```bash
npm run build
```

3. Serve the application:
```bash
npm run serve
```

4. Open http://localhost:8000 in your browser

## Development

```bash
npm run dev
```

This will build the WASM module and start a local server.

## EBC Color Scale

- 2-4: Pale Straw
- 4-6: Straw  
- 6-8: Pale Gold
- 8-12: Deep Gold
- 12-16: Pale Amber
- 16-20: Medium Amber
- 20-26: Deep Amber
- 26-33: Amber Brown
- 33-39: Brown
- 39-47: Ruby Brown
- 47-57: Deep Brown
- 57+: Black