function blen = GetPostprocessedBoutLengths(obj,iCls)
      % blen: row vector, bout length for classifier iCls over all
      % exps/flies
      
      %MERGESTUPDATED
      
      blen = zeros(1,0);
           
      if obj.HasCurrentScores()
        % For predicted scores.
        for endx = 1:obj.nexps
          for flies = 1:obj.nflies_per_exp(endx)
            pd = obj.predictdata{endx}{flies}(iCls);
            idx = find(pd.cur_valid); % AL20141215 
            ts = pd.t(idx);            
            [sortedts,idxorder] = sort(ts);
            % AL 20141215: added +1 to next line, cf ApplyPostProcessing
            gaps = find((sortedts(2:end) - sortedts(1:end-1))>1)+1; 
            gaps = [1;gaps';numel(ts)+1];
            for ndx = 1:numel(gaps)-1
              % loop over 'contiguous' segments of time
              curidx = idx(idxorder(gaps(ndx):gaps(ndx+1)-1)); % indices into pd.t, pd.cur_valid, pd.cur_pp for current time segment
              assert(isequal(size(pd.t),size(pd.cur_valid),size(pd.cur_pp)));
              posts = pd.cur_pp(curidx); 
              labeled = bwlabel(posts);
              aa = regionprops(labeled,'Area');  %#ok
              blen = [blen [aa.Area]];  %#ok
            end
          end
        end        
      else        
        % For loaded scores.
        for endx = 1:obj.nexps
          for flies = 1:obj.nflies_per_exp(endx)
            pd = obj.predictdata{endx}{flies}(iCls);
            curidx = pd.loaded_valid;
            curt = pd.t(curidx);
            if any(curt(2:end)-curt(1:end-1) ~= 1)
              warning('JLabelData:bouts','Scores are not in order');
              return;
            end
            posts = pd.loaded_pp(curidx);
            labeled = bwlabel(posts);
            aa = regionprops(labeled,'Area');  %#ok
            blen = [blen [aa.Area]];  %#ok
          end
        end        
      end
    end
