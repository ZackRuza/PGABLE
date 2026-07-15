% Define the coordinates for the letters in WATERLOO
W = {[0,3,0; 0.5,0,0; 1,3,0; 1.5,0,0; 2,3,0]};
A = {[2.5,0,0; 3.2,3,0; 3.9,0,0], [2.85,1.5,0; 3.55,1.5,0]};
T = {[4.2,3,0; 5.2,3,0], [4.7,0,0; 4.7,3,0]};
E = {[5.5,0,0; 5.5,3,0; 6.2,3,0], [5.5,1.5,0; 6.0,1.5,0], [5.5,0,0; 6.0,0,0]};
R = {[6.5,0,0; 6.5,3,0; 7.2,3,0; 7.5,1.5,0; 6.5,1.5,0], [7.1,1.5,0; 7.5,0,0]};
L = {[7.8,3,0; 7.8,0,0; 8.3,0,0]};
O = {[8.6,0,0; 8.6,3,0; 9.4,3,0; 9.4,0,0; 8.6,0,0]};
O2 = {[9.7,0,0; 9.7,3,0; 10.5,3,0; 10.5,0,0; 9.7,0,0]};

% Combine into a single cell array of paths with NaN separators to prevent connecting letters
waterloo_paths = [W, NaN(1,2), A, NaN(1,2), T, NaN(1,2), ...
                  E, NaN(1,2), R, NaN(1,2), L, NaN(1,2), O, NaN(1,2), O2];

% Extract X and Y data points and plot
X = []; Y = [];
for i = 1:length(waterloo_paths)
    if ~isnan(waterloo_paths{i})
        X = [X; waterloo_paths{i}(:,1); NaN];
        Y = [Y; waterloo_paths{i}(:,2); NaN];
    end
end

figure;
plot(X, Y, 'LineWidth', 3, 'Color', 'b');
axis equal;
title('Piecewise Linear "WATERLOO"');
xlabel('X'); ylabel('Y');
set(gca, 'YDir', 'normal');

% Combine into a single cell array of paths with NaN separators to prevent connecting letters
waterloo_paths = [W, NaN(1,3), A, NaN(1,3), T, NaN(1,3), ...
                  E, NaN(1,3), R, NaN(1,3), L, NaN(1,3), O, NaN(1,3), O2];
% Extract X and Y data points and plot
X = []; Y = []; Z = [];
for i = 1:length(waterloo_paths)
    if ~isnan(waterloo_paths{i})
        X = [X; waterloo_paths{i}(1,1); waterloo_paths{i}(:,1); waterloo_paths{i}(end,1)];
        Y = [Y; waterloo_paths{i}(1,2); waterloo_paths{i}(:,2); waterloo_paths{i}(end,2)];
        Z = [Z; 0.5; waterloo_paths{i}(:,3); 0.5];
    end
end

plot3(X,Y,Z); axis equal
