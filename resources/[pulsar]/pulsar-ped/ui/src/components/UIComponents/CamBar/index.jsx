import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { IconButton } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Nui from '../../../util/Nui';

const useStyles = makeStyles(() => ({
	wrapper: {
		position: 'absolute',
		left: 12,
		top: '50%',
		transform: 'translateY(-50%)',
		display: 'flex',
		flexDirection: 'column',
		gap: 6,
		padding: '10px 8px',
		background: 'rgba(0,0,0,0.72)',
		border: '1px solid rgba(177,76,255,0.2)',
		boxShadow: '0 0 24px rgba(0,0,0,0.6), 0 0 16px rgba(177,76,255,0.06)',
		borderRadius: 2,
		zIndex: 15,
		animation: '$camSlide 0.4s cubic-bezier(0.16, 1, 0.3, 1) both',
	},
	divider: {
		height: 1,
		background: 'rgba(177,76,255,0.15)',
		margin: '2px 0',
	},
	button: {
		width: 40,
		height: 40,
		borderRadius: 2,
		color: 'rgba(255,255,255,0.4)',
		background: 'transparent',
		border: '1px solid transparent',
		transition: 'all 0.15s ease',
		'&:hover': {
			color: 'rgba(255,255,255,0.8)',
			background: 'rgba(177,76,255,0.1)',
			borderColor: 'rgba(177,76,255,0.25)',
		},
		'&.active': {
			color: '#b14cff',
			background: 'rgba(177,76,255,0.15)',
			borderColor: 'rgba(177,76,255,0.4)',
			boxShadow: '0 0 8px rgba(177,76,255,0.2)',
		},
	},
	'@keyframes camSlide': {
		'0%': { opacity: 0, transform: 'translateY(-50%) translateX(-16px)' },
		'100%': { opacity: 1, transform: 'translateY(-50%) translateX(0)' },
	},
}));

const cams = [
	{ icon: ['fas', 'person'], id: 0 },
	{ icon: ['fas', 'face-smile'], id: 1 },
	{ icon: ['fas', 'shirt'], id: 2 },
	{ icon: ['fas', 'shoe-prints'], id: 3 },
];

export default function CamBar() {
	const classes = useStyles();
	const dispatch = useDispatch();
	const camera = useSelector((state) => state.app.camera);

	const setCam = async (cam) => {
		try {
			const res = await (await Nui.send('ChangeCamera', cam)).json();
			if (res) {
				dispatch({ type: 'SET_CAM', payload: { cam } });
			}
		} catch (err) {}
	};

	return (
		<div className={classes.wrapper}>
			{cams.map((c, i) => (
				<React.Fragment key={c.id}>
					<IconButton
						className={`${classes.button}${camera === c.id ? ' active' : ''}`}
						onClick={() => setCam(c.id)}
					>
						<FontAwesomeIcon icon={c.icon} style={{ fontSize: 15 }} />
					</IconButton>
					{i < cams.length - 1 && <div className={classes.divider} />}
				</React.Fragment>
			))}
		</div>
	);
}
