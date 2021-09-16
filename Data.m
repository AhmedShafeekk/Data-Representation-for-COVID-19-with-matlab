classdef Data
    properties
        data 
        Date
        Countries_Names 
        States_Names
        States_Data %States_Data{Country_Index,City_Index}{day_no}= {Cases,Deaths};
        Cases %for Calc_Cases
        Deaths %for Calc_Deaths
        global_Cases %Global Cases vector
        global_Deaths %Global_Deaths_Vector
        Daily_Cases % To Store output of Calc_Daily_Cases function
        Daily_Deaths % To Store output of Calc_Daily_Deaths function
        
%         Countries_Names   Countries_index      States_Names(States_index)
%         'Global'                   1             'All'(1) '[]'(2) ..... '[]'(57)   
%         'Afghanstan'               2             'All'(1) '[]'(2) ..... '[]'(57)
%           .                        3             'All'(1) '[]'(2) ..... '[]'(57
%           .                        .               .
%           .                        etc             .
%         'Canada'                   34               'All'(1)'Alberta'(2).... '[]'(57)
%           .
%           .
%          etc
% 
%  ============================================================================================
% States_Data:
%
%             | 
%             |  States_Indices  
%  ==============================================
%  Countryies | each cell of the 2D cell array contains
%  Indices    | a cell of {375 Cases , 375 Deaths} in 375 days
%             |
%             |
%             |
%             |
%             |
    end
    methods
        function obj= Data()
            load covid covid_data;
            obj.data=covid_data;
            obj.Date=covid_data(1,3:end); %% Storing Dates in Date

            obj.global_Cases=zeros(1,size(obj.Date,2));
            obj.global_Deaths=zeros(1,size(obj.Date,2));
            
            for row=2:size(obj.data,1)
                if isempty(obj.data{row,2})
                    for col=3:size(obj.data,2)
                        obj.global_Cases(col-2)=obj.global_Cases(col-2)+obj.data{row,col}(1);
                        obj.global_Deaths(col-2)=obj.global_Deaths(col-2)+obj.data{row,col}(2);
                    end
                end
            end
        
            obj.Countries_Names=covid_data(2:end,1);  %Storing all countries names
            obj.Countries_Names =unique(obj.Countries_Names); % removing repeated names
            obj.Countries_Names=reshape(obj.Countries_Names,1,numel(obj.Countries_Names));
            obj.Countries_Names=horzcat('Global',obj.Countries_Names);
            obj.States_Data{1,1}=[obj.global_Cases(:)',obj.global_Deaths(:)'];
            obj.States_Names{1,1}='All';
            Cindex=2;
            Sindex=1;
            new_country=0;
            r=size(covid_data,1);
            for row=2:r
                if isempty(covid_data{row,2})
                    if new_country==1
                        Cindex=Cindex+1;
                        new_country=0;
                    end
                    Sindex=1;
                    obj.States_Data{Cindex,Sindex}=covid_data(row,3:end);
                    obj.States_Names{Cindex,Sindex}='All';
                    Sindex=Sindex+1;
                    new_country=new_country+1;
                else
                    obj.States_Data{Cindex,Sindex}=covid_data(row,3:end);
                    obj.States_Names{Cindex,Sindex}=covid_data{row,2};
                    Sindex=Sindex+1;
                end
            end
        end
        function obj = Calc_Cases(obj,Cin,Sin) %Cin: Country index Sin: State index
            if Cin==1 && Sin==1
                obj.Cases=obj.global_Cases;
            else
                obj.Cases=zeros(1,size(obj.Date,2));
                for i=1:size(obj.Date,2)
                    obj.Cases(i)=obj.States_Data{Cin,Sin}{i}(1);
                end
            end
        end
        function obj = Calc_Deaths(obj,Cin,Sin) %Cin: Country index Sin: State index
            if Cin==1 && Sin==1
                obj.Deaths=obj.global_Deaths;
            else
                obj.Deaths=zeros(1,size(obj.Date,2));
                for i=1:size(obj.Date,2)
                    obj.Deaths(i)=obj.States_Data{Cin,Sin}{i}(2);
                end
            end
        end
        function obj = Calc_Daily_Cases(obj)
            obj.Daily_Cases=zeros(1,size(obj.Date,2));
            obj.Daily_Cases(1)=obj.Cases(1);
            for i=2:size(obj.Cases,2)
                obj.Daily_Cases(i)=obj.Cases(i)-obj.Cases(i-1);
            end
        end
        function obj = Calc_Daily_Deaths(obj)
            obj.Daily_Deaths=zeros(1,size(obj.Date,2));
            obj.Daily_Deaths(1)=obj.Deaths(1);
            for i=2:size(obj.Cases,2)
                obj.Daily_Deaths(i)=obj.Deaths(i)-obj.Deaths(i-1);
            end
        end
    end
end