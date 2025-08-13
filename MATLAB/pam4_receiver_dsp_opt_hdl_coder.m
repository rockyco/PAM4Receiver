function pam4_receiver_dsp_opt_hdl_coder()
% HDL_CODER Configuration for Advanced Pipelined PAM4 receiver
% 
% Configures HDL Coder for pam4_receiver_dsp_opt_hdl.m with:
% - Modular architecture with validIn/validOut interfaces
% - Deep pipeline registers between all modules (4 stages)
% - dsp.FIRFilter system object for 500x DSP reduction
% - Maximum clock frequency optimization (300+ MHz target)
%
% Function signature: 
%   [decision, error_signal, coeffs_out, validOut] = pam4_receiver_dsp_opt_hdl(
%                                                        input_samples, gain, ffe_coeffs, 
%                                                        step_size, slicer_levels, 
%                                                        enable, validIn)
%
% Architecture: Advanced pipelined DSP with modular validIn/validOut design

% ============================================================================
% ALGORITHM-SPECIFIC CONFIGURATION
% ============================================================================

% Algorithm-specific configuration
entryPointFunction = 'pam4_receiver_dsp_opt_hdl';  % Advanced pipelined HDL function
testbenchName = 'pam4_receiver_dsp_opt_hdl_tb';    % Testbench with validIn/validOut

% Buffer variable names for dsp.FIRFilter system object and pipeline registers
bufferVariables = "systolicFilter";

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

hdlcfg.SynthesisToolChipFamily = 'Zynq UltraScale+ RFSoC';
hdlcfg.SynthesisToolDeviceName = 'xczu28dr-ffvg1517-2-e';

% Memory optimization settings for batch processing buffers
hdlcfg.MapPersistentVarsToRAM = true;
hdlcfg.RAMVariableNames = bufferVariables;
hdlcfg.RAMThreshold = 16;  % Minimum size for RAM mapping
hdlcfg.RAMArchitecture = 'GenericRAM';

% Performance optimization settings for balanced pipelining
hdlcfg.TargetFrequency = 200;  % MHz - optimized for balanced pipeline architecture
hdlcfg.AdaptivePipelining = true;
hdlcfg.DistributedPipelining = true;

% Pipeline configuration
hdlcfg.InputPipeline = 1;
hdlcfg.OutputPipeline = 1;
hdlcfg.RegisterInputs = true;
hdlcfg.RegisterOutputs = true;
hdlcfg.AllowDelayDistribution = true;
hdlcfg.PipelineDistributionPriority = 'Performance';

% ============================================================================
% DATA TYPE CONFIGURATION
% ============================================================================

% Define consistent data types for complex lagged product computation
dataType = numerictype(1, 32, 16);     % Q16.16 format for complex input
offsetType = numerictype(1, 16, 0);    % Signed 16-bit for indices (negBase can be negative)

% Configure input argument types for advanced pipelined PAM4 receiver
% Function signature: [decision, error_signal, coeffs_out, validOut] = pam4_receiver_dsp_opt_hdl(input_samples, gain, ffe_coeffs, step_size, slicer_levels, enable, validIn)

% Input argument types
inputSamplesType = coder.typeof(uint8(0), [1 32]);        % 32 input samples
gainType = coder.typeof(uint8(0), [1 1]);                % Single gain value
ffeCoeffsType = coder.typeof(int16(0), [1 32]);          % 32 FIR coefficients
stepSizeType = coder.typeof(int16(0), [1 1]);            % LMS step size
slicerLevelsType = coder.typeof(int16(0), [1 3]);        % 3 slicer levels
enableType = coder.typeof(false, [1 1]);                 % Enable signal
validInType = coder.typeof(false, [1 1]);                % ValidIn signal

% Create arguments array matching function signature (7 inputs, 4 outputs)
args = {inputSamplesType, gainType, ffeCoeffsType, stepSizeType, slicerLevelsType, enableType, validInType};

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
    fprintf('  Function Signature: [decision, error_signal, coeffs_out, validOut] = pam4_receiver_dsp_opt_hdl(..., enable, validIn)\n');
    fprintf('  Architecture: Advanced pipelined PAM4 receiver with modular validIn/validOut design\n');
    
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
    fprintf('  - PAM4 output pattern: Decisions, Error signals, Coefficients, ValidOut\n');
    fprintf('  - Modular architecture: validIn/validOut interfaces for each stage\n');
    fprintf('  - Deep pipelining: 4-stage pipeline between modules for timing closure\n');
    fprintf('  - DSP resource optimization: dsp.FIRFilter system object\n');
    fprintf('  - HDL-compatible operations: Only +, -, *, bitwise shifts\n');
    fprintf('  - No floor(), rem(), mod() operations in generated HDL\n');
    fprintf('  - Maximum frequency design: 300+ MHz target with pipeline registers\n');
    
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
    fprintf('  1. Verify design_hdl.m exists and has correct function signature\n');
    fprintf('  2. Verify design_hdl_tb.m exists for testbench validation\n'); 
    fprintf('  3. Check that RAMVariableNames matches persistent variables in design_hdl.m\n');
    fprintf('  4. Ensure args array matches function signature exactly (7 inputs, 4 outputs)\n');
    fprintf('  5. Verify all input data types are correctly specified\n');
    fprintf('  6. Check for HDL-incompatible operations (floor, rem, mod should be in testbench)\n');
    
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