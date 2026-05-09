import React from 'react';
import { makeStyles } from '@mui/styles';

const useStyles = makeStyles(() => ({
	inner: {
		paddingBottom: 12,
		overflow: 'hidden',
	},
	header: {
		position: 'relative',
		display: 'flex',
		alignItems: 'center',
		gap: 8,
		marginBottom: 14,
		paddingBottom: 8,
		borderBottom: '1px solid rgba(177,76,255,0.2)',
		width: '100%',
	},
	headerText: {
		fontFamily: "'Oswald', sans-serif",
		fontSize: 12,
		fontWeight: 700,
		letterSpacing: '0.25em',
		textTransform: 'uppercase',
		color: 'rgba(255,255,255,0.9)',
		textShadow: '0 0 8px rgba(177,76,255,0.45), 0 0 2px rgba(177,76,255,0.65)',
		userSelect: 'none',
		overflow: 'hidden',
		textOverflow: 'ellipsis',
		whiteSpace: 'nowrap',
		textAlign: 'center',
	},
	headerLine: {
		flex: 1,
		height: 1,
		background: 'linear-gradient(90deg, rgba(177,76,255,0.2), transparent)',
	},
	headerLineLeft: {
		transform: 'scaleX(-1)',
	},
}));

export default (props) => {
	const classes = useStyles();
	return (
		<div className={classes.inner}>
			{Boolean(props.label) && (
				<div className={classes.header}>
					<div className={`${classes.headerLine} ${classes.headerLineLeft}`} />
					<span className={classes.headerText}>{props.label}</span>
					<div className={classes.headerLine} />
				</div>
			)}
			<div className={props.bodyClass}>{props.children}</div>
		</div>
	);
};
