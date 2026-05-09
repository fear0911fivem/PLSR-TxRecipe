exports('RegexTest', (regex, testString, regexOptions) => {
	return new RegExp(regex, regexOptions).test(testString);
});
