function getResourceName() {
	if (typeof window !== 'undefined' && typeof window.GetParentResourceName === 'function') {
		return window.GetParentResourceName();
	}
	return process.env.REACT_RESOURCE_NAME || 'pulsar-admin';
}

export default {
	async send(event, data = {}) {
		/// #if DEBUG
		return new Promise((resolve) => setTimeout(resolve, 100));
		/// #endif

		/* eslint-disable no-unreachable */
		return fetch(`https://${getResourceName()}/${event}`, {
			method: 'post',
			headers: {
				'Content-type': 'application/json; charset=UTF-8',
			},
			body: JSON.stringify(data),
		});
		/* eslint-enable no-unreachable  */
	},
	copyClipboard(text = '') {
		const node = document.createElement('textarea');
		const selection = document.getSelection();

		node.textContent = text;
		document.body.appendChild(node);

		selection.removeAllRanges();
		node.select();
		document.execCommand('copy');

		selection.removeAllRanges();
		document.body.removeChild(node);
	},
	emulate(type, data = null) {
		window.dispatchEvent(
			new MessageEvent('message', {
				data: {
					type,
					data,
				},
			}),
		);
	},
};
