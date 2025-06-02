use wasm_bindgen::prelude::*;

#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

#[wasm_bindgen]
extern "C" {
    fn alert(s: &str);
}

#[wasm_bindgen]
pub fn greet(name: &str) {
    alert(&format!("Hello, {}!", name));
}

#[wasm_bindgen]
pub struct EbcResult {
    ebc_value: f64,
    color_name: String,
    confidence: f64,
}

#[wasm_bindgen]
impl EbcResult {
    #[wasm_bindgen(getter)]
    pub fn ebc_value(&self) -> f64 {
        self.ebc_value
    }

    #[wasm_bindgen(getter)]
    pub fn color_name(&self) -> String {
        self.color_name.clone()
    }

    #[wasm_bindgen(getter)]
    pub fn confidence(&self) -> f64 {
        self.confidence
    }
}

#[wasm_bindgen]
pub fn detect_ebc_from_image_data(data: &[u8]) -> Result<EbcResult, JsValue> {
    console_error_panic_hook::set_once();
    
    let img = image::load_from_memory(data)
        .map_err(|e| JsValue::from_str(&format!("Failed to load image: {}", e)))?;
    
    let rgb_img = img.to_rgb8();
    let (width, height) = rgb_img.dimensions();
    
    let mut total_r = 0u64;
    let mut total_g = 0u64;
    let mut total_b = 0u64;
    let pixel_count = (width * height) as u64;
    
    for pixel in rgb_img.pixels() {
        total_r += pixel[0] as u64;
        total_g += pixel[1] as u64;
        total_b += pixel[2] as u64;
    }
    
    let avg_r = (total_r / pixel_count) as f64;
    let avg_g = (total_g / pixel_count) as f64;
    let avg_b = (total_b / pixel_count) as f64;
    
    let ebc_value = calculate_ebc_from_rgb(avg_r, avg_g, avg_b);
    let color_name = get_beer_color_name(ebc_value);
    let confidence = calculate_confidence(avg_r, avg_g, avg_b);
    
    Ok(EbcResult {
        ebc_value,
        color_name,
        confidence,
    })
}

fn calculate_ebc_from_rgb(r: f64, g: f64, b: f64) -> f64 {
    let luminance = 0.299 * r + 0.587 * g + 0.114 * b;
    let normalized_luminance = luminance / 255.0;
    
    if normalized_luminance > 0.9 {
        2.0
    } else if normalized_luminance < 0.1 {
        80.0
    } else {
        let lightness = 1.0 - normalized_luminance;
        2.0 + (lightness * 78.0)
    }
}

fn get_beer_color_name(ebc: f64) -> String {
    match ebc {
        x if x <= 4.0 => "Pale Straw".to_string(),
        x if x <= 6.0 => "Straw".to_string(),
        x if x <= 8.0 => "Pale Gold".to_string(),
        x if x <= 12.0 => "Deep Gold".to_string(),
        x if x <= 16.0 => "Pale Amber".to_string(),
        x if x <= 20.0 => "Medium Amber".to_string(),
        x if x <= 26.0 => "Deep Amber".to_string(),
        x if x <= 33.0 => "Amber Brown".to_string(),
        x if x <= 39.0 => "Brown".to_string(),
        x if x <= 47.0 => "Ruby Brown".to_string(),
        x if x <= 57.0 => "Deep Brown".to_string(),
        _ => "Black".to_string(),
    }
}

fn calculate_confidence(r: f64, g: f64, b: f64) -> f64 {
    let color_saturation = ((r - g).abs() + (g - b).abs() + (r - b).abs()) / 3.0 / 255.0;
    let brightness = (r + g + b) / 3.0 / 255.0;
    
    let saturation_score = if color_saturation > 0.1 { 0.8 } else { 0.95 };
    let brightness_score = if brightness > 0.1 && brightness < 0.9 { 0.9 } else { 0.7 };
    
    saturation_score * brightness_score
}