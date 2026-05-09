import React, { useEffect, useState } from 'react';
import { makeStyles } from '@material-ui/styles';
import moment from 'moment';

import {
    ResponsiveContainer,
    AreaChart,
    Area,
    XAxis,
    YAxis,
    CartesianGrid,
    Tooltip
} from 'recharts';

const useStyles = makeStyles((theme) => ({
    tooltipBox: {
        background: theme.palette.secondary.dark,
        border: `1px solid ${theme.palette.border.divider}`,
        borderRadius: 4,
        padding: '8px 12px',
        fontSize: 12,
        color: theme.palette.text.main,
    },
    tooltipLabel: {
        color: theme.palette.text.info,
        fontSize: 11,
        marginBottom: 3,
    },
}));

const CustomTooltip = ({ active, payload, label }) => {
    const classes = useStyles();
    if (active && payload && payload.length) {
        return (
            <div className={classes.tooltipBox}>
                <div className={classes.tooltipLabel}>{label}</div>
                <strong>{payload[0].value} players</strong>
            </div>
        );
    }
    return null;
};

export default ({ current, history }) => {
    const [pHistory, setPHistory] = useState([]);

    useEffect(() => {
        if (!history || !Array.isArray(history)) {
            setPHistory([{ name: 'Now', count: current ?? 0 }]);
            return;
        }

        const now = moment().unix();
        const cunts = history.map(h => ({
            ...h,
            name: moment.unix(h.time).format('HH:mm'),
        }));

        cunts.push({ time: now, count: current ?? 0, name: 'Now' });
        setPHistory(cunts);
    }, [history, current]);

    return (
        <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={pHistory} margin={{ top: 8, right: 16, left: -20, bottom: 0 }}>
                <defs>
                    <linearGradient id="purpleFill" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#7C3AED" stopOpacity={0.25} />
                        <stop offset="95%" stopColor="#7C3AED" stopOpacity={0} />
                    </linearGradient>
                </defs>
                <CartesianGrid
                    strokeDasharray="3 3"
                    stroke="#1A1A2E"
                    vertical={false}
                />
                <XAxis
                    dataKey="name"
                    tick={{ fill: '#64748B', fontSize: 11 }}
                    axisLine={{ stroke: '#1A1A2E' }}
                    tickLine={false}
                />
                <YAxis
                    allowDecimals={false}
                    tick={{ fill: '#64748B', fontSize: 11 }}
                    axisLine={false}
                    tickLine={false}
                />
                <Tooltip content={<CustomTooltip />} cursor={{ stroke: '#7C3AED40', strokeWidth: 1 }} />
                <Area
                    type="monotone"
                    dataKey="count"
                    stroke="#7C3AED"
                    strokeWidth={2}
                    fill="url(#purpleFill)"
                    dot={false}
                    activeDot={{ r: 4, fill: '#A78BFA', stroke: '#7C3AED', strokeWidth: 2 }}
                />
            </AreaChart>
        </ResponsiveContainer>
    );
};
