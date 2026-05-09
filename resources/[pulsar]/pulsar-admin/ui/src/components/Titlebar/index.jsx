import { useDispatch, useSelector } from 'react-redux';
import { makeStyles } from '@material-ui/styles';
import { AppBar, Toolbar, IconButton, Divider, Tooltip, Typography } from '@material-ui/core';
import { Link, useHistory } from 'react-router-dom';

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Logo from '../../assets/img/logo.png';

import Nui from '../../util/Nui';
import Account from './Account';

const useStyles = makeStyles((theme) => ({
	navbar: {
		backgroundColor: theme.palette.secondary.dark,
		width: '100%',
		borderBottom: `1px solid ${theme.palette.border.divider}`,
		position: 'relative',
		minHeight: 64,
	},
	toolbar: {
		minHeight: 64,
		padding: '0 8px 0 0',
		display: 'flex',
		alignItems: 'center',
	},
	logoArea: {
		display: 'flex',
		alignItems: 'center',
		height: 64,
		textDecoration: 'none',
		padding: '0 16px',
		transition: 'background ease-in 0.15s',
		'&:hover': {
			background: 'rgba(124, 58, 237, 0.08)',
		},
	},
	logo: {
		width: 40,
		height: 40,
		objectFit: 'contain',
	},
	brandingText: {
		marginLeft: 12,
		'& .title': {
			display: 'block',
			fontSize: 16,
			fontWeight: 700,
			letterSpacing: '0.08em',
			textTransform: 'uppercase',
			color: theme.palette.text.main,
			lineHeight: 1.1,
		},
		'& .subtitle': {
			display: 'block',
			fontSize: 10,
			letterSpacing: '0.12em',
			textTransform: 'uppercase',
			color: theme.palette.primary.light,
			marginTop: 2,
		},
	},
	divider: {
		height: 32,
		margin: '0 4px',
		borderColor: theme.palette.border.divider,
	},
	title: {
		flexGrow: 1,
	},
	right: {
		display: 'inline-flex',
		alignItems: 'center',
		gap: 2,
	},
	iconBtn: {
		width: 36,
		height: 36,
		borderRadius: 4,
		color: theme.palette.text.alt,
		transition: 'color ease-in 0.15s, background ease-in 0.15s',
		'& svg': {
			fontSize: 15,
		},
		'&:hover': {
			color: theme.palette.primary.light,
			background: 'rgba(124, 58, 237, 0.1)',
		},
	},
	closeBtn: {
		width: 36,
		height: 36,
		borderRadius: 4,
		color: theme.palette.text.alt,
		transition: 'color ease-in 0.15s, background ease-in 0.15s',
		'& svg': {
			fontSize: 15,
		},
		'&:hover': {
			color: '#EF4444',
			background: 'rgba(239, 68, 68, 0.1)',
		},
	},
	accentLine: {
		position: 'absolute',
		bottom: 0,
		left: 0,
		right: 0,
		height: 2,
		background: `linear-gradient(90deg, ${theme.palette.primary.main}80, transparent 60%)`,
		pointerEvents: 'none',
	},
}));

export default () => {
	const classes = useStyles();
	const history = useHistory();
	const dispatch = useDispatch();

	const hidden = useSelector(state => state.app.hidden);
	const user = useSelector(state => state.app.user);
	const permissionLevel = useSelector(state => state.app.permissionLevel);

	const onClose = () => {
		dispatch({ type: 'APP_HIDE' });
		Nui.send('Close').catch(() => {});
	};

	const onDetach = () => {
		Nui.send('StopAllAttach');
	};

	const viewSelf = () => {
		history.push(`/player/${user?.Source}`);
	};

	const goInvisible = () => {
		Nui.send('ToggleInvisible');
	};

	const toggleIds = () => {
		Nui.send('ToggleIDs');
	};

	const hoverChange = (state) => {
		if (!hidden) {
			dispatch({
				type: 'SET_OPACITY_MODE',
				payload: { state },
			});
		}
	};

	return (
		<AppBar
			elevation={0}
			position="relative"
			color="secondary"
			className={classes.navbar}
		>
			<Toolbar disableGutters className={classes.toolbar}>
				<div
					className={classes.title}
					onMouseEnter={() => hoverChange(true)}
					onMouseLeave={() => hoverChange(false)}
				>
					<Link to="/" className={classes.logoArea}>
						<img src={Logo} className={classes.logo} alt="Pulsar" />
						<div className={classes.brandingText}>
							<span className="title">Pulsar Admin</span>
							<span className="subtitle">System Panel</span>
						</div>
					</Link>
				</div>

				<div className={classes.right}>
					<Account />
					<Divider orientation="vertical" flexItem className={classes.divider} />
					{permissionLevel >= 100 && (
						<Tooltip title="Toggle Invisibility">
							<IconButton className={classes.iconBtn} onClick={goInvisible}>
								<FontAwesomeIcon icon={['fas', 'eye-slash']} />
							</IconButton>
						</Tooltip>
					)}
					<Tooltip title="Toggle Player IDs">
						<IconButton className={classes.iconBtn} onClick={toggleIds}>
							<FontAwesomeIcon icon={['fas', 'id-badge']} />
						</IconButton>
					</Tooltip>
					<Tooltip title="View My Player Data">
						<IconButton className={classes.iconBtn} onClick={viewSelf}>
							<FontAwesomeIcon icon={['fas', 'user-large']} />
						</IconButton>
					</Tooltip>
					<Tooltip title="Detach From Player">
						<IconButton className={classes.iconBtn} onClick={onDetach}>
							<FontAwesomeIcon icon={['fas', 'link-slash']} />
						</IconButton>
					</Tooltip>
					<Tooltip title="Previous Page">
						<IconButton className={classes.iconBtn} onClick={history.goBack}>
							<FontAwesomeIcon icon={['fas', 'chevron-left']} />
						</IconButton>
					</Tooltip>
					<Tooltip title="Next Page">
						<IconButton className={classes.iconBtn} onClick={history.goForward}>
							<FontAwesomeIcon icon={['fas', 'chevron-right']} />
						</IconButton>
					</Tooltip>
					<Divider orientation="vertical" flexItem className={classes.divider} />
					<Tooltip title="Close Panel">
						<IconButton className={classes.closeBtn} onClick={onClose}>
							<FontAwesomeIcon icon={['fas', 'xmark']} />
						</IconButton>
					</Tooltip>
				</div>
			</Toolbar>
			<div className={classes.accentLine} />
		</AppBar>
	);
};
