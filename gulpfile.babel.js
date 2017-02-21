import gulp from 'gulp';
import runseq from 'run-sequence';
import './task/app.js';
import './task/rel.js';

import bsync from 'browser-sync';

gulp.task('clean', ['app:clean', 'rel:clean']);
gulp.task('develop', (cb) => runseq('app:clean', 'app', 'app:serve', cb));
gulp.task('default', (cb) => runseq('clean', 'app', 'rel', cb));
