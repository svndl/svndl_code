function [ gcv_params ] = get_gcv_params( f2_flag )

% Default values
%%%%%%%%%%%%%%%%%%%%%%%%%%%
gcv_params.f1_Odd = true;
gcv_params.f1_Even = false;
if f2_flag
    gcv_params.f2_Odd = false;
    gcv_params.f2_Even = false;
    gcv_params.Intermodulation_order = false;
end
gcv_params.Time_window = false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display of the gui interface
f = fieldnames(gcv_params);
n = numel(f);
h = 0.8/n;
fig = figure('defaultuicontrolunits','normalized','units','normalized','position',[0.5 ,  0.5 , 0.3 , 0.3]);
U = zeros(1,n);
for i = 1:n
    uicontrol('style','text','position',[0.05 0.95-i*h 0.45 h],'string',f{i});
    U(i) = uicontrol('style','edit','position',[0.5 0.95-i*h 0.45 h],'string',num2str(gcv_params.(f{i})));
end
uicontrol('style','pushbutton','position',[0.05 0.05 0.9 0.1],'string','OK','callback','uiresume(gcf)');
uiwait(fig)
% time_based_regu = 0;
for i = 1:n
	gcv_params.(f{i}) = str2num(get(U(i),'string'));
    %time_based_regu = time_based_regu + gcv_params.(f{i})(1);
end
close(fig)
%if (time_based_regu==0)
if (gcv_params.Time_window)
    clear gcv_params
    gcv_params.TimeWindow = true;
    f = fieldnames(gcv_params);
    n = numel(f);
    h = 0.8/n;
    fig = figure('defaultuicontrolunits','normalized','units','normalized','position',[0.5 ,  0.5 , 0.3 , 0.3]);
    U = zeros(1,n);
    for i = 1:n
        uicontrol('style','text','position',[0.05 0.95-i*h 0.45 h],'string',f{i});
        U(i) = uicontrol('style','edit','position',[0.5 0.95-i*h 0.45 h],'string',num2str(gcv_params.(f{i})));
    end
    uicontrol('style','pushbutton','position',[0.05 0.05 0.9 0.1],'string','OK','callback','uiresume(gcf)');
    uiwait(fig)
    gcv_params.(f{i}) = str2num(get(U(i),'string'));
    close(fig)
end
