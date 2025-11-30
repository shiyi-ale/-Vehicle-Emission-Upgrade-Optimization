% 规模经济系数alpha折扣分析
clear; clc; close all;

%% 基础参数
C5 = 11000;  % 国5升级原价
quantities = [1000, 5000, 10000, 50000, 100000, 181973];
alphas = [-0.0001, -0.01, -0.014, -0.02, -0.024, -0.03];

%% 文本结果输出
fprintf('=== 规模经济系数alpha折扣分析 ===\n\n');
fprintf('升级标准: 国5 (原价%d元)\n', C5);
fprintf('%-12s', '数量');
for i = 1:length(alphas)
    fprintf('alpha=%-8.4f', alphas(i));
end
fprintf('\n%s\n', repmat('-', 1, 80));

for j = 1:length(quantities)
    q = quantities(j);
    fprintf('%-12d', q);
    
    for i = 1:length(alphas)
        cost = C5 + alphas(i) * q;
        discount = (C5 - cost) / C5 * 100;
        
        if cost > 0
            fprintf('%-10.1f%%', discount);
        else
            fprintf('%-10s', '负成本');
        end
    end
    fprintf('\n');
end

%% 图表1 - 多维度分析
figure('Position', [100, 100, 1400, 1000]);

% 子图1: 折扣率曲线
subplot(2,3,1);
hold on;
x_q = 1000:1000:200000;
colors = lines(length(alphas));

for i = 1:length(alphas)
    discount_curve = (C5 - (C5 + alphas(i) * x_q)) / C5 * 100;
    plot(x_q/1000, discount_curve, 'LineWidth', 2, 'Color', colors(i,:), ...
         'DisplayName', sprintf('α=%.4f', alphas(i)));
end

% 标记数据点
for j = 1:length(quantities)
    for i = 1:length(alphas)
        cost = C5 + alphas(i) * quantities(j);
        if cost > 0
            discount_val = (C5 - cost) / C5 * 100;
            plot(quantities(j)/1000, discount_val, 'o', 'MarkerSize', 6, ...
                 'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor', 'k');
        end
    end
end

xlabel('数量q/千辆'); ylabel('折扣率η/%');
legend('Location', 'northwest'); grid on;

% 子图2: 单位成本
subplot(2,3,2);
hold on;
for i = 1:length(alphas)
    cost_curve = C5 + alphas(i) * x_q;
    plot(x_q/1000, cost_curve, 'LineWidth', 2, 'Color', colors(i,:));
end
xlabel('数量q/千辆'); ylabel('单位成本C/元');
legend('Location', 'best'); grid on;
yline(0, 'r--', '零成本线');

% 子图3: 总成本
subplot(2,3,3);
hold on;
for i = 1:length(alphas)
    total_cost = x_q .* (C5 + alphas(i) * x_q);
    plot(x_q/1000, total_cost/1e6, 'LineWidth', 2, 'Color', colors(i,:));
end
xlabel('数量q/千辆'); ylabel('总成本Ctotal/百万');
legend('Location', 'best'); grid on;

% 子图4: 热力图
subplot(2,3,4);
discount_mat = zeros(length(quantities), length(alphas));
for i = 1:length(alphas)
    for j = 1:length(quantities)
        cost = C5 + alphas(i) * quantities(j);
        if cost > 0
            discount_mat(j,i) = (C5 - cost) / C5 * 100;
        else
            discount_mat(j,i) = NaN;
        end
    end
end

imagesc(1:length(alphas), 1:length(quantities), discount_mat);
colorbar;
set(gca, 'XTick', 1:length(alphas), 'XTickLabel', arrayfun(@(x) sprintf('%.4f', x), alphas, 'uni', false));
set(gca, 'YTick', 1:length(quantities), 'YTickLabel', arrayfun(@(x) sprintf('%d', x), quantities, 'uni', false));
xlabel('系数α'); ylabel('数量q');

% 热力图数值标注
for i = 1:length(alphas)
    for j = 1:length(quantities)
        if ~isnan(discount_mat(j,i))
            text_color = discount_mat(j,i) > 50 ? 'white' : 'black';
            text(i, j, sprintf('%.1f%%', discount_mat(j,i)), ...
                'HorizontalAlignment', 'center', 'FontWeight', 'bold', ...
                'Color', text_color, 'FontSize', 8);
        end
    end
end

% 子图5: 边际成本下降
subplot(2,3,5);
marginal_drop = -alphas * 10000;
bar(marginal_drop, 'FaceColor', [0.2 0.6 0.8]);
set(gca, 'XTickLabel', arrayfun(@(x) sprintf('%.4f', x), alphas, 'uni', false));
xlabel('系数α'); ylabel('边际成本下降ΔC/元');
grid on;

% 柱状图数值
for i = 1:length(marginal_drop)
    text(i, marginal_drop(i), sprintf('%.0f元', marginal_drop(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontWeight', 'bold');
end

% 子图6: 推荐参数
subplot(2,3,6);
max_q = 181973;
target_discounts = [0.10, 0.20, 0.30, 0.40, 0.50];
req_alphas = -(C5 * target_discounts) / max_q;
final_costs = C5 + req_alphas * max_q;

bar(target_discounts*100, final_costs, 'FaceColor', [0.8 0.4 0.2]);
xlabel('期望折扣η/%'); ylabel('最终单价Cfinal/元');
grid on;

% 推荐参数标注
for i = 1:length(target_discounts)
    text(target_discounts(i)*100, final_costs(i), ...
        sprintf('α=%.4f\n%.0f元', req_alphas(i), final_costs(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
        'FontWeight', 'bold', 'FontSize', 8);
end

%% 图表2 - 3D可视化
figure('Position', [200, 200, 1200, 500]);

% 3D曲面
subplot(1,2,1);
[Q_grid, A_grid] = meshgrid(linspace(1000, 200000, 50), linspace(-0.03, -0.0001, 50));
Cost_3D = C5 + A_grid .* Q_grid;
Discount_3D = (C5 - Cost_3D) ./ C5 * 100;
Discount_3D(Cost_3D <= 0) = NaN;

surf(Q_grid/1000, A_grid, Discount_3D, 'EdgeColor', 'none');
xlabel('数量q/千辆'); ylabel('系数α'); zlabel('折扣η/%');
colorbar; view(45, 30);

% 等高线
subplot(1,2,2);
contourf(Q_grid/1000, A_grid, Discount_3D, 20, 'LineColor', 'none');
xlabel('数量q/千辆'); ylabel('系数α');
colorbar;

hold on;
[C_lines, h] = contour(Q_grid/1000, A_grid, Discount_3D, 10, 'LineColor', 'k', 'LineWidth', 0.5);
clabel(C_lines, h, 'FontSize', 8, 'Color', 'white');

%% 验证计算
fprintf('\n=== 验证计算 ===\n');
test_data = [
    100000, -0.01;
    50000, -0.005; 
    181973, -0.01
];

for i = 1:size(test_data, 1)
    q_test = test_data(i, 1);
    alpha_test = test_data(i, 2);
    cost_test = C5 + alpha_test * q_test;
    discount_test = (C5 - cost_test) / C5 * 100;
    
    fprintf('数量%d, alpha=%.4f: ', q_test, alpha_test);
    fprintf('成本=%.0f元, 折扣=%.1f%%\n', cost_test, discount_test);
end

fprintf('\n=== alpha实际意义 ===\n');
fprintf('alpha = -0.0001: 每车成本降0.1元\n');
fprintf('alpha = -0.0010: 每车成本降1.0元\n'); 
fprintf('alpha = -0.0100: 每车成本降10.0元\n\n');

fprintf('=== 推荐参数 ===\n');
fprintf('基于最大数量%d辆:\n', max_q);
for i = 1:length(target_discounts)
    discount_target = target_discounts(i);
    alpha_req = -(C5 * discount_target) / max_q;
    cost_final = C5 + alpha_req * max_q;
    fprintf('折扣%2.0f%%: alpha=%.6f, 单价%.0f元\n', ...
        discount_target*100, alpha_req, cost_final);
end

% 统一图表格式
all_axes = findall(0, 'type', 'axes');
for i = 1:length(all_axes)
    set(all_axes(i), 'FontSize', 10, 'LineWidth', 1.2);
end

fprintf('\n分析完成！\n');
fprintf('• 图1: 6子图多维度分析\n');
fprintf('• 图2: 3D曲面和等高线\n');