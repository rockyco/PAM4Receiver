function hdl_coder()
% HDL_CODER Configuration for PAM4 Receiver
% 
% Configures HDL Coder for pam4_receiver_hdl.m with parallel processing
% architecture for high-speed PAM4 signal processing.
%
% Function signature: 
%   [decision, error_signal, coeffs_out] = pam4_receiver_hdl(input_samples, 
%                                                             gain, ffe_coeffs, 
%                                                             step_size, slicer_levels, 
%                                                             enable)
%
% Architecture: Parallel processing with P ∈ {32, 64, 128} samples per clock

% ============================================================================
% ALGORITHM-SPECIFIC CONFIGURATION
% ============================================================================

% Algorithm-specific configuration
entryPointFunction = 'pam4_receiver_hdl';  % HDL function name: pam4_receiver_hdl.m
testbenchName = 'pam4_receiver_hdl_tb';    % Testbench name: pam4_receiver_hdl_tb.m

% No persistent variables in simplified HDL version
bufferVariables = "";

% ============================================================================
% HDL CODER CONFIGURATION
% ============================================================================
% Set up HDL Simulator and Synthesis Tools
hdlsetuptoolpath('ToolName', 'Xilinx Vivado', ...
    'ToolPath', '/opt/Xilinx/Vivado/2024.2/bin/vivado');

% Create HDL configuration object
hdlcfg = coder.config('hdl');

% Basic configuration
hdlcfg.TestBenchName = testbenchName;  % Enable testbench reference
hdlcfg.TargetLanguage = 'Verilog';
hdlcfg.GenerateHDLTestBench = true;   % Enable HDL testbench generation  
hdlcfg.SimulateGeneratedCode = true;  % Enable simulation
hdlcfg.SimulationTool = 'Xilinx Vivado Simulator';
hdlcfg.SynthesizeGeneratedCode = true;  % Enable synthesis
hdlcfg.SynthesisTool = 'Xilinx Vivado';

% Target device: Zynq UltraScale+ RFSoC
hdlcfg.SynthesisToolChipFamily = 'Zynq UltraScale+ RFSoC';
hdlcfg.SynthesisToolDeviceName = 'xczu28dr-ffvg1517-2-e';

% Memory optimization settings (no persistent variables)
hdlcfg.MapPersistentVarsToRAM = false;
% hdlcfg.RAMVariableNames = bufferVariables;  % Not needed
hdlcfg.RAMThreshold = 32;  % Minimum size for RAM mapping
hdlcfg.RAMArchitecture = 'GenericRAM';

% Performance optimization settings for high-speed PAM4
hdlcfg.TargetFrequency = 300;  % MHz - target for RFSoC
hdlcfg.AdaptivePipelining = true;
hdlcfg.DistributedPipelining = true;

% Pipeline configuration for timing closure
hdlcfg.InputPipeline = 2;
hdlcfg.OutputPipeline = 2;
hdlcfg.RegisterInputs = true;
hdlcfg.RegisterOutputs = true;
hdlcfg.AllowDelayDistribution = true;
hdlcfg.PipelineDistributionPriority = 'Performance';

% ============================================================================
% DATA TYPE CONFIGURATION
% ============================================================================

% Define data types for PAM4 receiver
P = 32;  % Fixed parallelism factor

% Input argument types
inputSamplesType = coder.typeof(uint8(0), [1 P]);     % 7-bit PAM4 samples
gainType = coder.typeof(uint8(0), [1 1]);             % 8-bit gain
ffeCoeffsType = coder.typeof(int16(0), [1 32]);       % FFE coefficients (32 taps)
stepSizeType = coder.typeof(int16(0), [1 1]);         % LMS step size
slicerLevelsType = coder.typeof(int16(0), [1 3]);     % PAM4 slicer thresholds
enableType = coder.typeof(false, [1 1]);               % Enable signal

% Create arguments array matching function signature (6 inputs)
args = {inputSamplesType, gainType, ffeCoeffsType, stepSizeType, slicerLevelsType, enableType};

% ============================================================================
% HDL GENERATION EXECUTION
% ============================================================================

% Validate configuration before generation
validateConfiguration();

try
    fprintf('Starting HDL generation for %s...\n', entryPointFunction);
    fprintf('Configuration:\n');
    fprintf('  Entry Function: %s\n', entryPointFunction);
    fprintf('  Testbench: %s\n', testbenchName);
    fprintf('  RAM Variables: %s\n', bufferVariables);
    fprintf('  Target Frequency: %d MHz\n', hdlcfg.TargetFrequency);
    fprintf('  Target Device: Zynq UltraScale+ RFSoC (xczu28dr)\n');
    fprintf('  Parallelism: %d samples per clock\n', P);
    fprintf('  Architecture: Parallel PAM4 processing with FFE and LMS\n');
    
    % Generate HDL code
    codegen('-config', hdlcfg, entryPointFunction, '-args', args, '-report');
    
    fprintf('\n✓ HDL generation completed successfully!\n');
    fprintf('Check the following for results:\n');
    fprintf('  - Resource report: codegen/%s/hdlsrc/resource_report.html\n', entryPointFunction);
    fprintf('  - Conformance report: codegen/%s/hdlsrc/%s_conformance_report.html\n', entryPointFunction, entryPointFunction);
    fprintf('  - Generated HDL: codegen/%s/hdlsrc/%s.v\n', entryPointFunction, entryPointFunction);
    
    % Check for synthesis results
    synthesisReport = sprintf('codegen/%s/hdlsrc/synthesis_report.html', entryPointFunction);
    if exist(synthesisReport, 'file')
        fprintf('  - Synthesis report: %s\n', synthesisReport);
    end
    
    % Display generation summary
    fprintf('\nGeneration Summary:\n');
    fprintf('  - Parallel processing: %d samples per clock\n', P);
    fprintf('  - Digital Gain Control: 7-bit to 8-bit with saturation\n');
    fprintf('  - FFE: Programmable taps (16/32/64) with circular buffer\n');
    fprintf('  - LMS Engine: Adaptive coefficient update\n');
    fprintf('  - PAM4 Slicer: Programmable thresholds\n');
    
    % Display synthesis results if available
    if hdlcfg.SynthesizeGeneratedCode
        fprintf('  - Synthesis: Enabled for %s target\n', hdlcfg.SynthesisTool);
        fprintf('  - Target Device: %s\n', hdlcfg.SynthesisToolDeviceName);
        fprintf('  - Target Frequency: %d MHz\n', hdlcfg.TargetFrequency);
    end
    
catch ME
    fprintf('\n✗ HDL generation failed with error:\n');
    fprintf('  %s\n', ME.message);
    fprintf('\nTroubleshooting checklist:\n');
    fprintf('  1. Verify pam4_receiver_hdl.m exists and has correct function signature\n');
    fprintf('  2. Verify pam4_receiver_hdl_tb.m exists for testbench validation\n'); 
    fprintf('  3. Check that RAMVariableNames matches persistent variables in pam4_receiver_hdl.m\n');
    fprintf('  4. Ensure args array matches function signature exactly (6 inputs, 3 outputs)\n');
    fprintf('  5. Verify all input data types are correctly specified\n');
    fprintf('  6. Check for HDL-incompatible operations\n');
    
    rethrow(ME);
end

% ============================================================================
% CONFIGURATION VALIDATION HELPER
% ============================================================================

function validateConfiguration()
    fprintf('Validating HDL Coder configuration...\n');
    
    % Check if HDL function file exists
    hdlFile = [entryPointFunction '.m'];
    if ~exist(hdlFile, 'file')
        error('HDL function file not found: %s', hdlFile);
    end
    
    % Check if testbench file exists
    tbFile = [testbenchName '.m'];
    if ~exist(tbFile, 'file')
        error('Testbench file not found: %s', tbFile);
    end
    
    fprintf('✓ Configuration validation passed!\n');
end

end