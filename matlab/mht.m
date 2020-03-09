classdef mht
        
    methods(Static)
        %------------------------------------------------------------------
        % Main method
        %------------------------------------------------------------------
        % R      | Hypothesis tests     | int^(Sx4)  | [d1,d2,z,k], treatment IDs, subgroup ID, output column
        % Y      | Outcome Data         | real^(nxK) | 
        % D      | Treatment ID         | int^n      |
        % Z      | Subgroup ID          | int^n      |
        % n_boot | Bootstrap iterations | int        |
        %
        function [difference_absolute_og_vector, p_values_single_og, p_values_multi] = calculate(R, Y, D, Z, n_boot)
            
            % Default bootstrap iterations if none given
            if nargin < 5
                n_boot = 3000;
            end
                        
            n_comparisons = size(R,1);
                        
            % Split data by treatment and subgroup
            [id_group, Y_cell] = mht.split_data(Y, D, Z);
            
            R_indices = mht.comparison_2_index(R, id_group);
            
            % Calculate Original Differences, i.e. test statistics
            %--------------------------------------------------------------
            
            % Means, Vars, and Ns needed for studentized differences
            n_og_vector    = cellfun(@numel, Y_cell(:,1));
            mean_og_matrix = cellfun(@mean, Y_cell);
            var_og_matrix  = cellfun(@var, Y_cell);
                                    
            [difference_raw_og_vector, difference_absolute_og_vector, difference_studentized_og_vector]...
                = mht.calculate_difference_statistics(R_indices, mean_og_matrix, var_og_matrix, n_og_vector);
                        
            % Calculate Bootstrapped Differences, i.e. test statistics
            % NOTE: Original differences are needed for centering
            %--------------------------------------------------------------
            difference_studentized_centered_boot_matrix = zeros(n_comparisons, n_boot);
                                   
            parfor l = 1 : n_boot
                % Resample with replacement.
				% NOTE: Unlike the paper this is block bootstrapping. I believe 
				% it should be asymptotically equivalent as the number of observations per treatment-subgroup grows large.
				% It avoids the issue of drawing a bootstrap sample missing a treatment-subgroup.
				Y_boot = cellfun(@(z) z(randi(numel(z), [numel(z), 1])), Y_cell, 'UniformOutput', false); 
                
                mean_boot= cellfun(@mean, Y_boot);
                var_boot = cellfun(@var, Y_boot);
                
                difference_studentized_centered_boot_matrix(:,l)...
                    = mht.calculate_studentized_centered_difference(R_indices, mean_boot, var_boot, n_og_vector, difference_raw_og_vector);
            end
            
            % Calculate empirical test statistic distributions and p-values
            %--------------------------------------------------------------
            [ts_distribution_og, ts_distribution_boot] = mht.calculate_test_statistic_distribution(difference_studentized_og_vector, difference_studentized_centered_boot_matrix);

            p_values_single_og = 1 - ts_distribution_og;
			p_values_single_boot = 1 - ts_distribution_boot;
            
            p_values_multi = mht.calculate_stepwise_multiple_hypothesis_p_value(p_values_single_og, p_values_single_boot);
          
        end
                
        %------------------------------------------------------------------
        % Calculates differences for original data 
        %------------------------------------------------------------------
        function [difference_raw_vector, difference_absolute_vector, difference_studentized_vector]...
                    = calculate_difference_statistics(R_indices, mean_matrix, var_matrix, n_vector)
            % R= [d1,d2,z,k]            
            n_comparisons = size(R_indices,1);
            
            difference_raw_vector = zeros(n_comparisons, 1);
            difference_absolute_vector = zeros(n_comparisons, 1);
            difference_studentized_vector = zeros(n_comparisons, 1);
            
            for l = 1 : n_comparisons                
                idx_1 = R_indices(l,1);
                idx_2 = R_indices(l,2);
                k = R_indices(l,3);
                
                difference_raw_vector(l) = mean_matrix(idx_1,k)-mean_matrix(idx_2,k);
                difference_absolute_vector(l) = abs(difference_raw_vector(l));
                
                studentization_factor = sqrt(...
                    var_matrix(idx_1,k)/n_vector(idx_1)...
                    + var_matrix(idx_2,k)/n_vector(idx_2));
                
                difference_studentized_vector(l) = difference_absolute_vector(l) / studentization_factor;                
            end
        end
        
        %------------------------------------------------------------------
        % Calculates differences for bootstrapped data
        %------------------------------------------------------------------
        function difference_studentized_centered_vector = calculate_studentized_centered_difference(R_indices, mean_matrix, var_matrix, n_vector, difference_raw_og_vector)
            % R= [d1,d2,z,k]            
            n_comparisons = size(R_indices,1);

            difference_studentized_centered_vector = zeros(n_comparisons, 1);
            
            for l = 1 : n_comparisons                
                idx_1 = R_indices(l,1);
                idx_2 = R_indices(l,2);
                k = R_indices(l,3);
                
                difference_absolute_centered = abs(mean_matrix(idx_1,k)-mean_matrix(idx_2,k)-difference_raw_og_vector(l));
                
                studentization_factor = sqrt(...
                    var_matrix(idx_1,k)/n_vector(idx_1)...
                    + var_matrix(idx_2,k)/n_vector(idx_2));
                
                difference_studentized_centered_vector(l) = difference_absolute_centered / studentization_factor;                
            end
        end        
                
        %------------------------------------------------------------------
        % Calculates P(TS <= x) for original and booted test statistics
        %------------------------------------------------------------------
        function [ts_distribution_og, ts_distribution_boot] = calculate_test_statistic_distribution(ts_og, ts_boot)
            n_boot = size(ts_boot,2);
            n_comparisons = size(ts_og,1);
            
            ts_distribution_og = sum(ts_boot <= ts_og, 2) / n_boot;
			
            [~, sort_idx] = sort(ts_boot,2);			
            ts_distribution_boot = repmat((1:n_boot) / n_boot, [n_comparisons, 1]);
            
            ts_distribution_boot(sort_idx) = ts_distribution_boot;
        end
                
        %------------------------------------------------------------------
        % Calculates MHT modified p-value
        %------------------------------------------------------------------
        function p_values = calculate_multiple_hypothesis_p_value(p_values_single_og, p_values_single_boot)
            p_values = sum(max(p_values_single_boot,[],1) <= p_values_single_og,2) / size(p_values_single_boot,2); 
        end
        
        %------------------------------------------------------------------
        % Stepwise Procedure
        %------------------------------------------------------------------
        function p_values = calculate_stepwise_multiple_hypothesis_p_value(p_values_single_og, p_values_single_boot)
            n_comparisons = size(p_values_single_og,1);
            
            [p_values_single_og, idx_sort] = sort(p_values_single_og);
            p_values_single_boot = p_values_single_boot(idx_sort,:);
            
            p_values = zeros(n_comparisons,1);
            
            for l = 1 : n_comparisons
                p_values(l) = mht.calculate_multiple_hypothesis_p_value(p_values_single_og(l), p_values_single_boot(l:end,:));
            end
            p_values(idx_sort) = p_values;
        end
        
        %------------------------------------------------------------------
        % Converts treatment and subgroup IDs into indices, convenience method
        %------------------------------------------------------------------
        function R_indices = comparison_2_index(R, id_group)
            % R= [d1,d2,z,k]            
            n_comparisons = size(R,1);
            R_indices = zeros(n_comparisons, 3);
            
            R_indices(:,3) = R(:,4);
            
            for l = 1 : n_comparisons
                idx_1 = find(id_group(:,1) == R(l,1) & id_group(:,2) == R(l,3));
                idx_2 = find(id_group(:,1) == R(l,2) & id_group(:,2) == R(l,3));
                
                R_indices(l,1) = idx_1;
                R_indices(l,2) = idx_2;
            end
        end

        %------------------------------------------------------------------
        % Splits outcome data in cell array by treatment and subgroup
        %------------------------------------------------------------------
        function [id_group, Y_cell] = split_data(Y, D, Z)            
            id_group = unique([D,Z],'rows');
            id_group = [id_group, (1:size(id_group,1))'];
            n_groups = size(id_group,1);
            
            K = size(Y,2);
            
            Y_cell = cell(n_groups, K);
            
            for l = 1 : n_groups
                mask = D == id_group(l,1) & Z == id_group(l,2);                
                                
                for k = 1 : K
                    Y_cell{l,k} = Y(mask,k);                    
                end
            end            
        end
    end
end

