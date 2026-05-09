import React, { useState, useMemo } from 'react';
import {
  TextField,
  InputAdornment,
  IconButton,
  Chip,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { toast } from 'react-toastify';

import Nui from '../../util/Nui';

const COMMANDS = [
  { command: 'admin', label: '/admin', description: 'Open the Admin Panel.', permission: 'Admin', permColor: '#DC2626', category: 'Panel', params: [], closeMenu: false },
  { command: 'staff', label: '/staff', description: 'Open the Staff Panel.', permission: 'Staff', permColor: '#F59E0B', category: 'Panel', params: [], closeMenu: false },
  { command: 'noclip', label: '/noclip', description: 'Toggle NoClip freecam mode.', permission: 'Admin', permColor: '#DC2626', category: 'Tools', params: [], closeMenu: true },
  { command: 'noclip:dev', label: '/noclip:dev', description: 'Toggle Developer NoClip with coordinate overlay and debug info.', permission: 'Developer', permColor: '#7C3AED', category: 'Tools', params: [], closeMenu: true },
  { command: 'noclip:info', label: '/noclip:info', description: 'Toggle the NoClip camera coordinate info overlay.', permission: 'Developer', permColor: '#7C3AED', category: 'Tools', params: [], closeMenu: false },
  { command: 'staffcam', label: '/staffcam', description: 'Toggle staff observation / camera mode (same as noclip:dev).', permission: 'Admin', permColor: '#DC2626', category: 'Tools', params: [], closeMenu: true },
  { command: 'marker', label: '/marker', description: 'Place a GPS map marker at specific X/Y world coordinates.', permission: 'Admin', permColor: '#DC2626', category: 'Tools', params: [{ name: 'X Coordinate', placeholder: '0.0' }, { name: 'Y Coordinate', placeholder: '0.0' }], closeMenu: false },
  { command: 'setped', label: '/setped', description: 'Change your own ped model to any valid ped hash.', permission: 'Admin', permColor: '#DC2626', category: 'Tools', params: [{ name: 'Ped model name', placeholder: 'a_m_y_skater_01' }], closeMenu: false },
  { command: 'zsetped', label: '/zsetped', description: "Change another player's ped model using their server source ID.", permission: 'Admin', permColor: '#DC2626', category: 'Tools', params: [{ name: 'Server source ID', placeholder: '1' }, { name: 'Ped model name', placeholder: 'a_m_y_skater_01' }], closeMenu: false },
  { command: 'cpcoords', label: '/cpcoords', description: 'Copy your current coordinates to clipboard. Types: vec3, vec4, vec2, table, z, h, rot.', permission: 'Staff', permColor: '#F59E0B', category: 'Developer', params: [{ name: 'Type', placeholder: 'vec3' }], closeMenu: false },
  { command: 'cpproperty', label: '/cpproperty', description: 'Copy the ID of the nearest property to clipboard.', permission: 'Admin', permColor: '#DC2626', category: 'Developer', params: [], closeMenu: false },
  { command: 'property', label: '/property', description: 'Print detailed info about the nearest property (ID, label, owner, price, type).', permission: 'Admin', permColor: '#DC2626', category: 'Developer', params: [], closeMenu: false },
  { command: 'weptest', label: '/weptest', description: 'Start weapon damage testing mode. Mode 0 = body shots, 1 = headshots.', permission: 'Admin', permColor: '#DC2626', category: 'Developer', params: [{ name: 'Mode (0 or 1)', placeholder: '0' }], closeMenu: false },
  { command: 'statebaglog', label: '/statebaglog', description: 'Toggle console output of all state bag changes for debugging.', permission: 'Admin', permColor: '#DC2626', category: 'Developer', params: [], closeMenu: false },
  { command: 'voiptargetlog', label: '/voiptargetlog', description: 'Toggle console VOIP proximity target debug logging.', permission: 'Admin', permColor: '#DC2626', category: 'Developer', params: [], closeMenu: false },
  { command: 'record', label: '/record', description: 'Start recording a clip with the Rockstar Editor.', permission: 'All', permColor: '#059669', category: 'Recording', params: [], closeMenu: false },
  { command: 'recordstop', label: '/recordstop', description: 'Stop the current Rockstar Editor recording.', permission: 'All', permColor: '#059669', category: 'Recording', params: [], closeMenu: false },
  { command: 'nuke', label: '/nuke', description: '⚠ Triggers the server-wide nuke countdown and explosion event. Use with extreme caution.', permission: 'Admin', permColor: '#DC2626', category: 'Danger', params: [], closeMenu: false, danger: true },
];

const CATEGORIES = ['All', 'Panel', 'Tools', 'Developer', 'Recording', 'Danger'];

const CATEGORY_ICONS = {
  Panel: ['fas', 'table-columns'],
  Tools: ['fas', 'wrench'],
  Developer: ['fas', 'code'],
  Recording: ['fas', 'video'],
  Danger: ['fas', 'triangle-exclamation'],
};

const useStyles = makeStyles((theme) => ({
  wrapper: {
    display: 'flex',
    flexDirection: 'column',
    height: '100%',
    padding: '16px',
    gap: 12,
  },
  header: {
    flexShrink: 0,
  },
  pageTitle: {
    fontSize: 18,
    fontWeight: 700,
    color: theme.palette.text.main,
    letterSpacing: '0.04em',
    marginBottom: 10,
    display: 'flex',
    alignItems: 'center',
    gap: 10,
    '& svg': {
      color: theme.palette.primary.light,
      fontSize: 16,
    },
  },
  topRow: {
    display: 'flex',
    gap: 8,
    alignItems: 'center',
  },
  searchField: {
    flex: 1,
  },
  categoryBar: {
    display: 'flex',
    gap: 6,
    marginTop: 10,
    flexWrap: 'wrap',
  },
  catChip: {
    height: 26,
    fontSize: 11,
    fontWeight: 600,
    letterSpacing: '0.04em',
    borderRadius: 4,
    cursor: 'pointer',
    borderColor: theme.palette.border.divider,
    color: theme.palette.text.alt,
    '&:hover': {
      borderColor: `${theme.palette.primary.main}60`,
      color: theme.palette.primary.light,
    },
  },
  catChipActive: {
    height: 26,
    fontSize: 11,
    fontWeight: 600,
    letterSpacing: '0.04em',
    borderRadius: 4,
    cursor: 'pointer',
    background: `${theme.palette.primary.main} !important`,
    color: '#fff !important',
    border: 'none !important',
  },
  countBadge: {
    fontSize: 11,
    color: theme.palette.text.info,
    letterSpacing: '0.04em',
    marginTop: 6,
  },
  list: {
    flex: 1,
    overflowY: 'auto',
    display: 'flex',
    flexDirection: 'column',
    gap: 6,
    paddingRight: 4,
  },
  sectionLabel: {
    fontSize: 10,
    fontWeight: 700,
    letterSpacing: '0.12em',
    textTransform: 'uppercase',
    color: theme.palette.text.info,
    padding: '10px 0 4px 2px',
    userSelect: 'none',
    '&:first-child': {
      paddingTop: 2,
    },
  },
  card: {
    display: 'flex',
    alignItems: 'flex-start',
    gap: 14,
    padding: '12px 14px',
    background: theme.palette.secondary.light,
    border: `1px solid ${theme.palette.border.divider}`,
    borderRadius: 4,
    cursor: 'pointer',
    transition: 'background ease-in 0.15s, border-color ease-in 0.15s',
    '&:hover': {
      background: 'rgba(124, 58, 237, 0.07)',
      borderColor: `${theme.palette.primary.main}50`,
    },
  },
  dangerCard: {
    borderColor: 'rgba(220, 38, 38, 0.25)',
    '&:hover': {
      background: 'rgba(239, 68, 68, 0.06)',
      borderColor: 'rgba(220, 38, 38, 0.5)',
    },
  },
  iconArea: {
    width: 32,
    height: 32,
    borderRadius: 4,
    background: theme.palette.secondary.dark,
    border: `1px solid ${theme.palette.border.divider}`,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    flexShrink: 0,
    '& svg': {
      color: theme.palette.text.info,
      fontSize: 13,
    },
  },
  cardBody: {
    flex: 1,
    minWidth: 0,
  },
  commandLine: {
    display: 'flex',
    alignItems: 'center',
    gap: 8,
    marginBottom: 4,
    flexWrap: 'wrap',
  },
  commandText: {
    fontFamily: 'monospace',
    fontSize: 14,
    fontWeight: 700,
    color: theme.palette.primary.light,
    letterSpacing: '0.02em',
  },
  permBadge: {
    height: 18,
    fontSize: 10,
    fontWeight: 700,
    letterSpacing: '0.06em',
    borderRadius: 3,
  },
  description: {
    fontSize: 13,
    color: theme.palette.text.alt,
    lineHeight: 1.5,
    marginBottom: 4,
  },
  params: {
    display: 'flex',
    gap: 5,
    flexWrap: 'wrap',
    marginTop: 5,
  },
  paramChip: {
    height: 18,
    fontSize: 10,
    fontWeight: 600,
    borderRadius: 3,
    background: 'rgba(255,255,255,0.05)',
    color: theme.palette.text.info,
    border: `1px solid ${theme.palette.border.divider}`,
    letterSpacing: '0.02em',
  },
  runHint: {
    marginLeft: 'auto',
    fontSize: 10,
    fontWeight: 600,
    color: theme.palette.text.info,
    letterSpacing: '0.05em',
    textTransform: 'uppercase',
    display: 'flex',
    alignItems: 'center',
    gap: 5,
    flexShrink: 0,
  },
  empty: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '60px 0',
    gap: 12,
    '& svg': {
      fontSize: 32,
      color: '#1A1A2E',
    },
  },
  emptyText: {
    fontSize: 14,
    color: theme.palette.text.info,
  },
  dialogTitle: {
    background: theme.palette.secondary.dark,
    borderBottom: `1px solid ${theme.palette.border.divider}`,
    padding: '14px 20px',
    '& h2': {
      fontSize: 15,
      fontWeight: 700,
      color: theme.palette.text.main,
      display: 'flex',
      alignItems: 'center',
      gap: 8,
    },
  },
  dialogContent: {
    background: theme.palette.secondary.main,
    padding: '16px 20px',
    display: 'flex',
    flexDirection: 'column',
    gap: 12,
  },
  dialogActions: {
    background: theme.palette.secondary.dark,
    borderTop: `1px solid ${theme.palette.border.divider}`,
    padding: '10px 16px',
    gap: 8,
  },
  confirmBanner: {
    display: 'flex',
    alignItems: 'center',
    gap: 10,
    padding: '10px 14px',
    background: 'rgba(239,68,68,0.08)',
    border: '1px solid rgba(239,68,68,0.25)',
    borderRadius: 4,
    fontSize: 13,
    color: '#F87171',
    marginBottom: 4,
  },
}));

export default () => {
  const classes = useStyles();
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('All');
  const [pendingCmd, setPendingCmd] = useState(null);
  const [paramValues, setParamValues] = useState({});

  const filtered = useMemo(() => {
    return COMMANDS.filter(cmd => {
      const matchSearch = !search
        || cmd.label.toLowerCase().includes(search.toLowerCase())
        || cmd.description.toLowerCase().includes(search.toLowerCase());
      const matchCat = category === 'All' || cmd.category === category;
      return matchSearch && matchCat;
    });
  }, [search, category]);

  const grouped = useMemo(() => {
    return filtered.reduce((acc, cmd) => {
      if (!acc[cmd.category]) acc[cmd.category] = [];
      acc[cmd.category].push(cmd);
      return acc;
    }, {});
  }, [filtered]);

  const handleCardClick = (cmd) => {
    if (cmd.params.length > 0 || cmd.danger) {
      setParamValues({});
      setPendingCmd(cmd);
    } else {
      executeCommand(cmd, []);
    }
  };

  const executeCommand = async (cmd, args) => {
    try {
      const res = await (await Nui.send('ExecuteCommand', {
        command: cmd.command,
        args,
        closeMenu: cmd.closeMenu,
      })).json();
      if (res?.success) {
        toast.success(`Executed ${cmd.label}`);
      }
    } catch {
      // dev mode — command not available outside FiveM
      toast.info(`${cmd.label} — executed (dev mode)`);
    }
  };

  const handleModalSubmit = () => {
    if (!pendingCmd) return;
    const args = pendingCmd.params.map((p, i) => paramValues[i] || '');
    executeCommand(pendingCmd, args);
    setPendingCmd(null);
  };

  return (
    <div className={classes.wrapper}>
      <div className={classes.header}>
        <div className={classes.pageTitle}>
          <FontAwesomeIcon icon={['fas', 'terminal']} />
          Admin Commands
        </div>
        <div className={classes.topRow}>
          <TextField
            className={classes.searchField}
            variant="outlined"
            size="small"
            placeholder="Search commands..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <FontAwesomeIcon icon={['fas', 'magnifying-glass']} style={{ color: '#4B5563', fontSize: 13 }} />
                </InputAdornment>
              ),
              endAdornment: search ? (
                <InputAdornment position="end">
                  <IconButton size="small" onClick={() => setSearch('')}>
                    <FontAwesomeIcon icon={['fas', 'xmark']} style={{ fontSize: 12 }} />
                  </IconButton>
                </InputAdornment>
              ) : null,
            }}
          />
        </div>
        <div className={classes.categoryBar}>
          {CATEGORIES.map(cat => (
            <Chip
              key={cat}
              label={cat}
              variant={category === cat ? 'filled' : 'outlined'}
              className={category === cat ? classes.catChipActive : classes.catChip}
              onClick={() => setCategory(cat)}
            />
          ))}
        </div>
        <div className={classes.countBadge}>{filtered.length} command{filtered.length !== 1 ? 's' : ''}</div>
      </div>

      <div className={classes.list}>
        {filtered.length === 0 ? (
          <div className={classes.empty}>
            <FontAwesomeIcon icon={['fas', 'terminal']} />
            <span className={classes.emptyText}>No commands match your search</span>
          </div>
        ) : (
          Object.entries(grouped).map(([cat, cmds]) => (
            <React.Fragment key={cat}>
              <div className={classes.sectionLabel}>{cat}</div>
              {cmds.map(cmd => (
                <div
                  key={cmd.command}
                  className={`${classes.card} ${cmd.danger ? classes.dangerCard : ''}`}
                  onClick={() => handleCardClick(cmd)}
                >
                  <div className={classes.iconArea}>
                    <FontAwesomeIcon icon={CATEGORY_ICONS[cmd.category] || ['fas', 'terminal']} />
                  </div>
                  <div className={classes.cardBody}>
                    <div className={classes.commandLine}>
                      <span className={classes.commandText}>{cmd.label}</span>
                      <Chip
                        label={cmd.permission}
                        size="small"
                        className={classes.permBadge}
                        style={{ background: `${cmd.permColor}22`, color: cmd.permColor, border: `1px solid ${cmd.permColor}44` }}
                      />
                    </div>
                    <div className={classes.description}>{cmd.description}</div>
                    {cmd.params.length > 0 && (
                      <div className={classes.params}>
                        {cmd.params.map(p => (
                          <Chip key={p.name} label={`<${p.name}>`} size="small" className={classes.paramChip} />
                        ))}
                      </div>
                    )}
                  </div>
                  <div className={classes.runHint}>
                    <FontAwesomeIcon icon={['fas', 'play']} style={{ fontSize: 9 }} />
                    Run
                  </div>
                </div>
              ))}
            </React.Fragment>
          ))
        )}
      </div>

      {/* ── Param / confirm dialog ── */}
      <Dialog
        open={Boolean(pendingCmd)}
        onClose={() => setPendingCmd(null)}
        maxWidth="xs"
        fullWidth
        PaperProps={{ style: { background: 'transparent', boxShadow: 'none' } }}
      >
        {pendingCmd && (
          <>
            <DialogTitle className={classes.dialogTitle} disableTypography>
              <h2>
                <FontAwesomeIcon icon={['fas', 'terminal']} style={{ color: '#A78BFA', fontSize: 14 }} />
                {pendingCmd.label}
              </h2>
            </DialogTitle>
            <DialogContent className={classes.dialogContent}>
              {pendingCmd.danger && (
                <div className={classes.confirmBanner}>
                  <FontAwesomeIcon icon={['fas', 'triangle-exclamation']} />
                  <span>This is a dangerous action — confirm before running.</span>
                </div>
              )}
              <div style={{ fontSize: 13, color: '#94A3B8', lineHeight: 1.5 }}>
                {pendingCmd.description}
              </div>
              {pendingCmd.params.map((p, i) => (
                <TextField
                  key={i}
                  fullWidth
                  variant="outlined"
                  size="small"
                  label={p.name}
                  placeholder={p.placeholder}
                  value={paramValues[i] || ''}
                  onChange={(e) => setParamValues(v => ({ ...v, [i]: e.target.value }))}
                />
              ))}
            </DialogContent>
            <DialogActions className={classes.dialogActions}>
              <Button
                variant="outlined"
                size="small"
                onClick={() => setPendingCmd(null)}
                style={{ fontSize: 12 }}
              >
                Cancel
              </Button>
              <Button
                variant="contained"
                color="primary"
                size="small"
                onClick={handleModalSubmit}
                style={{ fontSize: 12 }}
              >
                <FontAwesomeIcon icon={['fas', 'play']} style={{ marginRight: 6, fontSize: 10 }} />
                Execute
              </Button>
            </DialogActions>
          </>
        )}
      </Dialog>
    </div>
  );
};
