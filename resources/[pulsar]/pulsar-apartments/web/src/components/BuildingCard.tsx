import { useState } from 'react';
import type { Building } from '../types';

interface Props {
  building: Building;
  disabled: boolean;
  onSelect: (buildingName: string) => void;
}

const BedIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.8}>
    <path d="M3 9v9M21 9v9M3 13h18M7 13V9a2 2 0 012-2h6a2 2 0 012 2v4" />
    <rect x="3" y="18" width="18" height="2" rx="1" />
  </svg>
);

const ClockIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.8}>
    <circle cx="12" cy="12" r="9" />
    <path d="M12 7v5l3 3" />
  </svg>
);

const CardIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.8}>
    <rect x="2" y="5" width="20" height="14" rx="2" />
    <path d="M2 10h20" />
  </svg>
);

const FallbackIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={0.8} style={{ width: 64, height: 64, opacity: 0.2 }}>
    <rect x="2" y="6" width="20" height="16" rx="1" />
    <path d="M2 10h20M8 6V4a2 2 0 014 0v2M12 6V4" />
    <path d="M6 14h.01M10 14h.01M14 14h.01M18 14h.01" strokeWidth={1.5} strokeLinecap="round" />
  </svg>
);

function availabilityLabel(count: number): { text: string; color: string; bg: string; border: string } {
  if (count === 0)  return { text: 'FULL',       color: '#e05050', bg: 'rgba(220,60,60,0.12)',   border: 'rgba(220,60,60,0.35)' };
  if (count <= 3)   return { text: `${count} LEFT`, color: '#ffa032', bg: 'rgba(255,160,50,0.12)', border: 'rgba(255,160,50,0.35)' };
  return              { text: `${count} AVAILABLE`, color: '#3ecf75', bg: 'rgba(62,207,117,0.12)', border: 'rgba(62,207,117,0.35)' };
}

export default function BuildingCard({ building, disabled, onSelect }: Props) {
  const [imgError, setImgError] = useState(false);
  const avail = availabilityLabel(building.count);
  const unavailable = building.count === 0;

  return (
    <div
      style={{
        background: '#111117',
        border: '1px solid rgba(255,255,255,0.07)',
        borderRadius: 14,
        width: 300,
        display: 'flex',
        flexDirection: 'column',
        overflow: 'hidden',
        boxShadow: '0 4px 24px rgba(0,0,0,0.55)',
        transition: 'transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease',
        opacity: unavailable ? 0.5 : 1,
        flexShrink: 0,
      }}
      onMouseEnter={e => {
        if (unavailable) return;
        (e.currentTarget as HTMLDivElement).style.transform = 'translateY(-5px)';
        (e.currentTarget as HTMLDivElement).style.boxShadow = '0 10px 40px rgba(0,0,0,0.8), 0 0 0 1px rgba(167,139,250,0.4)';
        (e.currentTarget as HTMLDivElement).style.borderColor = 'rgba(167,139,250,0.4)';
      }}
      onMouseLeave={e => {
        (e.currentTarget as HTMLDivElement).style.transform = 'none';
        (e.currentTarget as HTMLDivElement).style.boxShadow = '0 4px 24px rgba(0,0,0,0.55)';
        (e.currentTarget as HTMLDivElement).style.borderColor = 'rgba(255,255,255,0.07)';
      }}
    >
      {/* Image area */}
      <div style={{ position: 'relative', height: 190, background: '#0a0a12', overflow: 'hidden' }}>
        {!imgError ? (
          <img
            src={`./buildings/${building.buildingName}.png`}
            alt={building.label}
            onError={() => setImgError(true)}
            style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block', transition: 'transform 0.4s ease' }}
            onMouseEnter={e => { if (!unavailable) (e.currentTarget as HTMLImageElement).style.transform = 'scale(1.05)'; }}
            onMouseLeave={e => { (e.currentTarget as HTMLImageElement).style.transform = 'none'; }}
          />
        ) : (
          <div style={{ width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'linear-gradient(135deg,#0d0d18,#121220,#0a0a14)' }}>
            <FallbackIcon />
          </div>
        )}

        {/* Bottom fade */}
        <div style={{ position: 'absolute', bottom: 0, left: 0, right: 0, height: 70, background: 'linear-gradient(to top, #111117, transparent)', pointerEvents: 'none' }} />

        {/* Availability badge */}
        <div style={{
          position: 'absolute', top: 10, right: 10,
          background: avail.bg, border: `1px solid ${avail.border}`, color: avail.color,
          fontSize: 10, fontWeight: 700, letterSpacing: '0.08em',
          padding: '4px 10px', borderRadius: 20,
          backdropFilter: 'blur(6px)',
        }}>
          {avail.text}
        </div>
      </div>

      {/* Body */}
      <div style={{ padding: '18px 20px 20px', display: 'flex', flexDirection: 'column', gap: 14, flex: 1 }}>
        <div style={{ fontSize: 17, fontWeight: 700, color: '#f0f0f0', letterSpacing: '-0.01em', lineHeight: 1.2 }}>
          {building.label}
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {[
            { icon: <BedIcon />, text: `${building.count} room${building.count !== 1 ? 's' : ''} available` },
            { icon: <ClockIcon />, text: 'Immediate move-in' },
            { icon: <CardIcon />, text: '$2,000 / week' },
          ].map(({ icon, text }, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 12, color: '#888896' }}>
              <span style={{ width: 14, height: 14, color: '#a78bfa', opacity: 0.85, flexShrink: 0, display: 'flex' }}>{icon}</span>
              {text}
            </div>
          ))}
        </div>

        <button
          disabled={disabled || unavailable}
          onClick={() => onSelect(building.buildingName)}
          style={{
            marginTop: 'auto',
            width: '100%',
            padding: '11px 0',
            background: 'linear-gradient(135deg, #8b6ef7 0%, #a78bfa 50%, #8b6ef7 100%)',
            backgroundSize: '200% 100%',
            border: 'none',
            borderRadius: 8,
            color: '#ffffff',
            fontSize: 13,
            fontWeight: 800,
            letterSpacing: '0.08em',
            textTransform: 'uppercase',
            cursor: disabled || unavailable ? 'not-allowed' : 'pointer',
            opacity: disabled || unavailable ? 0.45 : 1,
            transition: 'opacity 0.2s ease, transform 0.15s ease, box-shadow 0.2s ease',
            fontFamily: 'inherit',
          }}
          onMouseEnter={e => {
            if (!disabled && !unavailable) {
              (e.currentTarget as HTMLButtonElement).style.boxShadow = '0 4px 20px rgba(167,139,250,0.45)';
              (e.currentTarget as HTMLButtonElement).style.transform = 'scale(1.01)';
            }
          }}
          onMouseLeave={e => {
            (e.currentTarget as HTMLButtonElement).style.boxShadow = 'none';
            (e.currentTarget as HTMLButtonElement).style.transform = 'none';
          }}
        >
          Select Building
        </button>
      </div>
    </div>
  );
}
