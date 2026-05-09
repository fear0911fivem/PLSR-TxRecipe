import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Tab, Tabs, Button } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import { TabPanel, Dialog } from '../../components/UIComponents';
import { Face } from '../../components';
import { SavePed } from '../../actions/pedActions';
import Body from '../../components/Body/Body';
import Hair from '../../components/Hair/Hair';
import Clothes from '../../components/Clothes/Clothes';
import Tattoo from '../../components/Tattoos';
import Accessories from '../../components/Accessories/Accessories';
import Naked from '../../components/PedComponents/Naked';
import FaceMakeup from '../../components/Face/FaceMakeup/FaceMakeup';
import Wrapper from '../../components/UIComponents/Wrapper/Wrapper';
import CamBar from '../../components/UIComponents/CamBar';

const useStyles = makeStyles(() => ({
	panelShell: {
		position: 'absolute',
		right: 20,
		top: '4vh',
		width: 500,
		height: '92vh',
		display: 'flex',
		flexDirection: 'column',
		background: 'rgba(0,0,0,0.78)',
		border: '1px solid rgba(177,76,255,0.2)',
		boxShadow: '0 0 0 1px rgba(177,76,255,0.06), 0 24px 80px rgba(0,0,0,0.7), 0 0 40px rgba(177,76,255,0.06)',
		borderRadius: 2,
		overflow: 'hidden',
		animation: '$panelSlide 0.5s cubic-bezier(0.16, 1, 0.3, 1) both',
	},
	panelAccent: {
		height: 2,
		background: 'linear-gradient(90deg, transparent, #b14cff, transparent)',
		flexShrink: 0,
	},
	panelHeader: {
		padding: '12px 16px 10px',
		borderBottom: '1px solid rgba(177,76,255,0.15)',
		flexShrink: 0,
		display: 'flex',
		flexDirection: 'column',
		background: 'rgba(0,0,0,0.24)',
	},
	panelLabel: {
		fontSize: 9,
		fontWeight: 700,
		letterSpacing: '0.3em',
		textTransform: 'uppercase',
		color: 'rgba(177,76,255,0.7)',
		marginBottom: 2,
		fontFamily: "'Oswald', sans-serif",
	},
	panelTitle: {
		fontFamily: "'Oswald', sans-serif",
		fontSize: 13,
		fontWeight: 700,
		color: '#ffffff',
		letterSpacing: '0.08em',
	},
	tabHeader: {
		flex: '0 0 auto',
		borderBottom: '1px solid rgba(177,76,255,0.15)',
	},
	tabs: { minHeight: 42 },
	tab: {
		minHeight: 42,
		minWidth: 0,
		flex: 1,
		padding: 0,
		opacity: 0.45,
		color: '#ffffff',
		fontSize: 15,
		transition: 'opacity 0.2s ease, color 0.2s ease',
		'&.Mui-selected': { opacity: 1, color: '#b14cff' },
		'& svg': { fontSize: 16 },
	},
	panelBody: {
		flex: '1 1 auto',
		overflowY: 'auto',
		padding: 12,
	},
	panelFooter: {
		flexShrink: 0,
		borderTop: '1px solid rgba(177,76,255,0.15)',
		background: 'rgba(0,0,0,0.24)',
		padding: '10px 12px',
		display: 'flex',
		justifyContent: 'flex-end',
	},
	btn: {
		height: 34,
		padding: '0 16px',
		borderRadius: 2,
		textTransform: 'uppercase',
		fontSize: 11,
		fontWeight: 700,
		fontFamily: "'Oswald', sans-serif",
		letterSpacing: '0.15em',
		boxShadow: 'none',
		transition: 'all 150ms ease',
		'& .MuiButton-startIcon': { marginRight: 6 },
		'& .MuiButton-startIcon svg': { fontSize: 11 },
	},
	btnPrimary: {
		color: '#c97dff',
		background: 'transparent',
		border: '1px solid rgba(177,76,255,0.45)',
		'&:hover': {
			background: 'rgba(177,76,255,0.12)',
			borderColor: 'rgba(201,125,255,0.7)',
			boxShadow: '0 0 10px rgba(177,76,255,0.25)',
			transform: 'translateY(-1px)',
		},
	},
	'@keyframes panelSlide': {
		'0%': { opacity: 0, transform: 'translateX(40px)' },
		'100%': { opacity: 1, transform: 'translateX(0)' },
	},
}));

export default (props) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const state = useSelector((state) => state.app.state);

	const [saving, setSaving] = useState(false);
	const [value, setValue] = useState(0);

	const handleChange = (event, newValue) => setValue(newValue);

	const onSave = () => {
		setSaving(false);
		dispatch(SavePed(state));
	};

	return (
		<div>
			<CamBar />
			<div className={classes.panelShell}>
				<div className={classes.panelAccent} />
				<div className={classes.panelHeader}>
					<span className={classes.panelLabel}>Character Creation</span>
					<span className={classes.panelTitle}>Create Your Character</span>
				</div>
				<div className={classes.tabHeader}>
					<Tabs
						orientation="horizontal"
						value={value}
						onChange={handleChange}
						indicatorColor="primary"
						textColor="primary"
						variant="fullWidth"
						className={classes.tabs}
					>
						<Tab className={classes.tab} label={<FontAwesomeIcon icon={['fas', 'face-smile']} />} />
						<Tab className={classes.tab} label={<FontAwesomeIcon icon={['fas', 'child-reaching']} />} />
						<Tab className={classes.tab} label={<FontAwesomeIcon icon={['fas', 'scissors']} />} />
						<Tab className={classes.tab} label={<FontAwesomeIcon icon={['fas', 'paintbrush']} />} />
						<Tab className={classes.tab} label={<FontAwesomeIcon icon={['fas', 'shirt']} />} />
						<Tab className={classes.tab} label={<FontAwesomeIcon icon={['fas', 'hat-cowboy']} />} />
						<Tab className={classes.tab} label={<FontAwesomeIcon icon={['fas', 'anchor']} />} />
					</Tabs>
				</div>
				<div className={classes.panelBody} id="noHover">
					<TabPanel value={value} index={0}><Face /></TabPanel>
					<TabPanel value={value} index={1}><Body /></TabPanel>
					<TabPanel value={value} index={2}><Hair /></TabPanel>
					<TabPanel value={value} index={3}><Wrapper><FaceMakeup /></Wrapper></TabPanel>
					<TabPanel value={value} index={4}><Clothes /></TabPanel>
					<TabPanel value={value} index={5}><Accessories /></TabPanel>
					<TabPanel value={value} index={6}><Tattoo /></TabPanel>
				</div>
				<div className={classes.panelFooter}>
					<Button
						className={`${classes.btn} ${classes.btnPrimary}`}
						onClick={() => setSaving(true)}
						startIcon={<FontAwesomeIcon icon={['fas', 'save']} />}
					>
						Finished, Lets Spawn
					</Button>
				</div>
			</div>

			<Naked />

			<Dialog
				title="Create Character Ped?"
				open={saving}
				onAccept={onSave}
				onDecline={() => setSaving(false)}
			>
				<p>Are you sure you want to save?</p>
				<p>
					You may not be able to edit some things after this screen,
					ensure you are totally done creating your character before
					you continue!
				</p>
			</Dialog>
		</div>
	);
};
