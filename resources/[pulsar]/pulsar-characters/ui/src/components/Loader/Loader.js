import React from 'react';
import { Loader } from '@mantine/core';

export default () => (
    <div style={{ width: 200, height: 200, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Loader color="brand" size={90} />
    </div>
);
