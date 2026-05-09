import React from 'react';
import { useSelector } from 'react-redux';
import { makeStyles } from '@material-ui/styles';
import { useMediaQuery, List } from '@material-ui/core';
import { useTheme } from '@material-ui/core/styles';

import MenuItem from './MenuItem';
import MenuItemSub from './MenuItemSub';

const useStyles = makeStyles((theme) => ({
	mainNav: {
		borderRight: `1px solid ${theme.palette.border.divider}`,
		background: theme.palette.secondary.dark,
		width: '100%',
		display: 'inline-block',
		verticalAlign: 'top',
		height: '100%',
		overflow: 'auto',
		padding: '8px 0',
		'&::-webkit-scrollbar': {
			width: 0,
		},
	},
	navSection: {
		padding: '12px 12px 4px 14px',
		fontSize: 10,
		fontWeight: 700,
		letterSpacing: '0.12em',
		textTransform: 'uppercase',
		color: theme.palette.text.info,
		userSelect: 'none',
	},
}));

export default (props) => {
	const classes = useStyles();
	const theme = useTheme();
	const user = useSelector(state => state.app.user);
	const permissionLevel = useSelector(state => state.app.permissionLevel);
	const isMobile = !useMediaQuery(theme.breakpoints.up('lg'));

	return (
		<List className={!isMobile ? classes.mainNav : ''} disablePadding>
			{props.links.map((link, i) => {
				if (
					link.restrict &&
					(!Boolean(user) || (permissionLevel < link.restrict.permission))
				)
					return null;

				if (link.sectionLabel) {
					return (
						<div key={`section-${i}`} className={classes.navSection}>
							{link.sectionLabel}
						</div>
					);
				}

				if (Boolean(link.items) && link.items.length > 0) {
					return (
						<div key={`${link.path}-${i}`}>
							<MenuItemSub
								compress={props.compress}
								link={link}
								open={props.open}
								onClick={props.onClick}
								handleMenuClose={props.handleMenuClose}
							/>
						</div>
					);
				} else {
					return (
						<div key={`${link.path}-${i}`}>
							<MenuItem
								compress={props.compress}
								link={link}
								onClick={props.handleMenuClose}
							/>
						</div>
					);
				}
			})}
		</List>
	);
};
