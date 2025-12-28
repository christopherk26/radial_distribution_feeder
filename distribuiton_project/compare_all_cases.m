%% Compare all three cases
clear; clc;

%% Load all three cases
mpc_base = feeder_base_case;
mpc_reg = feeder_with_regulator;
mpc_reg_cap = feeder_with_regulator_and_cap;

%% Run power flow
fprintf('Running all cases...\n');
results_base = runpf(mpc_base, mpoption('verbose', 0, 'out.all', 0));
results_reg = runpf(mpc_reg, mpoption('verbose', 0, 'out.all', 0));
results_reg_cap = runpf(mpc_reg_cap, mpoption('verbose', 0, 'out.all', 0));

%% Extract voltages
V_base = results_base.bus(:, 8);
V_reg = results_reg.bus(:, 8);
V_reg_cap = results_reg_cap.bus(:, 8);

%% Display comparison
fprintf('\n========== VOLTAGE COMPARISON ==========\n');
fprintf('Bus\tBase\t\tRegulator\tReg+Cap\n');
fprintf('------------------------------------------------\n');
for i = 1:6
    fprintf('%d\t%.4f pu\t%.4f pu\t%.4f pu\n', i, V_base(i), V_reg(i), V_reg_cap(i));
end

%% Calculate losses (CORRECTED)
PF_base = results_base.branch(:, 14);    % Real power at "from" end
PT_base = results_base.branch(:, 16);    % Real power at "to" end
loss_base = sum(PF_base + PT_base);      % Total real loss

PF_reg = results_reg.branch(:, 14);
PT_reg = results_reg.branch(:, 16);
loss_reg = sum(PF_reg + PT_reg);

PF_reg_cap = results_reg_cap.branch(:, 14);
PT_reg_cap = results_reg_cap.branch(:, 16);
loss_reg_cap = sum(PF_reg_cap + PT_reg_cap);

fprintf('\n========== SYSTEM LOSSES ==========\n');
fprintf('Base Case:        %.3f MW (%.1f kW)\n', loss_base, loss_base*1000);
fprintf('With Regulator:   %.3f MW (%.1f kW)  [%.1f%% change]\n', ...
    loss_reg, loss_reg*1000, (loss_reg/loss_base-1)*100);
fprintf('Reg + Capacitor:  %.3f MW (%.1f kW)  [%.1f%% change]\n', ...
    loss_reg_cap, loss_reg_cap*1000, (loss_reg_cap/loss_base-1)*100);

%% Show percentage of total load
total_load = sum(mpc_base.bus(:, 3)) * mpc_base.baseMVA;  % Convert to MW
fprintf('\nTotal Load:       %.1f MW\n', total_load);
fprintf('Base losses:      %.1f%% of load\n', (loss_base/total_load)*100);
fprintf('Reg+Cap losses:   %.1f%% of load\n', (loss_reg_cap/total_load)*100);

%% Plot all three
figure('Position', [100 100 1000 600]);
plot(1:6, V_base, '-o', 'LineWidth', 2.5, 'MarkerSize', 10, ...
     'Color', [0.8 0.2 0.2], 'MarkerFaceColor', [0.8 0.2 0.2], 'DisplayName', 'Base Case');
hold on;
plot(1:6, V_reg, '-s', 'LineWidth', 2.5, 'MarkerSize', 10, ...
     'Color', [1.0 0.6 0.0], 'MarkerFaceColor', [1.0 0.6 0.0], 'DisplayName', 'With Regulator');
plot(1:6, V_reg_cap, '-d', 'LineWidth', 2.5, 'MarkerSize', 10, ...
     'Color', [0.2 0.8 0.2], 'MarkerFaceColor', [0.2 0.8 0.2], 'DisplayName', 'Regulator + Capacitor');
yline(0.95, '--r', 'LineWidth', 2, 'Label', 'Min Limit (0.95 pu)');
yline(1.05, '--r', 'LineWidth', 2, 'Label', 'Max Limit (1.05 pu)');
grid on;
xlabel('Bus Number', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Voltage Magnitude (pu)', 'FontSize', 12, 'FontWeight', 'bold');
title('Voltage Profile Comparison: Three Regulation Strategies', 'FontSize', 14);
ylim([0.70 1.06]);
legend('Location', 'southwest', 'FontSize', 11);