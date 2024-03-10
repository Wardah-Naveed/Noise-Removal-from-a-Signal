% Get the current folder where the script is located
currentFolder = fileparts(mfilename('fullpath'));

% Update the audio file paths to be relative to the script location
originalAudioFile = 'original.wav';
noiseAudioFile = 'noise.wav';
noisyAudioFile = 'noisy_output.wav';
denoisedAudioFile = 'denoised_output.wav';
furtherDenoisedAudioFile = 'further_denoised_output.wav';

% Full file paths
originalAudioFileFull = fullfile(currentFolder, originalAudioFile);
noiseAudioFileFull = fullfile(currentFolder, noiseAudioFile);
noisyAudioFileFull = fullfile(currentFolder, noisyAudioFile);
denoisedAudioFileFull = fullfile(currentFolder, denoisedAudioFile);
furtherDenoisedAudioFileFull = fullfile(currentFolder, furtherDenoisedAudioFile);

% Load pre-recorded audio signal
[originalSignal, originalFs] = audioread(originalAudioFileFull);
[noiseSignal, noiseFs] = audioread(noiseAudioFileFull);

% Ensure both signals have the same sampling rate

% Trim both signals to the length of the smaller one
minLength = min(length(originalSignal), length(noiseSignal));
originalSignal = originalSignal(1:minLength, :);
noiseSignal = noiseSignal(1:minLength, :);

% Adjust the volume of the noise signal (you can change the scaling factor)
scaledNoise = 0.5 * noiseSignal;

% Add noise to the original signal
noisySignal = originalSignal + scaledNoise;

% Save the noisy audio signal
audiowrite(noisyAudioFileFull, noisySignal, originalFs);

% Plot original, noisy, denoised, and further denoised signals for comparison
figure;

subplot(4, 1, 1);
plot((0:minLength-1) / originalFs, originalSignal(:, 1), 'b'); % Blue
title('Trimmed Original Audio Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(4, 1, 2);
plot((0:minLength-1) / originalFs, noisySignal(:, 1), 'g'); % Green
title('Noisy Audio Signal');
xlabel('Time (s)');
ylabel('Amplitude');

% Design a low-pass Butterworth filter
cutoffFrequency = 900; % Adjust as needed
order = 1; % Adjust as needed
[b, a] = butter(order, cutoffFrequency / (originalFs / 2), 'low');

% Apply the filter to the noisy signal
filteredSignal = filtfilt(b, a, noisySignal);

% Increase the volume of the filtered signal (you can change the scaling factor)
scalingFactor = 2; % Adjust as needed
increasedVolumeFilteredSignal = scalingFactor * filteredSignal;

% Save the denoised audio signal with increased volume
audiowrite(denoisedAudioFileFull, increasedVolumeFilteredSignal, originalFs);

subplot(4, 1, 3);
plot((0:minLength-1) / originalFs, increasedVolumeFilteredSignal(:, 1), 'r'); % Red
title('Filtered Signal');
xlabel('Time (s)');
ylabel('Amplitude');

% Apply another low-pass Butterworth filter to further reduce noise
additionalCutoffFrequency = 600; % Adjust as needed
[additionalB, additionalA] = butter(order, additionalCutoffFrequency / (originalFs / 2), 'low');

% Apply the filter to the already denoised signal
furtherDenoisedSignal = filtfilt(additionalB, additionalA, increasedVolumeFilteredSignal);

% Increase the volume of the filtered signal (you can change the scaling factor)
scalingFactor = 1; % Adjust as needed
furtherDenoisedSignal = scalingFactor * furtherDenoisedSignal;

% Save the further denoised audio signal
audiowrite(furtherDenoisedAudioFileFull, furtherDenoisedSignal, originalFs);

subplot(4, 1, 4);
plot((0:minLength-1) / originalFs, furtherDenoisedSignal(:, 1), 'm'); % Magenta
title('Further Denoised Audio Signal');
xlabel('Time (s)');
ylabel('Amplitude');

% Save the figure in the same folder as the code
saveas(gcf, fullfile(currentFolder, 'comparison_plot.png'));

% Optional: Listen to the original, noisy, denoised, and further denoised signals
sound(originalSignal(:, 1), originalFs);
pause(length(originalSignal) / originalFs + 1);  % Wait for the original signal to finish

sound(noisySignal(:, 1), originalFs);
pause(length(noisySignal) / originalFs + 1);  % Wait for the noisy signal to finish

sound(increasedVolumeFilteredSignal(:, 1), originalFs);
pause(length(increasedVolumeFilteredSignal) / originalFs + 1);  % Wait for the denoised signal to finish

sound(furtherDenoisedSignal(:, 1), originalFs);
pause(length(furtherDenoisedSignal) / originalFs + 1);  % Wait for the further denoised signal to finish
