function M = func_cellToMatrix(A,B)

    NFrames = length(A);  % Asumimos que todos los cell arrays tienen el mismo largo
    AllData = cell(NFrames, 1);
    FrameIndices = cell(NFrames, 1);

    for k = 1:NFrames
        % Convertir celdas a matrices y concatenarlas horizontalmente
        AllData{k} = [A{k}, B{k}];
        
        % Generar índice de frame
        NDetections = size(A{k}, 1);
        FrameIndices{k} = repmat(k, NDetections, 1);
    end

    % Concatenar todo en una única matriz
    M = [cell2mat(AllData), cell2mat(FrameIndices)];
end
