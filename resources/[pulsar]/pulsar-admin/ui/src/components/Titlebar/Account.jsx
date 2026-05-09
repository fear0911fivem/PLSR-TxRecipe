import React from 'react';
import { useSelector } from 'react-redux';
import { makeStyles } from '@material-ui/styles';
import { Avatar } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
	user: {
		display: 'flex',
		alignItems: 'center',
		gap: 10,
		marginRight: 8,
		padding: '0 10px',
	},
	avatar: {
		width: 32,
		height: 32,
		border: `2px solid ${theme.palette.primary.dark}`,
	},
	inner: {
		textAlign: 'right',
	},
	permLabel: {
		display: 'block',
		fontSize: 10,
		letterSpacing: '0.1em',
		textTransform: 'uppercase',
		color: theme.palette.primary.light,
		lineHeight: 1.2,
	},
	nameLabel: {
		display: 'block',
		fontSize: 14,
		fontWeight: 600,
		color: theme.palette.text.main,
		lineHeight: 1.3,
	},
}));

export default () => {
	const classes = useStyles();
	const user = useSelector((state) => state.app.user);
	const permissionName = useSelector(state => state.app.permissionName);

	return (
		<div className={classes.user}>
			<div className={classes.inner}>
				<span className={classes.permLabel}>
					{permissionName ?? 'Staff'}
				</span>
				<span className={classes.nameLabel}>
					{user?.Name}
				</span>
			</div>
			<Avatar className={classes.avatar} src={user?.Avatar} />
		</div>
	);
};
