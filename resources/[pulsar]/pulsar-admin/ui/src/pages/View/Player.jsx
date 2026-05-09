import React, { useEffect, useState } from 'react';
import {
  Avatar,
  Chip,
  Button,
  TextField,
  InputAdornment,
  IconButton,
  MenuItem,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import { toast } from 'react-toastify';
import moment from 'moment';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { useHistory } from 'react-router-dom';

import { Loader, Modal } from '../../components';
import Nui from '../../util/Nui';
import { useSelector } from 'react-redux';
import { round } from 'lodash';
import { CurrencyFormat } from '../../util/Parser';

const useStyles = makeStyles((theme) => ({
  wrapper: {
    padding: '20px 10px 20px 20px',
    height: '100%',
    overflowY: 'auto',
    overflowX: 'hidden',
    boxSizing: 'border-box',
  },

  // ── Section header ──────────────────────────────────
  sectionTitle: {
    display: 'flex',
    alignItems: 'center',
    gap: 8,
    fontSize: 11,
    fontWeight: 700,
    letterSpacing: '0.12em',
    textTransform: 'uppercase',
    color: theme.palette.text.info,
    marginBottom: 12,
    '&::before': {
      content: '""',
      display: 'inline-block',
      width: 3,
      height: 13,
      background: theme.palette.primary.main,
      borderRadius: 2,
    },
  },

  // ── Player header card ───────────────────────────────
  playerHeader: {
    display: 'flex',
    alignItems: 'center',
    gap: 16,
    padding: '16px 20px',
    background: theme.palette.secondary.light,
    border: `1px solid ${theme.palette.border.divider}`,
    borderRadius: 4,
    marginBottom: 16,
  },
  playerAvatar: {
    width: 56,
    height: 56,
    border: `2px solid ${theme.palette.primary.main}40`,
    flexShrink: 0,
  },
  playerHeaderInfo: {
    flex: 1,
    minWidth: 0,
  },
  playerName: {
    fontSize: 18,
    fontWeight: 700,
    color: theme.palette.text.light,
    marginBottom: 4,
    display: 'flex',
    alignItems: 'center',
    gap: 8,
  },
  playerMeta: {
    fontSize: 12,
    color: theme.palette.text.info,
    display: 'flex',
    gap: 16,
    flexWrap: 'wrap',
  },
  metaItem: {
    display: 'flex',
    alignItems: 'center',
    gap: 5,
  },

  // ── Action toolbar ───────────────────────────────────
  actionBar: {
    display: 'flex',
    gap: 8,
    flexWrap: 'wrap',
    marginBottom: 20,
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
    borderColor: 'rgba(239, 68, 68, 0.4)',
    '&:hover': {
      borderColor: '#F87171',
      background: 'rgba(239, 68, 68, 0.08)',
    },
    '&.Mui-disabled': {
      opacity: 0.35,
    },
  },

  // ── Disconnect banner ────────────────────────────────
  disconnectBanner: {
    display: 'flex',
    alignItems: 'center',
    gap: 12,
    padding: '10px 16px',
    background: 'rgba(251, 191, 36, 0.08)',
    border: '1px solid rgba(251, 191, 36, 0.25)',
    borderRadius: 4,
    marginBottom: 16,
    fontSize: 13,
    color: '#FCD34D',
    cursor: 'pointer',
    transition: 'background ease-in 0.15s',
    '&:hover': {
      background: 'rgba(251, 191, 36, 0.13)',
    },
  },

  // ── Info grid ────────────────────────────────────────
  infoGrid: {
    display: 'grid',
    gridTemplateColumns: '1fr 1fr',
    gap: 12,
    marginBottom: 20,
  },
  infoCard: {
    background: theme.palette.secondary.light,
    border: `1px solid ${theme.palette.border.divider}`,
    borderRadius: 4,
    padding: '14px 16px',
  },
  infoRow: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    padding: '7px 0',
    borderBottom: `1px solid ${theme.palette.border.divider}`,
    '&:last-child': {
      borderBottom: 'none',
      paddingBottom: 0,
    },
    '&:first-child': {
      paddingTop: 0,
    },
  },
  infoLabel: {
    fontSize: 11,
    fontWeight: 600,
    letterSpacing: '0.05em',
    textTransform: 'uppercase',
    color: theme.palette.text.info,
    flexShrink: 0,
    marginRight: 12,
  },
  infoValue: {
    fontSize: 12,
    fontWeight: 500,
    color: theme.palette.text.main,
    textAlign: 'right',
    wordBreak: 'break-all',
  },
  infoValueClickable: {
    fontSize: 12,
    fontWeight: 500,
    color: theme.palette.primary.light,
    textAlign: 'right',
    cursor: 'pointer',
    '&:hover': {
      textDecoration: 'underline',
    },
  },
  cardSectionTitle: {
    fontSize: 11,
    fontWeight: 700,
    letterSpacing: '0.1em',
    textTransform: 'uppercase',
    color: theme.palette.text.info,
    marginBottom: 10,
  },

  // ── Characters table ─────────────────────────────────
  charsSection: {
    marginBottom: 20,
  },
  charTable: {
    width: '100%',
    borderCollapse: 'collapse',
  },
  charThead: {
    '& th': {
      padding: '8px 10px',
      fontSize: 10,
      fontWeight: 700,
      letterSpacing: '0.08em',
      textTransform: 'uppercase',
      color: theme.palette.text.info,
      borderBottom: `1px solid ${theme.palette.border.divider}`,
      textAlign: 'left',
    },
  },
  charRow: {
    '& td': {
      padding: '9px 10px',
      fontSize: 12,
      fontWeight: 500,
      color: theme.palette.text.main,
      borderBottom: `1px solid ${theme.palette.border.divider}`,
    },
    '&:last-child td': {
      borderBottom: 'none',
    },
  },
  charRowDeleted: {
    opacity: 0.4,
  },

  editorField: {
    marginBottom: 10,
  },
}));

const banLengths = [
  { name: '1 Day', value: 1, permissionLevel: 75 },
  { name: '2 Day', value: 2, permissionLevel: 75 },
  { name: '3 Day', value: 3, permissionLevel: 75 },
  { name: '7 Day', value: 7, permissionLevel: 75 },
  { name: '14 Day', value: 14, permissionLevel: 99 },
  { name: '30 Day', value: 30, permissionLevel: 99 },
  { name: 'Permanent', value: -1, permissionLevel: 99 },
];

export default ({ match }) => {
  const classes = useStyles();
  const history = useHistory();
  const user = useSelector((state) => state.app.user);
  const permissionLevel = useSelector((state) => state.app.permissionLevel);

  const [err, setErr] = useState(false);
  const [loading, setLoading] = useState(false);
  const [player, setPlayer] = useState(null);

  const [kick, setKick] = useState(false);
  const [pendingKick, setPendingKick] = useState('');
  const [ban, setBan] = useState(false);
  const [pendingBanReason, setPendingBanReason] = useState('');
  const [pendingBanLength, setPendingBanLength] = useState(1);

  const fetch = async (forced) => {
    if (!player || player.Source != match.params.id || forced) {
      setLoading(true);
      try {
        let res = await (await Nui.send('GetPlayer', parseInt(match.params.id))).json();
        if (res) setPlayer(res);
        else toast.error('Unable to Load');
      } catch (e) {
        toast.error('Unable to Load');
        setErr(true);
      }
      setLoading(false);
    }
  };

  useEffect(() => { fetch(); }, [match]);

  const onAction = async (action) => {
    try {
      let res = await (await Nui.send('ActionPlayer', { targetSource: player?.Source, action })).json();
      if (res?.success) toast.success(res.message);
      else toast.error(res?.message ?? 'Error');
    } catch {
      toast.error('Error');
    }
  };

  const openForumUrl = () => {
    Nui.copyClipboard(`https://pulsarfw.com/admin/users/${player.AccountID}/`);
    toast.success('Copied URL');
  };

  const copyCoords = () => {
    Nui.copyClipboard(
      `vector3(${round(player.Character.Coords?.x, 3)}, ${round(player.Character.Coords?.y, 3)}, ${round(player.Character.Coords?.z, 3)})`
    );
    toast.success('Copied Coordinates');
  };

  const startKick = () => { setPendingKick(''); setKick(true); };
  const startBan = () => { setPendingBanLength(1); setPendingBanReason(''); setBan(true); };

  const onKick = async (e) => {
    e.preventDefault();
    setKick(false);
    setLoading(true);
    try {
      let res = await (await Nui.send('KickPlayer', { targetSource: player?.Source, reason: e.target.kickReason.value })).json();
      if (res?.success) { toast.success(`Kicked ${player?.Name ?? 'Player'}`); history.goBack(); }
      else toast.error(res?.message ?? 'Failed to Kick Player');
    } catch { toast.error('Error Kicking Player'); }
    setLoading(false);
  };

  const onBan = async (e) => {
    e.preventDefault();
    setBan(false);
    setLoading(true);
    try {
      let res = await (await Nui.send('BanPlayer', { targetSource: player?.Source, reason: e.target.banReason.value, length: parseInt(e.target.banLength.value) })).json();
      if (res?.success) toast.success(`Banned ${player?.Name ?? 'Player'}`);
      else toast.error(res?.message ?? 'Failed to Ban Player');
    } catch { toast.error('Error Banning Player'); }
    setLoading(false);
  };

  const formatLastPlayed = (ts) => {
    if (!ts || ts === '0000-00-00 00:00:00') return 'Never';
    let m;
    if (typeof ts === 'number') {
      m = ts > 1e10 ? moment(ts) : moment.unix(ts);
    } else {
      m = moment(ts);
    }
    return m.isValid() && m.year() > 1971 ? m.fromNow() : 'Never';
  };

  const formatJobs = (jobs) => {
    if (jobs && jobs.length > 0) return jobs.map((j) => `${j.Name} — ${j.Grade.Name}`).join('; ');
    return 'No Jobs';
  };

  if (loading || (!player && !err)) {
    return (
      <div className={classes.wrapper} style={{ position: 'relative' }}>
        <Loader static text="Loading Player" />
      </div>
    );
  }

  if (err) {
    return (
      <div className={classes.wrapper}>
        <div style={{ padding: '20px 16px', background: 'rgba(239,68,68,0.08)', border: '1px solid rgba(239,68,68,0.25)', borderRadius: 4, color: '#F87171', fontSize: 13, fontWeight: 500 }}>
          <FontAwesomeIcon icon={['fas', 'circle-exclamation']} style={{ marginRight: 8 }} />
          Invalid Player — no data found.
        </div>
      </div>
    );
  }

  const isOnline = Boolean(player.Character) && !player.Disconnected;
  const isSelf = user?.Source === player.Source;

  return (
    <div className={classes.wrapper}>
      {/* ── Player header ── */}
      <div className={classes.playerHeader}>
        <Avatar src={player.Avatar} className={classes.playerAvatar} />
        <div className={classes.playerHeaderInfo}>
          <div className={classes.playerName}>
            {player.Name}
            {isSelf && <Chip label="You" size="small" style={{ height: 18, fontSize: 10, fontWeight: 700, background: 'rgba(124,58,237,0.2)', color: '#A78BFA', border: '1px solid rgba(124,58,237,0.35)', borderRadius: 3 }} />}
            {player.StaffGroup && <Chip label={player.StaffGroup} size="small" style={{ height: 18, fontSize: 10, fontWeight: 700, background: 'rgba(251,191,36,0.1)', color: '#FCD34D', border: '1px solid rgba(251,191,36,0.25)', borderRadius: 3 }} />}
          </div>
          <div className={classes.playerMeta}>
            <span className={classes.metaItem}>
              <FontAwesomeIcon icon={['fas', 'hashtag']} style={{ fontSize: 10 }} /> Source {player.Source}
            </span>
            <span className={classes.metaItem}>
              <FontAwesomeIcon icon={['fas', 'id-card']} style={{ fontSize: 10 }} /> Account {player.AccountID}
            </span>
            {player.Character && (
              <span className={classes.metaItem}>
                <FontAwesomeIcon icon={['fas', 'user']} style={{ fontSize: 10 }} /> {player.Character.First} {player.Character.Last} (SID {player.Character.SID})
              </span>
            )}
          </div>
        </div>
        <Chip
          label={isOnline ? 'Online' : player.Disconnected ? 'Disconnected' : 'Lobby'}
          size="small"
          style={isOnline
            ? { height: 22, fontSize: 11, fontWeight: 700, background: 'rgba(5,150,105,0.15)', color: '#10B981', border: '1px solid rgba(5,150,105,0.3)', borderRadius: 3 }
            : player.Disconnected
              ? { height: 22, fontSize: 11, fontWeight: 700, background: 'rgba(251,191,36,0.1)', color: '#FCD34D', border: '1px solid rgba(251,191,36,0.25)', borderRadius: 3 }
              : { height: 22, fontSize: 11, fontWeight: 700, background: 'rgba(100,116,139,0.15)', color: '#94A3B8', border: '1px solid rgba(100,116,139,0.3)', borderRadius: 3 }
          }
        />
      </div>

      {/* ── Disconnect banner ── */}
      {player.Disconnected && (
        <div
          className={classes.disconnectBanner}
          onClick={() => player.Reconnected && history.push(`/player/${player.Reconnected}`)}
        >
          <FontAwesomeIcon icon={['fas', 'triangle-exclamation']} />
          <span>
            Player disconnected {moment(player.DisconnectedTime * 1000).fromNow()} — Reason: {player.Reason ?? 'Unknown'}.
            {player.Reconnected && ' They have since reconnected. Click to view.'}
          </span>
        </div>
      )}

      {/* ── Action toolbar ── */}
      <div className={classes.actionBar}>
        <Button
          variant="outlined"
          color="primary"
          size="small"
          className={classes.actionBtn}
          onClick={() => onAction('goto')}
          disabled={!player.Character || isSelf || player.Disconnected}
        >
          <FontAwesomeIcon icon={['fas', 'location-arrow']} /> Goto
        </Button>
        <Button
          variant="outlined"
          color="primary"
          size="small"
          className={classes.actionBtn}
          onClick={() => onAction('bring')}
          disabled={!player.Character || isSelf || permissionLevel < player.Level || player.Disconnected}
        >
          <FontAwesomeIcon icon={['fas', 'person-walking-arrow-right']} /> Bring
        </Button>
        <Button
          variant="outlined"
          color="primary"
          size="small"
          className={classes.actionBtn}
          onClick={() => onAction('heal')}
          disabled={!player.Character || player.Disconnected || (isSelf && permissionLevel < 75)}
        >
          <FontAwesomeIcon icon={['fas', 'heart-pulse']} /> Heal
        </Button>
        <Button
          variant="outlined"
          color="primary"
          size="small"
          className={classes.actionBtn}
          onClick={() => onAction('attach')}
          disabled={!player.Character || isSelf || permissionLevel < player.Level || player.Disconnected}
        >
          <FontAwesomeIcon icon={['fas', 'eye']} /> Spectate
        </Button>
        {permissionLevel >= 90 && (
          <Button
            variant="outlined"
            color="primary"
            size="small"
            className={classes.actionBtn}
            onClick={() => onAction('marker')}
            disabled={isSelf}
          >
            <FontAwesomeIcon icon={['fas', 'map-pin']} /> GPS Marker
          </Button>
        )}
        <Button
          variant="outlined"
          color="primary"
          size="small"
          className={classes.actionBtn}
          onClick={openForumUrl}
        >
          <FontAwesomeIcon icon={['fas', 'link']} /> Copy Site URL
        </Button>
        <Button
          variant="outlined"
          size="small"
          className={classes.actionBtn}
          onClick={() => fetch(true)}
        >
          <FontAwesomeIcon icon={['fas', 'rotate-right']} /> Refresh
        </Button>
        <Button
          variant="outlined"
          size="small"
          className={classes.dangerBtn}
          onClick={startKick}
          disabled={isSelf || permissionLevel < player.Level}
        >
          <FontAwesomeIcon icon={['fas', 'right-from-bracket']} /> Kick
        </Button>
        <Button
          variant="outlined"
          size="small"
          className={classes.dangerBtn}
          onClick={startBan}
          disabled={isSelf || permissionLevel < player.Level || permissionLevel < 75}
        >
          <FontAwesomeIcon icon={['fas', 'ban']} /> Ban
        </Button>
      </div>

      {/* ── Info cards ── */}
      <div className={classes.sectionTitle}>Player Info</div>
      <div className={classes.infoGrid}>
        {/* Left — account */}
        <div className={classes.infoCard}>
          <div className={classes.cardSectionTitle}>Account</div>
          <div className={classes.infoRow}>
            <span className={classes.infoLabel}>Player Name</span>
            <span className={classes.infoValue}>{player.Name}{isSelf ? ' (You)' : ''}</span>
          </div>
          <div className={classes.infoRow}>
            <span className={classes.infoLabel}>Account ID</span>
            <span className={classes.infoValue}>{player.AccountID}</span>
          </div>
          <div className={classes.infoRow}>
            <span className={classes.infoLabel}>Server Source</span>
            <span className={classes.infoValue}>{player.Source}</span>
          </div>
          <div className={classes.infoRow}>
            <span className={classes.infoLabel}>Game Name</span>
            <span className={classes.infoValue}>{player.GameName ?? '—'}</span>
          </div>
          <div className={classes.infoRow}>
            <span className={classes.infoLabel}>Discord ID</span>
            <span className={classes.infoValue}>{player.Discord ?? '—'}</span>
          </div>
          <div className={classes.infoRow}>
            <span className={classes.infoLabel}>Discord @</span>
            <span className={classes.infoValue}>{player.Mention ?? '—'}</span>
          </div>
          <div className={classes.infoRow}>
            <span className={classes.infoLabel}>Identifier</span>
            <span className={classes.infoValue} style={{ fontSize: 11 }}>{player.Identifier ?? '—'}</span>
          </div>
          {player.StaffGroup && (
            <div className={classes.infoRow}>
              <span className={classes.infoLabel}>Staff Group</span>
              <span className={classes.infoValue}>{player.StaffGroup}</span>
            </div>
          )}
        </div>

        {/* Right — character */}
        <div className={classes.infoCard}>
          <div className={classes.cardSectionTitle}>Character</div>
          {player.Character ? (
            <>
              <div className={classes.infoRow}>
                <span className={classes.infoLabel}>Name</span>
                <span className={classes.infoValue}>{player.Character.First} {player.Character.Last}</span>
              </div>
              <div className={classes.infoRow}>
                <span className={classes.infoLabel}>State ID</span>
                <span className={classes.infoValue}>{player.Character.SID}</span>
              </div>
              <div className={classes.infoRow}>
                <span className={classes.infoLabel}>DOB</span>
                <span className={classes.infoValue}>{player.Character.DOB ? moment(player.Character.DOB).format('LL') : '—'}</span>
              </div>
              {permissionLevel >= 90 && (
                <div className={classes.infoRow}>
                  <span className={classes.infoLabel}>Phone #</span>
                  <span className={classes.infoValue}>{player.Character.Phone ?? '—'}</span>
                </div>
              )}
              {permissionLevel >= 90 && player.Character.Coords && (
                <div className={classes.infoRow}>
                  <span className={classes.infoLabel}>Coords</span>
                  <span className={classes.infoValueClickable} onClick={copyCoords}>
                    {round(player.Character.Coords.x, 1)}, {round(player.Character.Coords.y, 1)}, {round(player.Character.Coords.z, 1)}
                    <FontAwesomeIcon icon={['fas', 'copy']} style={{ marginLeft: 6, fontSize: 10 }} />
                  </span>
                </div>
              )}
              {player.Character.ApartmentRoom && (
                <div className={classes.infoRow}>
                  <span className={classes.infoLabel}>Apartment</span>
                  <span className={classes.infoValue}>{player.Character.ApartmentRoom}</span>
                </div>
              )}
              {player.Vehicle && (
                <div className={classes.infoRow}>
                  <span className={classes.infoLabel}>Vehicle</span>
                  <span
                    className={permissionLevel >= 75 ? classes.infoValueClickable : classes.infoValue}
                    onClick={() => permissionLevel >= 75 && history.push(`/vehicle/${player.Vehicle.Entity}`)}
                  >
                    {player.Vehicle.Make ?? 'Unknown'} {player.Vehicle.Model ?? ''} — {player.Vehicle.Plate}
                  </span>
                </div>
              )}
            </>
          ) : (
            <div style={{ padding: '20px 0', textAlign: 'center', color: '#64748B', fontSize: 13 }}>
              <FontAwesomeIcon icon={['fas', 'user-slash']} style={{ fontSize: 22, display: 'block', margin: '0 auto 8px' }} />
              Not logged into a character
            </div>
          )}
        </div>
      </div>

      {/* ── Characters table ── */}
      <div className={classes.charsSection}>
        <div className={classes.sectionTitle}>
          {player.Character ? "Player's Other Characters" : "Player's Characters"}
        </div>
        <div className={classes.infoCard} style={{ padding: 0, overflow: 'hidden' }}>
          <table className={classes.charTable}>
            <thead className={classes.charThead}>
              <tr>
                <th>SID</th>
                <th>Name</th>
                <th>Last Played</th>
                <th>Jobs</th>
                <th>Cash</th>
                <th>Bank Acct</th>
                <th>Phone</th>
                <th>DOB</th>
                <th>Apartment</th>
              </tr>
            </thead>
            <tbody>
              {player.Characters?.sort((a, b) => Number(a.Deleted) - Number(b.Deleted)).map((c, i) => (
                <tr key={i} className={`${classes.charRow} ${c.Deleted ? classes.charRowDeleted : ''}`}>
                  <td>{c.SID}</td>
                  <td>{c.First} {c.Last}</td>
                  <td>{formatLastPlayed(c.LastPlayed)}</td>
                  <td>{formatJobs(c.Jobs)}</td>
                  <td>{CurrencyFormat.format(c.Cash)}</td>
                  <td>{c.BankAccount ?? '—'}</td>
                  <td>{c.Phone ?? '—'}</td>
                  <td>{c.DOB ? moment(c.DOB).format('MM/DD/YY') : '—'}</td>
                  <td>{c.ApartmentRoom ?? '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* ── Modals ── */}
      <Modal open={kick} title={`Kick ${player.Name}`} onSubmit={onKick} submitLang="Kick" onClose={() => setKick(false)}>
        <TextField
          fullWidth
          required
          variant="outlined"
          name="kickReason"
          value={pendingKick}
          onChange={(e) => setPendingKick(e.target.value)}
          label="Kick Reason"
          helperText="Please give a reason."
          multiline
          InputProps={{
            endAdornment: (
              <InputAdornment position="end">
                {pendingKick !== '' && (
                  <IconButton onClick={() => setPendingKick('')}>
                    <FontAwesomeIcon icon={['fas', 'xmark']} />
                  </IconButton>
                )}
              </InputAdornment>
            ),
          }}
        />
      </Modal>

      <Modal open={ban} title={`Ban ${player.Name}`} onSubmit={onBan} submitLang="Ban" onClose={() => setBan(false)}>
        <TextField
          select
          fullWidth
          name="banLength"
          label="Ban Length"
          className={classes.editorField}
          value={pendingBanLength}
          onChange={(e) => setPendingBanLength(e.target.value)}
        >
          {banLengths.filter((l) => permissionLevel >= l.permissionLevel).map((l) => (
            <MenuItem key={l.value} value={l.value}>{l.name}</MenuItem>
          ))}
        </TextField>
        <TextField
          fullWidth
          required
          variant="outlined"
          name="banReason"
          value={pendingBanReason}
          onChange={(e) => setPendingBanReason(e.target.value)}
          label="Ban Reason"
          helperText="Please give a reason."
          multiline
          InputProps={{
            endAdornment: (
              <InputAdornment position="end">
                {pendingBanReason !== '' && (
                  <IconButton onClick={() => setPendingBanReason('')}>
                    <FontAwesomeIcon icon={['fas', 'xmark']} />
                  </IconButton>
                )}
              </InputAdornment>
            ),
          }}
        />
      </Modal>
    </div>
  );
};
