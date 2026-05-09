import React, { useState, useEffect } from 'react';
import { useSelector } from 'react-redux';
import { makeStyles } from '@material-ui/styles';
import { useMediaQuery, Drawer } from '@material-ui/core';
import { useTheme } from '@material-ui/core/styles';
import { useLocation } from 'react-router-dom';

import NavLinksEl from './NavLinks';

const useStyles = makeStyles((theme) => ({
	root: {
		flexGrow: 1,
		width: '100%',
		height: '100%',
		zIndex: 100,
	},
	mobileNav: {
		width: '100%',
		maxWidth: 360,
		backgroundColor: theme.palette.secondary.dark,
	},
}));

export default ({ links }) => {
	const classes = useStyles();
	const theme = useTheme();
	const isMobile = !useMediaQuery(theme.breakpoints.up('lg'));
	const [mobileOpen, setMobileOpen] = useState(false);
	const [open, setOpen] = useState(false);

	useEffect(() => {
		if (!isMobile) {
			setMobileOpen(false);
		}
	}, [isMobile]);

	const onClick = (e) => {
		e.preventDefault();
		if (e.currentTarget.name === open) {
			setOpen(false);
		} else {
			setOpen(e.currentTarget.name);
		}
	};

	const handleMenuClose = () => {
		setMobileOpen(false);
	};

	return (
		<>
			{!isMobile ? (
				<NavLinksEl
					links={links}
					onClick={onClick}
					handleMenuClose={handleMenuClose}
					open={open}
					compress={false}
				/>
			) : null}

			<Drawer
				PaperProps={{ className: classes.mobileNav }}
				anchor="left"
				open={mobileOpen && isMobile}
				onClose={() => setMobileOpen(false)}
			>
				<NavLinksEl
					links={links}
					onClick={onClick}
					handleMenuClose={handleMenuClose}
					open={open}
					compress={false}
				/>
			</Drawer>
		</>
	);
};
