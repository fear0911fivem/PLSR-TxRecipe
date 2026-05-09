import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  MenuItem,
  Chip,
  IconButton,
  CircularProgress,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { toast } from 'react-toastify';
import Nui from '../../util/Nui';

const ITEM_TYPES = {
  1: { label: 'Consumable', color: '#059669' },
  2: { label: 'Weapon', color: '#DC2626' },
  3: { label: 'Tool', color: '#2563EB' },
  4: { label: 'Crafting', color: '#D97706' },
  5: { label: 'Collectible', color: '#7C3AED' },
  6: { label: 'Junk', color: '#6B7280' },
  7: { label: 'Unknown', color: '#4B5563' },
  8: { label: 'Evidence', color: '#0891B2' },
  9: { label: 'Ammo', color: '#B45309' },
  10: { label: 'Container', color: '#6D28D9' },
  11: { label: 'Gem', color: '#DB2777' },
  12: { label: 'Paraphernalia', color: '#7C3AED' },
  13: { label: 'Wearable', color: '#0D9488' },
  14: { label: 'Contraband', color: '#DC2626' },
  15: { label: 'Gang Chain', color: '#B45309' },
  16: { label: 'Attachment', color: '#4B5563' },
  17: { label: 'Schematic', color: '#0891B2' },
};

const RARITY_CONFIG = {
  0: { label: null, color: null },
  1: { label: 'Common', color: '#94A3B8' },
  2: { label: 'Uncommon', color: '#10B981' },
  3: { label: 'Rare', color: '#3B82F6' },
  4: { label: 'Epic', color: '#A78BFA' },
  5: { label: 'Special', color: '#F59E0B' },
};

const useStyles = makeStyles((theme) => ({
  dialog: {
    '& .MuiDialog-paper': {
      background: theme.palette.secondary.main,
      border: `1px solid ${theme.palette.border.divider}`,
      borderRadius: 6,
      minWidth: 420,
    },
  },
  title: {
    background: theme.palette.secondary.dark,
    borderBottom: `1px solid ${theme.palette.border.divider}`,
    padding: '14px 16px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  titleText: {
    fontSize: 15,
    fontWeight: 700,
    color: theme.palette.text.main,
  },
  closeBtn: {
    padding: 6,
    borderRadius: 4,
    color: theme.palette.text.alt,
    '&:hover': {
      color: '#EF4444',
      background: 'rgba(239, 68, 68, 0.1)',
    },
  },
  content: {
    padding: '16px',
  },
  itemHeader: {
    display: 'flex',
    gap: 14,
    alignItems: 'center',
    marginBottom: 16,
    padding: 12,
    background: theme.palette.secondary.dark,
    border: `1px solid ${theme.palette.border.divider}`,
    borderRadius: 4,
  },
  imgBox: {
    width: 56,
    height: 56,
    borderRadius: 4,
    background: theme.palette.secondary.light,
    border: `1px solid ${theme.palette.border.divider}`,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    flexShrink: 0,
    overflow: 'hidden',
  },
  img: {
    width: '100%',
    height: '100%',
    objectFit: 'contain',
  },
  fallbackIcon: {
    color: '#2D2D40',
    fontSize: 22,
  },
  itemInfo: {
    flex: 1,
  },
  itemLabel: {
    fontSize: 15,
    fontWeight: 700,
    color: theme.palette.text.main,
    lineHeight: 1.3,
  },
  itemName: {
    fontSize: 11,
    color: theme.palette.text.info,
    letterSpacing: '0.04em',
    marginBottom: 6,
  },
  badges: {
    display: 'flex',
    gap: 4,
    flexWrap: 'wrap',
  },
  badge: {
    height: 18,
    fontSize: 10,
    fontWeight: 700,
    letterSpacing: '0.05em',
    borderRadius: 3,
  },
  statsRow: {
    display: 'flex',
    gap: 8,
    marginBottom: 14,
  },
  statBox: {
    flex: 1,
    padding: '8px 10px',
    background: theme.palette.secondary.dark,
    border: `1px solid ${theme.palette.border.divider}`,
    borderRadius: 4,
    textAlign: 'center',
  },
  statLabel: {
    display: 'block',
    fontSize: 10,
    letterSpacing: '0.08em',
    textTransform: 'uppercase',
    color: theme.palette.text.info,
    marginBottom: 3,
  },
  statValue: {
    display: 'block',
    fontSize: 14,
    fontWeight: 600,
    color: theme.palette.text.main,
  },
  field: {
    marginBottom: 12,
  },
  actions: {
    padding: '12px 16px',
    borderTop: `1px solid ${theme.palette.border.divider}`,
    display: 'flex',
    gap: 8,
    justifyContent: 'flex-end',
    background: theme.palette.secondary.dark,
  },
  selfBtn: {
    borderColor: `${theme.palette.primary.main}60`,
    color: theme.palette.primary.light,
    '&:hover': {
      borderColor: theme.palette.primary.main,
      background: 'rgba(124, 58, 237, 0.1)',
    },
  },
  giveBtn: {
    background: theme.palette.primary.main,
    color: '#fff',
    '&:hover': {
      background: theme.palette.primary.dark,
    },
    '&:disabled': {
      opacity: 0.4,
    },
  },
}));

export default ({ item, open, onClose, players }) => {
  const classes = useStyles();
  const [quantity, setQuantity] = useState(1);
  const [targetSource, setTargetSource] = useState('');
  const [loading, setLoading] = useState(false);
  const [imgFailed, setImgFailed] = useState(false);

  useEffect(() => {
    if (open) {
      setQuantity(1);
      setTargetSource('');
      setImgFailed(false);
    }
  }, [open, item]);

  if (!item) return null;

  const typeInfo = ITEM_TYPES[item.type] || ITEM_TYPES[7];
  const rarityInfo = RARITY_CONFIG[item.rarity] || RARITY_CONFIG[0];
  const imgSrc = `nui://ox_inventory/web/images/${item.name}.webp`;

  const handleGive = async (toSelf) => {
    if (!toSelf && !targetSource) {
      toast.error('Select a player first');
      return;
    }
    setLoading(true);
    try {
      const res = await (await Nui.send('GiveItem', {
        itemName: item.name,
        quantity: Math.max(1, Math.min(parseInt(quantity) || 1, 1000)),
        toSelf,
        targetSource: toSelf ? null : parseInt(targetSource),
      })).json();

      if (res && res.success) {
        toast.success(res.message || `Gave ${item.label} x${quantity}`);
        onClose();
      } else {
        toast.error(res?.message || 'Failed to give item');
      }
    } catch (e) {
      toast.error('Error giving item');
    }
    setLoading(false);
  };

  const selectedPlayer = players.find(p => p.Source === parseInt(targetSource));

  return (
    <Dialog open={open} onClose={onClose} className={classes.dialog}>
      <div className={classes.title}>
        <span className={classes.titleText}>Give Item</span>
        <IconButton className={classes.closeBtn} size="small" onClick={onClose}>
          <FontAwesomeIcon icon={['fas', 'xmark']} />
        </IconButton>
      </div>

      <div className={classes.content}>
        <div className={classes.itemHeader}>
          <div className={classes.imgBox}>
            {!imgFailed ? (
              <img
                src={imgSrc}
                className={classes.img}
                alt={item.label}
                onError={() => setImgFailed(true)}
              />
            ) : (
              <FontAwesomeIcon icon={['fas', 'box']} className={classes.fallbackIcon} />
            )}
          </div>
          <div className={classes.itemInfo}>
            <div className={classes.itemLabel}>{item.label}</div>
            <div className={classes.itemName}>{item.name}</div>
            <div className={classes.badges}>
              <Chip
                label={typeInfo.label}
                size="small"
                className={classes.badge}
                style={{ background: `${typeInfo.color}22`, color: typeInfo.color, border: `1px solid ${typeInfo.color}44` }}
              />
              {rarityInfo.label && (
                <Chip
                  label={rarityInfo.label}
                  size="small"
                  className={classes.badge}
                  style={{ background: `${rarityInfo.color}22`, color: rarityInfo.color, border: `1px solid ${rarityInfo.color}44` }}
                />
              )}
            </div>
          </div>
        </div>

        <div className={classes.statsRow}>
          <div className={classes.statBox}>
            <span className={classes.statLabel}>Weight</span>
            <span className={classes.statValue}>{item.weight ?? 0}g</span>
          </div>
          <div className={classes.statBox}>
            <span className={classes.statLabel}>Price</span>
            <span className={classes.statValue}>${(item.price ?? 0).toLocaleString()}</span>
          </div>
          <div className={classes.statBox}>
            <span className={classes.statLabel}>Stackable</span>
            <span className={classes.statValue}>
              {item.isStackable ? (typeof item.isStackable === 'number' ? item.isStackable : 'Yes') : 'No'}
            </span>
          </div>
        </div>

        <TextField
          select
          fullWidth
          label="Target Player"
          value={targetSource}
          onChange={(e) => setTargetSource(e.target.value)}
          className={classes.field}
          variant="outlined"
          size="small"
        >
          <MenuItem value="">— Select a player —</MenuItem>
          {players
            .filter(p => p.Character)
            .sort((a, b) => (a.Character?.First || '').localeCompare(b.Character?.First || ''))
            .map(p => (
              <MenuItem key={p.Source} value={p.Source}>
                {p.Character ? `${p.Character.First} ${p.Character.Last} (SID: ${p.Character.SID})` : p.Name}
              </MenuItem>
            ))}
        </TextField>

        <TextField
          fullWidth
          label="Quantity"
          type="number"
          variant="outlined"
          size="small"
          value={quantity}
          onChange={(e) => setQuantity(Math.max(1, Math.min(1000, parseInt(e.target.value) || 1)))}
          inputProps={{ min: 1, max: 1000 }}
        />
      </div>

      <div className={classes.actions}>
        <Button variant="outlined" size="small" className={classes.selfBtn} onClick={() => handleGive(true)} disabled={loading}>
          {loading ? <CircularProgress size={14} /> : 'Give to Self'}
        </Button>
        <Button
          variant="contained"
          size="small"
          className={classes.giveBtn}
          onClick={() => handleGive(false)}
          disabled={loading || !targetSource}
        >
          {loading ? <CircularProgress size={14} /> : selectedPlayer
            ? `Give to ${selectedPlayer.Character?.First ?? selectedPlayer.Name}`
            : 'Give to Player'}
        </Button>
      </div>
    </Dialog>
  );
};
