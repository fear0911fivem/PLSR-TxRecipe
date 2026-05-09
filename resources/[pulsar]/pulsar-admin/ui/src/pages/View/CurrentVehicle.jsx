import React, { useEffect, useState } from 'react';
import { Button } from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import { toast } from 'react-toastify';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { round } from 'lodash';

import { Loader } from '../../components';
import Nui from '../../util/Nui';
import { useSelector } from 'react-redux';

const useStyles = makeStyles((theme) => ({
  wrapper: {
    padding: '20px 10px 20px 20px',
    height: '100%',
    overflowY: 'auto',
    boxSizing: 'border-box',
    display: 'flex',
    flexDirection: 'column',
    gap: 16,
  },
  sectionTitle: {
    display: 'flex',
    alignItems: 'center',
    gap: 8,
    fontSize: 11,
    fontWeight: 700,
    letterSpacing: '0.12em',
    textTransform: 'uppercase',
    color: theme.palette.text.info,
    marginBottom: 10,
    '&::before': {
      content: '""',
      display: 'inline-block',
      width: 3,
      height: 13,
      background: theme.palette.primary.main,
      borderRadius: 2,
    },
  },

  // ── Action bar ───────────────────────────────────────
  actionBar: {
    display: 'flex',
    gap: 8,
    flexWrap: 'wrap',
    flexShrink: 0,
  },
  actionBtn: {
    height: 34,
    fontSize: 12,
    fontWeight: 600,
    letterSpacing: '0.04em',
    padding: '0 14px',
    gap: 7,
  },
  dangerBtn: {
    height: 34,
    fontSize: 12,
    fontWeight: 600,
    letterSpacing: '0.04em',
    padding: '0 14px',
    gap: 7,
    color: '#F87171',
    borderColor: 'rgba(239,68,68,0.4)',
    '&:hover': {
      borderColor: '#F87171',
      background: 'rgba(239,68,68,0.08)',
    },
  },

  // ── Info grid ────────────────────────────────────────
  infoGrid: {
    display: 'grid',
    gridTemplateColumns: '1fr 1fr',
    gap: 12,
  },
  infoCard: {
    background: theme.palette.secondary.light,
    border: `1px solid ${theme.palette.border.divider}`,
    borderRadius: 4,
    padding: '14px 16px',
  },
  cardSectionTitle: {
    fontSize: 11,
    fontWeight: 700,
    letterSpacing: '0.1em',
    textTransform: 'uppercase',
    color: theme.palette.text.info,
    marginBottom: 10,
  },
  infoRow: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: '7px 0',
    borderBottom: `1px solid ${theme.palette.border.divider}`,
    '&:last-child': { borderBottom: 'none', paddingBottom: 0 },
    '&:first-child': { paddingTop: 0 },
  },
  infoLabel: {
    fontSize: 11,
    fontWeight: 600,
    letterSpacing: '0.05em',
    textTransform: 'uppercase',
    color: theme.palette.text.info,
  },
  infoValue: {
    fontSize: 12,
    fontWeight: 500,
    color: theme.palette.text.main,
    textAlign: 'right',
  },
  infoValueClickable: {
    fontSize: 12,
    fontWeight: 500,
    color: theme.palette.primary.light,
    textAlign: 'right',
    cursor: 'pointer',
    '&:hover': { textDecoration: 'underline' },
  },

  // ── Damage bars ──────────────────────────────────────
  damageRow: {
    padding: '7px 0',
    borderBottom: `1px solid ${theme.palette.border.divider}`,
    '&:last-child': { borderBottom: 'none' },
  },
  damageHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    marginBottom: 5,
  },
  damageLabel: {
    fontSize: 11,
    fontWeight: 600,
    letterSpacing: '0.05em',
    textTransform: 'uppercase',
    color: theme.palette.text.info,
  },
  damageValue: {
    fontSize: 11,
    fontWeight: 600,
    color: theme.palette.text.main,
  },
  errBanner: {
    padding: '12px 16px',
    background: 'rgba(239,68,68,0.08)',
    border: '1px solid rgba(239,68,68,0.25)',
    borderRadius: 4,
    color: '#F87171',
    fontSize: 13,
    fontWeight: 500,
    display: 'flex',
    alignItems: 'center',
    gap: 8,
  },
}));

const DamageBar = ({ label, value, max = 1000, classes }) => {
  const pct = Math.max(0, Math.min(100, (value / max) * 100));
  const color = pct >= 75 ? '#10B981' : pct >= 40 ? '#F59E0B' : '#EF4444';
  return (
    <div className={classes.damageRow}>
      <div className={classes.damageHeader}>
        <span className={classes.damageLabel}>{label}</span>
        <span className={classes.damageValue} style={{ color }}>{round(value, 0)}</span>
      </div>
      <div style={{ height: 4, borderRadius: 3, background: '#1A1A2E', overflow: 'hidden' }}>
        <div style={{ height: '100%', width: `${pct}%`, background: color, borderRadius: 3, transition: 'width 0.3s ease' }} />
      </div>
    </div>
  );
};

export default ({ match }) => {
  const classes = useStyles();
  const permissionLevel = useSelector((state) => state.app.permissionLevel);

  const [err, setErr] = useState(false);
  const [loading, setLoading] = useState(false);
  const [vehicle, setVehicle] = useState(null);

  const fetch = async () => {
    setLoading(true);
    try {
      const res = await (await Nui.send('GetCurrentVehicle', {})).json();
      if (res) setVehicle(res);
      else { toast.error('Not in a vehicle'); setErr(true); }
    } catch {
      toast.error('Unable to Load');
      setErr(true);
    }
    setLoading(false);
  };

  useEffect(() => { fetch(); }, []);

  const copyInfo = (data) => {
    Nui.copyClipboard(data);
    toast.success('Copied');
  };

  const onAction = async (action) => {
    try {
      const res = await (await Nui.send('CurrentVehicleAction', { action })).json();
      if (res?.success) toast.success(res.message);
      else toast.error(res?.message ?? 'Error');
    } catch { toast.error('Error'); }
  };

  if (loading || (!vehicle && !err)) {
    return (
      <div className={classes.wrapper} style={{ position: 'relative' }}>
        <Loader static text="Loading Vehicle" />
      </div>
    );
  }

  if (err) {
    return (
      <div className={classes.wrapper}>
        <div className={classes.errBanner}>
          <FontAwesomeIcon icon={['fas', 'circle-exclamation']} />
          Not in a vehicle or unable to load data.
        </div>
      </div>
    );
  }

  const coordStr = vehicle.Coords
    ? `vector3(${round(vehicle.Coords.x, 2)}, ${round(vehicle.Coords.y, 2)}, ${round(vehicle.Coords.z, 2)})`
    : '—';

  return (
    <div className={classes.wrapper}>
      {/* ── Actions ── */}
      <div>
        <div className={classes.sectionTitle}>Actions</div>
        <div className={classes.actionBar}>
          <Button variant="outlined" color="primary" size="small" className={classes.actionBtn} onClick={() => onAction('repair')}>
            <FontAwesomeIcon icon={['fas', 'wrench']} /> Quick Repair
          </Button>
          {permissionLevel >= 90 && (
            <>
              <Button variant="outlined" color="primary" size="small" className={classes.actionBtn} onClick={() => onAction('repair_full')}>
                <FontAwesomeIcon icon={['fas', 'screwdriver-wrench']} /> Full Repair
              </Button>
              <Button variant="outlined" color="primary" size="small" className={classes.actionBtn} onClick={() => onAction('repair_engine')}>
                <FontAwesomeIcon icon={['fas', 'gear']} /> Engine Repair
              </Button>
              <Button variant="outlined" color="primary" size="small" className={classes.actionBtn} onClick={() => onAction('fuel')}>
                <FontAwesomeIcon icon={['fas', 'gas-pump']} /> Refuel
              </Button>
              <Button variant="outlined" color="primary" size="small" className={classes.actionBtn} onClick={() => onAction('alarm')}>
                <FontAwesomeIcon icon={['fas', 'bell']} /> Toggle Alarm
              </Button>
              <Button variant="outlined" color="primary" size="small" className={classes.actionBtn} onClick={() => onAction('customs')}>
                <FontAwesomeIcon icon={['fas', 'paintbrush']} /> Customs
              </Button>
            </>
          )}
          <Button variant="outlined" size="small" className={classes.actionBtn} onClick={fetch}>
            <FontAwesomeIcon icon={['fas', 'rotate-right']} /> Refresh
          </Button>
          {permissionLevel >= 90 && (
            <Button variant="outlined" size="small" className={classes.dangerBtn} onClick={() => onAction('explode')}>
              <FontAwesomeIcon icon={['fas', 'explosion']} /> Explode
            </Button>
          )}
        </div>
      </div>

      {/* ── Info + Damage cards ── */}
      <div>
        <div className={classes.sectionTitle}>Vehicle Info</div>
        <div className={classes.infoGrid}>
          {/* Left — identity */}
          <div className={classes.infoCard}>
            <div className={classes.cardSectionTitle}>Identity</div>
            <div className={classes.infoRow}>
              <span className={classes.infoLabel}>Make / Model</span>
              <span className={classes.infoValue}>{vehicle.Make ?? 'Unknown'} {vehicle.Model ?? ''}</span>
            </div>
            <div className={classes.infoRow}>
              <span className={classes.infoLabel}>VIN</span>
              <span className={classes.infoValue} style={{ fontFamily: 'monospace', fontSize: 11 }}>{vehicle.VIN ?? '—'}</span>
            </div>
            <div className={classes.infoRow}>
              <span className={classes.infoLabel}>Plate</span>
              <span className={classes.infoValue} style={{ fontFamily: 'monospace', letterSpacing: '0.05em' }}>{vehicle.Plate ?? '—'}</span>
            </div>
            <div className={classes.infoRow}>
              <span className={classes.infoLabel}>Owned</span>
              <span className={classes.infoValue}>{vehicle.Owned ? `Yes — Owner ${vehicle.Owner?.Id ?? '?'}` : 'No'}</span>
            </div>
            <div className={classes.infoRow}>
              <span className={classes.infoLabel}>Est. Value</span>
              <span className={classes.infoValue}>${(vehicle.Value ?? 0).toLocaleString()}</span>
            </div>
            <div className={classes.infoRow}>
              <span className={classes.infoLabel}>Entity Model</span>
              <span
                className={classes.infoValueClickable}
                onClick={() => copyInfo(String(vehicle.EntityModel))}
              >
                {vehicle.EntityModel}
                <FontAwesomeIcon icon={['fas', 'copy']} style={{ marginLeft: 6, fontSize: 10 }} />
              </span>
            </div>
            <div className={classes.infoRow}>
              <span className={classes.infoLabel}>Coords</span>
              <span
                className={classes.infoValueClickable}
                onClick={() => copyInfo(coordStr)}
                style={{ fontSize: 11 }}
              >
                {round(vehicle.Coords?.x, 1)}, {round(vehicle.Coords?.y, 1)}, {round(vehicle.Coords?.z, 1)}
                <FontAwesomeIcon icon={['fas', 'copy']} style={{ marginLeft: 6, fontSize: 10 }} />
              </span>
            </div>
            <div className={classes.infoRow}>
              <span className={classes.infoLabel}>Heading</span>
              <span className={classes.infoValue}>{round(vehicle.Heading, 2)}°</span>
            </div>
            <div className={classes.infoRow}>
              <span className={classes.infoLabel}>Seat</span>
              <span className={classes.infoValue}>{vehicle.Seat === -1 ? 'Driver' : `Seat ${vehicle.Seat}`}</span>
            </div>
          </div>

          {/* Right — condition */}
          <div className={classes.infoCard}>
            <div className={classes.cardSectionTitle}>Condition</div>
            <DamageBar label="Fuel" value={vehicle.Fuel ?? 0} max={100} classes={classes} />
            <DamageBar label="Engine" value={vehicle.Damage?.Engine ?? 1000} classes={classes} />
            <DamageBar label="Body" value={vehicle.Damage?.Body ?? 1000} classes={classes} />
            {vehicle.DamagedParts && (
              <>
                <DamageBar label="Axle" value={vehicle.DamagedParts.Axle ?? 100} max={100} classes={classes} />
                <DamageBar label="Radiator" value={vehicle.DamagedParts.Radiator ?? 100} max={100} classes={classes} />
                <DamageBar label="Transmission" value={vehicle.DamagedParts.Transmission ?? 100} max={100} classes={classes} />
                <DamageBar label="Fuel Injectors" value={vehicle.DamagedParts.FuelInjectors ?? 100} max={100} classes={classes} />
                <DamageBar label="Brakes" value={vehicle.DamagedParts.Brakes ?? 100} max={100} classes={classes} />
                <DamageBar label="Clutch" value={vehicle.DamagedParts.Clutch ?? 100} max={100} classes={classes} />
                <DamageBar label="Electronics" value={vehicle.DamagedParts.Electronics ?? 100} max={100} classes={classes} />
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
