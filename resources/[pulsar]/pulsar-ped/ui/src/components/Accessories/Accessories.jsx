import React, { useState } from 'react';
import { AppBar, Tab, Tabs } from '@mui/material';
import { TabPanel } from '../UIComponents';
import Wrapper from '../UIComponents/Wrapper/Wrapper';
import Props from './Props';
import Misc from './Misc';

export default (props) => {
	const [value, setValue] = useState(0);

	const handleChange = (event, newValue) => setValue(newValue);

	return (
		<Wrapper>
			<AppBar
				position="static"
				color="transparent"
				style={{ marginBottom: 15, boxShadow: 'none' }}
			>
				<Tabs
					value={value}
					onChange={handleChange}
					variant="fullWidth"
					indicatorColor="primary"
					textColor="primary"
				>
					<Tab label="Props" />
					<Tab label="Misc" />
				</Tabs>
			</AppBar>
			<TabPanel value={value} index={0}><Props /></TabPanel>
			<TabPanel value={value} index={1}><Misc /></TabPanel>
		</Wrapper>
	);
};
