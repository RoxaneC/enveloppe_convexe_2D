% usage : matrix = chemin_convexe_bas(p1, p2, X, Y)
%
% Par récurrence, renvoie le chemin des points formant le bas de l'enveloppe
% convexe du groupe de points de coordonnées (X,Y) et passant en dessous du
% segment [p1;p2]

% Version : 1.1
% Author : Cellier R.

function chemin = chemin_convexe_bas(p1, p2, X, Y)
  % voir equation_cartesienne
  [coeff_dir, const] = equation_cartesienne(p1,p2);
  
  % on ne considère plus dans le groupe à tester les points formants la droite cartésienne
  X_test = X;
  Y_test = Y;
  x_p1 = find(X==p1(1))(1);
  x_p2 = find(X==p2(1))(1);
  y_p1 = find(Y==p1(2))(1);
  y_p2 = find(Y==p2(2))(1);
  X_test(x_p1) = [];
  X_test(x_p2) = [];
  Y_test(y_p1) = [];
  Y_test(y_p2) = [];
  % calcule le nombre de points placés strictement en dessous du segment [p1;p2]
  hors_connexe = sum(Y_test < (X_test.*coeff_dir +const));
  
  if hors_connexe == 0
    % s'il n'y a aucun point en dessous du segment, renvoie simplement le segment [p1;p2]
    chemin = [p1;p2];
  elseif hors_connexe == 1
    % s'il n'y a qu'un point en dessous du segment, on l'ajoute directement, puis
    % on renvoie le nouveau chemin [p1;new;p2]
    x_new = X_test(Y_test < (X_test.*coeff_dir +const));
    y_new = Y_test(Y_test < (X_test.*coeff_dir +const));
    chemin = [p1;[x_new, y_new];p2];
  else
    % s'il y a plusieurs points en dessous du segment, on stocke leurs coordonnées
    % dans un tableau auxiliaire, et l'on initialise le tableau distance
    distances = 0;
    X_aux = X_test(Y_test < (X_test.*coeff_dir +const));
    Y_aux = Y_test(Y_test < (X_test.*coeff_dir +const));
    
    for i = 1:hors_connexe
      % voir projete_ortho
      [x_proj,y_proj] = projete_ortho([X_aux(i),Y_aux(i)],p1,p2);
      
      % on calcule la distance des points hors convexe à leurs projetés orthogonaux
      % sur le segment que l'on étudie
      distances(i) = sqrt( (X_aux(i)-x_proj)^2 + (Y_aux(i)-y_proj)^2 );
    endfor
    
    % on ne considère que le point ayant la plus grande distance avec son projeté
    % orthogonal sur le segment [p1;p2]
    x_new = X_aux(max(distances) == distances);
    y_new = Y_aux(max(distances) == distances);
    % en cas d'égalité, on ne garde arbitrairement que le premier point trouvé
    % ayant la plus grande distance
    nouv_p = [x_new(1), y_new(1)];
    
    % par récurrence on cherche les points à ajouter à chaque nouveau segment
    new_cheminG = chemin_convexe_bas(p1, nouv_p, X, Y);
    new_cheminD = chemin_convexe_bas(nouv_p, p2, X, Y);
    
    % on renvoie le chemin final trouvé entre les points p1 et p2 (en supprimant le doublon)
    chemin = [new_cheminG(1:end-1,:);new_cheminD];
  end
endfunction
