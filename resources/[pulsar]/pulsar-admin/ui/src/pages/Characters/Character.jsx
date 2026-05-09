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
    transition: 'background ease-in 0.15s, border-color ease-in 0.15s',
    '&:not($disabled)': {
      cursor: 'pointer',
      '&:hover': {
        background: 'rgba(124, 58, 237, 0.07)',
        borderColor: `${theme.palette.primary.main}50`,
      },
    },
  },
  disabled: {
    opacity: 0.45,
  },
  iconBox: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: 36,
    height: 36,
    borderRadius: 4,
    background: 'rgba(124, 58, 237, 0.1)',
    border: '1px solid rgba(124, 58, 237, 0.2)',
    color: theme.palette.primary.light,
    fontSize: 14,
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
  statusChip: {
    height: 20,
    fontSize: 10,
    fontWeight: 700,
    letterSpacing: '0.06em',
    borderRadius: 3,
    flexShrink: 0,
  },
  arrow: {
    color: theme.palette.text.info,
    fontSize: 12,
    flexShrink: 0,
  },
}));

export default ({ player }) => {
  const classes = useStyles();
  const history = useHistory();
  const isOnline = Boolean(player.Online);

  const onClick = () => {
    if (isOnline) history.push(`/player/${player.Online}`);
  };

  return (
    <div
      className={`${classes.row} ${!isOnline ? classes.disabled : ''}`}
      onClick={onClick}
    >
      <div className={classes.iconBox}>
        <FontAwesomeIcon icon={['fas', 'user']} />
      </div>
      <div className={classes.info}>
        <div className={classes.col}>
          <span className={classes.colLabel}>State ID</span>
          <span className={classes.colValue}>{player.SID}</span>
        </div>
        <div className={classes.col} style={{ flex: 2 }}>
          <span className={classes.colLabel}>Character Name</span>
          <span className={classes.colValue}>{player.First} {player.Last}</span>
        </div>
        <div className={classes.col} style={{ flex: 2 }}>
          <span className={classes.colLabel}>User</span>
          <span className={classes.colValue}>{player.User ?? '—'}</span>
        </div>
      </div>
      <Chip
        label={isOnline ? 'Online' : 'Offline'}
        size="small"
        className={classes.statusChip}
        style={isOnline
          ? { background: 'rgba(5, 150, 105, 0.15)', color: '#10B981', border: '1px solid rgba(5, 150, 105, 0.3)' }
          : { background: 'rgba(100, 116, 139, 0.15)', color: '#94A3B8', border: '1px solid rgba(100, 116, 139, 0.3)' }
        }
      />
      {isOnline && (
        <FontAwesomeIcon icon={['fas', 'chevron-right']} className={classes.arrow} />
      )}
    </div>
  );
};
