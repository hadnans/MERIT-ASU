function [process_signals] = DMAS()
  % Assumes window x channels x points x ...

  function [energies] = process_(dsig)
    tmp = 0.5 * (sum(dsig, 2).^2 - sum(dsig.^2, 2));
    energies = shiftdim(sum(tmp.^2, 1), 2);
  end

  process_signals = @process_;
end
