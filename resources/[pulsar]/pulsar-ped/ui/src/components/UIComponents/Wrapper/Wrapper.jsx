import React from 'react';
import { makeStyles } from '@mui/styles';

const useStyles = makeStyles(() => ({
	wrapper: {
		padding: '20px 16px',
		color: '#ffffff',
		overflowX: 'hidden',
		overflowY: 'auto',
		'&::-webkit-scrollbar': { width: 4 },
		'&::-webkit-scrollbar-thumb': {
			background: 'rgba(177,76,255,0.3)',
			borderRadius: 2,
		},
		'&::-webkit-scrollbar-thumb:hover': {
			background: 'rgba(177,76,255,0.55)',
		},
		'&::-webkit-scrollbar-track': {
			background: 'transparent',
		},
	},
}));

export default (props) => {
	const classes = useStyles();
	return <div className={classes.wrapper}>{props.children}</div>;
};
