import React from 'react';
import { ListItem, ListItemIcon, ListItemText } from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { NavLink } from 'react-router-dom';

export default (props) => {
	const useStyles = makeStyles((theme) => ({
		link: {
			paddingLeft: props.nested ? '14%' : 14,
			paddingRight: 10,
			height: 48,
			color: '#6B7280',
			borderLeft: '3px solid transparent',
			transition: 'color ease-in 0.15s, background ease-in 0.15s, border-color ease-in 0.15s',
			'& .MuiListItemIcon-root': {
				minWidth: 36,
				color: '#4A5568',
				transition: 'color ease-in 0.15s',
				'& svg': {
					fontSize: 15,
				},
			},
			'& .MuiListItemText-primary': {
				fontSize: 13,
				fontWeight: 500,
				letterSpacing: '0.01em',
			},
			'&:hover': {
				color: theme.palette.text.main,
				borderLeftColor: `${theme.palette.primary.main}70`,
				background: 'rgba(124, 58, 237, 0.07)',
				'& .MuiListItemIcon-root': {
					color: theme.palette.primary.light,
				},
			},
			'&.active': {
				color: theme.palette.text.main,
				borderLeftColor: theme.palette.primary.main,
				background: 'rgba(124, 58, 237, 0.12)',
				'& .MuiListItemIcon-root': {
					color: theme.palette.primary.light,
				},
				'& .MuiListItemText-primary': {
					fontWeight: 600,
					color: theme.palette.text.light,
				},
			},
		},
	}));
	const classes = useStyles();

	return (
		<ListItem
			button
			exact={props.link.exact}
			className={classes.link}
			component={NavLink}
			to={props.link.path}
			name={props.link.name}
			onClick={props.onClick}
		>
			<ListItemIcon>
				<FontAwesomeIcon icon={props.link.icon} />
			</ListItemIcon>
			{!props.compress ? (
				<ListItemText primary={props.link.label} />
			) : null}
		</ListItem>
	);
};
