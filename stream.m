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
label = {'Copy:      ','Scale:     ','Add:       ', 'Triad:     '};

% .. Arrays in Common ..
a = zeros(1, n);
b = zeros(1, n);
c = zeros(1, n);

fprintf('----------------------------------------------\n');
fprintf('STREAM-Matlab Version $Revision: 0.1 $\n')
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
   for jj = 1:n
      c(jj) = a(jj);
   end
   c(n) = c(n) + t;
   alltimes(1, k) = toc();

   % --- SCALE ---
   t = rand();
   tic();
   c(1) = c(1) + t;
   for jj = 1:n
      b(jj) = scalar * c(jj);
   end
   b(n) = b(n) + t;
   alltimes(2, k) = toc();

   % --- SUM ---
   t = rand();
   tic();
   a(1) = a(1) + t;
   for jj = 1:n
      c(jj) = a(jj) + b(jj);
   end
   c(n) = c(n) + t;
   alltimes(3, k) = toc();

   % --- TRIAD ---
   t = rand();
   tic();
   b(1) = b(1) + t;
   for jj = 1:n
      a(jj) = b(jj) + scalar * c(jj);
   end
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