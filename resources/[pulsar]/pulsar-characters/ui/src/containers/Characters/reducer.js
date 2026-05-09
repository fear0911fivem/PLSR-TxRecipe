import {
	APP_RESET,
	SET_CHARACTERS,
	CREATE_CHARACTER,
	DELETE_CHARACTER,
	SELECT_CHARACTER,
	DESELECT_CHARACTER,
	SET_DATA,
	UPDATE_PLAYED,
} from '../../actions/types';

export const initialState = {
	characters:
		process.env.NODE_ENV == 'production'
			? []
			: [
					{
						SID: 1,
						ID: '606e8a3c8144f19ec0aeeece',
						First: 'John',
						Last: 'Doe',
						DOB: '1991-01-01',
						Phone: '555-0100',
						LastPlayed: Date.now() - 86400000,
						Gender: 0,
						Jobs: [
							{
								Id: 'police',
								Name: 'Police',
								Workplace: { Id: 'lspd', Name: 'Los Santos PD' },
								Grade: { Id: 'officer', Name: 'Officer' },
							},
						],
					},
					{
						SID: 2,
						ID: '606e8a3c8144f19ec0aeeecf',
						First: 'Jane',
						Last: 'Smith',
						DOB: '1995-06-15',
						Phone: '555-0101',
						LastPlayed: -1,
						Gender: 1,
						Jobs: [],
					},
					{
						SID: 3,
						ID: '606e8a3c8144f19ec0aeeed0',
						First: 'Mike',
						Last: 'Johnson',
						DOB: '1988-03-22',
						Phone: '555-0102',
						LastPlayed: Date.now() - 3600000,
						Gender: 0,
						Jobs: [
							{ Id: 'ems', Name: 'EMS', Workplace: null, Grade: { Id: 'paramedic', Name: 'Paramedic' } },
							{ Id: 'mechanic', Name: 'Mechanic', Workplace: null, Grade: { Id: 'tech', Name: 'Technician' } },
						],
					},
			  ],
	changelog: null,
	motd: process.env.NODE_ENV == 'production' ? null : 'This is a test :)',
	selected: null,
	characterLimit: 3,
};

const charReducer = (state = initialState, action) => {
	switch (action.type) {
		case SET_CHARACTERS:
			return { ...state, characters: action.payload, selected: null };
		case CREATE_CHARACTER:
			state.characters.push(action.payload.character);
			return state;
		case DELETE_CHARACTER:
			return {
				...state,
				characters: state.characters.filter(
					(c) => c.ID != action.payload.id,
				),
			};
		case SELECT_CHARACTER:
			return { ...state, selected: action.payload.character };
		case DESELECT_CHARACTER:
			return { ...state, selected: null };
		case SET_DATA:
			return {
				...state,
				characters: action.payload.characters,
				changelog: action.payload.changelog,
				motd: action.payload.motd,
				characterLimit: action.payload.characterLimit,
			};
		case UPDATE_PLAYED:
			return {
				...state,
				characters: state.characters.map((char) =>
					char.ID === state.selected.ID
						? { ...char, LastPlayed: Date.now() }
						: char,
				),
			};
		case APP_RESET:
			return {
				...initialState,
				hidden: false,
			};
		default:
			return state;
	}
};

export default charReducer;
