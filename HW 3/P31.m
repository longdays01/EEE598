function P31()
    Ms = [100, 150, 200]; % Total number of players for each setting

    for M_idx = 1:length(Ms)
        M = Ms(M_idx);
        [iterations, potentials, player_distribution] = best_response_dynamics(M);
        
        % Plot the convergence graph
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
    % Initialize the number of players on each path
    action_matrix_ini = randi([1, 4], 1, M);
    action_matrix_update = action_matrix_ini;
    % players_SAAD = M / 4;
    % players_SBBD = M / 4;
    % players_SAABBD = M / 4;
    % players_SD = M - (players_SAAD + players_SBBD + players_SAABBD);
    [players_SAAD, players_SBBD, players_SAABBD, players_SD] = cal_num_players(action_matrix_ini);

    iterations = [];
    potentials = [];
    
    iter = 0; % Initialize iteration count
    converged = false; % Convergence flag
    
    while ~converged && iter < 1000 % Set a limit on the number of iterations
        iter = iter + 1;
        % players_SA = players_SAAD + players_SAABBD;
        % players_SB = players_SBBD
        % players_AD = players_SAAD
        % Calculate delays for each path
        % delay_SA = 15 + (players_SAAD + players_SAABBD) / 10;
        % delay_SB = 15 + players_SBBD / 8;
        % delay_AD = 10 + players_SAAD / 20;
        % delay_BD = 12; % Fixed delay
        % delay_AB = 11; % Fixed delay
        % 
        % delay_SD = 15 + players_SD / 5;
        % delay_SAAD = 15 + (players_SAAD + players_SAABBD) / 10 + 10 + players_SAAD / 20;
        % delay_SBBD = 15 + players_SBBD / 8 + 12;
        % delay_SAABBD = 15 + (players_SAAD + players_SAABBD) / 10 + 11 + 12;
        % 
        % delay_SA_cumulative = 15 + (1:(players_SAAD+players_SAABBD)) / 10;
        % delay_SB_cumulative = 15 + (1:players_SBBD) / 8;
        % delay_AD_cumulative = 10 + (1:players_SAAD) / 20;
        % delay_BD_cumulative = repmat(12, 1, (players_SBBD+players_SAABBD));
        % delay_AB_cumulative = repmat(11, 1, players_SAABBD);
        % delay_SD_cumulative = 15 + (1:players_SD) / 5;
        
        % % Sum the delays for each player on their respective path
        % total_delay_SA = sum(delay_SA);
        % total_delay_SB = sum(delay_SB);
        % total_delay_AD = sum(delay_AD);
        % total_delay_BD = sum(delay_BD);
        % total_delay_AB = sum(delay_AB);
        % total_delay_SD = sum(delay_SD);
        
        % Calculate the potential for this iteration
        % potential = sum(delay_SA_cumulative) + sum(delay_SB_cumulative) + sum(delay_AD_cumulative) + ...
        %             sum(delay_BD_cumulative) + sum(delay_AB_cumulative) + sum(delay_SD_cumulative);
        iterations(end+1) = iter;
        
        [delay_SAAD, delay_SBBD, delay_SAABBD,  delay_SD, potential_new] =... 
        cal_delay(players_SAAD, players_SBBD, players_SAABBD, players_SD);

        potentials(end+1) = potential_new;
        delay_array = [delay_SAAD, delay_SBBD, delay_SAABBD,  delay_SD, potential_new];
        
        new_iter = false;
        % temp = 0; 
        for i = 1:M
            if new_iter
                break;
            end

            temp = 0;
            while temp < 4
                temp = temp + 1;
                action_matrix_deviate = action_matrix_update;
                action_matrix_deviate(i) = temp;
                players_SAAD, players_SBBD, players_SAABBD, players_SD = cal_num_players(action_matrix_deviate);
                [delay_SAAD_new, delay_SBBD_new, delay_SAABBD_new,  delay_SD_new, potential_new] =... 
                cal_delay(players_SAAD, players_SBBD, players_SAABBD, players_SD);
                delay_array_new = [delay_SAAD_new, delay_SBBD_new, delay_SAABBD_new,  delay_SD_new, potential_new];
                if delay_array_new(temp) < delay_array(temp)
                    action_matrix_update(i) = temp;
                    new_iter = true;
                    break;
                end
            end
        end
        % switch true
        %     case cal_delay(players_SAAD-1, players_SBBD+1, players_SAABBD, players_SD)(1)
        % end
        % Find the path with the minimum delay and check for best response
        % [min_delay, min_delay_path] = min([delay_SAAD, delay_SBBD, delay_SAABBD, delay_SD]);
        % 
        % % Reset the number of players on each path
        % players_SAAD = 0;
        % players_SBBD = 0;
        % players_SAABBD = 0;
        % players_SD = 0;
        % 
        % % Distribute players according to the best response
        % if min_delay_path == 1
        %     players_SAAD = M;
        % elseif min_delay_path == 2
        %     players_SBBD = M;
        % elseif min_delay_path == 3
        %     players_SAABBD = M;
        % else
        %     players_SD = M;
        % end
        % 
        % % Update the delays for the next iteration
        % delay_SA = 15 + (players_SAAD + players_SAABBD) / 10;
        % delay_SB = 15 + players_SBBD / 8;
        % delay_AD = 10 + players_SAAD / 20;
        % delay_SAAD = delay_SA + delay_AD;
        % delay_SBBD = delay_SB + delay_BD;
        % delay_SAABBD = delay_SA + delay_AB + delay_BD;
        % 
        % % Update the potential for the next iteration
        % new_potential = players_SAAD * delay_SAAD + players_SBBD * delay_SBBD + ...
        %                 players_SAABBD * delay_SAABBD + players_SD * delay_SD;
        
        % Check for convergence (no players move)

        players_SAAD, players_SBBD, players_SAABBD, players_SD = cal_num_players(action_matrix_update);
        [delay_SAAD_new, delay_SBBD_new, delay_SAABBD_new,  delay_SD_new, potential_update] =... 
        cal_delay(players_SAAD, players_SBBD, players_SAABBD, players_SD);

        if abs(potential_update - potential_new) < 1e-4
            converged = true;
        end
        
        potentials(end) = potential_update; % Update the last potential value
    end
    
    % Return the player distribution at equilibrium
    player_distribution = [players_SAAD, players_SBBD, players_SAABBD, players_SD];
end

function [delay_SAAD, delay_SBBD, delay_SAABBD,  delay_SD, potential_new] =... 
        cal_delay(players_SAAD, players_SBBD, players_SAABBD, players_SD)
    
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

function [players_SAAD, players_SBBD, players_SAABBD, players_SD] =... 
        cal_num_players(action_matrix)
    players_SAAD = 0;
    players_SBBD = 0;
    players_SAABBD = 0;
    players_SD = 0;
    for i = 1:size(action_matrix)
        switch action_matrix(i)
            case 1
                players_SAAD = players_SAAD + 1;
            case 2
                players_SBBD = players_SAAD + 1;
            case 3
                players_SAABBD = players_SAAD + 1;
            otherwise
                players_SD = players_SAAD + 1;
        end
    end
end