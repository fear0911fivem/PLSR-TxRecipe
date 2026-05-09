import { useState, useCallback } from 'react';
import { useNuiMessage } from './hooks/useNuiMessage';
import { fetchNui, isEnvBrowser } from './lib/nui';
import BuildingCard from './components/BuildingCard';
import type { Building, NuiAction, SelectResult } from './types';

const DEV_BUILDINGS: Building[] = [
  { buildingName: 'nexus_apartment_block_1', label: 'La Putura - Building 1', count: 34 },
  { buildingName: 'nexus_apartment_block_2', label: 'La Putura - Building 2', count: 12 },
  { buildingName: 'map_wiwang_hotel',        label: 'Wiwang Hotel',           count: 3  },
];

const BuildingIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.4} style={{ width: 22, height: 22 }}>
    <path d="M3 9.75L12 3l9 6.75V21a1 1 0 01-1 1H4a1 1 0 01-1-1V9.75z" />
    <path d="M9 22V12h6v10" />
  </svg>
);

export default function App() {
  const [visible,  setVisible]  = useState(isEnvBrowser());
  const [loading,  setLoading]  = useState(false);
  const [buildings, setBuildings] = useState<Building[]>(isEnvBrowser() ? DEV_BUILDINGS : []);

  useNuiMessage<NuiAction>('show', useCallback((data) => {
    if (data.action === 'show') {
      setBuildings(data.buildings ?? []);
      setLoading(false);
      setVisible(true);
    }
  }, []));

  useNuiMessage<NuiAction>('hide', useCallback((data) => {
    if (data.action === 'hide') {
      setVisible(false);
      setLoading(false);
    }
  }, []));

  const handleSelect = async (buildingName: string) => {
    setLoading(true);
    try {
      const result = await fetchNui<SelectResult>('selectBuilding', { buildingName });
      if (!result.success) {
        setLoading(false);
      }
      // On success, Lua closes the NUI via 'hide' message and handles teleport
    } catch {
      setLoading(false);
    }
  };

  if (!visible) return null;

  return (
    <div style={{
      position: 'fixed', inset: 0,
      background: 'rgba(4,4,6,0.9)',
      backdropFilter: 'blur(6px)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontFamily: "'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif",
      zIndex: 100,
    }}>

      {/* Loading overlay */}
      {loading && (
        <div style={{
          position: 'absolute', inset: 0,
          background: 'rgba(4,4,6,0.92)',
          display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
          gap: 18, zIndex: 10,
        }}>
          <div style={{
            width: 40, height: 40,
            border: '3px solid rgba(167,139,250,0.15)',
            borderTopColor: '#a78bfa',
            borderRadius: '50%',
            animation: 'spin 0.8s linear infinite',
          }} />
          <div style={{ fontSize: 14, color: '#888896', letterSpacing: '0.06em' }}>
            Assigning your room&hellip;
          </div>
        </div>
      )}

      {/* Main panel */}
      <div style={{
        background: '#0c0c10',
        border: '1px solid rgba(167,139,250,0.16)',
        borderRadius: 16,
        width: 'min(1080px, 94vw)',
        maxHeight: '92vh',
        overflowY: 'auto',
        padding: '32px 36px 28px',
        display: 'flex', flexDirection: 'column', gap: 28,
        boxShadow: '0 24px 80px rgba(0,0,0,0.8), 0 0 0 1px rgba(255,255,255,0.025)',
      }}>

        {/* Header */}
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 24 }}>

          {/* Brand */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, flexShrink: 0, minWidth: 185 }}>
            <div style={{
              width: 42, height: 42, flexShrink: 0,
              background: 'rgba(201,162,74,0.12)',
              border: '1px solid rgba(201,162,74,0.28)',
              borderRadius: 10,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: '#a78bfa',
            }}>
              <BuildingIcon />
            </div>
            <div>
              <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: '0.13em', color: '#a78bfa', lineHeight: 1 }}>
                DYNASTY 8 REAL ESTATE
              </div>
              <div style={{ fontSize: 10, color: '#444455', marginTop: 4, letterSpacing: '0.02em' }}>
                Premium Residential Leasing
              </div>
            </div>
          </div>

          {/* Title */}
          <div style={{ flex: 1, textAlign: 'center' }}>
            <h1 style={{ fontSize: 26, fontWeight: 700, color: '#f0f0f0', letterSpacing: '-0.02em', margin: 0 }}>
              Select Your Home
            </h1>
            <p style={{ fontSize: 13, color: '#777785', marginTop: 7, lineHeight: 1.5, maxWidth: 500, marginLeft: 'auto', marginRight: 'auto' }}>
              Thank you for choosing Dynasty 8! Select your preferred residence below and we'll have you settled in right away.
            </p>
          </div>

          {/* Rent badge */}
          <div style={{
            flexShrink: 0, minWidth: 130, textAlign: 'right',
            border: '1px solid rgba(167,139,250,0.18)',
            borderRadius: 10, padding: '12px 16px',
            background: 'rgba(167,139,250,0.08)',
          }}>
            <div style={{ fontSize: 9, fontWeight: 700, letterSpacing: '0.14em', color: '#a78bfa' }}>WEEKLY RENT</div>
            <div style={{ fontSize: 22, fontWeight: 800, color: '#f0f0f0', lineHeight: 1.1, marginTop: 4 }}>$2,000</div>
            <div style={{ fontSize: 10, color: '#444455', marginTop: 3 }}>auto-charged to bank</div>
          </div>
        </div>

        {/* Divider */}
        <div style={{ height: 1, background: 'linear-gradient(90deg,transparent,rgba(167,139,250,0.18),transparent)' }} />

        {/* Building cards */}
        <div style={{ display: 'flex', gap: 20, justifyContent: 'center', flexWrap: 'wrap' }}>
          {buildings.length === 0 ? (
            <div style={{ color: '#555560', fontSize: 14, padding: '40px 0', textAlign: 'center', width: '100%' }}>
              No apartments are currently available.
            </div>
          ) : (
            buildings.map(b => (
              <BuildingCard
                key={b.buildingName}
                building={b}
                disabled={loading}
                onSelect={handleSelect}
              />
            ))
          )}
        </div>

        {/* Footer */}
        <div style={{
          textAlign: 'center', fontSize: 11, color: '#3a3a45',
          letterSpacing: '0.03em', paddingTop: 4,
          borderTop: '1px solid rgba(255,255,255,0.04)',
        }}>
          All units include private stash storage &bull; Wardrobe &bull; En-suite shower &bull; Secure key-card access
        </div>
      </div>

      <style>{`
        @keyframes spin { to { transform: rotate(360deg); } }
        ::-webkit-scrollbar { width: 4px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: rgba(167,139,250,0.2); border-radius: 2px; }
      `}</style>
    </div>
  );
}
