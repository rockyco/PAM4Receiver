function pam4_receiver_visualization(input_signal, pam4_symbols, all_decisions, all_errors, all_equalized, coeffs_history, error_per_block, gain_history, P, num_blocks, snr_db, ser, ber, slicer_levels, all_adc_signal)
    % Enhanced PAM4 Receiver Visualization Suite with Module-Specific Analysis
    % Creates comprehensive visualizations for each processing module
    
    %% Main Performance Overview Figure
    main_fig = figure('Name', 'PAM4 Receiver Performance Overview', 'Position', [50 50 1400 900]);
    
    % 1. Input Signal Quality with PAM4 Levels
    subplot(3, 3, 1);
    sample_range = 1000:1500;
    pam4_voltages = [10, 42, 85, 117]; % ADC levels for PAM4
    plot(sample_range, double(input_signal(sample_range)), 'b-', 'LineWidth', 1);
    hold on;
    stem(sample_range(1:10:end), pam4_voltages(pam4_symbols(sample_range(1:10:end)) + 1), 'r', 'LineWidth', 0.5);
    hold off;
    title('Input Signal (Post-ADC)');
    xlabel('Sample Index');
    ylabel('ADC Value (7-bit)');
    grid on;
    legend('Received Signal', 'Transmitted Symbols', 'Location', 'best');
    ylim([0 127]);
    
    % 2. FFE Coefficient Evolution
    subplot(3, 3, 2);
    plot(1:num_blocks, coeffs_history(:, 1), 'b-', 'LineWidth', 2);
    hold on;
    for tap = 2:min(5, size(coeffs_history, 2))
        plot(1:num_blocks, coeffs_history(:, tap), 'LineWidth', 1);
    end
    hold off;
    title('FFE Coefficient Adaptation');
    xlabel('Block Number');
    ylabel('Coefficient Value');
    grid on;
    legend('Main Tap', 'Tap 2', 'Tap 3', 'Tap 4', 'Tap 5', 'Location', 'best');
    
    % 3. Error Rate Convergence
    subplot(3, 3, 3);
    plot(1:num_blocks, error_per_block * 100, 'r-', 'LineWidth', 1.5);
    hold on;
    window = 10;
    ma_error = movmean(error_per_block * 100, window);
    plot(window:num_blocks, ma_error(window:end), 'b-', 'LineWidth', 2);
    hold off;
    title('Symbol Error Rate Convergence');
    xlabel('Block Number');
    ylabel('SER (%)');
    grid on;
    legend('Instantaneous', sprintf('%d-block Average', window), 'Location', 'best');
    ylim([0 max(20, max(error_per_block)*120)]);
    
    % 4. Eye Diagram Comparison (ADC vs Equalized)
    subplot(3, 3, 4);
    
    % Prepare ADC signal (7-bit bipolar)
    eye_start_idx = max(1, length(all_adc_signal) - 1000);
    eye_samples_adc = all_adc_signal(eye_start_idx:end);
    eye_samples_bipolar = double(eye_samples_adc) - 64; % Convert to bipolar
    
    % Prepare equalized signal 
    eq_start_idx = max(1, length(all_equalized) - 1000);
    eye_samples_equalized = all_equalized(eq_start_idx:end);
    
    % Create eye diagram with 2 symbol periods
    samples_per_symbol = 1;
    eye_period_samples = 2; % Show exactly 2 symbol periods
    num_traces = floor(min(length(eye_samples_bipolar), length(eye_samples_equalized)) / eye_period_samples) - 1;
    
    hold on;
    adc_trace_count = 0;
    eq_trace_count = 0;
    
    % Plot ADC eye diagram traces (blue - input signal)
    for trace = 1:min(150, num_traces)
        start_idx = (trace - 1) * eye_period_samples + 1;
        if start_idx + eye_period_samples <= length(eye_samples_bipolar)
            trace_data = eye_samples_bipolar(start_idx:start_idx + eye_period_samples);
            time_axis = 0:eye_period_samples;
            plot(time_axis, trace_data, 'b-', 'LineWidth', 0.3, 'Color', [0 0 1 0.2]);
            adc_trace_count = adc_trace_count + 1;
        end
    end
    
    % Plot equalized eye diagram traces (red - after FFE/LMS)
    for trace = 1:min(150, num_traces)
        start_idx = (trace - 1) * eye_period_samples + 1;
        if start_idx + eye_period_samples <= length(eye_samples_equalized)
            trace_data = eye_samples_equalized(start_idx:start_idx + eye_period_samples);
            % Scale equalized signal to similar range for comparison
            trace_data_scaled = trace_data * 0.5; % Scale down for visibility
            time_axis = 0:eye_period_samples;
            plot(time_axis, trace_data_scaled, 'r-', 'LineWidth', 0.3, 'Color', [1 0 0 0.3]);
            eq_trace_count = eq_trace_count + 1;
        end
    end
    
    % Add slicer thresholds
    for thresh = double(slicer_levels)
        plot([0 2], [thresh thresh], 'k--', 'LineWidth', 2);
    end
    
    % Add ideal PAM4 levels for 7-bit bipolar ADC
    ideal_levels = [-48, -16, 16, 48];
    for level = ideal_levels
        plot([0 2], [level level], 'g:', 'LineWidth', 1);
    end
    
    % Add decision time markers
    plot([1 1], [-64 63], 'm:', 'LineWidth', 1.5); % Symbol 1 decision time
    plot([2 2], [-64 63], 'm:', 'LineWidth', 1.5); % Symbol 2 decision time
    
    hold off;
    
    title(sprintf('Eye Diagram Comparison (ADC:%d, EQ:%d traces)', adc_trace_count, eq_trace_count));
    xlabel('Symbol Period');
    ylabel('Amplitude');
    grid on;
    ylim([-64 63]); % 7-bit bipolar range
    xlim([0 2]);
    legend('ADC Input', 'Equalized (scaled)', 'Slicer Thresholds', 'Ideal Levels', 'Decision Times', 'Location', 'best');
    
    % 5. PAM4 Constellation (7-bit Bipolar ADC)
    subplot(3, 3, 5);
    last_samples = 2000;
    const_start = max(1, length(pam4_symbols) - last_samples + 1);
    
    % Use 7-bit ADC signal converted to bipolar for constellation
    adc_const_start = max(1, length(all_adc_signal) - last_samples + 1);
    constellation_adc = double(all_adc_signal(adc_const_start:end)) - 64; % Convert to bipolar
    
    colors = ['b', 'r', 'g', 'm'];
    for symbol = 0:3
        indices = find(pam4_symbols(const_start:end) == symbol);
        if ~isempty(indices) && length(indices) <= length(constellation_adc)
            % Make sure indices don't exceed constellation_adc length
            valid_indices = indices(indices <= length(constellation_adc));
            scatter(ones(size(valid_indices))*symbol, constellation_adc(valid_indices), 20, colors(symbol+1), 'filled', 'MarkerFaceAlpha', 0.5);
            hold on;
        end
    end
    
    % Add ideal levels for 7-bit bipolar PAM4
    ideal_levels = [-48, -16, 16, 48];
    plot(0:3, ideal_levels, 'k*', 'MarkerSize', 15, 'LineWidth', 2);
    hold off;
    
    title('PAM4 Constellation - 7-bit Bipolar ADC');
    xlabel('PAM4 Symbol');
    ylabel('Bipolar Amplitude');
    grid on;
    xlim([-0.5 3.5]);
    ylim([-64 63]); % 7-bit bipolar range
    legend('Symbol 0', 'Symbol 1', 'Symbol 2', 'Symbol 3', 'Ideal', 'Location', 'best');
    
    % 6. Histogram of 7-bit Bipolar ADC Signal
    subplot(3, 3, 6);
    hist_start_idx = max(1, length(all_adc_signal) - 2000);
    adc_hist = double(all_adc_signal(hist_start_idx:end)) - 64; % Convert to bipolar
    histogram(adc_hist, 50, 'Normalization', 'probability', 'FaceColor', 'b', 'EdgeColor', 'none');
    hold on;
    
    % Add slicer thresholds (adjusted for bipolar range)
    for thresh = double(slicer_levels)
        xline(thresh, 'r--', 'LineWidth', 2);
    end
    
    % Add ideal PAM4 levels for 7-bit bipolar
    ideal_levels = [-48, -16, 16, 48];
    for level = ideal_levels
        xline(level, 'g:', 'LineWidth', 1);
    end
    hold off;
    
    title('7-bit Bipolar ADC Signal Distribution');
    xlabel('Bipolar Amplitude');
    ylabel('Probability');
    grid on;
    xlim([-64 63]); % 7-bit bipolar range
    
    % 7. FFE Frequency Response
    subplot(3, 3, 7);
    channel_taps = [1, 0.15, -0.05]; % Channel model from testbench
    ffe_initial = zeros(1, 32);
    ffe_initial(1) = 64; ffe_initial(2) = -10; ffe_initial(3) = 3;
    
    [H_channel, f] = freqz(channel_taps, 1, 512, 'half');
    [H_init, ~] = freqz(double(ffe_initial)/64, 1, 512, 'half');
    [H_final, ~] = freqz(double(coeffs_history(end, :))/64, 1, 512, 'half');
    
    plot(f/pi, 20*log10(abs(H_channel)), 'k-', 'LineWidth', 2);
    hold on;
    plot(f/pi, 20*log10(abs(H_init)), 'b--', 'LineWidth', 1.5);
    plot(f/pi, 20*log10(abs(H_final)), 'r-', 'LineWidth', 2);
    hold off;
    
    title('Frequency Response');
    xlabel('Normalized Frequency (×π rad/sample)');
    ylabel('Magnitude (dB)');
    grid on;
    legend('Channel', 'FFE Initial', 'FFE Adapted', 'Location', 'best');
    ylim([-30 10]);
    
    % 8. Bit Error Rate Evolution
    subplot(3, 3, 8);
    ber_per_block = zeros(1, num_blocks);
    for block = 1:num_blocks
        block_range = (block-1)*P+1:block*P;
        block_bit_errors = 0;
        for i = block_range
            if i <= length(pam4_symbols)
                tx_bits = de2bi(pam4_symbols(i), 2);
                rx_bits = de2bi(all_decisions(i), 2);
                block_bit_errors = block_bit_errors + sum(tx_bits ~= rx_bits);
            end
        end
        ber_per_block(block) = block_bit_errors / (P * 2);
    end
    
    semilogy(1:num_blocks, ber_per_block + 1e-6, 'g-', 'LineWidth', 1.5);
    hold on;
    semilogy(1:num_blocks, movmean(ber_per_block + 1e-6, 10), 'b-', 'LineWidth', 2);
    hold off;
    
    title('Bit Error Rate vs Block');
    xlabel('Block Number');
    ylabel('BER');
    grid on;
    legend('Instantaneous', '10-block Average', 'Location', 'best');
    ylim([1e-5 1]);
    
    % 9. AGC and Signal Power Tracking
    subplot(3, 3, 9);
    yyaxis left
    plot(1:num_blocks, gain_history, 'b-', 'LineWidth', 2);
    ylabel('AGC Gain');
    ylim([0 5]);
    
    yyaxis right
    block_power = zeros(1, num_blocks);
    for block = 1:num_blocks
        block_range = (block-1)*P+1:block*P;
        if block_range(end) <= length(input_signal)
            block_power(block) = std(double(input_signal(block_range)));
        end
    end
    plot(1:num_blocks, block_power, 'r-', 'LineWidth', 1.5);
    ylabel('Input RMS Level');
    
    xlabel('Block Number');
    title('AGC Tracking Performance');
    grid on;
    legend('AGC Gain', 'Input RMS', 'Location', 'best');
    
    % Overall title
    sgtitle(sprintf('PAM4 Receiver: P=%d, SNR=%ddB, Final SER=%.2f%%, BER=%.2e', ...
            P, snr_db, ser*100, ber));
    
    % Save main figure
    saveas(main_fig, 'pam4_receiver_overview.png');
    
    %% Eye Diagram Detailed Comparison Figure
    eye_fig = figure('Name', 'PAM4 Eye Diagram Analysis', 'Position', [50 50 1200 800]);
    
    % Prepare data for detailed eye diagram
    eye_length = 1500;
    adc_start_idx = max(1, length(all_adc_signal) - eye_length);
    eq_start_idx = max(1, length(all_equalized) - eye_length);
    
    adc_eye_data = double(all_adc_signal(adc_start_idx:end)) - 64; % Bipolar ADC
    eq_eye_data = all_equalized(eq_start_idx:end);
    
    % Subplot 1: ADC Input Eye Diagram
    subplot(2, 2, 1);
    samples_per_symbol = 1;
    traces_to_plot = min(200, floor(length(adc_eye_data) / 2));
    
    hold on;
    for trace = 1:traces_to_plot
        start_idx = (trace - 1) * 2 + 1;
        if start_idx + 2 <= length(adc_eye_data)
            trace_data = adc_eye_data(start_idx:start_idx + 2);
            plot(0:2, trace_data, 'b-', 'LineWidth', 0.4, 'Color', [0 0 1 0.3]);
        end
    end
    
    % Add reference lines
    for thresh = double(slicer_levels)
        plot([0 2], [thresh thresh], 'r--', 'LineWidth', 2);
    end
    for level = [-48, -16, 16, 48]
        plot([0 2], [level level], 'g:', 'LineWidth', 1);
    end
    plot([1 1], [-64 63], 'm:', 'LineWidth', 2);
    plot([2 2], [-64 63], 'm:', 'LineWidth', 2);
    
    hold off;
    title(sprintf('ADC Input Eye Diagram (%d traces)', traces_to_plot));
    xlabel('Symbol Period');
    ylabel('Bipolar Amplitude');
    grid on;
    ylim([-64 63]);
    xlim([0 2]);
    
    % Subplot 2: Equalized Signal Eye Diagram
    subplot(2, 2, 2);
    traces_to_plot_eq = min(200, floor(length(eq_eye_data) / 2));
    
    hold on;
    for trace = 1:traces_to_plot_eq
        start_idx = (trace - 1) * 2 + 1;
        if start_idx + 2 <= length(eq_eye_data)
            trace_data = eq_eye_data(start_idx:start_idx + 2);
            plot(0:2, trace_data, 'r-', 'LineWidth', 0.4, 'Color', [1 0 0 0.3]);
        end
    end
    
    % Add reference lines (scaled for equalized signal)
    eq_thresh_scale = 1; % Adjust based on actual equalized signal range
    for thresh = double(slicer_levels) * eq_thresh_scale
        plot([0 2], [thresh thresh], 'k--', 'LineWidth', 2);
    end
    plot([1 1], [min(eq_eye_data) max(eq_eye_data)], 'm:', 'LineWidth', 2);
    plot([2 2], [min(eq_eye_data) max(eq_eye_data)], 'm:', 'LineWidth', 2);
    
    hold off;
    title(sprintf('Equalized Signal Eye Diagram (%d traces)', traces_to_plot_eq));
    xlabel('Symbol Period');
    ylabel('Equalized Amplitude');
    grid on;
    ylim([min(eq_eye_data)*1.1 max(eq_eye_data)*1.1]);
    xlim([0 2]);
    
    % Subplot 3: Overlay Comparison (Normalized)
    subplot(2, 2, 3);
    
    % Normalize both signals for comparison
    adc_normalized = adc_eye_data / max(abs(adc_eye_data));
    eq_normalized = eq_eye_data / max(abs(eq_eye_data));
    
    hold on;
    traces_overlay = min(100, floor(min(length(adc_normalized), length(eq_normalized)) / 2));
    
    for trace = 1:traces_overlay
        start_idx = (trace - 1) * 2 + 1;
        if start_idx + 2 <= min(length(adc_normalized), length(eq_normalized))
            adc_trace = adc_normalized(start_idx:start_idx + 2);
            eq_trace = eq_normalized(start_idx:start_idx + 2);
            plot(0:2, adc_trace, 'b-', 'LineWidth', 0.3, 'Color', [0 0 1 0.2]);
            plot(0:2, eq_trace, 'r-', 'LineWidth', 0.3, 'Color', [1 0 0 0.2]);
        end
    end
    
    plot([1 1], [-1 1], 'm:', 'LineWidth', 2);
    plot([2 2], [-1 1], 'm:', 'LineWidth', 2);
    hold off;
    
    title('Normalized Overlay Comparison');
    xlabel('Symbol Period');
    ylabel('Normalized Amplitude');
    grid on;
    ylim([-1.2 1.2]);
    xlim([0 2]);
    legend('ADC Input', 'Equalized', 'Decision Times', 'Location', 'best');
    
    % Subplot 4: Eye Opening Analysis
    subplot(2, 2, 4);
    
    % Calculate eye opening metrics
    decision_time = 1; % Middle of symbol period
    eye_levels = [-48, -16, 16, 48]; % Ideal levels
    eye_openings = zeros(1, 4);
    
    % Simple eye opening calculation (vertical opening at decision time)
    for level_idx = 1:4
        if level_idx < 4
            eye_openings(level_idx) = abs(eye_levels(level_idx+1) - eye_levels(level_idx));
        end
    end
    
    bar(1:3, eye_openings(1:3));
    title('Eye Opening Analysis');
    xlabel('Eye Level');
    ylabel('Vertical Eye Opening');
    grid on;
    xticks(1:3);
    xticklabels({'Level 0-1', 'Level 1-2', 'Level 2-3'});
    
    sgtitle('PAM4 Eye Diagram Detailed Analysis');
    saveas(eye_fig, 'pam4_eye_diagram_analysis.png');
    
    %% Generate Standalone Eye Diagram for Clear Illustration
    pam4_standalone_eye_diagram(all_adc_signal, all_equalized, pam4_symbols, slicer_levels);
    
    %% Module-Specific Detailed Analysis Figures
    
    % AGC Module Analysis
    agc_fig = figure('Name', 'AGC Module Analysis', 'Position', [50 50 1200 800]);
    
    subplot(2, 2, 1);
    % AGC input/output comparison
    sample_range = 1000:1100;
    scaled_samples = double(input_signal(sample_range)) .* double(gain_history(floor(sample_range/P)+1));
    plot(sample_range, double(input_signal(sample_range)), 'b-', 'LineWidth', 1);
    hold on;
    plot(sample_range, min(255, scaled_samples), 'r-', 'LineWidth', 1);
    hold off;
    title('AGC Input vs Output');
    xlabel('Sample Index');
    ylabel('Amplitude');
    legend('Input', 'Scaled Output', 'Location', 'best');
    grid on;
    
    subplot(2, 2, 2);
    % AGC gain adaptation
    plot(1:num_blocks, gain_history, 'b-', 'LineWidth', 2);
    hold on;
    plot(1:num_blocks, ones(1, num_blocks)*mean(gain_history), 'r--', 'LineWidth', 1);
    hold off;
    title('AGC Gain Adaptation');
    xlabel('Block Number');
    ylabel('Gain Value');
    legend('Gain', 'Average', 'Location', 'best');
    grid on;
    
    subplot(2, 2, 3);
    % Signal power vs gain
    scatter(block_power, gain_history, 20, 'filled');
    xlabel('Input RMS Level');
    ylabel('AGC Gain');
    title('AGC Response Curve');
    grid on;
    
    subplot(2, 2, 4);
    % Output signal distribution after AGC
    agc_output = zeros(size(input_signal));
    for i = 1:length(input_signal)
        block_idx = floor((i-1)/P) + 1;
        if block_idx <= num_blocks
            agc_output(i) = min(255, double(input_signal(i)) * double(gain_history(block_idx)));
        end
    end
    last_idx = max(1, length(agc_output) - 5000);
    histogram(agc_output(last_idx:end), 50, 'Normalization', 'probability');
    title('AGC Output Distribution');
    xlabel('Amplitude');
    ylabel('Probability');
    grid on;
    
    sgtitle('AGC Module Performance Analysis');
    saveas(agc_fig, 'pam4_agc_analysis.png');
    
    % FFE Module Analysis
    ffe_fig = figure('Name', 'FFE Module Analysis', 'Position', [50 50 1200 800]);
    
    subplot(2, 2, 1);
    % FFE coefficient evolution (all taps)
    num_taps_to_show = min(10, size(coeffs_history, 2));
    for tap = 1:num_taps_to_show
        plot(1:num_blocks, coeffs_history(:, tap), 'LineWidth', 1.5);
        hold on;
    end
    hold off;
    title('FFE Coefficient Evolution (First 10 Taps)');
    xlabel('Block Number');
    ylabel('Coefficient Value');
    legend(arrayfun(@(x) sprintf('Tap %d', x), 1:num_taps_to_show, 'UniformOutput', false), 'Location', 'best');
    grid on;
    
    subplot(2, 2, 2);
    % FFE impulse response
    stem(0:31, coeffs_history(end, :), 'filled');
    title('Final FFE Impulse Response');
    xlabel('Tap Index');
    ylabel('Coefficient Value');
    grid on;
    xlim([-1 32]);
    
    subplot(2, 2, 3);
    % Combined channel-equalizer response
    H_combined = H_channel .* H_final;
    plot(f/pi, 20*log10(abs(H_combined)), 'm-', 'LineWidth', 2);
    hold on;
    plot([0 1], [0 0], 'k--');
    hold off;
    title('Combined Channel-Equalizer Response');
    xlabel('Normalized Frequency (×π rad/sample)');
    ylabel('Magnitude (dB)');
    grid on;
    ylim([-10 10]);
    
    subplot(2, 2, 4);
    % FFE adaptation speed
    coeff_change = diff(coeffs_history(:, 1));
    plot(2:num_blocks, abs(coeff_change), 'b-', 'LineWidth', 1);
    title('FFE Main Tap Adaptation Rate');
    xlabel('Block Number');
    ylabel('|Coefficient Change|');
    grid on;
    
    sgtitle('FFE Module Performance Analysis');
    saveas(ffe_fig, 'pam4_ffe_analysis.png');
    
    % Slicer Module Analysis
    slicer_fig = figure('Name', 'Slicer Module Analysis', 'Position', [50 50 1200 800]);
    
    subplot(2, 2, 1);
    % Decision distribution
    bar(0:3, histcounts(all_decisions, 0.5:4.5)/length(all_decisions));
    title('PAM4 Decision Distribution');
    xlabel('Symbol');
    ylabel('Probability');
    grid on;
    ylim([0 0.3]);
    
    subplot(2, 2, 2);
    % Error signal distribution
    error_start_idx = max(1, length(all_errors) - 5000);
    histogram(all_errors(error_start_idx:end), 100, 'Normalization', 'probability');
    title('Slicer Error Signal Distribution');
    xlabel('Error Value');
    ylabel('Probability');
    grid on;
    
    subplot(2, 2, 3);
    % Confusion matrix
    conf_matrix = zeros(4, 4);
    for i = 1:length(pam4_symbols)
        tx_sym = pam4_symbols(i) + 1;
        rx_sym = all_decisions(i) + 1;
        conf_matrix(tx_sym, rx_sym) = conf_matrix(tx_sym, rx_sym) + 1;
    end
    
    imagesc(conf_matrix);
    colorbar;
    title('Symbol Confusion Matrix');
    xlabel('Received Symbol');
    ylabel('Transmitted Symbol');
    set(gca, 'XTick', 1:4, 'XTickLabel', 0:3);
    set(gca, 'YTick', 1:4, 'YTickLabel', 0:3);
    
    % Add text annotations
    for i = 1:4
        for j = 1:4
            text(j, i, sprintf('%.1f%%', 100*conf_matrix(i,j)/sum(conf_matrix(i,:))), ...
                'HorizontalAlignment', 'center', 'Color', 'w');
        end
    end
    
    subplot(2, 2, 4);
    % Slicer threshold optimization visualization
    slicer_start_idx = max(1, min(length(all_equalized), length(pam4_symbols)) - 5000);
    equalized_last = all_equalized(slicer_start_idx:end); % Use HDL output directly
    symbols_last = pam4_symbols(slicer_start_idx:end);
    
    hold on;
    for sym = 0:3
        idx = symbols_last == sym;
        histogram(equalized_last(idx), 50, 'Normalization', 'probability', ...
                 'FaceAlpha', 0.5, 'DisplayName', sprintf('Symbol %d', sym));
    end
    
    for thresh = double(slicer_levels)
        xline(thresh, 'r--', 'LineWidth', 2);
    end
    hold off;
    
    title('Symbol Distributions with Slicer Thresholds');
    xlabel('Equalized Amplitude');
    ylabel('Probability');
    legend('Location', 'best');
    grid on;
    xlim([-100 100]);
    
    sgtitle('Slicer Module Performance Analysis');
    saveas(slicer_fig, 'pam4_slicer_analysis.png');
    
    % LMS Module Analysis
    lms_fig = figure('Name', 'LMS Module Analysis', 'Position', [50 50 1200 800]);
    
    subplot(2, 2, 1);
    % LMS convergence metric
    coeff_norm = sqrt(sum(coeffs_history.^2, 2));
    plot(1:num_blocks, coeff_norm, 'b-', 'LineWidth', 2);
    title('FFE Coefficient Norm Evolution');
    xlabel('Block Number');
    ylabel('||w||₂');
    grid on;
    
    subplot(2, 2, 2);
    % Error power evolution
    error_power = zeros(1, num_blocks);
    for block = 1:num_blocks
        block_range = (block-1)*P+1:block*P;
        if block_range(end) <= length(all_errors)
            error_power(block) = mean(all_errors(block_range).^2);
        end
    end
    semilogy(1:num_blocks, error_power, 'r-', 'LineWidth', 1.5);
    title('Mean Squared Error Evolution');
    xlabel('Block Number');
    ylabel('MSE');
    grid on;
    
    subplot(2, 2, 3);
    % Coefficient stability analysis
    coeff_start_idx = max(1, size(coeffs_history, 1) - 20);
    coeff_variance = var(coeffs_history(coeff_start_idx:end, :), 0, 1);
    stem(0:31, coeff_variance, 'filled');
    title('Coefficient Variance (Last 20 Blocks)');
    xlabel('Tap Index');
    ylabel('Variance');
    grid on;
    xlim([-1 32]);
    
    subplot(2, 2, 4);
    % Learning curve
    plot(1:num_blocks, error_per_block, 'b-', 'LineWidth', 1);
    hold on;
    plot(1:num_blocks, movmean(error_per_block, 20), 'r-', 'LineWidth', 2);
    hold off;
    title('LMS Learning Curve');
    xlabel('Block Number');
    ylabel('Symbol Error Rate');
    legend('Instantaneous', '20-block Average', 'Location', 'best');
    grid on;
    
    sgtitle('LMS Module Performance Analysis');
    saveas(lms_fig, 'pam4_lms_analysis.png');
    
    fprintf('\n✅ All visualization figures saved:\n');
    fprintf('  - pam4_receiver_overview.png\n');
    fprintf('  - pam4_eye_diagram_analysis.png\n');
    fprintf('  - pam4_standalone_eye_diagram.png (publication quality)\n');
    fprintf('  - pam4_standalone_eye_diagram.pdf (vector format)\n');
    fprintf('  - pam4_agc_analysis.png\n');
    fprintf('  - pam4_ffe_analysis.png\n');
    fprintf('  - pam4_slicer_analysis.png\n');
    fprintf('  - pam4_lms_analysis.png\n');
end