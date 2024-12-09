function handles=update_experiment_data(handles,features,sexdata,individuals)

handlesexperimentlist=[handles.experimentlist{:}];

handlesfeatures=cell(1,length(handlesexperimentlist));
handlessexdata=cell(1,length(handlesexperimentlist));
handlesindividualsbehavior=zeros(length(handlesexperimentlist),length(handles.scorefiles));
handlesindividualsfeature=zeros(1,length(handlesexperimentlist));

parfor ge=1:length(handlesexperimentlist)
  if(features)
    tmp=dir(fullfile(handlesexperimentlist{ge},handles.perframe_dir,'*.mat'));
    [handlesfeatures{ge}{1:length(tmp)}]=deal(tmp.name);
    handlesfeatures{ge}=cellfun(@(x) x(1:(end-4)),handlesfeatures{ge},'uniformoutput',false);
  end

  if(sexdata)
    fname = fullfile(handlesexperimentlist{ge},handles.perframe_dir,'sex.mat');
    if(exist(fname,'file'))
      tmp=load(fname);
      handlessexdata(ge)={cellfun(@(x) strcmp(x,'M'),tmp.data,'uniformoutput',false)};
    else
      tmp=dir(fullfile(handlesexperimentlist{ge},handles.perframe_dir,'*.mat'));
      tmp=load(fullfile(handlesexperimentlist{ge},handles.perframe_dir,tmp(1).name));
      handlessexdata(ge)={cellfun(@(x) nan(1,length(x)),tmp.data,'uniformoutput',false)};
    end
  end

  if(individuals)
    behavior_data=[];
    parfor_tmp=zeros(1,length(handles.scorefiles));
    for s=1:length(handles.scorefiles)
      %classifier=load(handles.classifierlist{s});
      classifier=load(handles.classifierlist{s},'-mat');
      %classifier=x;
      parfor_tmp(s)=get_nindividuals_behavior(handlesexperimentlist{ge},handles.scorefiles{s},...
          classifier.x.classifierStuff.timeStamp);
    end
    handlesindividualsbehavior(ge,:)=parfor_tmp;

    handlesindividualsfeature(ge)=...
        get_nindividuals_feature(handlesexperimentlist{ge},handles.perframe_dir,handlesfeatures{ge});
  end
end

if(features)
  handles.features={handlesfeatures{:}};
  handles.featurelist=check_for_diff_and_return_intersection(handles.features);
end

if(sexdata)
  handles.sexdata={handlessexdata{:}};
end

if(individuals)
  handles.individuals_behavior=handlesindividualsbehavior;
  handles.individuals_feature=handlesindividualsfeature;
  handles=fillin_individuallist(handles);
end

%classifier=load(handles.classifierlist{1});
%handles.fps=get_fps(fullfile(handlesexperiments{1},classifier.trxfilename));
[handles.fps,handles.trx_file]=get_fps(handlesexperimentlist{1},handles.trx_file);

handles.interestingfeaturehistograms_cache=[];
handles.interestingfeaturetimeseries_cache=[];