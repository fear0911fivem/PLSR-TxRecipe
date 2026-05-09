import React, { useEffect } from 'react';
import { makeStyles } from '@material-ui/styles';
import { useDispatch, useSelector } from 'react-redux';

import PlayerCountHistory from './PlayerCountHistory';
import PlayerCount from './PlayerCount';
import Nui from '../../util/Nui';

const useStyles = makeStyles((theme) => ({
  wrapper: {
    padding: '20px',
    height: '100%',
    display: 'flex',
    flexDirection: 'column',
    gap: 20,
    boxSizing: 'border-box',
  },
  sectionRow: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 12,
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
    '&::before': {
      content: '""',
      display: 'inline-block',
      width: 3,
      height: 13,
      background: theme.palette.primary.main,
      borderRadius: 2,
    },
  },
  liveBadge: {
    display: 'flex',
    alignItems: 'center',
    gap: 6,
    fontSize: 11,
    fontWeight: 600,
    letterSpacing: '0.06em',
    textTransform: 'uppercase',
    color: theme.palette.success.light,
  },
  liveDot: {
    width: 7,
    height: 7,
    borderRadius: '50%',
    background: theme.palette.success.light,
    boxShadow: `0 0 0 3px ${theme.palette.success.main}30`,
  },
  chartSection: {
    flex: 1,
    display: 'flex',
    flexDirection: 'column',
    minHeight: 0,
  },
  chartCard: {
    flex: 1,
    minHeight: 0,
    background: theme.palette.secondary.light,
    border: `1px solid ${theme.palette.border.divider}`,
    borderRadius: 4,
    padding: '16px 16px 10px 8px',
  },
}));

export default () => {
  const classes = useStyles();
  const dispatch = useDispatch();
  const pData = useSelector(state => state.data.data.playerHistory);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      let res = await (await Nui.send('GetPlayerHistory', {})).json();
      if (res) {
        dispatch({
          type: 'SET_DATA',
          payload: { type: 'playerHistory', data: res },
        });
      }
    } catch (e) {}
  };

  return (
    <div className={classes.wrapper}>
      <div>
        <div className={classes.sectionRow}>
          <span className={classes.sectionTitle}>Server Overview</span>
          <span className={classes.liveBadge}>
            <span className={classes.liveDot} />
            Live
          </span>
        </div>
        <PlayerCount
          players={pData?.current ?? 0}
          max={pData?.max ?? 0}
          queue={pData?.queue ?? 0}
        />
      </div>

      <div className={classes.chartSection}>
        <div className={classes.sectionRow}>
          <span className={classes.sectionTitle}>Player Count — 24h History</span>
        </div>
        <div className={classes.chartCard}>
          <PlayerCountHistory
            current={pData?.current ?? 0}
            history={pData?.history ?? []}
          />
        </div>
      </div>
    </div>
  );
};
