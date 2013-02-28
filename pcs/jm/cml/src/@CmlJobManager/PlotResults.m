function PlotResults(obj, JobParam, JobState, FiguresDir, JobName, TempJMDir)
% Plot the results.

% set(gca,'FontSize',12, 'FontName','Times', 'FontWeight','normal')

FigNumber = 0;
FigHandle = [];

switch JobParam.sim_type
    case 'capacity' % Plot capacity vs. Eb/N0 and Es/N0 and Eb/N0 vs. capacity (useful for FSK modulation).
        [FigHandle, FigNumber] = PlotCapacityCurves(JobParam, JobState, FigHandle, FigNumber);
    case 'exit' % Plot EXIT curves.
        [FigHandle, FigNumber] = PlotExitCurves( JobParam, JobState, FigHandle, FigNumber, JobParam.SNR);
    % Plot BER vs. Eb/N0 for coded or uncoded simulations, AND BER vs. Es/N0 for coded simulations.
    % AND SER vs. Eb/N0 for uncoded simulations.
    case 'uncoded' % Uncoded modulation.
        [FigHandle, FigNumber] = PlotBerSerCodedUncoded( JobParam, JobState, [], [], FigHandle, FigNumber);
    case 'coded' % Coded modulation.
        [FigHandle, FigNumber] = PlotBerSerCodedUncoded( [], [], JobParam, JobState, FigHandle, FigNumber);
        [FigHandle, FigNumber] = PlotFerCodedOutage( JobParam, JobState, [], [], FigHandle, FigNumber);
    case {'outage', 'bloutage'} % Plot BER vs. Eb/N0 for outage probability simulations.
        [FigHandle, FigNumber] = PlotFerCodedOutage( [], [], JobParam, JobState, FigHandle, FigNumber);
    case 'throughput' % Plot throughput vs. Es/N0 for throughput of hybrid-ARQ.
        [FigHandle, FigNumber] = PlotThroughputEsN0( JobParam, JobState, FigHandle, FigNumber);
    case 'bwcapacity' % Plot CAPACITY min Eb/N0 vs. h and min Eb/N0 vs. rate for nonorthogonal FSK under BW constraints B.
        [FigHandle, FigNumber] = PlotMinEbN0hRateNonOrthogonalFsk( JobParam, JobState, FigHandle, FigNumber);
    % Plot min Eb/N0 vs. B, eta vs. min Eb/N0, optimal h vs. B, optimal rate vs. B for nonorthogonal FSK under BW constraint B.
    case 'minSNRvsB'
        [FigHandle, FigNumber] = PlotMinEbN0BNonOrthogonalFsk( JobParam, JobState, FigHandle, FigNumber);
    otherwise
        fprintf('\nThe specified simulation type %s is not supported!\n',JobParam.sim_type);
        keyboard;
end

FigTitleText = ['The time of the last update of this figure is ' datestr(clock, 'dd/mm/yyyy at HH:MM:SS PM') '.'];

for Fig = 1:FigNumber
    figure(FigHandle(Fig));
    title(FigTitleText);
    try
        % print(FigHandle(Fig), '-dpdf', fullfile(FiguresDir, [JobName(1:end-4) '_Fig' num2str(Fig) '.pdf']));
        saveas( FigHandle(Fig), fullfile(FiguresDir, [JobName(1:end-4) '_Fig' num2str(Fig) '.pdf']) );
    catch
        % print(FigHandle(Fig), '-dpdf', fullfile(FiguresDir, [JobName(1:end-4) '_Fig' num2str(Fig) '.pdf']));
        saveas( FigHandle(Fig), fullfile(TempJMDir, [JobName(1:end-4) '_Fig' num2str(Fig) '.pdf']) );
        obj.MoveFile( fullfile(TempJMDir, [JobName(1:end-4) '_Fig' num2str(Fig) '.pdf']), FiguresDir);
    end
end
end