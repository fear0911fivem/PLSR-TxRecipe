import React, { useState } from 'react';
import { makeStyles } from '@material-ui/styles';
import { Chip } from '@material-ui/core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

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
  card: {
    display: 'flex',
    flexDirection: 'column',
    background: theme.palette.secondary.light,
    border: `1px solid ${theme.palette.border.divider}`,
    borderRadius: 6,
    cursor: 'pointer',
    transition: 'background ease-in 0.15s, border-color ease-in 0.15s, transform ease-in 0.1s',
    overflow: 'hidden',
    '&:hover': {
      background: 'rgba(124, 58, 237, 0.07)',
      borderColor: `${theme.palette.primary.main}60`,
      transform: 'translateY(-1px)',
    },
  },
  imgArea: {
    position: 'relative',
    width: '100%',
    height: 68,
    flexShrink: 0,
    background: theme.palette.secondary.main,
    borderBottom: `1px solid ${theme.palette.border.divider}`,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  },
  img: {
    width: '100%',
    height: '100%',
    objectFit: 'contain',
    padding: 8,
    boxSizing: 'border-box',
  },
  fallbackWrap: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: '100%',
    height: '100%',
  },
  fallbackIcon: {
    color: '#2D2D40',
    fontSize: 28,
  },
  rarityBar: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: 3,
  },
  body: {
    padding: '8px 10px 10px',
    flex: 1,
    display: 'flex',
    flexDirection: 'column',
    gap: 5,
  },
  label: {
    fontSize: 12,
    fontWeight: 600,
    color: theme.palette.text.main,
    whiteSpace: 'nowrap',
    overflow: 'hidden',
    textOverflow: 'ellipsis',
    lineHeight: 1.3,
  },
  name: {
    fontSize: 10,
    color: theme.palette.text.info,
    letterSpacing: '0.02em',
    whiteSpace: 'nowrap',
    overflow: 'hidden',
    textOverflow: 'ellipsis',
  },
  badges: {
    display: 'flex',
    gap: 4,
    flexWrap: 'wrap',
    marginTop: 2,
  },
  badge: {
    height: 16,
    fontSize: 9,
    fontWeight: 700,
    letterSpacing: '0.05em',
    borderRadius: 3,
  },
}));

export default ({ item, onClick }) => {
  const classes = useStyles();
  const [imgFailed, setImgFailed] = useState(false);

  const imgSrc = `nui://ox_inventory/web/images/${item.name}.webp`;
  const typeInfo = ITEM_TYPES[item.type] || ITEM_TYPES[7];
  const rarityInfo = RARITY_CONFIG[item.rarity] || RARITY_CONFIG[0];

  return (
    <div className={classes.card} onClick={() => onClick(item)}>
      <div className={classes.imgArea}>
        {!imgFailed ? (
          <img
            src={imgSrc}
            className={classes.img}
            alt={item.label}
            onError={() => setImgFailed(true)}
          />
        ) : (
          <div className={classes.fallbackWrap}>
            <FontAwesomeIcon icon={['fas', 'box']} className={classes.fallbackIcon} />
          </div>
        )}
        {rarityInfo.color && (
          <div
            className={classes.rarityBar}
            style={{ background: rarityInfo.color }}
          />
        )}
      </div>
      <div className={classes.body}>
        <div className={classes.label}>{item.label}</div>
        <div className={classes.name}>{item.name}</div>
        <div className={classes.badges}>
          {typeInfo.label !== 'Unknown' && (
            <Chip
              label={typeInfo.label}
              size="small"
              className={classes.badge}
              style={{ background: `${typeInfo.color}22`, color: typeInfo.color, border: `1px solid ${typeInfo.color}44` }}
            />
          )}
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
  );
};
