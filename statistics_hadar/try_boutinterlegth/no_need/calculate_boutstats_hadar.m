function handles=initialize(handles)

handles.grouplist={};
handles.groupvalue=1;
handles.experimentlist={{}};
handles.experimentvalue={1};
handles.classifierlist={};
handles.classifiervalue=1;
%handles.configurations={};
handles.scorefiles={};
handles.analysis='';
handles.behaviorlist={};
handles.behaviornot=0;
handles.behaviorvalue=1;
handles.behaviorlogic=1;
handles.behaviorvalue2=1;
handles.behaviornormalizenot=0;
handles.behaviorvalue3=1;
handles.features={};
handles.featurelist={};
handles.featurevalue=1;
handles.individuals_behavior=[];
handles.individuals_feature=[];
handles.individuallist={'All'};
handles.individualvalue=1;
handles.individualidx='A';
handles.sexdata={};
handles.fps=nan;
handles.classify_forcecompute=false;
handles.behaviorbarchart_style=1;
handles.behaviortimeseries_style=1;
handles.featurehistogram_style=1;
handles.featurehistogram_style2=1;
handles.comparison=0;
handles.logbinsize=0;
handles.nbins=100;
handles.featuretimeseries_style=1;
handles.featuretimeseries_style2=1;
handles.subtractmean=0;
handles.windowradius=10;
handles.boutstats_style=1;
handles.boutstats_style2=1;
handles.omitnan=1;
handles.omitinf=1;
handles.absdprimezscore=1;
handles.comparison2=0;
handles.dump2csv=1;
handles.dump2mat=1;
handles.centraltendency=1;
handles.dispersion=1;
handles.xoffset=1;
handles.minimumtrajectorylength=1;
handles.convolutionwidth=10;
handles.pvalue=0.01;
handles.interestingfeaturehistograms_cache=[];
handles.interestingfeaturetimeseries_cache=[];
handles.defaultcolors=[1 0 0;  0 0.5 0;  0 0 1;  0 1 1;  1 0 1;  0.749 0.749 0;  0 0 0];
handles.colors=[];
handles.trx_file='registered_trx.mat';
handles.perframe_dir='perframe';
% ---
function handles=feature_timeseries_plot(handles)

set(handles.Status,'string','Thinking...','foregroundcolor','b');
set(handles.figure1,'pointer','watch');
drawnow;

handlesexperimentlist=[handles.experimentlist{:}];

cumsum_num_indi_per_exp=[0 cumsum(handles.individuals_feature)];
cumsum_num_exp_per_group=[0 cumsum(cellfun(@length,handles.experimentlist))];
mat2cell(cumsum_num_exp_per_group(1:end-1),1,ones(1,length(cumsum_num_exp_per_group)-1));
cellfun(@(x,y) x+y,handles.experimentvalue,ans,'uniformoutput',false);
selected_exp=[ans{:}];
cumsum_num_selexp_per_group=[0 cumsum(cellfun(@length,handles.experimentvalue))];

%ggee=1:length(handlesexperimentlist);
ggee=selected_exp;
individual=handles.individualidx;
if isnumeric(individual)
  ggee=find(cumsum_num_indi_per_exp<individual,1,'last');
  individual=individual-cumsum_num_indi_per_exp(ggee);
end

fid=nan;  if(handles.dump2csv)  fid=fopen('most_recent_figure.csv','w');  end

handles.type='feature time series';

hf=figure('toolbar','figure');

bb=handles.behaviorvalue;
if(handles.featuretimeseries_style2==1)  bb=1;  end
if(bb==(length(handles.behaviorlist)+1))  bb=1:(bb-1);  end
if(strcmp(get(handles.BehaviorList,'enable'),'off'))  bb=0;  end

behavior_logic=handles.behaviorlogic;
score_file2=[];
if((length(bb)>1) || (bb>0))  score_file2=handles.scorefiles{handles.behaviorvalue2};  end
feature_value=handles.featurevalue;
feature_list=handles.featurelist;
%sexdata=handles.sexdata;
timing=handles.featuretimeseries_style2;
xoffset=handles.xoffset;
if((length(bb)==1) && (bb==0))
  timing=1;
  xoffset=2;
end
style=handles.featuretimeseries_style;
centraltendency=handles.centraltendency;
dispersion=handles.dispersion;
convolutionwidth=round(handles.convolutionwidth*handles.fps);
subtractmean=handles.subtractmean;
windowradius=handles.windowradius;
behaviornot=handles.behaviornot;

h=[];
for b=bb

  if(length(bb)>1)
    ceil(sqrt(length(bb)));
    ha=subplot(ceil(length(bb)/ans),ans,b,'parent',hf);
  else
    ha=subplot(1,1,1,'parent',hf);
  end
  hold(ha,'on');

  score_file=[];
  if(b>0)  score_file=handles.scorefiles{b};  end

  num_indi=0;
  raw_data=cell(length(ggee),length(individual));
  data=cell(length(ggee),length(individual));
  parfor gei=1:length(ggee)
  %for gei=1:length(ggee)
    ge = ggee(gei);

    if(b>0)
      behavior_data=load(fullfile(handlesexperimentlist{ge},score_file));
      behavior_data=update_t01s_from_postprocessed(behavior_data);
      if(behavior_logic>1)
        behavior_data2=load(fullfile(handlesexperimentlist{ge},score_file2));
        behavior_data2=update_t01s_from_postprocessed(behavior_data2);
      else
        behavior_data2=[];
      end
    else
      behavior_data=[];
      behavior_data2=[];
    end
    feature_data=load(fullfile(handlesexperimentlist{ge},handles.perframe_dir,...
        [feature_list{feature_value} '.mat']));

    [behavior_data,behavior_data2,~,feature_data,sex_data]=...
        cull_short_trajectories(handles,behavior_data,behavior_data2,[],feature_data,handles.sexdata{ge});
    num_indi=num_indi+length(feature_data.data);

    raw_parfor_tmp=cell(1,length(individual));
    parfor_tmp=cell(1,length(individual));
    for ii = 1:length(individual)
      i=individual(ii);
      if(iscell(i))  i=char(i);  end
      tmp2=[];
      switch(i)
        case('M')
          tmp2=sex_data;
        case('F')
          tmp2=cellfun(@not,sex_data,'uniformoutput',false);
        otherwise
          tmp2=cellfun(@(x) ones(1,length(x)),sex_data,'uniformoutput',false);
      end
      tmp=nan;  if isnumeric(i)  tmp=i;  end

      if(timing==1)
        calculate_entiretimeseries(behavior_data,feature_data,tmp2,tmp,xoffset);
        raw_parfor_tmp{ii}=nanmean(ans,1);
        if(~isempty(raw_parfor_tmp{ii}))
          conv(raw_parfor_tmp{ii},ones(1,convolutionwidth),'valid');
          ans./conv(ones(1,length(raw_parfor_tmp{ii})),ones(1,convolutionwidth),'valid');
          parfor_tmp{ii}=[nan(1,floor((convolutionwidth-1)/2)) ans nan(1,ceil((convolutionwidth-1)/2))];
        else
          parfor_tmp{ii}=raw_parfor_tmp{ii};
        end
      else
        calculate_triggeredtimeseries(behavior_data,behavior_logic,behavior_data2,...
            feature_data,tmp2,tmp,timing,windowradius,subtractmean,behaviornot);
        raw_parfor_tmp{ii}=nanmean(ans,1);
        parfor_tmp{ii}=raw_parfor_tmp{ii};
      end
    end
    raw_data(gei,:)=raw_parfor_tmp;
    data(gei,:)=parfor_tmp;
  end
  raw_data=reshape(raw_data,1,prod(size(raw_data)));
  data=reshape(data,1,prod(size(data)));

  if(num_indi==0)
    delete(hf);
    set(handles.Status,'string','Ready.','foregroundcolor','g');
    set(handles.figure1,'pointer','arrow');
    uiwait(errordlg('no valid data.  check minimum trajectory length.'));  drawnow;
    return;
  end

  if(timing==1)
    max(cellfun(@(x) size(x,2),data));
    cellfun(@(x) [x nan(size(x,1),ans-size(x,2))],data,'uniformoutput',false);
    ydata=cat(1,ans{:});
    xdata=1:size(ydata,2);
  else
    ydata=cat(1,data{:});
    xdata=-windowradius:windowradius;
  end

  tstr='';
  if(timing>1)
    tstr='';  if(behaviornot)  tstr='NOT ';  end
    tstr=[tstr char(strrep(handles.behaviorlist(b),'_','-'))];
    switch(handles.behaviorlogic)
      case 2
        tstr=[tstr ' AND '];
      case 3
        tstr=[tstr ' AND NOT '];
%      case 4
%        tstr=[tstr ' OR '];
%      case 5
%        tstr=[tstr ' OR NOT '];
    end
    if(behavior_logic>1)
      tstr=[tstr char(strrep(handles.behaviorlist(handles.behaviorvalue2),'_','-'))];
    end
  end
  time_base=xdata./handles.fps;
  xstr='time (sec)';
  if(time_base(end)>60)
    time_base=time_base./60;
    xstr='time (min)';
  end
  if(time_base(end)>60)
    time_base=time_base./60;
    xstr='time (hr)';
  end
  if(time_base(end)>24)
    time_base=time_base./24;
    xstr='time (d)';
  end
  units=load(fullfile(handlesexperimentlist{ggee(1)},handles.perframe_dir,...
      [feature_list{feature_value} '.mat']),'units');
  ystr=get_label(feature_list(feature_value),units.units);

  if(handles.dump2csv)  print_csv_help(fid,handles.type,tstr,xstr,ystr);  end

  ii=0;
  for i = individual
    ii=ii+1;
    if(iscell(i))  i=char(i);  end
    for g=1:length(handles.grouplist)
      color=handles.colors(g,:);

      if ischar(i)
        idx=(cumsum_num_selexp_per_group(g)+1):(cumsum_num_selexp_per_group(g+1));
      else
        find(cumsum_num_exp_per_group<ggee,1,'last');
        if(ans~=g)  continue;  end
        idx=1;
      end
      idx2=idx+(ii-1)*numel(ggee);
      linestyle='-';  if(ii>1)  linestyle='--';  end

      if(handles.dump2csv)  fprintf(fid,['%% group ' handles.grouplist{g} '\n']);  end
      plot_it(ha,time_base,ydata(idx2,:),style,centraltendency,dispersion,color,1,linestyle,...
          fid,handlesexperimentlist(idx));
      if (ii==1)
        h(g)=ans;
        hh{g}=handles.grouplist{g};
      end
    end

    if(handles.dump2csv)  fprintf(fid,'\n%% raw data\n');  end
    for g=1:length(handles.grouplist)
      if ischar(i)
        idx=(cumsum_num_selexp_per_group(g)+1):(cumsum_num_selexp_per_group(g+1));
      else
        find(cumsum_num_exp_per_group<ggee,1,'last');
        if(ans~=g)  continue;  end
        idx=1;
      end
      idx2=idx+(ii-1)*numel(ggee);

      if(handles.dump2csv)
        fprintf(fid,['%% group ' handles.grouplist{g} '\n']);
        for e=1:length(idx2)
          fprintf(fid,'%% experiment %s\n',handlesexperimentlist{selected_exp(idx(e))});
          print_csv_data(fid,raw_data{idx2(e)});
          fprintf(fid,'\n');
        end
      end
    end
  end

  if(handles.dump2mat)
    find(b==bb);
    raw_data2{ans}=raw_data;
  end

  xlabel(ha,xstr,'interpreter','none');
  ylabel(ha,ystr,'interpreter','none');
  title(ha,tstr,'interpreter','none');
  axis(ha,'tight');  zoom(ha,'reset');
end

if(handles.dump2mat)
  raw_data=raw_data2;
  save('most_recent_figure.mat','handles','raw_data');
end

if(iscell(individual))
  h(end+1)=plot(0,0,'k-');   hh{end+1}='males';
  h(end+1)=plot(0,0,'k--');  hh{end+1}='females';
  set(h((end-1):end),'visible','off');
end

idx=find(h>0);
if ~isnumeric(individual)
  %legend(ha,h(idx),[cellfun(@(x) [x ' ' handles.individuallist{handles.individualvalue}],...
  %    handles.grouplist,'uniformoutput',false)],'interpreter','none');
  legend(ha,h(idx),hh(idx),'interpreter','none');
%else
%  legend(ha,h(idx),handles.individuallist(handles.individualvalue),'interpreter','none');
end

uicontrol(hf,'style','pushbutton','string','Params','position',[5 5 60 20],...
    'callback',@figure_params_callback);

if(handles.dump2csv)  fclose(fid);  end

guidata(hf,handles);

set(handles.Status,'string','Ready.','foregroundcolor','g');
set(handles.figure1,'pointer','arrow');
drawnow;

% --- 
%%
behavior_data = load("F:\hadar\GH\together\GroupedHouse5\Assa_Males_Grouped5_Unknown_RigA_20221229T082833\scores_Social_Clustering.mat");
behavior_logic = handles.behaviorlogic;


%%
function [bout_lengths sex inter_bout_lengths inter_sex]=...
    calculate_boutstats(behavior_data,behavior_logic,behavior_data2,sexdata,behaviornot)

bout_lengths=cell(1,length(behavior_data.allScores.t0s));
inter_bout_lengths=cell(1,length(behavior_data.allScores.t0s));
sex=cell(1,length(behavior_data.allScores.t0s));
inter_sex=cell(1,length(behavior_data.allScores.t0s));
for i=1:length(behavior_data.allScores.t0s)  % individual
  tmp1 = compute_behavior_logic(behavior_data.allScores, i);
  tmp1 = tmp1(behavior_data.allScores.tStart(i) : behavior_data.allScores.tEnd(i));

  tmp2=[];
  if(behavior_logic>1)
    tmp2 = compute_behavior_logic(behavior_data2.allScores, i);
    tmp2 = tmp2(behavior_data2.allScores.tStart(i) : behavior_data2.allScores.tEnd(i));
  end

  if(behaviornot)  tmp1=~tmp1;  end

  partition_idx=[];
  switch(behavior_logic)
    case(1)
      partition_idx=tmp1;
    case(2)
      partition_idx=tmp1 & tmp2;
    case(3)
      partition_idx=tmp1 & ~tmp2;
    case(4)
      partition_idx=tmp1 | tmp2;
    case(5)
      partition_idx=tmp1 | ~tmp2;
  end

  % inter-bout NOT <behavior> is not quite the same as bout <behavior>

  partition_idx=[0 partition_idx 0];
  start=1+find(~partition_idx(1:(end-1)) &  partition_idx(2:end))-1;
  stop =  find( partition_idx(1:(end-1)) & ~partition_idx(2:end))-1;
  if(length(start)>0)
    bout_lengths{i}=stop-start+1;
    sex{i}=zeros(1,length(bout_lengths{i}));
    for j=1:length(bout_lengths{i})
      if numel(sexdata{i})==1,
        sex{i}(j) = sexdata{i};
      else
        sex{i}(j)=sum(sexdata{i}(start(j):stop(j))) > (bout_lengths{i}(j)/2);
      end
    end
    if(length(start)>1)
      inter_bout_lengths{i}=start(2:end)-stop(1:(end-1));
      inter_sex{i}=zeros(1,length(inter_bout_lengths{i}));
      for j=1:length(inter_bout_lengths{i})
        if numel(sexdata{i})==1,
          inter_sex{i}(j)=sexdata{i};
        else
          inter_sex{i}(j)=sum(sexdata{i}(stop(j):start(j+1))) > (inter_bout_lengths{i}(j)/2);
        end
      end
    end
  end
end


% ---
function handles=bout_stats_plot(handles)

set(handles.Status,'string','Thinking...','foregroundcolor','b');
set(handles.figure1,'pointer','watch');
drawnow;

handlesexperimentlist=[handles.experimentlist{:}];

cumsum_num_indi_per_exp=[0 cumsum(handles.individuals_feature)];
cumsum_num_exp_per_group=[0 cumsum(cellfun(@length,handles.experimentlist))];
mat2cell(cumsum_num_exp_per_group(1:end-1),1,ones(1,length(cumsum_num_exp_per_group)-1));
cellfun(@(x,y) x+y,handles.experimentvalue,ans,'uniformoutput',false);
selected_exp=[ans{:}];
cumsum_num_selexp_per_group=[0 cumsum(cellfun(@length,handles.experimentvalue))];

%ggee=1:length(handlesexperimentlist);
ggee=selected_exp;
individual=handles.individualidx;
if isnumeric(individual)
  ggee=find(cumsum_num_indi_per_exp<individual,1,'last');
  individual=individual-cumsum_num_indi_per_exp(ggee);
end

fid=nan;  if(handles.dump2csv)  fid=fopen('most_recent_figure.csv','w');  end

handles.type='bout stats';

hf=figure('toolbar','figure');

bb=handles.behaviorvalue;
if(bb==(length(handles.behaviorlist)+1))  bb=1:(bb-1);  end

behavior_logic=handles.behaviorlogic;
score_file2=handles.scorefiles{handles.behaviorvalue2};
%sexdata=handles.sexdata;
behaviornot=handles.behaviornot;

h=[];
table_data={};
for b=bb

  if(length(bb)>1)
    ceil(sqrt(length(bb)));
    ha=subplot(ceil(length(bb)/ans),ans,b,'parent',hf);
  else
    ha=subplot(1,1,1,'parent',hf);
  end
  hold(ha,'on');

  score_file=handles.scorefiles{b};

  num_indi=0;
  collated_data=cell(1,length(ggee));
  parfor gei=1:length(ggee)
  %for gei=1:length(ggee)
    ge = ggee(gei);

    behavior_data=load(fullfile(handlesexperimentlist{ge},score_file));
    behavior_data=update_t01s_from_postprocessed(behavior_data);
    behavior_data2=[];
    if(behavior_logic>1)
      behavior_data2=load(fullfile(handlesexperimentlist{ge},score_file2));
      behavior_data2=update_t01s_from_postprocessed(behavior_data2);
    end

    [behavior_data,behavior_data2,~,~,sex_data]=...
        cull_short_trajectories(handles,behavior_data,behavior_data2,[],[],handles.sexdata{ge});
    num_indi=num_indi+length(behavior_data.allScores.scores);

    [bout_lengths sex inter_bout_lengths inter_sex]=...
        calculate_boutstats(behavior_data,behavior_logic,behavior_data2,sex_data,behaviornot);
    collated_data{gei}={bout_lengths sex inter_bout_lengths inter_sex};
  end

  if(num_indi==0)
    delete(hf);
    set(handles.Status,'string','Ready.','foregroundcolor','g');
    set(handles.figure1,'pointer','arrow');
    uiwait(errordlg('no valid data.  check minimum trajectory length.'));  drawnow;
    return;
  end

  tstr='';  if(behaviornot)  tstr='NOT ';  end
  tstr=[tstr char(strrep(handles.behaviorlist(b),'_','-'))];
  switch(handles.behaviorlogic)
    case 2
      tstr=[tstr ' AND '];
    case 3
      tstr=[tstr ' AND NOT '];
    case 4
      tstr=[tstr ' OR '];
    case 5
      tstr=[tstr ' OR NOT'];
  end
  if(handles.behaviorlogic>1)
    tstr=[tstr char(strrep(handles.behaviorlist(handles.behaviorvalue2),'_','-'))];
  end
  ystr='bout length (sec)';
  if(handles.boutstats_style2==2)  ystr=['inter-' ystr];  end
  xstr='group';

  if(handles.dump2csv)  print_csv_help(fid,handles.type,tstr,xstr,ystr);  end

  idx=cellfun(@isempty,collated_data);
  collated_data=collated_data(~idx);

  exp_separators=[];  maxy=0;  k=[];  m=0;  ii=0;  
  table_data{end+1}=[];
  for idx = 1:length(individual)
    i = individual(idx);
    if(iscell(i))  i=char(i);  end
    idx=handles.boutstats_style2*2-1;
    switch(i)
      case 'A'
        length_data=cellfun(@(x) x{idx},collated_data,'uniformoutput',false);
      case {'M'}
        for ge=1:length(collated_data)
          length_data{ge}=cellfun(@(x,y) x(y==1),...
              collated_data{ge}{idx},collated_data{ge}{idx+1},'uniformoutput',false);
        end
      case {'F'}
        for ge=1:length(collated_data)
          length_data{ge}=cellfun(@(x,y) x(y==0),...
              collated_data{ge}{idx},collated_data{ge}{idx+1},'uniformoutput',false);
        end
      otherwise
        length_data=cellfun(@(x) x{idx}(individual),collated_data,'uniformoutput',false);
    end

    if(handles.dump2csv)
      fprintf(fid,'\n%% raw data\n');
      for g=1:length(handles.grouplist)
        if ~isnumeric(individual)
          idx=(cumsum_num_selexp_per_group(g)+1):(cumsum_num_selexp_per_group(g+1));
        else
          find(cumsum_num_exp_per_group<ggee,1,'last');
          if(ans~=g)  continue;  end
          idx=1;
        end
        fprintf(fid,['%% group ' handles.grouplist{g} '\n']);
        for e=1:length(idx)
          fprintf(fid,'%% experiment %s\n',handlesexperimentlist{selected_exp(idx(e))});
          for i2=1:length(length_data{idx(e)})
            fprintf(fid,'%% individual %d\n',i2);
            print_csv_data(fid,length_data{idx(e)}{i2}./handles.fps);
            fprintf(fid,'\n');
          end
        end
      end
    end

    for g=1:length(handles.grouplist)
      color=handles.colors(g,:);
      ii=ii+1;

      if ischar(i)
        idx=(cumsum_num_selexp_per_group(g)+1):(cumsum_num_selexp_per_group(g+1));
      else
        find(cumsum_num_exp_per_group<ggee,1,'last');
        if(ans~=g)  continue;  end
        idx=1;
      end

      xticklabels{ii}=handles.grouplist{g};

      switch(handles.boutstats_style)
        case 1  % per experiment, error bars
          table_data{end}{ii}=cellfun(@(x) nanmean([x{:}]./handles.fps),length_data(idx));
          [ct(g),dp(g),dn(g)]=...
              calculate_ct_d(table_data{end}{ii},handles.centraltendency,handles.dispersion);
          h{ii}=errorbarplot(ha,ii,ct(g),ct(g)-dn(g),dp(g)-ct(g),color);
        case 2  % per fly, grouped
          cumsum(cellfun(@length,length_data(idx)))';
          exp_separators=[exp_separators; ans+sum(k)];
          table_data{end}{ii}=cellfun(@nanmean,[length_data{idx}])./handles.fps;
          maxy=max([maxy table_data{end}{ii}]);
          h{ii}=bar(ha,(1:length(table_data{end}{ii}))+sum(k),table_data{end}{ii},...
              'barwidth',1,'edgecolor','none');
          set(h{ii},'facecolor',color);
          k(end+1)=length(table_data{end}{ii});
      end
    end
  end

  if(ismember(handles.behaviorbarchart_style,[1 2 4 6]) && (length(individual)==2))
    for g=(length(h)/2+1):length(h)
      findobj([h{g}],'type','patch');
      hatchfill(ans,'single',45,5,handles.colors(g-length(h)/2,:));
    end
  end

  if(handles.dump2csv)
    fprintf(fid,'\n%% summary data\n');
    fprintf(fid,['%% xdata\n']);  fprintf(fid,'%s, ',xticklabels{:});  fprintf(fid,'\n');
  end
  switch(handles.boutstats_style)
    case 1  % per experiment, error bars
      if(handles.dump2csv)
        fprintf(fid,['%% ydata, CT+D\n']);  fprintf(fid,'%g, ',dp);  fprintf(fid,'\n');
        fprintf(fid,['%% ydata, CT-D\n']);  fprintf(fid,'%g, ',dn);  fprintf(fid,'\n');
        fprintf(fid,['%% ydata, CT\n']);    fprintf(fid,'%g, ',ct);  fprintf(fid,'\n');
      end
    case 2  % per fly, grouped
      l=exp_separators(1:2:(end-1));
      r=exp_separators(2:2:end);
      hh=patch(0.5+[l r r l l]',repmat([0 0 maxy*1.05 maxy*1.05 0]',1,floor(length(exp_separators)/2)),...
          [0.95 0.95 0.95],'parent',ha);
      set(hh,'edgecolor','none');
      set(ha,'children',circshift(get(ha,'children'),-1));
      k=round(cumsum(k)-k/2);
      if(handles.dump2csv)
        fprintf(fid,['%% ydata\n']);
        for i=1:length(table_data{end})
          fprintf(fid,'%g, ',[table_data{end}{i}]);
          fprintf(fid,'\n');
        end
      end
  end

  if(handles.dump2mat)
    find(b==bb);
    raw_data{ans}=collated_data;
  end

  if(isempty(k))  k=1:length(length_data);  end
  title(ha,tstr,'interpreter','none');
  ylabel(ha,ystr,'interpreter','none');
  set(ha,'xtick',k,'xticklabel',xticklabels);
  axis(ha,'tight');  vt=axis;
  axisalmosttight([],ha);  vat=axis;
  if(handles.boutstats_style==2)
    axis(ha,[vat(1) vat(2) 0 vt(4)]);
  else
    axis(ha,[vat(1) vat(2) 0 vat(4)]);
  end
  %if(handles.dump2csv)  fprintf(fid,'\n');  end
end

if(handles.dump2mat)
  save('most_recent_figure.mat','handles','raw_data');
end

if(iscell(individual))
  h2(1)=plot(0,0,'k-');   hh2{1}='males';
  h2(2)=plot(0,0,'k--');  hh2{2}='females';
  set(h2,'visible','off');
  legend(ha,h2,hh2,'interpreter','none');
end

uicontrol(hf,'style','pushbutton','string','Params','position',[5 5 60 20],...
    'callback',@figure_params_callback);
if(ischar(individual) && (length(handles.grouplist)>1))
  uicontrol(hf,'style','pushbutton','string','Stats','position',[70 5 50 20],...
      'callback',@figure_stats_callback);
  handles.statistics=calculate_statistics(table_data,handles.behaviorlist(bb),handles.grouplist,...
      fid,handles.pvalue);
end

if(handles.dump2csv)  fclose(fid);  end

guidata(hf,handles);

set(handles.Status,'string','Ready.','foregroundcolor','g');
set(handles.figure1,'pointer','arrow');
drawnow;

