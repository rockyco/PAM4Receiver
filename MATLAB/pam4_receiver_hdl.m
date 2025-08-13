function [decision, error_signal, coeffs_out] = pam4_receiver_hdl(input_samples, gain, ffe_coeffs, step_size, slicer_levels, enable)
    % Parallelized Digital Front-End for PAM4 Receiver - HDL Compatible Version
    % Fixed parallelism for HDL generation
    %
    % Inputs:
    %   input_samples: 7-bit PAM4 samples (32-element vector)
    %   gain: 8-bit programmable gain value
    %   ffe_coeffs: FFE coefficient array (32 taps)
    %   step_size: LMS step size parameter
    %   slicer_levels: 3-element array of PAM4 threshold levels
    %   enable: Control signal to enable processing
    %
    % Outputs:
    %   decision: PAM4 decisions (0,1,2,3) for 32 samples
    %   error_signal: Error signals for LMS adaptation
    %   coeffs_out: Updated FFE coefficients
    
    %#codegen
    
    % Fixed parallelism factor P (HDL-compatible)
    P = int32(32); % Fixed for HDL generation
    
    % Initialize outputs (fixed size)
    decision = zeros(1, 32, 'uint8');
    error_signal = zeros(1, 32, 'int16');
    
    if enable
        % Stage 1: Digital Gain Control
        scaled_samples = digital_gain_control(input_samples, gain, P);
        
        % Stage 2: Feed Forward Equalizer (simplified for HDL)
        equalized_samples = feed_forward_equalizer_simple(scaled_samples, ffe_coeffs, P);
        
        % Stage 3: Slicer and Error Generator
        [decision, error_signal] = slicer_error_generator(equalized_samples, slicer_levels, P);
        
        % Stage 4: LMS Update Engine (simplified for HDL)
        coeffs_out = lms_update_engine_simple(scaled_samples, error_signal, ffe_coeffs, step_size, P);
    else
        coeffs_out = ffe_coeffs;
    end
end

function scaled_output = digital_gain_control(input_samples, gain, P)
    % Digital Gain Control Module
    % Input: 7-bit PAM4 samples
    % Output: 8-bit scaled samples with saturation detection
    
    %#codegen
    
    scaled_output = zeros(1, 32, 'uint8');
    
    % Apply gain with saturation to 8-bit (fixed loop)
    for i = 1:32
        % Scale input by gain
        scaled_val = uint16(input_samples(i)) * uint16(gain);
        
        % Saturate to 8-bit range
        if scaled_val > 255
            scaled_output(i) = uint8(255);
        else
            scaled_output(i) = uint8(scaled_val);
        end
    end
end

function equalized_output = feed_forward_equalizer_simple(input_samples, coeffs, P)
    % Simplified FFE for HDL generation  
    % Uses simplified convolution that better matches original behavior
    
    %#codegen
    
    num_taps = length(coeffs); % Use actual coefficient length
    equalized_output = zeros(1, 32, 'int16');
    
    % Convert input to signed and center around 0 (like original)
    input_signed = zeros(1, 32, 'int16');
    for i = 1:32
        input_signed(i) = int16(input_samples(i)) - int16(64); % Match original centering
    end
    
    % FIR filtering with available taps (simplified but more accurate)
    for p = 1:32
        acc = int32(0);
        
        % Apply coefficients to available samples (simplified approach)
        % This approximates the circular buffer behavior without persistence
        for t = 1:min(p, num_taps)
            acc = acc + int32(input_signed(p - t + 1)) * int32(coeffs(t));
        end
        
        % Scale output (coeffs are in Q6.6 format, same as original)
        equalized_output(p) = int16(bitshift(acc, -6));
    end
end

function [decision, error_signal] = slicer_error_generator(equalized_samples, slicer_levels, P)
    % PAM4 Slicer and Error Generator
    % Programmable slicer levels for PAM4 thresholding
    
    %#codegen
    
    decision = zeros(1, 32, 'uint8');
    error_signal = zeros(1, 32, 'int16');
    
    % PAM4 ideal levels (match original algorithm scaling)
    pam4_ideal_0 = int16(-192); % Symbol 0 (scaled for -3 * 64)
    pam4_ideal_1 = int16(-64);  % Symbol 1 (scaled for -1 * 64)
    pam4_ideal_2 = int16(64);   % Symbol 2 (scaled for 1 * 64)
    pam4_ideal_3 = int16(192);  % Symbol 3 (scaled for 3 * 64)
    
    for i = 1:32
        sample = equalized_samples(i);
        
        % PAM4 slicing with programmable thresholds
        if sample < slicer_levels(1)
            decision(i) = uint8(0);
            ideal_level = pam4_ideal_0;
        elseif sample < slicer_levels(2)
            decision(i) = uint8(1);
            ideal_level = pam4_ideal_1;
        elseif sample < slicer_levels(3)
            decision(i) = uint8(2);
            ideal_level = pam4_ideal_2;
        else
            decision(i) = uint8(3);
            ideal_level = pam4_ideal_3;
        end
        
        % Generate error signal for LMS
        error_signal(i) = sample - ideal_level;
    end
end

function updated_coeffs = lms_update_engine_simple(scaled_samples, error_signal, coeffs, step_size, P)
    % Simplified LMS Update Engine for HDL
    % Updates only first few coefficients
    
    %#codegen
    
    num_coeffs = int32(32); % Full 32 coefficients  
    updated_coeffs = coeffs;
    
    % Coefficient limits
    coeff_max = int16(127);
    coeff_min = int16(-128);
    
    % LMS update using current samples (fixed loop)
    for i = 1:32
        % Convert scaled sample to signed
        sample_signed = int16(scaled_samples(i)) - int16(128);
        
        % Update first coefficient (main tap)
        if i <= num_coeffs
            % LMS update: w(n+1) = w(n) + mu * e(n) * x(n)
            mu_scaled = bitshift(int32(step_size), -12); % Small step size
            error_scaled = bitshift(int32(error_signal(i)), -4);
            
            update = mu_scaled * error_scaled * int32(sample_signed);
            update = bitshift(update, -8); % Scale down
            
            new_coeff = int32(coeffs(i)) + update;
            
            % Clip coefficient
            if new_coeff > int32(coeff_max)
                updated_coeffs(i) = coeff_max;
            elseif new_coeff < int32(coeff_min)
                updated_coeffs(i) = coeff_min;
            else
                updated_coeffs(i) = int16(new_coeff);
            end
        end
    end
end