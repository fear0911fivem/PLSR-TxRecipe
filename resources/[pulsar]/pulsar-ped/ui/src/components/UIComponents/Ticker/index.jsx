import React from 'react';
import { useDispatch } from 'react-redux';
import { TextField, IconButton } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Nui from '../../../util/Nui';

const useStyles = makeStyles(() => ({
	div: {
		boxSizing: 'border-box',
		width: '100%',
		display: 'block',
		fontSize: 12,
		fontFamily: "'Oswald', sans-serif",
		fontWeight: 600,
		textAlign: 'center',
		borderRadius: 2,
		transition: '0.1s all linear',
		userSelect: 'none',
		color: '#ffffff',
		marginBottom: 4,
		background: 'rgba(0,0,0,0.3)',
		border: '1px solid rgba(177,76,255,0.35)',
		padding: '6px 8px',
	},
	label: {
		display: 'block',
		gridColumn: 2,
		gridRow: 1,
		letterSpacing: '0.08em',
		textTransform: 'uppercase',
		color: 'rgba(255,255,255,0.7)',
		fontSize: 11,
		lineHeight: '32px',
	},
	wrapper: {
		display: 'grid',
		gridTemplateColumns: '36px 1fr 36px',
		gridTemplateRows: '32px 36px',
		alignItems: 'center',
	},
	actionBtn: {
		width: 32,
		height: 32,
		borderRadius: 2,
		color: 'rgba(177,76,255,0.8)',
		border: '1px solid rgba(177,76,255,0.3)',
		background: 'rgba(177,76,255,0.1)',
		transition: 'all 0.15s ease',
		'&:hover:not(.disabled)': {
			color: '#b14cff',
			borderColor: 'rgba(177,76,255,0.6)',
			background: 'rgba(177,76,255,0.22)',
		},
		'&.disabled': {
			opacity: 0.3,
			cursor: 'default',
		},
	},
	valueBox: {
		gridColumn: 2,
		gridRow: 2,
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'center',
		gap: 4,
		fontSize: 13,
		color: '#c97dff',
		fontWeight: 700,
	},
	textField: {
		width: 32,
		'& input': {
			textAlign: 'center',
			color: '#c97dff',
			fontFamily: "'Oswald', sans-serif",
			fontWeight: 700,
			fontSize: 14,
			padding: '2px 0',
		},
		'& input::-webkit-outer-spin-button, & input::-webkit-inner-spin-button': {
			display: 'none',
		},
		'& .MuiInput-underline:before': {
			borderBottomColor: 'rgba(177,76,255,0.3)',
		},
		'& .MuiInput-underline:after': {
			borderBottomColor: '#b14cff',
		},
	},
	maxLabel: {
		color: 'rgba(255,255,255,0.4)',
		fontSize: 12,
		fontWeight: 600,
	},
}));

export default (props) => {
	const classes = useStyles();
	const dispatch = useDispatch();

	const min = props.min ?? 0;
	const max = props.max;

	const sendValue = (v) => {
		Nui.send('FrontEndSound', { sound: 'UPDOWN' });
		if (Boolean(props.onChange)) {
			props.onChange(v, props.data);
		} else {
			dispatch(props.event(v, props.data));
		}
	};

	const onLeft = () => {
		if (props.disabled) return;
		sendValue(props.current - 1 < min ? max : props.current - 1);
	};

	const onRight = () => {
		if (props.disabled) return;
		sendValue(props.current + 1 > max ? min : props.current + 1);
	};

	const updateIndex = (event) => {
		if (props.disabled) return;
		try {
			const raw = event.target.value;
			if (raw === '') return;
			let v = parseInt(raw, 10);
			if (Number.isNaN(v)) return;
			if (v > max) v = min;
			else if (v < min) v = max;
			sendValue(v);
		} catch (err) {}
	};

	const style = props.disabled ? { opacity: 0.4 } : {};

	return (
		<div className={classes.div} style={style}>
			<div className={classes.wrapper}>
				<span className={classes.label} style={{ gridColumn: 2, gridRow: 1 }}>
					{props.label}
				</span>
				<IconButton
					className={`${classes.actionBtn}${props.disabled ? ' disabled' : ''}`}
					onClick={onLeft}
					style={{ gridColumn: 1, gridRow: 2 }}
				>
					<FontAwesomeIcon icon={['fas', 'chevron-left']} style={{ fontSize: 11 }} />
				</IconButton>
				<div className={classes.valueBox}>
					<TextField
						variant="standard"
						value={props.current}
						className={classes.textField}
						onChange={updateIndex}
						disabled={props.disabled}
						type="number"
						inputProps={{ min, max, step: 1 }}
					/>
					<span className={classes.maxLabel}>/ {max}</span>
				</div>
				<IconButton
					className={`${classes.actionBtn}${props.disabled ? ' disabled' : ''}`}
					onClick={onRight}
					style={{ gridColumn: 3, gridRow: 2 }}
				>
					<FontAwesomeIcon icon={['fas', 'chevron-right']} style={{ fontSize: 11 }} />
				</IconButton>
			</div>
		</div>
	);
};
