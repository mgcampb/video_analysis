function [sync_pulse, camt] = extract_gpio(gpio_file)
%EXTRACT_GPIO Extracts gpio signal from file
%   Returns the sync pulse and the time stamps for each frame
    
    % Figure out what delimiter to use
%     if contains(gpio_file,'GPIOTS')
%         type = 1;
%         delim = ',';
%     elseif contains(gpio_file,'gpio1')
%         type = 2;
%         delim = ' ';
%     end

    type = 2;
    if contains(gpio_file,'gpio1')
        delim = ' ';
    elseif contains(gpio_file,'gpio2')
        delim = ',';
    end

    gpio = readtable(gpio_file,'Delimiter',delim);
    sync_pulse = gpio.Var1; % first column is the sync pulse
    if max(sync_pulse)~=0
        sync_pulse = sync_pulse/max(sync_pulse);
    end

    if type==1
        time_str = char(gpio.Var2);
        time_str = time_str(:,12:end-6);
        camt0 = duration(time_str(1,:));
        camt = nan(size(gpio,1),1);
        for i = 1:numel(camt)
            camt(i) = seconds(duration(time_str(i,:))-camt0);
        end
    elseif type==2
        camt = seconds(gpio.Var3-gpio.Var3(1));
    end
   
end

