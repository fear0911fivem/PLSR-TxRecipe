import React, { useEffect, useState } from 'react';
import {
    Grid,
    TextField,
    InputAdornment,
    IconButton,
    Pagination,
    MenuItem,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Nui from '../../util/Nui';
import { Loader } from '../../components';

import Player from './Player';

const useStyles = makeStyles((theme) => ({
    wrapper: {
        padding: '20px 10px 20px 20px',
        height: '100%',
        display: 'flex',
        flexDirection: 'column',
        boxSizing: 'border-box',
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
    search: {
        flex: '0 0 auto',
        marginBottom: 12,
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
}));

export default (props) => {
    const classes = useStyles();
    const PER_PAGE = 32;

    const [searched, setSearched] = useState('');
    const [includeLoggedOut, setIncludeLoggedOut] = useState(true);
    const [pages, setPages] = useState(1);
    const [page, setPage] = useState(1);
    const [loading, setLoading] = useState(false);

    const [results, setResults] = useState(Array());
    const [players, setPlayers] = useState(Array());

    useEffect(() => {
        fetch();
        // let interval = setInterval(() => fetch(), 60 * 1000);

        // return () => {
        //     clearInterval(interval);
        // }
    }, []);

    useEffect(() => {
        setPages(Math.ceil(players.length / PER_PAGE));
    }, [players]);

    useEffect(() => {
        setPlayers(results.filter((r) => {
            return (
                (r.Name.toLowerCase().includes(searched.toLowerCase())) ||
                (r.AccountID == parseInt(searched)) ||
                (r.Character && `${r.Character?.First} ${r.Character?.Last}`.toLowerCase().includes(searched.toLowerCase())) ||
                (r.Character && (r.Character.SID == parseInt(searched)))
            ) && (r.Character || !includeLoggedOut)
        }));
    }, [results, searched, includeLoggedOut]);

    const fetch = async () => {
        setLoading(true);

        try {
            let res = await (await Nui.send('GetPlayerList', {
                disconnected: false,
            })).json()
            if (res) setResults(res);
        } catch (e) {
            setResults([
                {
                    AccountID: 1,
                    Source: 1,
                    Name: 'Dr Nick',
                    Character: {
                        First: 'Walter',
                        Last: 'Western',
                        SID: 3
                    }
                },
                {
                    AccountID: 2,
                    Source: 2,
                    Name: 'Panda',
                    // Character: {
                    //     First: 'Willy',
                    //     Last: 'Western',
                    //     SID: 4
                    // }
                },
            ])
            //console.log(e)
        }

        setLoading(false)
    }

    const onClear = () => {
        setSearched('');
    };

    const onPagi = (e, p) => {
        setPage(p);
    };

    return (
        <div className={classes.wrapper}>
            <div className={classes.pageTitle}>Online Players</div>
            <div className={classes.search}>
                <Grid container spacing={1}>
                    <Grid item xs={4}>
                        <TextField
                            select
                            fullWidth
                            label="Filter"
                            className={classes.editorField}
                            value={includeLoggedOut}
                            onChange={(e) => setIncludeLoggedOut(e.target.value)}
                        >
                            <MenuItem key={'include-logged-out'} value={false}>
                                Show All
                            </MenuItem>
                            <MenuItem key={'exclude-logged-out'} value={true}>
                                Logged In
                            </MenuItem>
                        </TextField>
                    </Grid>
                    <Grid item xs={8}>
                        <TextField
                            fullWidth
                            variant="outlined"
                            name="search"
                            value={searched}
                            onChange={(e) => setSearched(e.target.value)}
                            label="Search"
                            InputProps={{
                                endAdornment: (
                                    <InputAdornment position="end">
                                        {searched != '' && (
                                            <IconButton
                                                type="button"
                                                onClick={onClear}
                                            >
                                                <FontAwesomeIcon
                                                    icon={['fas', 'xmark']}
                                                />
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
                    <Loader text="Loading" />
                ) : (
                    <>
                        <div className={classes.items}>
                            {players
                                .slice((page - 1) * PER_PAGE, page * PER_PAGE)
                                .sort((a, b) => b.Source - a.Source)
                                .map((p) => (
                                    <Player key={p.Source} player={p} />
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
