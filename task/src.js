import base from './base.js';

function path(...args) {
	return base.path(...[].concat('src', args));
}

export default {
	path: path
};

