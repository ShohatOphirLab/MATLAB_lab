function handles=bout_stats_plot(handles)

% the handles should be update:
% handles.experimentlist
%handles.individual_feature

handlesexperimentlist=[handles.experimentlist{:}]; % shuld be fixed to the correct name

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
