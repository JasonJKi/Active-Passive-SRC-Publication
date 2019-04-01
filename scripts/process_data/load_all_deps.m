function load_all_deps(rootDir)
if nargin < 1
    rootDir = './';
end
% load_arl_deps load all dependencies for ARL 
libsPath = genpath([rootDir 'libs/']); % in house libs and depndencies
libsExternalPath = genpath([rootDir 'libs_external/']); % external libs and dependencies
addpath(libsPath,libsExternalPath) % loading libs
