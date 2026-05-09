import React from 'react';
import { Chip } from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import { useHistory } from 'react-router-dom';
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
  idBadge: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    minWidth: 42,
    height: 28,
    borderRadius: 4,
    padding: '0 8px',
    background: 'rgba(124, 58, 237, 0.12)',
    border: '1px solid rgba(124, 58, 237, 0.25)',
    fontSize: 11,
    fontWeight: 700,
    color: theme.palette.primary.light,
    flexShrink: 0,
    whiteSpace: 'nowrap',
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

export default ({ doorlock }) => {
  const classes = useStyles();
  const history = useHistory();

  const isLocked = doorlock.state === 1;
  const coordStr = doorlock.coords
    ? `${doorlock.coords.x.toFixed(1)}, ${doorlock.coords.y.toFixed(1)}, ${doorlock.coords.z.toFixed(1)}`
    : '—';
  const groupStr = doorlock.groups && Object.keys(doorlock.groups).length > 0
    ? Object.keys(doorlock.groups).join(', ')
    : 'No groups';

  return (
    <div className={classes.row} onClick={() => history.push(`/doorlock/${doorlock.id}`)}>
      <div className={classes.idBadge}>#{doorlock.id}</div>
      <div className={classes.info}>
        <div className={classes.col} style={{ flex: 2 }}>
          <span className={classes.colLabel}>Name</span>
          <span className={classes.colValue}>{doorlock.name}</span>
        </div>
        <div className={classes.col} style={{ flex: 2 }}>
          <span className={classes.colLabel}>Coordinates</span>
          <span className={classes.colValue}>{coordStr}</span>
        </div>
        <div className={classes.col}>
          <span className={classes.colLabel}>Groups</span>
          <span className={classes.colValue}>{groupStr}</span>
        </div>
      </div>
      <Chip
        label={isLocked ? 'Locked' : 'Unlocked'}
        size="small"
        className={classes.statusChip}
        style={isLocked
          ? { background: 'rgba(239, 68, 68, 0.15)', color: '#F87171', border: '1px solid rgba(239, 68, 68, 0.3)' }
          : { background: 'rgba(5, 150, 105, 0.15)', color: '#10B981', border: '1px solid rgba(5, 150, 105, 0.3)' }
        }
      />
      <FontAwesomeIcon icon={['fas', 'chevron-right']} className={classes.arrow} />
    </div>
  );
};
