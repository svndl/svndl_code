function [inverse_name] = gcv_inverse_name(gcv_params)

inverse_name = 'gcv_regu';
if isfield(gcv_params,'TimeWindow')
    inverse_name = strcat( inverse_name , '_TWindow_' );
    inverse_name = strcat( inverse_name , num2str( gcv_params.TimeWindow(1) ) );
    inverse_name = strcat( inverse_name , '_' , num2str( gcv_params.TimeWindow(2) ) );
else
    if (gcv_params.f1_Odd | gcv_params.f1_Even)
        inverse_name = strcat( inverse_name , '_F1' );
        f = [ 2*gcv_params.f1_Odd - 1 , 2*(gcv_params.f1_Even) ];
        f = sort(f(f>0));
        for k = 1 : length(f)
            inverse_name = strcat( inverse_name , '_' , num2str( f(k) ) );
        end
    end
    if isfield(gcv_params,'f2_Odd')
        f = [ 2*gcv_params.f2_Odd - 1 , 2*(gcv_params.f2_Even) ];
        f = sort(f(f>0));
        if f
            inverse_name = strcat( inverse_name , '_F2' );
            for k = 1 : length(f)
                inverse_name = strcat( inverse_name , '_' , num2str( f(k) ) );
            end
        end
        if isfield(gcv_params,'Intermodulation_order')
            inverse_name = strcat( inverse_name , '_Intermod' , num2str( gcv_params.Intermodulation_order ) );
        end
    end
end