function minima = findLocalMinima(fun)
    
    l = size(fun,1);
    yMax = max(fun(5:l-5));
    yMin = min(fun(5:l-5));
    dif = yMax - yMin;
    
    minima = zeros(l,1);
    
    for i=2:1:l
        %Define local gradient:
        grad = (fun(i) - fun(i-1)) / 2;
        %If the local gradient is close to zero, it might be a minimum
        if abs(grad) <= 0.1
           %We look for a large difference relative to the environment
            if i < 3
                if fun(i+3) >= fun(i) + 0.2*dif
                   minima(i) = 1; 
                end
            elseif i > l - 3
                if (fun(i+3) >= fun(i) + 0.2*dif) || (fun(i-3) >= fun(i) + 0.2*dif)
                   minima(i) = 1; 
                end
            else
                if fun(i-3) >= fun(i) + 0.2*dif
                   minima(i) = 1; 
                end
            end
        end
    end
end