import React, { useEffect, useState } from 'react';
import {
    TextField,
    InputAdornment,
    IconButton,
    Pagination,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Nui from '../../util/Nui';
import { Loader } from '../../components';

import Vehicle from './Vehicle';

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
    const [pages, setPages] = useState(1);
    const [page, setPage] = useState(1);
    const [loading, setLoading] = useState(false);

    const [results, setResults] = useState(Array());
    const [vehicles, setVehicles] = useState(Array());

    useEffect(() => {
        fetch();
        // let interval = setInterval(() => fetch(), 60 * 1000);

        // return () => {
        //     clearInterval(interval);
        // }
    }, []);

    useEffect(() => {
        setPages(Math.ceil(vehicles.length / PER_PAGE));
    }, [vehicles]);

    useEffect(() => {
        setVehicles(results.filter((r) => {
            return (
                (`${r?.Make} ${r?.Model}`.toLowerCase().includes(searched.toLowerCase())) ||
                (r.Plate.toUpperCase().includes(searched.toUpperCase())) ||
                (r.VIN.toUpperCase() == searched.toUpperCase()) ||
                (r.OwnerId.toString().includes(searched.toLowerCase()))
            )
        }));
    }, [results, searched]);

    const fetch = async () => {
        setLoading(true);

        try {
            let res = await (await Nui.send('GetVehicleList', {})).json()
            if (res) setResults(res);
        } catch (e) {
            // setResults([
            //     {
            //         OwnerId: 'police',
            //         Entity: 1,
            //         Plate: 'TWAT',
            //         Make: 'Ford',
            //         Model: 'CVPI',
            //         VIN: "RWAAAAAAAAAAAAAAAAAAAAAA",
            //     },
            //     {
            //         OwnerId: 1,
            //         Entity: 1,
            //         Plate: 'TWAT',
            //         Make: 'Ford',
            //         Model: 'CVPI',
            //         VIN: "RWAAAAAAAAAAAAAAAAAAAAAA",
            //     },
            // ])
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
            <div className={classes.pageTitle}>Active Vehicles</div>
            <div className={classes.search}>
                <TextField
                    fullWidth
                    variant="outlined"
                    name="search"
                    value={searched}
                    onChange={(e) => setSearched(e.target.value)}
                    label="Search by make, model, plate or VIN"
                    InputProps={{
                        endAdornment: (
                            <InputAdornment position="end">
                                {searched != '' && (
                                    <IconButton type="button" onClick={onClear}>
                                        <FontAwesomeIcon icon={['fas', 'xmark']} />
                                    </IconButton>
                                )}
                            </InputAdornment>
                        ),
                    }}
                />
            </div>
            <div className={classes.results}>
                {loading ? (
                    <Loader text="Loading" />
                ) : (
                    <>
                        <div className={classes.items}>
                            {vehicles
                                .slice((page - 1) * PER_PAGE, page * PER_PAGE)
                                .map((p) => (
                                    <Vehicle key={p.Entity} vehicle={p} />
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
