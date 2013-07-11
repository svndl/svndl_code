function preprocessEgiRaw(projectInfo)


mrcProjDir = projectInfo.projectDir;

rawDir = fullfile(mrcProjDir,projectInfo.subjId,'Raw');

rawFile = dir([rawDir filesep '*.raw']);




cfg.dataset = rawFile;

cfg.lpfilter = 'no'
cfg.lpfreq = 100;

cfg.bsfilter      = 'no'
cfg.bsfreq        = [119 121];

cfg.bsfilter      = 'no'
cfg.bsfreq        = [59 61];


data = preprocessing(cfg,data)



cfg = [];
cfg.dataset = ['/Users/ales/data/hazard/' fname]




cfg.trialdef='?'



cfg.trialdef.eventtype  = 'trigger'
cfg.trialdef.eventvalue = 'c002'
cfg.trialdef.prestim    = .630;
cfg.trialdef.poststim   = 3*.63;
cfg.trialfun = 'lock2din'; 

cfg = definetrial(cfg);

data = redefinetrial(cfg, data);
