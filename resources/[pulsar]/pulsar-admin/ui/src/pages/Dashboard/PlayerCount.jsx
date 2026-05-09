import React from 'react';
import { LinearProgress } from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

const useStyles = makeStyles((theme) => ({
  grid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(3, 1fr)',
    gap: 12,
  },
  card: {
    padding: '16px 18px',
    background: theme.palette.secondary.light,
    border: `1px solid ${theme.palette.border.divider}`,
    borderRadius: 4,
    display: 'flex',
    alignItems: 'center',
    gap: 16,
    position: 'relative',
    overflow: 'hidden',
    '&::before': {
      content: '""',
      position: 'absolute',
      top: 0,
      left: 0,
      width: 3,
      height: '100%',
      background: theme.palette.primary.main,
      borderRadius: '0 2px 2px 0',
    },
  },
  iconBox: {
    width: 46,
    height: 46,
    borderRadius: 4,
    background: `${theme.palette.primary.main}18`,
    border: `1px solid ${theme.palette.primary.main}30`,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    flexShrink: 0,
    '& svg': {
      fontSize: 20,
      color: theme.palette.primary.light,
    },
  },
  info: {
    flex: 1,
    minWidth: 0,
  },
  label: {
    display: 'block',
    fontSize: 10,
    fontWeight: 700,
    letterSpacing: '0.12em',
    textTransform: 'uppercase',
    color: theme.palette.text.info,
    marginBottom: 5,
  },
  value: {
    display: 'block',
    fontSize: 34,
    fontWeight: 800,
    color: theme.palette.text.main,
    lineHeight: 1,
    letterSpacing: '-0.03em',
  },
  capValue: {
    display: 'block',
    fontSize: 26,
    fontWeight: 800,
    color: theme.palette.text.main,
    lineHeight: 1,
    letterSpacing: '-0.03em',
    marginBottom: 10,
  },
  maxSuffix: {
    fontSize: 14,
    fontWeight: 400,
    color: theme.palette.text.info,
    letterSpacing: 0,
  },
  progressWrap: {
    marginTop: 2,
  },
  progressLabel: {
    display: 'flex',
    justifyContent: 'space-between',
    marginBottom: 6,
    fontSize: 11,
    color: theme.palette.text.info,
  },
  pct: {
    color: theme.palette.primary.light,
    fontWeight: 700,
  },
}));

export default ({ players, max, queue }) => {
  const classes = useStyles();
  const pct = max > 0 ? Math.min(100, Math.floor((players / max) * 100)) : 0;

  return (
    <div className={classes.grid}>
      <div className={classes.card}>
        <div className={classes.iconBox}>
          <FontAwesomeIcon icon={['fas', 'users']} />
        </div>
        <div className={classes.info}>
          <span className={classes.label}>Online Players</span>
          <span className={classes.value}>{players}</span>
        </div>
      </div>

      <div className={classes.card}>
        <div className={classes.iconBox}>
          <FontAwesomeIcon icon={['fas', 'hourglass-half']} />
        </div>
        <div className={classes.info}>
          <span className={classes.label}>In Queue</span>
          <span className={classes.value}>{queue}</span>
        </div>
      </div>

      <div className={classes.card}>
        <div className={classes.iconBox}>
          <FontAwesomeIcon icon={['fas', 'server']} />
        </div>
        <div className={classes.info}>
          <span className={classes.label}>Server Capacity</span>
          <span className={classes.capValue}>
            {players}
            <span className={classes.maxSuffix}> / {max}</span>
          </span>
          <div className={classes.progressWrap}>
            <div className={classes.progressLabel}>
              <span>Load</span>
              <span className={classes.pct}>{pct}%</span>
            </div>
            <LinearProgress variant="determinate" value={pct} color="primary" />
          </div>
        </div>
      </div>
    </div>
  );
};
