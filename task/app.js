import gulp from 'gulp';
import pug from 'gulp-pug';
import jshint from 'gulp-jshint';
import gulpif from 'gulp-if';
import crisper from 'gulp-crisper';
import postcss from 'gulp-postcss';
import postcssinline from 'gulp-html-postcss';
import browserify from 'gulp-browserify';
import cssnext from 'postcss-cssnext';
import autoprefixer from 'autoprefixer';
import bsync from 'browser-sync';
import del from 'del';
import base from './base.js';
import src from './src.js';

let _bsync = bsync.create();

function path(...args) {
	return base.path(...[].concat('_app', args));
}

function cssProcessors() {
	const browsers =
		[	'ie >= 10',
			'ie_mob >= 10',
			'ff >= 30',
			'chrome >= 34',
			'safari >= 7',
			'opera >= 23',
			'ios >= 7',
			'android >= 4.4',
			'bb >= 10' ];

	const processors =
		[	cssnext(),
			autoprefixer(browsers) ];

	return processors;
}

function html() {
	return gulp
		.src([src.path('**/*.pug')])
		.pipe(pug({pretty: true}))
		.pipe(crisper({scriptInHead: false, onlySplit: false}))
		.pipe(gulpif('*.html', postcssinline(cssProcessors())));
}

function js() {
	return gulp
		.src([src.path('**/*.js')])
		.pipe(browserify({
			insertGlobals: true
		}));
}

function css() {
	return gulp
		.src([src.path('**/*.css')])
		.pipe(postcss(cssProcessors()));
}

export default {
	path: path,
	task: {html: html, css: css, js: js}
};

gulp.task('app:js', () => js().pipe(gulp.dest(path())).pipe(_bsync.stream()));
gulp.task('app:css', () => css().pipe(gulp.dest(path())).pipe(_bsync.stream()));
gulp.task('app:html', () => html().pipe(gulp.dest(path())).pipe(_bsync.stream()));
gulp.task('app:lint', () => {
	return gulp
		.src([src.path('**/*.js'), base.path('task/**/*.js')])
		.pipe(jshint({esversion: 6, esnext: true}))
		.pipe(jshint.reporter('default'));
});

gulp.task('app:serve', () => {
	_bsync.init({
		server: {
			baseDir: [path(), base.path('bower_components'), base.path('assets')]
		},
		port: 9000,
		https: false,
		open: false
	});

	gulp.watch(src.path('**/*.js'), ['app:js', 'app:lint']);
	gulp.watch(src.path('**/*.css'), ['app:css']);
	gulp.watch(src.path('**/*.pug'), ['app:html', 'app:lint']);
	gulp.watch(path('**/*.{js,html}')).on('change', _bsync.reload);
});

gulp.task('app:clean', (cb) => del([path()], cb));

gulp.task('app', ['app:html', 'app:css', 'app:js']);
