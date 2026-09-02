function scan1 = rotate_data_set(scan2, A, channel_names)

    % scan2 is F x N (complex)
    [~, N] = size(scan2);
%     if N ~= A*(A-1)
%         error('Expected %d channels (%d*%d). Got %d', A*(A-1),(A),(A-1),N);
%     end
    
    % Build original channel order (rx, tx) as before
    pairs = channel_names;
    
    % Rotate both rx and tx by +1 modulo to A
    rot_pairs = mod(pairs,A) + 1;
    
    % Create output
    scan1 = zeros(size(scan2));
    
    % Map rotated pairs back into the same ordering
    for oldIdx = 1:N
        target = rot_pairs(oldIdx,:);
        % find where this rotated pair sits in the original ordering
        newIdx = pairs(:,1)==target(1) & pairs(:,2)==target(2);
        scan1(:,newIdx) = scan2(:,oldIdx);
    end

end