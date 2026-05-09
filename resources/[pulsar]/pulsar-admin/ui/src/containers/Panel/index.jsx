import React, { useEffect } from 'react';
import { useSelector } from 'react-redux';
import { Paper, Slide } from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import { withRouter, useHistory } from 'react-router-dom';
import { ToastContainer, Flip } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

import { Admin, Staff } from '../Groups';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		height: '100%',
		width: '100%',
		border: `1px solid ${theme.palette.border.divider}`,
		transition: 'opacity 500ms',
		borderRadius: 6,
		overflow: 'hidden',
	},
	inner: {
		position: 'relative',
		height: '100%',
	},
}));

export default withRouter(() => {
	const classes = useStyles();
	const history = useHistory();
	const hidden = useSelector((state) => state.app.hidden);
	const permission = useSelector(state => state.app.permission);
	const opacityMode = useSelector(state => state.app.opacity);

	useEffect(() => {
		const handleMessage = (event) => {
			if (event.data.type === 'SET_ROUTE' && event.data.data?.route) {
				const route = event.data.data.route.replace('#', '');
				history.push(route);
			}
		};

		window.addEventListener('message', handleMessage);
		return () => window.removeEventListener('message', handleMessage);
	}, [history]);

	const getPanel = () => {
		switch (permission) {
			case "dev":
			case "management":
				return <Admin />;
			default:
				return <Staff />;
		};
	};

	return (
		<Slide direction="up" in={!hidden}>
			<Paper
				elevation={0}
				className={classes.wrapper}
				style={{ opacity: opacityMode ? '60%' : null }}>
				<div className={classes.inner}>
					<ToastContainer
						position="bottom-right"
						newestOnTop={false}
						closeOnClick
						rtl={false}
						draggable
						transition={Flip}
						pauseOnHover={false}
					/>
					{getPanel(permission)}
				</div>
			</Paper>
		</Slide>
	);
});
