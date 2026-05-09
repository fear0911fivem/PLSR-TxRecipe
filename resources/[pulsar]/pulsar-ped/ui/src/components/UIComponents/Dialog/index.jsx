import React from 'react';
import {
	Dialog,
	DialogTitle,
	DialogContent,
	DialogActions,
	Button,
} from '@mui/material';
import { makeStyles } from '@mui/styles';

const useStyles = makeStyles(() => ({
	dialogPaper: {
		background: 'rgba(0,0,0,0.82)',
		border: '1px solid rgba(177,76,255,0.25)',
		borderRadius: 2,
		boxShadow: '0 0 0 1px rgba(177,76,255,0.08), 0 32px 80px rgba(0,0,0,0.8)',
		color: '#ffffff',
		minWidth: 380,
		overflow: 'hidden',
	},
	dialogAccent: {
		height: 2,
		background: 'linear-gradient(90deg, transparent, #b14cff, transparent)',
	},
	dialogTitle: {
		fontFamily: "'Oswald', sans-serif",
		fontSize: 14,
		fontWeight: 700,
		letterSpacing: '0.06em',
		color: '#ffffff',
		borderBottom: '1px solid rgba(177,76,255,0.15)',
		padding: '16px 20px 12px',
	},
	dialogContent: {
		fontFamily: "'Oswald', sans-serif",
		fontSize: 14,
		color: 'rgba(255,255,255,0.7)',
		letterSpacing: '0.02em',
		padding: '16px 20px',
		'& p': { margin: '0 0 8px', '&:last-child': { marginBottom: 0 } },
	},
	dialogActions: {
		padding: '12px 20px 16px',
		gap: 8,
		borderTop: '1px solid rgba(177,76,255,0.12)',
		display: 'flex',
	},
	btn: {
		flex: 1,
		height: 34,
		padding: '0 14px',
		borderRadius: 2,
		textTransform: 'uppercase',
		fontSize: 11,
		fontWeight: 700,
		fontFamily: "'Oswald', sans-serif",
		letterSpacing: '0.15em',
		color: 'rgba(255,255,255,0.6)',
		background: 'transparent',
		border: '1px solid rgba(255,255,255,0.15)',
		boxShadow: 'none',
		transition: 'all 150ms ease',
		'&:hover': {
			color: '#ffffff',
			borderColor: 'rgba(255,255,255,0.35)',
			background: 'rgba(255,255,255,0.05)',
		},
	},
	btnPrimary: {
		color: '#c97dff',
		background: 'rgba(177,76,255,0.15)',
		borderColor: 'rgba(177,76,255,0.5)',
		'&:hover': {
			background: 'rgba(177,76,255,0.3)',
			borderColor: '#c97dff',
			boxShadow: '0 0 10px rgba(177,76,255,0.3)',
		},
	},
	btnDanger: {
		color: '#a13434',
		background: 'rgba(110,22,22,0.12)',
		borderColor: 'rgba(110,22,22,0.4)',
		'&:hover': {
			background: 'rgba(110,22,22,0.25)',
			borderColor: '#a13434',
			boxShadow: '0 0 10px rgba(110,22,22,0.25)',
		},
	},
}));

export default ({
	open,
	title,
	onAccept,
	onDecline,
	children,
	declineLang = 'Cancel',
	acceptLang = 'Save',
}) => {
	const classes = useStyles();

	return (
		<Dialog
			fullWidth
			maxWidth="sm"
			open={open}
			onClose={onDecline}
			PaperProps={{ className: classes.dialogPaper }}
		>
			<div className={classes.dialogAccent} />
			<DialogTitle className={classes.dialogTitle} style={{ userSelect: 'none' }}>
				{title}
			</DialogTitle>
			<DialogContent className={classes.dialogContent}>
				{children}
			</DialogContent>
			<DialogActions className={classes.dialogActions}>
				<Button className={`${classes.btn} ${classes.btnDanger}`} onClick={onDecline}>
					{declineLang}
				</Button>
				<Button className={`${classes.btn} ${classes.btnPrimary}`} onClick={onAccept}>
					{acceptLang}
				</Button>
			</DialogActions>
		</Dialog>
	);
};
