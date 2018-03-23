%=======================================================================
% Program: STREAM-Matlab
% Programmer: John D. McCalpin (orignal STREAM), Patryk Kiepas (STREAM-Matlab)
% RCS Revision: $Id: stream.m,v 0.1 2018/03/22 18:02:33 quepas $
%-----------------------------------------------------------------------
% Copyright 1991-2003: John D. McCalpin
%-----------------------------------------------------------------------
% License:
%  1. You are free to use this program and/or to redistribute
%     this program.
%  2. You are free to modify this program for your own use,
%     including commercial use, subject to the publication
%     restrictions in item 3.
%  3. You are free to publish results obtained from running this
%     program, or from works that you derive from this program,
%     with the following limitations:
%     3a. In order to be referred to as "STREAM benchmark results",
%         published results must be in conformance to the STREAM
%         Run Rules, (briefly reviewed below) published at
%         http://www.cs.virginia.edu/stream/ref.html
%         and incorporated herein by reference.
%         As the copyright holder, John McCalpin retains the
%         right to determine conformity with the Run Rules.
%     3b. Results based on modified source code or on runs not in
%         accordance with the STREAM Run Rules must be clearly
%         labelled whenever they are published.  Examples of
%         proper labelling include:
%         "tuned STREAM benchmark results"
%         "based on a variant of the STREAM benchmark code"
%         Other comparable, clear and reasonable labelling is
%         acceptable.
%     3c. Submission of results to the STREAM benchmark web site
%         is encouraged, but not required.
%  4. Use of this program or creation of derived works based on this
%     program constitutes acceptance of these licensing restrictions.
%  5. Absolutely no warranty is expressed or implied.
%-----------------------------------------------------------------------
% This program measures sustained memory transfer rates in MB/s for
% simple computational kernels coded in MATLAB.
%
% The intent is to demonstrate the extent to which ordinary user
% code can exploit the main memory bandwidth of the system under
% test.
%=======================================================================
% The STREAM web page is at:
%          http://www.cs.virginia.edu/stream/
%
% BRIEF INSTRUCTIONS:
%       0) See http://www.cs.virginia.edu/stream/ref.html for details
%       1) STREAM requires a timing function called mysecond().
%          Several examples are provided in this directory.
%          "CPU" timers are only allowed for uniprocessor runs.
%          "Wall-clock" timers are required for all multiprocessor runs.
%       2) The STREAM array sizes must be set to size the test.
%          The value "N" must be chosen so that each of the three
%          arrays is at least 4x larger than the sum of all the last-
%          level caches used in the run, or 1 million elements, which-
%          ever is larger.
%          ------------------------------------------------------------
%          Note that you are free to use any array length and offset
%          that makes each array 4x larger than the last-level cache.
%          The intent is to determine the %best% sustainable bandwidth
%          available with this simple coding.  Of course, lower values
%          are usually fairly easy to obtain on cached machines, but
%          by keeping the test to the %best% results, the answers are
%          easier to interpret.
%          You may put the arrays in common or not, at your discretion.
%          There is a commented-out COMMON statement below.
%          Fortran90 "allocatable" arrays are fine, too.
%          ------------------------------------------------------------
%       3) Compile the code with full optimization.  Many compilers
%          generate unreasonably bad code before the optimizer tightens
%          things up.  If the results are unreasonably good, on the
%          other hand, the optimizer might be too smart for me
%          Please let me know if this happens.
%       4) Mail the results to mccalpin@cs.virginia.edu
%          Be sure to include:
%               a) computer hardware model number and software revision
%               b) the compiler flags
%               c) all of the output from the test case.
%          Please let me know if you do not want your name posted along
%          with the submitted results.
%       5) See the web page for more comments about the run rules and
%          about interpretation of the results.
%
% Thanks,
%   Dr. Bandwidth
%=========================================================================
%

% .. Parameters ..
n = 100000000;
offset = 0;
ndim = n+offset;
ntimes = 10
% .. Local Arrays ..
maxtime = zeros(1, 4);
mintime = [realmax, realmax, realmax, realmax];
avgtime = zeros(1, 4);
alltimes = zeros(4, ntimes);
bytes = [2, 2, 3, 3];
nbpw = 8;
label = {'Copy (vec):  ','Scale (vec): ','Add (vec):   ', 'Triad (vec): '};

% .. Arrays in Common ..
a = zeros(1, n);
b = zeros(1, n);
c = zeros(1, n);

fprintf('----------------------------------------------\n');
fprintf('STREAM-Matlab (Vectorized) Version $Revision: 0.1 $\n')
fprintf('----------------------------------------------\n');
fprintf('Array size = %d\n', n);
fprintf('Offset     = %d\n', offset);
fprintf('The total memory requirement is %d MB\n', ceil(3*nbpw*n/(1024*1024)));
fprintf('You are running each test %d times\n', ntimes);
fprintf('--\n');
fprintf('The *best* time for each test is used\n');
fprintf('*EXCLUDING* the first and last iterations\n');
fprintf('----------------------------------------------\n');

for jj = 1:n
   a(jj) = 2.0;
   b(jj) = 0.5;
   c(jj) = 0.0;
end

for jj = 1:n
   a(jj) = 0.5*a(jj);
end

% --- MAIN LOOP --- repeat test cases NTIMES times ---
scalar = 0.5 * a(1);

for k = 1:ntimes

   % --- COPY ---
   t = rand();
   tic();
   a(1) = a(1) + t;
   c = a;
   c(n) = c(n) + t;
   alltimes(1, k) = toc();

   % --- SCALE ---
   t = rand();
   tic();
   c(1) = c(1) + t;
   b = scalar * c;
   b(n) = b(n) + t;
   alltimes(2, k) = toc();

   % --- SUM ---
   t = rand();
   tic();
   a(1) = a(1) + t;
   c = a + b;
   c(n) = c(n) + t;
   alltimes(3, k) = toc();

   % --- TRIAD ---
   t = rand();
   tic();
   b(1) = b(1) + t;
   a = b + scalar * c;
   a(n) = a(n) + t;
   alltimes(4, k) = toc();

end

% --- SUMMARY ---
for k = 2:ntimes
   for jj = 1:4
      avgtime(jj) = avgtime(jj) + alltimes(jj,k);
      mintime(jj) = min(mintime(jj), alltimes(jj,k));
      maxtime(jj) = max(maxtime(jj), alltimes(jj,k));
   end
end

fprintf('Function    Best Rate (MB/s)  Avg time   Min time  Max time\n');
for jj = 1:4
   avgtime(jj) = avgtime(jj) / double(ntimes-1);
   fprintf('%s      %10.4f%10.4f%10.4f%10.4f\n', label{jj}, n*bytes(jj)*nbpw/mintime(jj) / 1.0d6, avgtime(jj), mintime(jj), maxtime(jj))
end