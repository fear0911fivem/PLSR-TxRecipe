//  Pulsar Characters UI — Theme Configuration
//  Edit this file to customise the look of the character selection, create, and spawn screens
//  After editing run:  bun run build

// -- Logo
// Drop your logo into src/assets/imgs/ and update the filename here
import logoFile from './assets/imgs/logo_pulsar.png';
export const LOGO = logoFile;

// -- Server identity
export const SERVER_NAME = 'Pulsar Framework';

// -- Accent colour
// This is the single colour used for all active indicators, borders, buttons, and highlights
export const ACCENT       = '#7c3aed';
export const ACCENT_HOVER = '#6d28d9';
export const ACCENT_DIM   = 'rgba(124,58,237,0.2)';

// Mantine brand scale
// 10 shades from lightest to darkest Shade [5] should match ACCENT
export const BRAND_COLORS = [
    '#f5f0ff', '#ede5ff', '#ddd0ff', '#c4a8ff',
    '#a78bfa', '#7c3aed', '#6d28d9', '#5b21b6',
    '#4c1d95', '#3b0764',
];

// Backgrounds
export const BG_BASE    = 'rgba(7,5,15,0.97)';   // main panel background
export const BG_CARD    = 'rgba(8,6,16,0.93)';   // character card (inactive)
export const BG_ACTIVE  = 'rgba(10,8,20,0.97)';  // character card (selected)
export const BG_INPUT   = 'rgba(5,4,12,0.8)';    // form input background
export const BG_SLOT    = 'rgba(14,12,24,0.45)'; // empty character slot

// ── Text colours
export const TEXT_PRIMARY   = '#c8c0dc'; // names, main content
export const TEXT_SECONDARY = '#5a5070'; // job, secondary info
export const TEXT_DIM       = '#3a3350'; // labels, hints
export const TEXT_FAINT     = '#221e30'; // SID, watermarks

// Border colours
export const BORDER_SUBTLE  = 'rgba(150,140,180,0.07)';
export const BORDER_DIM     = 'rgba(150,140,180,0.12)';

// Character card dimensions
export const CARD_WIDTH  = 196;
export const CARD_HEIGHT = 320;

// Spawn panel
export const SPAWN_PANEL_WIDTH = 300;

// Create panel
export const CREATE_PANEL_WIDTH = 660;
