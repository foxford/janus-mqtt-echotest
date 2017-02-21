import gulp from 'gulp';
import minify from 'gulp-minify-html';
import uglify from 'gulp-uglify';
import gulpif from 'gulp-if';
import cssnano from 'cssnano';
import postcss from 'gulp-postcss';
import postcssinline from 'gulp-html-postcss';
import bsync from 'browser-sync';
import runseq from 'run-sequence';
import lazypipe from 'lazypipe';
import del from 'del';
import base from './base.js';
import app from './app.js';

function path(...args) {
	return base.path(...[].concat('_rel', args));
}

function cssProcessors() {
	return [ cssnano() ];
}

export default {
	path: path
};

gulp.task('rel:assets', () => base.task.assets().pipe(gulp.dest(path())));

gulp.task('rel:html', () => {
	let htmlPipe =
		lazypipe()
			.pipe(() => postcssinline(cssProcessors()))
			.pipe(() => minify({quotes: true, empty: true, spare: true}));

	return app.task.html()
		.pipe(gulpif('*.html', htmlPipe()))
		.pipe(gulpif('*.js', uglify()))
		.pipe(gulp.dest(path()));
});

gulp.task('rel:css', () => {
	return app.task.css()
		.pipe(postcss(cssProcessors()))
		.pipe(gulp.dest(path()));
});

gulp.task('rel:js', () => {
	return app.task.js()
		.pipe(uglify())
		.pipe(gulp.dest(path()));
});

gulp.task('rel:serve', () => {
	bsync.create().init({
		server: {
			baseDir: path()
		},
		port: 9000,
		https: true,
		injectChanges: false,
		codeSync: false,
		open: false,
		ui: false
	});
});

gulp.task('rel:clean', (cb) => del([path()], cb));

gulp.task('rel', ['rel:assets', 'rel:html', 'rel:css', 'rel:js']);
