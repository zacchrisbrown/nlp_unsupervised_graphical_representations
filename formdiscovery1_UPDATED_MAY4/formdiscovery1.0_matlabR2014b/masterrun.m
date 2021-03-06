% Charles Kemp, 2008
% Fit different structures to feature, similarity and relational data

addpath(pwd);

masterfile    = 'resultsdemo.mat';
% masterfile must have .mat suffix, otherwise exist() won't find it
if ~strcmp(masterfile(end-3:end), ['.mat'])
  error('masterfile must have a .mat suffix');
end

ps = setps();
% set default values of all parameters
ps = defaultps(ps);

% change default parameters for this run
[s,w] = system('which neato');

if s == 0 % neato available
ps.showinferredgraph = 1; % show inferred graph 
ps.showpostclean     = 1; % show best graph (post cleaning) at each depth 
end


ps.reloutsideinit    ='overd';   % initialize relational structure with 
				 % one object per group

% Structures for this run. We'll fit the chain model, the ring model and
% the tree model. The indices correspond to form names in setpsexport()
thisstruct = [2,4,6];	 
% Datasets for this run. Indices correspond to dataset names in  setpsexport() 
thisdata = [1:3];			

% to run some additional structure/data pairs list them here.
extraspairs = [];
extradpairs = [];

% Use these structure and data indices for analyzing

% a) synthetic data described in Kemp (2008)
%   thisstruct = [1,2,4,6,7];	 
%   thisdata = [7:11];			

% b) real world feature and similarity data in Kemp (2008)
% thisstruct = [1:8];	 
% thisdata = [12:16];			

% c) real world relational data in Kemp (2008)
%   thisstruct = [1,9,10:13, 3,14:16,17:20, 21:24]  
%   thisdata = [17:20];	

% d) we do what we want
 thisstruct = [1:8];
 thisdata = [21];

sindpair = repmat(thisstruct', 1, length(thisdata));
dindpair = repmat(thisdata, length(thisstruct), 1);
%disp('Here is the original sindpair');
%disp(sindpair);
%disp('Here is the original dindpair');
%disp(dindpair);

sindpair = [extraspairs(:); sindpair(:)]';
dindpair = [extradpairs(:); dindpair(:)]';
%disp('This is sindpair after they bulked it up');
%disp(sindpair)
%disp('This is dindpair after they bulked it up');
%disp(dindpair)

repeats = 1;
for rind = 1:repeats
  for ind = 1:length(dindpair)
    dind = dindpair(ind);
    sind = sindpair(ind); 
    disp(['  ', ps.data{dind}, ' ', ps.structures{sind}]);
    rand('state', rind);
    [mtmp stmp  ntmp ltmp gtmp] = runmodel(ps, sind, dind, rind);
    succ = 0;
    while (succ == 0)
      try
        if exist(masterfile)
          currps = ps; load(masterfile); ps = currps;
	 end
	pss{sind,dind,rind} = ps;
        modellike(sind, dind, rind) = mtmp;  
        structure{sind,dind, rind}  = stmp;
        names{dind} = ntmp;		   
        llhistory{sind, dind, rind} = ltmp;
        save(masterfile, 'modellike', 'structure', 'names', 'pss', ...
			 'llhistory'); 
        succ = 1;
      catch
        succ = 0;
        disp('error reading masterfile');
        pause(10*rand);
      end
    end
  end
end

