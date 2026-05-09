import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Tab, Tabs, Button } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import { TabPanel, Dialog } from '../../components/UIComponents';
import { CurrencyFormat } from '../../util/Parser';
import { SavePed, CancelEdits } from '../../actions/pedActions';
import Hair from '../../components/Hair/Hair';
import FaceMakeup from '../../components/Face/FaceMakeup/FaceMakeup';
import Wrapper from '../../components/UIComponents/Wrapper/Wrapper';
import Naked from '../../components/PedComponents/Naked';
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
		gap: 8,
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
		border: 'none !important',
		outline: 'none !important',
		boxShadow: 'none !important',
		transition: 'background 150ms ease, transform 150ms ease',
		'&:hover': { border: 'none !important', outline: 'none !important', boxShadow: 'none !important', transform: 'translateY(-1px)' },
		'&:focus': { border: 'none !important', outline: 'none !important', boxShadow: 'none !important' },
		'&:active': { transform: 'translateY(0)', border: 'none !important', outline: 'none !important', boxShadow: 'none !important' },
		'& .MuiButton-startIcon': { marginRight: 6 },
		'& .MuiButton-startIcon svg': { fontSize: 11 },
	},
	btnPrimary: {
		background: 'rgba(177,76,255,0.15)',
		color: '#c97dff',
		'&:hover': { background: 'rgba(177,76,255,0.28)' },
	},
	btnDanger: {
		background: 'rgba(110,22,22,0.15)',
		color: '#a13434',
		'&:hover': { background: 'rgba(110,22,22,0.28)' },
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
	const cost = useSelector((state) => state.app.pricing.BARBER);

	const [cancelling, setCancelling] = useState(false);
	const [saving, setSaving] = useState(false);
	const [value, setValue] = useState(0);

	const handleChange = (event, newValue) => setValue(newValue);

	const onCancel = () => {
		setCancelling(false);
		dispatch(CancelEdits());
	};

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
					<span className={classes.panelLabel}>Barber Shop</span>
					<span className={classes.panelTitle}>Style Your Look</span>
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
						<Tab className={classes.tab} label={<FontAwesomeIcon icon={['fas', 'scissors']} />} />
						<Tab className={classes.tab} label={<FontAwesomeIcon icon={['fas', 'paintbrush']} />} />
					</Tabs>
				</div>
				<div className={classes.panelBody} id="noHover">
					<TabPanel value={value} index={0}><Hair /></TabPanel>
					<TabPanel value={value} index={1}><Wrapper><FaceMakeup /></Wrapper></TabPanel>
				</div>
				<div className={classes.panelFooter}>
					<Button disableRipple disableElevation variant="text" className={`${classes.btn} ${classes.btnDanger}`} onClick={() => setCancelling(true)} startIcon={<FontAwesomeIcon icon={['fas', 'chair']} />}>
						Leave Barber Chair
					</Button>
					<Button disableRipple disableElevation variant="text" className={`${classes.btn} ${classes.btnPrimary}`} onClick={() => setSaving(true)} startIcon={<FontAwesomeIcon icon={['fas', 'save']} />}>
						Pay {CurrencyFormat.format(cost || 0)}
					</Button>
				</div>
			</div>

			<Naked />

			<Dialog title="Cancel?" open={cancelling} onAccept={onCancel} onDecline={() => setCancelling(false)} acceptLang="Yes" declineLang="No">
				<p>All changes will be discarded, are you sure you want to continue?</p>
			</Dialog>
			<Dialog title="Save Haircut?" open={saving} onAccept={onSave} onDecline={() => setSaving(false)}>
				<p>You will be charged <span style={{ color: '#b14cff', fontWeight: 700 }}>{CurrencyFormat.format(cost)}</span>?</p>
				<p>Are you sure you want to save?</p>
			</Dialog>
		</div>
	);
};
