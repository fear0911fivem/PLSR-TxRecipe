import React from 'react';
import { useSelector } from 'react-redux';
import { Grid } from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import { Route, Switch } from 'react-router';

import links from './links';
import { Navbar, Modal } from '../../components';

import {
	Error,
	Dashboard,
	Players,
	DisconnectedPlayers,
	PlayerView,
	CurrentVehicle,
	Vehicles,
	VehicleView,
	Characters,
	Doorlocks,
	DoorlockView,
	Items,
	Commands,
} from '../../pages';

import Titlebar from '../../components/Titlebar';

const useStyles = makeStyles((theme) => ({
	container: {
		height: '100%',
		display: 'flex',
		flexDirection: 'column',
	},
	titlebarRow: {
		flexShrink: 0,
	},
	body: {
		flex: 1,
		display: 'flex',
		overflow: 'hidden',
	},
	sidebar: {
		width: '25%',
		flexShrink: 0,
		height: '100%',
		overflow: 'hidden',
	},
	content: {
		flex: 1,
		height: '100%',
		overflowY: 'auto',
		overflowX: 'hidden',
	},
}));

export default () => {
	const classes = useStyles();
	const permission = useSelector((state) => state.app.permission);

	return (
		<div className={classes.container}>
			<div className={classes.titlebarRow}>
				<Titlebar />
			</div>
			<div className={classes.body}>
				<div className={classes.sidebar}>
					<Navbar links={links(permission)} />
				</div>
				<div className={classes.content}>
					<Switch>
						<Route exact path="/" component={Dashboard} />
						<Route exact path="/players" component={Players} />
						<Route exact path="/disconnected-players" component={DisconnectedPlayers} />
						<Route exact path="/current-vehicle" component={CurrentVehicle} />
						<Route exact path="/player/:id" component={PlayerView} />
						<Route exact path="/vehicles" component={Vehicles} />
						<Route exact path="/players-characters" component={Characters} />
						<Route exact path="/vehicle/:id" component={VehicleView} />
						<Route exact path="/doorlocks" component={Doorlocks} />
						<Route exact path="/doorlock/:id" component={DoorlockView} />
						<Route exact path="/items" component={Items} />
						<Route exact path="/commands" component={Commands} />
						<Route component={Error} />
					</Switch>
				</div>
			</div>
		</div>
	);
};
