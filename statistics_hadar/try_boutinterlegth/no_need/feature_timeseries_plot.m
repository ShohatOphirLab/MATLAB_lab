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