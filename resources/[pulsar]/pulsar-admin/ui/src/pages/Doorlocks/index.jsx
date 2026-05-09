import React, { useEffect, useState } from "react";
import { useLocation } from "react-router-dom";
import { Grid, TextField, InputAdornment, IconButton, Pagination, Button } from "@material-ui/core";
import { makeStyles } from "@material-ui/styles";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

import Nui from "../../util/Nui";
import { Loader } from "../../components";

import Doorlock from "./Doorlock";

const useStyles = makeStyles((theme) => ({
  wrapper: {
    padding: '20px 10px 20px 20px',
    height: '100%',
    display: 'flex',
    flexDirection: 'column',
    boxSizing: 'border-box',
  },
  header: {
    flex: '0 0 auto',
    marginBottom: 14,
  },
  pageTitle: {
    display: 'flex',
    alignItems: 'center',
    gap: 8,
    fontSize: 11,
    fontWeight: 700,
    letterSpacing: '0.12em',
    textTransform: 'uppercase',
    color: theme.palette.text.info,
    marginBottom: 14,
    '&::before': {
      content: '""',
      display: 'inline-block',
      width: 3,
      height: 13,
      background: theme.palette.primary.main,
      borderRadius: 2,
    },
  },
  results: {
    flex: '1 1 auto',
    minHeight: 0,
    display: 'flex',
    flexDirection: 'column',
  },
  items: {
    flex: '1 1 auto',
    overflowY: 'auto',
    overflowX: 'hidden',
    paddingRight: 10,
  },
  actionBtn: {
    height: 40,
    fontSize: 12,
    fontWeight: 600,
    letterSpacing: '0.04em',
  },
}));

export default (props) => {
  const classes = useStyles();
  const location = useLocation();
  const PER_PAGE = 20;

  const [searched, setSearched] = useState("");
  const [pages, setPages] = useState(1);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(false);

  const [results, setResults] = useState(Array());
  const [doorlocks, setDoorlocks] = useState(Array());

  useEffect(() => {
    fetch();
  }, [location.pathname]);

  useEffect(() => {
    setPages(Math.ceil(doorlocks.length / PER_PAGE));
  }, [doorlocks]);

  useEffect(() => {
    setDoorlocks(
      results.filter((r) => {
        if (!searched) return true;

        return r.name.toLowerCase().includes(searched.toLowerCase()) || r.id === parseInt(searched);
      })
    );
  }, [results, searched]);

  const fetch = async () => {
    setLoading(true);

    try {
      let res = await (await Nui.send("GetDoorLocks", {})).json();
      if (res) setResults(res);
    } catch (e) {
      setResults([
        {
          id: 1,
          name: "Test Door 1",
          state: 1,
          coords: { x: 100.0, y: 200.0, z: 30.0 },
          maxDistance: 2.5,
        },
        {
          id: 2,
          name: "Test Door 2",
          state: 0,
          coords: { x: 150.0, y: 250.0, z: 30.0 },
          maxDistance: 3.0,
        },
      ]);
    }

    setLoading(false);
  };

  const onClear = () => {
    setSearched("");
  };

  const onPagi = (e, p) => {
    setPage(p);
  };

  const onAddNew = () => {
    window.location.hash = "#/doorlock/new";
  };

  const onRefresh = () => {
    fetch();
  };

  return (
    <div className={classes.wrapper}>
      <div className={classes.header}>
        <div className={classes.pageTitle}>Door Locks</div>
        <Grid container spacing={1}>
          <Grid item xs={6}>
            <Button
              fullWidth
              className={classes.actionBtn}
              variant="contained"
              color="primary"
              onClick={onAddNew}
            >
              <FontAwesomeIcon icon={['fas', 'plus']} style={{ marginRight: 8 }} />
              Create New
            </Button>
          </Grid>
          <Grid item xs={6}>
            <Button
              fullWidth
              className={classes.actionBtn}
              variant="outlined"
              onClick={onRefresh}
            >
              <FontAwesomeIcon icon={['fas', 'rotate-right']} style={{ marginRight: 8 }} />
              Refresh
            </Button>
          </Grid>
          <Grid item xs={12}>
            <TextField
              fullWidth
              variant="outlined"
              name="search"
              value={searched}
              onChange={(e) => setSearched(e.target.value)}
              label="Search by Name or ID"
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    {searched !== '' && (
                      <IconButton type="button" onClick={onClear}>
                        <FontAwesomeIcon icon={['fas', 'xmark']} />
                      </IconButton>
                    )}
                  </InputAdornment>
                ),
              }}
            />
          </Grid>
        </Grid>
      </div>
      <div className={classes.results}>
        {loading ? (
          <Loader text="Loading Doorlocks" />
        ) : (
          <>
            <div className={classes.items}>
              {doorlocks
                .slice((page - 1) * PER_PAGE, page * PER_PAGE)
                .sort((a, b) => a.id - b.id)
                .map((doorlock) => (
                  <Doorlock key={doorlock.id} doorlock={doorlock} onUpdate={fetch} />
                ))}
            </div>
            {pages > 1 && (
              <Pagination
                variant="outlined"
                shape="rounded"
                color="primary"
                page={page}
                count={pages}
                onChange={onPagi}
              />
            )}
          </>
        )}
      </div>
    </div>
  );
};
