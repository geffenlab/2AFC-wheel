
clc
mice = {'K196','K197','K199'};

for mm = 1:length(mice)
    mouse = mice{mm};
    dataLoc = ['C:\Users\Maria\Documents\GitHub\2AFC-wheel\mice\' mouse filesep];

    files = dir([dataLoc '*.txt']);
    filenames = {files.name}';
    unique_dates = unique(cellfun(@(x) x(1:13),filenames,'UniformOutput',false));
    for ii = 1:length(unique_dates)
        save_name = [dataLoc unique_dates{ii} '_combined.mat'];
        if ~isfile(save_name)
            date_files = filenames(contains(filenames,unique_dates{ii}));
            data = [];
            for jj = 1:length(date_files)
                d = importdata([dataLoc date_files{jj}]);
                data = [data; d.data];
            end
            column_headers = d.colheaders;
            save(save_name,'data','column_headers')
             fprintf('Mouse: %s\nDate: %s\nCorrect trials: %d/%d Percent correct: %0.0f%%\n\n',unique_dates{ii}(1:4),unique_dates{ii}(6:end),sum(data(:,9)),size(data,1),mean(data(data(:,8)==0,9))*100);
        else
            %             load(save_name)
            %         end
           
        end
    end
end