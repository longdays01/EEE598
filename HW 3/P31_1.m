function P31()
    Ms = [100, 150, 200]; % Total number of players for each setting

    for M_idx = 1:length(Ms)
        M = Ms(M_idx);
        [iterations, potentials, player_distribution] = best_response_dynamics(M);
        % disp(length(iterations));
        % disp(length(potentials));
        % Plot the potential function convergence graph
        figure;
        plot(iterations, potentials);
        title(['Convergence with M = ', num2str(M)]);
        xlabel('Number of Iterations');
        ylabel('Potential Function Value');
        
        % Display the Nash equilibrium distribution
        fprintf('For M = %d, at Nash Equilibrium:\n', M);
        fprintf('Players on SAAD: %d\n', player_distribution(1));
        fprintf('Players on SBBD: %d\n', player_distribution(2));
        fprintf('Players on SAABBD: %d\n', player_distribution(3));
        fprintf('Players on SD: %d\n', player_distribution(4));
    end
end

function [iterations, potentials, player_distribution] = best_response_dynamics(M)
    action_matrix_update = randi([1, 4], 1, M); % Random initial actions for each player

    iterations = [1];
    potentials = [];
    
    iter = 1; 
    converged = false;

    [players_SAAD, players_SBBD, players_SAABBD, players_SD] = cal_num_players(action_matrix_update);

    % Calculate the potential for this iteration
    [delay_SAAD, delay_SBBD, delay_SAABBD,  delay_SD, potential_new] =... 
        cal_delay(players_SAAD, players_SBBD, players_SAABBD, players_SD);
    delay_array = [delay_SAAD, delay_SBBD, delay_SAABBD,  delay_SD];
    potentials(end+1) = potential_new;

    while ~converged && iter < 1000 % Set a limit on the number of iterations
        iter = iter + 1;
        % 
        % [players_SAAD, players_SBBD, players_SAABBD, players_SD] = cal_num_players(action_matrix_update);
        % 
        % % Calculate the potential for this iteration
        % [delay_SAAD, delay_SBBD, delay_SAABBD,  delay_SD, potential_new] =... 
        %     cal_delay(players_SAAD, players_SBBD, players_SAABBD, players_SD);
        % delay_array = [delay_SAAD, delay_SBBD, delay_SAABBD,  delay_SD];
        
        % potentials(end+1) = potential_new;

        new_iter = false;
        % Attempt to find a better response for each player
        for i = 1:M
            if new_iter == true
                break;
            end

            current_best_action = action_matrix_update(i);
            for temp = 1:4
                if new_iter == true
                    break;
                end

                if temp ~= current_best_action
                    action_matrix_deviate = action_matrix_update;
                    action_matrix_deviate(i) = temp;
                    [new_players_SAAD, new_players_SBBD, new_players_SAABBD, new_players_SD] = cal_num_players(action_matrix_deviate);
                    [new_delay_SAAD, new_delay_SBBD, new_delay_SAABBD,  new_delay_SD, new_potential] =...
                        cal_delay(new_players_SAAD, new_players_SBBD, new_players_SAABBD, new_players_SD);

                    delay_array_new = [new_delay_SAAD, new_delay_SBBD, new_delay_SAABBD,  new_delay_SD];
                    
                    if delay_array_new(temp) < delay_array(current_best_action)
                        action_matrix_update(i) = temp;
                        potential_new = new_potential;
                        new_iter = true;
                        break;
                    end
                end
                % disp("really" + new_iter + i + temp + iter)
            end
        end
        
        if abs(potentials(end) - potential_new) == 0
            converged = true;
        end


        [players_SAAD, players_SBBD, players_SAABBD, players_SD] = cal_num_players(action_matrix_update);

        % Calculate the potential for this iteration
        [delay_SAAD, delay_SBBD, delay_SAABBD,  delay_SD, potential_new] =... 
            cal_delay(players_SAAD, players_SBBD, players_SAABBD, players_SD);
        delay_array = [delay_SAAD, delay_SBBD, delay_SAABBD,  delay_SD];

        potentials(end+1) = potential_new;
        iterations(end+1) = iter;
    end
    
    [players_SAAD, players_SBBD, players_SAABBD, players_SD] = cal_num_players(action_matrix_update);
    player_distribution = [players_SAAD, players_SBBD, players_SAABBD, players_SD];
end

function [delay_SAAD, delay_SBBD, delay_SAABBD,  delay_SD, potential_new] = cal_delay(players_SAAD, players_SBBD, players_SAABBD, players_SD)
    delay_SA = 15 + (players_SAAD + players_SAABBD) / 10;
    delay_SB = 15 + players_SBBD / 8;
    delay_AD = 10 + players_SAAD / 20;
    delay_BD = 12; % Fixed delay
    delay_AB = 11; % Fixed delay

    delay_SD = 15 + players_SD / 5;
    delay_SAAD = delay_SA + delay_AD;
    delay_SBBD = delay_SB + delay_BD;
    delay_SAABBD = delay_SA + delay_AB + delay_BD;

    delay_SA_cumulative = 15 + (1:(players_SAAD+players_SAABBD)) / 10;
    delay_SB_cumulative = 15 + (1:players_SBBD) / 8;
    delay_AD_cumulative = 10 + (1:players_SAAD) / 20;
    delay_BD_cumulative = repmat(12, 1, (players_SBBD+players_SAABBD));
    delay_AB_cumulative = repmat(11, 1, players_SAABBD);
    delay_SD_cumulative = 15 + (1:players_SD) / 5;

    potential_new = sum(delay_SA_cumulative) + sum(delay_SB_cumulative) + sum(delay_AD_cumulative) + ...
            sum(delay_BD_cumulative) + sum(delay_AB_cumulative) + sum(delay_SD_cumulative);
end

function [players_SAAD, players_SBBD, players_SAABBD, players_SD] = cal_num_players(action_matrix)
    players_SAAD = sum(action_matrix == 1);
    players_SBBD = sum(action_matrix == 2);
    players_SAABBD = sum(action_matrix == 3);
    players_SD = sum(action_matrix == 4);
end
