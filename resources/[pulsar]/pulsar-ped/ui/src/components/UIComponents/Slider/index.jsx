import React, { useState } from 'react';
import { Grid, Slider as MSlider, Tooltip } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { useDispatch } from 'react-redux';

import Nui from '../../../util/Nui';

const useStyles = makeStyles(() => ({
	div: {
		boxSizing: 'border-box',
		width: '100%',
		minHeight: 84,
		fontSize: 12,
		fontFamily: "'Oswald', sans-serif",
		fontWeight: 600,
		textAlign: 'center',
		display: 'flex',
		flexDirection: 'column',
		justifyContent: 'center',
		padding: '8px 14px',
		borderRadius: 2,
		transition: '0.1s all linear',
		userSelect: 'none',
		color: '#ffffff',
		marginBottom: 4,
		background: 'rgba(0,0,0,0.3)',
		border: '1px solid rgba(177,76,255,0.35)',
	},
	label: {
		display: 'block',
		width: '100%',
		letterSpacing: '0.08em',
		textTransform: 'uppercase',
		color: 'rgba(255,255,255,0.7)',
		fontSize: 11,
		marginBottom: 8,
	},
	slider: {
		display: 'block',
		'& .MuiSlider-thumb': {
			width: 12,
			height: 12,
			background: '#b14cff',
			border: '2px solid rgba(201,125,255,0.6)',
			'&:hover, &.Mui-focusVisible': {
				boxShadow: '0 0 0 6px rgba(177,76,255,0.2)',
			},
		},
		'& .MuiSlider-track': {
			background: 'linear-gradient(90deg, #7a22c9, #b14cff)',
			border: 'none',
		},
		'& .MuiSlider-rail': {
			background: 'rgba(177,76,255,0.2)',
		},
	},
}));

function ValueLabelComponent(props) {
	const { children, open, value } = props;
	return (
		<Tooltip open={open} enterTouchDelay={0} placement="top" title={value}>
			{children}
		</Tooltip>
	);
}

export default (props) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const [currentValue, setCurrentValue] = useState(props.current);

	const onChange = (event, newValue) => {
		if (!props.disabled) {
			setCurrentValue(newValue);
			dispatch(props.event(currentValue, props.data));
		}
	};

	const style = props.disabled ? { opacity: 0.4 } : {};

	return (
		<div className={classes.div} style={style}>
			<span className={classes.label}>{props.label}</span>
			<MSlider
				className={classes.slider}
				onChange={onChange}
				components={{ ValueLabel: ValueLabelComponent }}
				defaultValue={0}
				value={currentValue}
				disabled={props.disabled}
				step={1}
				min={props.min}
				max={props.max}
				component="div"
			/>
		</div>
	);
};
