import React from 'react';
import { makeStyles } from '@mui/styles';

const useStyles = makeStyles(() => ({
	backdrop: {
		position: 'fixed',
		inset: 0,
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'center',
		background: 'rgba(0,0,0,0.72)',
		zIndex: 9999,
	},
	card: {
		display: 'flex',
		flexDirection: 'column',
		alignItems: 'center',
		gap: 20,
		padding: '32px 48px',
		background: 'rgba(0,0,0,0.8)',
		border: '1px solid rgba(177,76,255,0.25)',
		borderRadius: 2,
		boxShadow: '0 0 0 1px rgba(177,76,255,0.08), 0 24px 60px rgba(0,0,0,0.8)',
	},
	spinnerWrap: {
		position: 'relative',
		width: 48,
		height: 48,
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'center',
	},
	spinnerOuter: {
		width: 48,
		height: 48,
		border: '2px solid rgba(177,76,255,0.15)',
		borderTop: '2px solid #b14cff',
		borderRadius: '50%',
		animation: '$spin 0.8s linear infinite',
		position: 'absolute',
	},
	spinnerInner: {
		width: 32,
		height: 32,
		border: '2px solid rgba(177,76,255,0.08)',
		borderBottom: '2px solid rgba(201,125,255,0.6)',
		borderRadius: '50%',
		animation: '$spinReverse 1.2s linear infinite',
		position: 'absolute',
	},
	dot: {
		width: 6,
		height: 6,
		borderRadius: '50%',
		background: '#b14cff',
		boxShadow: '0 0 8px rgba(177,76,255,0.8)',
	},
	label: {
		fontFamily: "'Oswald', sans-serif",
		fontSize: 11,
		fontWeight: 600,
		letterSpacing: '0.25em',
		textTransform: 'uppercase',
		color: 'rgba(177,76,255,0.7)',
		animation: '$pulse 2s ease-in-out infinite',
	},
	'@keyframes spin': {
		'0%': { transform: 'rotate(0deg)' },
		'100%': { transform: 'rotate(360deg)' },
	},
	'@keyframes spinReverse': {
		'0%': { transform: 'rotate(0deg)' },
		'100%': { transform: 'rotate(-360deg)' },
	},
	'@keyframes pulse': {
		'0%, 100%': { opacity: 1 },
		'50%': { opacity: 0.4 },
	},
}));

export default () => {
	const classes = useStyles();
	return (
		<div className={classes.backdrop}>
			<div className={classes.card}>
				<div className={classes.spinnerWrap}>
					<div className={classes.spinnerOuter} />
					<div className={classes.spinnerInner} />
					<div className={classes.dot} />
				</div>
				<span className={classes.label}>Loading...</span>
			</div>
		</div>
	);
};
