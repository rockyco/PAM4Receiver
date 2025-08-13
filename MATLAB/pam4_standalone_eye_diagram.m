function pam4_standalone_eye_diagram(all_adc_signal, all_equalized, pam4_symbols, slicer_levels)
    % Standalone PAM4 Eye Diagram Generator
    % Creates publication-quality eye diagrams for PAM4 receiver analysis
    
    % Create large figure for high-quality output
    eye_fig = figure('Name', 'PAM4 Receiver Eye Diagram', 'Position', [100 100 1600 1000]);
    
    % Prepare data
    eye_length = 2000; % Use more data for smoother eye diagram
    adc_start_idx = max(1, length(all_adc_signal) - eye_length);
    eq_start_idx = max(1, length(all_equalized) - eye_length);
    
    % Convert ADC to bipolar
    adc_eye_data = double(all_adc_signal(adc_start_idx:end)) - 64;
    eq_eye_data = all_equalized(eq_start_idx:end);
    
    % Subplot 1: ADC Input Eye Diagram (Large)
    subplot(2, 3, [1 2]);
    
    % Plot eye traces with high trace count for smooth visualization
    traces_to_plot = min(400, floor(length(adc_eye_data) / 2));
    
    hold on;
    for trace = 1:traces_to_plot
        start_idx = (trace - 1) * 2 + 1;
        if start_idx + 2 <= length(adc_eye_data)
            trace_data = adc_eye_data(start_idx:start_idx + 2);
            time_axis = 0:2;
            plot(time_axis, trace_data, 'b-', 'LineWidth', 0.2, 'Color', [0 0.4 0.8 0.15]);
        end
    end
    
    % Add PAM4 ideal levels
    ideal_levels = [-48, -16, 16, 48];
    for i = 1:length(ideal_levels)
        plot([0 2], [ideal_levels(i) ideal_levels(i)], '--', 'Color', [0.18 0.49 0.20], 'LineWidth', 2);
    end
    
    % Add slicer thresholds
    for thresh = double(slicer_levels)
        plot([0 2], [thresh thresh], 'r-', 'LineWidth', 3);
    end
    
    % Add decision time markers
    plot([1 1], [-64 63], 'm:', 'LineWidth', 2);
    plot([2 2], [-64 63], 'm:', 'LineWidth', 2);
    
    % Add eye mask (typical eye opening requirements)
    eye_mask_x = [0.7, 1.3, 1.3, 0.7, 0.7];
    eye_mask_y1 = [-25, -25, -5, -5, -25]; % Between levels 0 and 1
    eye_mask_y2 = [-5, -5, 5, 5, -5];     % Between levels 1 and 2  
    eye_mask_y3 = [5, 5, 25, 25, 5];      % Between levels 2 and 3
    
    plot(eye_mask_x, eye_mask_y1, 'k--', 'LineWidth', 1.5);
    plot(eye_mask_x, eye_mask_y2, 'k--', 'LineWidth', 1.5);
    plot(eye_mask_x, eye_mask_y3, 'k--', 'LineWidth', 1.5);
    
    hold off;
    
    title(sprintf('ADC Input Eye Diagram (%d traces)', traces_to_plot), 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('Symbol Period', 'FontSize', 12);
    ylabel('Bipolar Amplitude (7-bit ADC)', 'FontSize', 12);
    grid on;
    ylim([-64 63]);
    xlim([0 2]);
    
    % Add text annotation instead of legend
    text(0.05, 55, 'Signal Traces: Blue', 'FontSize', 9, 'Color', [0 0.4 0.8], 'FontWeight', 'bold');
    text(0.05, 50, 'Ideal Levels: Green dashed', 'FontSize', 9, 'Color', [0.18 0.49 0.20], 'FontWeight', 'bold');
    text(0.05, 45, 'Slicer Thresholds: Red solid', 'FontSize', 9, 'Color', 'r', 'FontWeight', 'bold');
    text(0.05, 40, 'Decision Times: Magenta dotted', 'FontSize', 9, 'Color', 'm', 'FontWeight', 'bold');
    
    % Subplot 2: Equalized Signal Eye Diagram (Large)
    subplot(2, 3, [4 5]);
    
    traces_to_plot_eq = min(400, floor(length(eq_eye_data) / 2));
    
    hold on;
    for trace = 1:traces_to_plot_eq
        start_idx = (trace - 1) * 2 + 1;
        if start_idx + 2 <= length(eq_eye_data)
            trace_data = eq_eye_data(start_idx:start_idx + 2);
            time_axis = 0:2;
            plot(time_axis, trace_data, 'r-', 'LineWidth', 0.2, 'Color', [0.8 0.2 0.2 0.15]);
        end
    end
    
    % Add reference lines scaled for equalized signal
    eq_min = min(eq_eye_data);
    eq_max = max(eq_eye_data);
    eq_range = eq_max - eq_min;
    
    % Estimate equalized ideal levels based on signal range
    eq_ideal_levels = [eq_min + 0.125*eq_range, eq_min + 0.375*eq_range, eq_min + 0.625*eq_range, eq_min + 0.875*eq_range];
    for level = eq_ideal_levels
        plot([0 2], [level level], '--', 'Color', [0.18 0.49 0.20], 'LineWidth', 2);
    end
    
    % Add equalized slicer thresholds (estimated)
    eq_thresh_levels = [eq_min + 0.25*eq_range, eq_min + 0.5*eq_range, eq_min + 0.75*eq_range];
    for thresh = eq_thresh_levels
        plot([0 2], [thresh thresh], 'r-', 'LineWidth', 3);
    end
    
    % Add decision time markers
    plot([1 1], [eq_min eq_max], 'm:', 'LineWidth', 2);
    plot([2 2], [eq_min eq_max], 'm:', 'LineWidth', 2);
    
    hold off;
    
    title(sprintf('Equalized Signal Eye Diagram (%d traces)', traces_to_plot_eq), 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('Symbol Period', 'FontSize', 12);
    ylabel('Equalized Amplitude (After FFE/LMS)', 'FontSize', 12);
    grid on;
    ylim([eq_min*1.05 eq_max*1.05]);
    xlim([0 2]);
    
    % Subplot 3: Eye Quality Metrics
    subplot(2, 3, 3);
    
    % Calculate eye opening metrics
    adc_eye_opening = calculate_eye_opening(adc_eye_data, ideal_levels);
    eq_eye_opening = calculate_eye_opening(eq_eye_data, eq_ideal_levels);
    
    % Normalize for comparison
    adc_opening_norm = adc_eye_opening / max(adc_eye_opening);
    eq_opening_norm = eq_eye_opening / max(eq_eye_opening);
    
    x_pos = [1 2 3];
    width = 0.35;
    
    bar(x_pos - width/2, adc_opening_norm, width, 'FaceColor', [0 0.4 0.8], 'DisplayName', 'ADC Input');
    hold on;
    bar(x_pos + width/2, eq_opening_norm, width, 'FaceColor', [0.8 0.2 0.2], 'DisplayName', 'Equalized');
    hold off;
    
    title('Eye Opening Comparison', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('PAM4 Level Transition', 'FontSize', 10);
    ylabel('Normalized Eye Opening', 'FontSize', 10);
    xticks(x_pos);
    xticklabels({'Level 0-1', 'Level 1-2', 'Level 2-3'});
    legend('Location', 'best', 'FontSize', 9);
    grid on;
    ylim([0 1.2]);
    
    % Subplot 4: Signal Quality Metrics
    subplot(2, 3, 6);
    
    % Calculate signal-to-noise ratio estimates
    adc_levels = [-48, -16, 16, 48];
    adc_snr = calculate_snr_estimate(adc_eye_data, adc_levels);
    eq_snr = calculate_snr_estimate(eq_eye_data, eq_ideal_levels);
    
    % Calculate jitter estimates (simplified)
    adc_jitter = std(diff(adc_eye_data));
    eq_jitter = std(diff(eq_eye_data));
    
    metrics = {'SNR (dB)', 'Jitter (σ)', 'Peak-to-Peak'};
    adc_values = [adc_snr, adc_jitter, max(adc_eye_data) - min(adc_eye_data)];
    eq_values = [eq_snr, eq_jitter, max(eq_eye_data) - min(eq_eye_data)];
    
    % Normalize metrics for comparison
    adc_norm = adc_values ./ max(adc_values);
    eq_norm = eq_values ./ max(eq_values);
    
    x_metrics = 1:3;
    bar(x_metrics - width/2, adc_norm, width, 'FaceColor', [0 0.4 0.8], 'DisplayName', 'ADC Input');
    hold on;
    bar(x_metrics + width/2, eq_norm, width, 'FaceColor', [0.8 0.2 0.2], 'DisplayName', 'Equalized');
    hold off;
    
    title('Signal Quality Metrics', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Metric', 'FontSize', 10);
    ylabel('Normalized Value', 'FontSize', 10);
    xticks(x_metrics);
    xticklabels(metrics);
    xtickangle(45);
    legend('Location', 'best', 'FontSize', 9);
    grid on;
    ylim([0 1.2]);
    
    % Overall title
    sgtitle('PAM4 Receiver Eye Diagram Analysis - Signal Quality Comparison', ...
            'FontSize', 16, 'FontWeight', 'bold');
    
    % Add text annotations with key information
    annotation('textbox', [0.02 0.95 0.3 0.04], 'String', ...
               sprintf('7-bit ADC Range: -64 to +63'), ...
               'FontSize', 10, 'EdgeColor', 'none');
    
    annotation('textbox', [0.02 0.91 0.3 0.04], 'String', ...
               sprintf('Symbol Period: 2 UI'), ...
               'FontSize', 10, 'EdgeColor', 'none');
    
    annotation('textbox', [0.02 0.87 0.3 0.04], 'String', ...
               sprintf('PAM4 Levels: 4 symbols'), ...
               'FontSize', 10, 'EdgeColor', 'none');
    
    % Save with high resolution
    saveas(eye_fig, 'pam4_standalone_eye_diagram.png');
    
    % Also save as PDF for publications
    saveas(eye_fig, 'pam4_standalone_eye_diagram.pdf');
    
    fprintf('✅ Standalone eye diagram saved:\n');
    fprintf('  - pam4_standalone_eye_diagram.png (high resolution)\n');
    fprintf('  - pam4_standalone_eye_diagram.pdf (publication quality)\n');
end

function eye_opening = calculate_eye_opening(signal_data, ideal_levels)
    % Calculate vertical eye opening between adjacent levels
    eye_opening = zeros(1, 3);
    
    for i = 1:3
        % Find samples near each ideal level
        level1_samples = signal_data(abs(signal_data - ideal_levels(i)) < 10);
        level2_samples = signal_data(abs(signal_data - ideal_levels(i+1)) < 10);
        
        if ~isempty(level1_samples) && ~isempty(level2_samples)
            % Calculate separation between levels
            level1_mean = mean(level1_samples);
            level2_mean = mean(level2_samples);
            level1_std = std(level1_samples);
            level2_std = std(level2_samples);
            
            % Eye opening considering noise
            eye_opening(i) = abs(level2_mean - level1_mean) - 3*(level1_std + level2_std);
            eye_opening(i) = max(0, eye_opening(i)); % Ensure non-negative
        else
            eye_opening(i) = abs(ideal_levels(i+1) - ideal_levels(i)) * 0.5; % Fallback
        end
    end
end

function snr_db = calculate_snr_estimate(signal_data, ideal_levels)
    % Estimate SNR by comparing signal to ideal levels
    total_signal_power = 0;
    total_noise_power = 0;
    
    for level = ideal_levels
        % Find samples near this level
        near_level = abs(signal_data - level) < 20;
        if sum(near_level) > 10
            level_samples = signal_data(near_level);
            signal_power = level^2;
            noise_power = var(level_samples - level);
            
            total_signal_power = total_signal_power + signal_power;
            total_noise_power = total_noise_power + noise_power;
        end
    end
    
    if total_noise_power > 0
        snr_db = 10 * log10(total_signal_power / total_noise_power);
    else
        snr_db = 40; % High SNR if no noise detected
    end
    
    % Limit to reasonable range
    snr_db = max(0, min(40, snr_db));
end