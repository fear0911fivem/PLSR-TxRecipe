import React from 'react';
import Loadscreen from '../Loadscreen';

import { library } from '@fortawesome/fontawesome-svg-core';
import { fas } from '@fortawesome/free-solid-svg-icons';
import { fab } from '@fortawesome/free-brands-svg-icons';

library.add(fab, fas);

export default function App() {
  return <Loadscreen />;
}
