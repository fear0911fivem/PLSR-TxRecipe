import React from 'react';
import { Chip } from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import { useHistory } from 'react-router';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

const useStyles = makeStyles((theme) => ({
  row: {
    display: 'flex',
    alignItems: 'center',
    gap: 12,
    padding: '10px 14px',
    background: theme.palette.secondary.light,
    border: `1px solid ${theme.palette.border.divider}`,
    borderRadius: 4,
    marginBottom: 6,
    cursor: 'pointer',
    transition: 'background ease-in 0.15s, border-color ease-in 0.15s',
    '&:hover': {
      background: 'rgba(124, 58, 237, 0.07)',
      borderColor: `${theme.palette.primary.main}50`,
    },
  },
  iconBox: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: 38,
    height: 38,
    borderRadius: 4,
    background: 'rgba(124, 58, 237, 0.1)',
    border: '1px solid rgba(124, 58, 237, 0.2)',
    color: theme.palette.primary.light,
    fontSize: 16,
    flexShrink: 0,
  },
  info: {
    flex: 1,
    display: 'flex',
    alignItems: 'center',
    gap: 16,
    minWidth: 0,
  },
  col: {
    flex: 1,
    minWidth: 0,
  },
  colLabel: {
    display: 'block',
    fontSize: 10,
    fontWeight: 700,
    letterSpacing: '0.08em',
    textTransform: 'uppercase',
    color: theme.palette.text.info,
    marginBottom: 2,
  },
  colValue: {
    display: 'block',
    fontSize: 13,
    fontWeight: 500,
    color: theme.palette.text.main,
    whiteSpace: 'nowrap',
    overflow: 'hidden',
    textOverflow: 'ellipsis',
  },
  ownerChip: {
    height: 20,
    fontSize: 10,
    fontWeight: 700,
    letterSpacing: '0.05em',
    borderRadius: 3,
    flexShrink: 0,
  },
  arrow: {
    color: theme.palette.text.info,
    fontSize: 12,
    flexShrink: 0,
  },
}));

export default ({ vehicle }) => {
  const classes = useStyles();
  const history = useHistory();

  const isPlayerOwned = typeof vehicle.OwnerId === 'number';

  return (
    <div className={classes.row} onClick={() => history.push(`/vehicle/${vehicle.Entity}`)}>
      <div className={classes.iconBox}>
        <FontAwesomeIcon icon={['fas', 'car']} />
      </div>
      <div className={classes.info}>
        <div className={classes.col} style={{ flex: 2 }}>
          <span className={classes.colLabel}>Make / Model</span>
          <span className={classes.colValue}>{vehicle.Make ?? 'Unknown'} {vehicle.Model ?? ''}</span>
        </div>
        <div className={classes.col}>
          <span className={classes.colLabel}>Plate</span>
          <span className={classes.colValue} style={{ fontFamily: 'monospace', letterSpacing: '0.05em' }}>
            {vehicle.Plate}
          </span>
        </div>
        <div className={classes.col} style={{ flex: 2 }}>
          <span className={classes.colLabel}>VIN</span>
          <span className={classes.colValue} style={{ fontFamily: 'monospace', fontSize: 11 }}>
            {vehicle.VIN}
          </span>
        </div>
        <div className={classes.col}>
          <span className={classes.colLabel}>Owner</span>
          <span className={classes.colValue}>{vehicle.OwnerId ?? 'Unowned'}</span>
        </div>
      </div>
      <Chip
        label={isPlayerOwned ? 'Owned' : 'Job / Temp'}
        size="small"
        className={classes.ownerChip}
        style={isPlayerOwned
          ? { background: 'rgba(5,150,105,0.15)', color: '#10B981', border: '1px solid rgba(5,150,105,0.3)' }
          : { background: 'rgba(100,116,139,0.15)', color: '#94A3B8', border: '1px solid rgba(100,116,139,0.3)' }
        }
      />
      <FontAwesomeIcon icon={['fas', 'chevron-right']} className={classes.arrow} />
    </div>
  );
};
