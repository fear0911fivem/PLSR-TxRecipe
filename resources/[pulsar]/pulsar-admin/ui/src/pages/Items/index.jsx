import React, { useEffect, useState, useMemo } from 'react';
import {
  TextField,
  InputAdornment,
  IconButton,
  Pagination,
  MenuItem,
  CircularProgress,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Nui from '../../util/Nui';
import ItemCard from './ItemCard';
import ItemModal from './ItemModal';

const ITEM_TYPES = {
  0: 'All Types',
  1: 'Consumable',
  2: 'Weapon',
  3: 'Tool',
  4: 'Crafting',
  5: 'Collectible',
  6: 'Junk',
  7: 'Unknown',
  8: 'Evidence',
  9: 'Ammo',
  10: 'Container',
  11: 'Gem',
  12: 'Paraphernalia',
  13: 'Wearable',
  14: 'Contraband',
  15: 'Gang Chain',
  16: 'Attachment',
  17: 'Schematic',
};

const RARITY_LABELS = {
  '-1': 'All Rarities',
  0: 'None',
  1: 'Common',
  2: 'Uncommon',
  3: 'Rare',
  4: 'Epic',
  5: 'Special',
};

const PER_PAGE = 30;

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
  filters: {
    display: 'flex',
    gap: 8,
  },
  searchField: {
    flex: 1,
  },
  selectField: {
    width: 160,
  },
  countBadge: {
    fontSize: 11,
    color: theme.palette.text.info,
    letterSpacing: '0.04em',
    marginTop: 4,
  },
  grid: {
    flex: 1,
    overflowY: 'auto',
    overflowX: 'hidden',
    display: 'grid',
    gridTemplateColumns: 'repeat(5, 1fr)',
    gap: 10,
    alignContent: 'start',
    paddingRight: 4,
  },
  centered: {
    gridColumn: '1 / -1',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '60px 0',
    gap: 12,
    color: theme.palette.text.info,
    '& svg': {
      fontSize: 36,
      color: '#1A1A2E',
    },
  },
  emptyText: {
    fontSize: 14,
    color: theme.palette.text.info,
  },
  pagination: {
    flexShrink: 0,
    display: 'flex',
    justifyContent: 'center',
    paddingTop: 8,
    '& .MuiPaginationItem-root': {
      borderColor: theme.palette.border.divider,
      color: theme.palette.text.alt,
      borderRadius: 4,
      '&.Mui-selected': {
        background: theme.palette.primary.main,
        borderColor: theme.palette.primary.main,
        color: '#fff',
      },
    },
  },
}));

export default () => {
  const classes = useStyles();
  const [items, setItems] = useState([]);
  const [players, setPlayers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [search, setSearch] = useState('');
  const [typeFilter, setTypeFilter] = useState(0);
  const [rarityFilter, setRarityFilter] = useState(-1);
  const [page, setPage] = useState(1);
  const [selectedItem, setSelectedItem] = useState(null);

  useEffect(() => {
    fetchItems();
    fetchPlayers();
  }, []);

  const fetchItems = async () => {
    setLoading(true);
    try {
      const res = await (await Nui.send('GetItemList', {})).json();
      if (Array.isArray(res)) {
        setItems(res.sort((a, b) => (a.label || '').localeCompare(b.label || '')));
      }
    } catch (e) {
      setItems([]);
    }
    setLoading(false);
  };

  const fetchPlayers = async () => {
    try {
      const res = await (await Nui.send('GetPlayerList', { disconnected: false })).json();
      if (Array.isArray(res)) setPlayers(res);
    } catch (e) {
      setPlayers([]);
    }
  };

  const filtered = useMemo(() => {
    return items.filter(item => {
      const matchSearch = !search
        || (item.label || '').toLowerCase().includes(search.toLowerCase())
        || (item.name || '').toLowerCase().includes(search.toLowerCase());
      const matchType = typeFilter === 0 || item.type === typeFilter;
      const matchRarity = rarityFilter === -1 || item.rarity === rarityFilter;
      return matchSearch && matchType && matchRarity;
    });
  }, [items, search, typeFilter, rarityFilter]);

  const pages = Math.max(1, Math.ceil(filtered.length / PER_PAGE));
  const pageItems = filtered.slice((page - 1) * PER_PAGE, page * PER_PAGE);

  const onFilterChange = (setter) => (e) => {
    setter(e.target.value);
    setPage(1);
  };

  return (
    <div className={classes.wrapper}>
      <div className={classes.header}>
        <div className={classes.pageTitle}>
          <FontAwesomeIcon icon={['fas', 'box-open']} />
          Item Database
        </div>
        <div className={classes.filters}>
          <TextField
            className={classes.searchField}
            variant="outlined"
            size="small"
            placeholder="Search by name or label..."
            value={search}
            onChange={onFilterChange(setSearch)}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <FontAwesomeIcon icon={['fas', 'magnifying-glass']} style={{ color: '#4B5563', fontSize: 13 }} />
                </InputAdornment>
              ),
              endAdornment: search ? (
                <InputAdornment position="end">
                  <IconButton size="small" onClick={() => { setSearch(''); setPage(1); }}>
                    <FontAwesomeIcon icon={['fas', 'xmark']} style={{ fontSize: 12 }} />
                  </IconButton>
                </InputAdornment>
              ) : null,
            }}
          />
          <TextField
            select
            className={classes.selectField}
            variant="outlined"
            size="small"
            label="Type"
            value={typeFilter}
            onChange={onFilterChange(setTypeFilter)}
          >
            {Object.entries(ITEM_TYPES).map(([k, v]) => (
              <MenuItem key={k} value={parseInt(k)}>{v}</MenuItem>
            ))}
          </TextField>
          <TextField
            select
            className={classes.selectField}
            variant="outlined"
            size="small"
            label="Rarity"
            value={rarityFilter}
            onChange={onFilterChange(setRarityFilter)}
          >
            {Object.entries(RARITY_LABELS).map(([k, v]) => (
              <MenuItem key={k} value={parseInt(k)}>{v}</MenuItem>
            ))}
          </TextField>
        </div>
        <div className={classes.countBadge}>
          {filtered.length} item{filtered.length !== 1 ? 's' : ''} found
        </div>
      </div>

      <div className={classes.grid}>
        {loading ? (
          <div className={classes.centered}>
            <CircularProgress size={28} style={{ color: '#7C3AED' }} />
            <span className={classes.emptyText}>Loading items...</span>
          </div>
        ) : pageItems.length === 0 ? (
          <div className={classes.centered}>
            <FontAwesomeIcon icon={['fas', 'box-open']} />
            <span className={classes.emptyText}>No items found</span>
          </div>
        ) : (
          pageItems.map(item => (
            <ItemCard
              key={item.name}
              item={item}
              onClick={setSelectedItem}
            />
          ))
        )}
      </div>

      {pages > 1 && (
        <div className={classes.pagination}>
          <Pagination
            variant="outlined"
            shape="rounded"
            page={page}
            count={pages}
            onChange={(e, p) => setPage(p)}
          />
        </div>
      )}

      <ItemModal
        open={Boolean(selectedItem)}
        item={selectedItem}
        players={players}
        onClose={() => setSelectedItem(null)}
      />
    </div>
  );
};
