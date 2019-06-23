clearvars
number_of_times_to_run = 1000;
J_1000_s = zeros(number_of_times_to_run, 5);
for run_number = 1:number_of_times_to_run
    
    run_me
    J_1000_s(run_number, :) = [sum(J_dual), sum(J_low), sum(J_high), (sum(J_low)/sum(J_dual)-1)*100,(sum(J_high)/sum(J_dual)-1)*100];
    run_number
end
J_1000_s

%% PLot
figure(1);clf
histogram(J_1000_s(:,4),'Normalization','probability')
hold on;
histogram(J_1000_s(:,5),'Normalization','probability')
hold off;
xlabel('Improvement[%]')
ylabel('Normalized Frequency')
legend('improvement of slow controller', 'improvement of fast controller')

txt = ['\bf', 'K_{Slow}', '\rm', sprintf('\nAvg: %.2f\nstd: %.2f\nMed: %.2f\nMin: %.1f\nMax: %.1f', mean(J_1000_s(:, 4)), std(J_1000_s(:, 4)), median(J_1000_s(:, 4)), min(J_1000_s(:, 4)), max(J_1000_s(:, 4)) )];
dim = [0.65, 0.8,0, 0];
annotation('textbox',dim,'String',txt,'FitBoxToText','on');

txt = ['\bf', 'K_{fast}', '\rm', sprintf('\nAvg: %.2f\nstd: %.2f\nMed: %.2f\nMin: %.1f\nMax: %.1f', mean(J_1000_s(:, 5)), std(J_1000_s(:, 5)), median(J_1000_s(:, 5)), min(J_1000_s(:, 5)), max(J_1000_s(:, 5)) )];
dim = [0.15, 0.8,0, 0];
annotation('textbox',dim,'String',txt,'FitBoxToText','on');
