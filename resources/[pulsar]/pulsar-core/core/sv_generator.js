const { faker } = require('@faker-js/faker');

exports('GeneratorColor', (t) => {
	return faker.internet.color();
});

exports('GeneratorNameFirst', (t) => {
	return faker.name.firstName();
});

exports('GeneratorNameLast', (t) => {
	return faker.name.lastName();
});

exports('GeneratorNameMiddle', (t) => {
	return faker.name.middleName();
});

exports('GeneratorJob', (t) => {
	return faker.name.jobTitle();
});

exports('GeneratorCompany', (t) => {
	return faker.company.companyName();
});

exports('GeneratorAddressCity', (t) => {
	return faker.address.cityName();
});

exports('GeneratorAddressState', (t) => {
	return faker.address.state();
});

exports('GeneratorAddressStreet', (t) => {
	return faker.address.streetAddress();
});

exports('GeneratorAddressStreetSecondary', (t) => {
	return faker.address.secondaryAddress();
});

exports('GeneratorFinanceAccount', (t) => {
	return faker.finance.account();
});

exports('GeneratorFinanceCreditCard', (t) => {
	return faker.finance.creditCardNumber();
});

exports('GeneratorFinanceCryptoAddress', (t) => {
	return faker.finance.bitcoinAddress();
});

exports('GeneratorInternetEmail', (t) => {
	return faker.internet.email();
});

exports('GeneratorInternetAvatar', (t) => {
	return faker.internet.avatar();
});

exports('GeneratorInternetDomain', (t) => {
	return faker.internet.domainName();
});

exports('GeneratorInternetIP', (t) => {
	return faker.internet.ip();
});

exports('GeneratorInternetIPv6', (t) => {
	return faker.internet.ipv6();
});

exports('GeneratorInternetMacAddress', (t) => {
	return faker.internet.mac();
});

exports('GeneratorDatePast', (t) => {
	return faker.date.past();
});

exports('GeneratorDateFuture', (t) => {
	return faker.date.future();
});

exports('GeneratorDateRecent', (t) => {
	return faker.date.recent();
});

exports('GeneratorDateSoon', (t) => {
	return faker.date.soon();
});

exports('GeneratorPhone', (t) => {
	return faker.phone.phoneNumber();
});

exports('GeneratorVehicleMakeModel', (t) => {
	return faker.vehicle.vehicle();
});

exports('GeneratorVehicleMake', (t) => {
	return faker.vehicle.manufacturer();
});

exports('GeneratorVehicleModel', (t) => {
	return faker.vehicle.model();
});

exports('GeneratorVehicleColor', (t) => {
	return faker.vehicle.color();
});

exports('GeneratorVehicleVIN', (t) => {
	return faker.vehicle.vin();
});

exports('GeneratorVehiclePlate', (t) => {
	return faker.vehicle.vrm();
});

exports('GeneratorDataNumber', (t) => {
	return faker.datatype.number();
});

exports('GeneratorDataFloat', (t) => {
	return faker.datatype.float();
});

exports('GeneratorDataString', (t) => {
	return faker.datatype.string();
});

exports('GeneratorDataUUID', (t) => {
	return faker.datatype.uuid();
});

exports('GeneratorImageImage', (t) => {
	return faker.image.image();
});

exports('GeneratorImageAvatar', (t) => {
	return faker.image.avatar();
});

exports('GeneratorHackerAbbreviation', (t) => {
	return faker.hacker.abbreviation();
});

exports('GeneratorHackerAdjective', (t) => {
	return faker.hacker.adjective();
});

exports('GeneratorHackerNoun', (t) => {
	return faker.hacker.noun();
});

exports('GeneratorHackerVerb', (t) => {
	return faker.hacker.verb();
});

exports('GeneratorHackerIngVerb', (t) => {
	return faker.hacker.ingverb();
});

exports('GeneratorWordAdjective', (t) => {
	return faker.word.adjective();
});

exports('GeneratorWordAdverb', (t) => {
	return faker.word.adverb();
});

exports('GeneratorWordNoun', (t) => {
	return faker.word.noun();
});

exports('GeneratorWordVerb', (t) => {
	return faker.word.verb();
});
