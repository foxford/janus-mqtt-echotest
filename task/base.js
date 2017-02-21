import gulp from 'gulp';
import _path from 'path';

function path(...args) {
	return _path.join(...[].concat(__dirname, '..', args));
}

function assets() {
	return gulp.src([path('bower_components/**'), path('assets/**')]);
}

export default {
	path: path,
	task: {assets: assets}
};

