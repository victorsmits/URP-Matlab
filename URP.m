function comp  = URP(L,nbrvar)

% Etape 1
if isempty(L)
    comp = ones(1,nbrvar)*3;
    return;
end

% Etape 2
ADCC = ones(1,nbrvar)*3; % AllDontCareCube
i = 1;
while i <= size(L,1)
    if L(i,:) == ADCC
        comp = [];
        return;
    end
    i=i+1;
end

% Etape 3
if size(L,1) == 1
    nbrvarbis = nbrvar;
    comp = ones(nbrvarbis,nbrvar)*3;
    n = 1; % ligne
    m = 1; % colone
    while n <= nbrvarbis && m <= nbrvar
        switch L(1,m)
            case 3
                comp(n,:)=[];
                nbrvarbis = nbrvarbis-1;
                m= m+1;
            case 2
                comp(n,m)= 1;
                n= n+1;
                m= m+1;
            case 1
                comp(n,m)= 2;
                n= n+1;
                m= m+1;
        end
    end
    return;
end

% Etape 4
% check if f is biforme
% bif = ones(size(L,1),1);
status = zeros(1,nbrvar);
y = 1;
while y<= nbrvar
    % si une colonne contient uniquement des 1 ==> 2 et 1 sont présent
    % dans la colonne et donc que la variable est biforme
    Mat_Check3 = L(:,y)==2 | L(:,y)==3;
    if nnz(Mat_Check3) ~= 0
        status(1,y) = 1;
    end
    y = y+1;
end

val = 0;
if status == zeros(1,nbrvar) % f est monoform
    % val est la colonne avec le plus de 1 ou de 2 possèdant l'indexe
    % le plus petit
    a = 1;
    count1 = 0;
    count12 = 0;
    count2 = 0;
    count22 = 0;
    while a <= nbrvar
        Mat1 = L(:,a)==2; % matrice colonne 1 si valeur == 2 sinon 0
        Mat2 = L(:,a)==1; % matrice colonne 1 si valeur == 1 sinon 0
        % compare le nombre de 1 dans la colonne 1 avec count1
        % et compare le nombre de 1 dans la colonne2 avec count2
        % true si une des 2 comparaison est bonne => si le nombre de
        % 1 est plus grand que le count1 ou le nombre de 2 est plus
        % grand que le count2
        if nnz(Mat1)> count1
            % update les count
            count1 = nnz(Mat1);
            if count1 ~= count12
                val = a;
            end
            count12 = count1;
        end
        if nnz(Mat2)> count2
            count2 = nnz(Mat2);
            if count2 ~= count22
                val = a;
            end
            count22 = count2;
        end
        a =a +1;
    end
    
else % f est biforme
    % val est la colonne avec le plus de 1 et de 2
    % possèdant l'indexe le plus petit
    a = 1;
    count2 = 0;
    count = 0;
    while a <= nbrvar
        % matrice de 1 si vla = 1 ou 2 le reste fait de 0
        Mat = L(:,a)==2 | L(:,a)==1;
        % compare le nombre de 1 dans la colonne avec count
        if nnz(Mat)> count
            count = nnz(Mat);
            if count ~= count2
                val = a;
            end
            count2 = count;
        end
        a =a +1;
    end
    
end

% Etape 5
% création des cofacteur posistif et negatif. il depende de l'index de la
% variable qui a été sélectionner au par avant. 
% Pour le cofacteur Positif (cofP) on change la variable par un 1 logique
% et on observe la sortie, pour le cofacteur négatif (cofN) on change 
% la variable par un 0 logique et on observe à nouveau la sortie. Ensuite
% on change la variable par un don't care dans les 2 matrices.
cofP = zeros(size(L,1),nbrvar);
cofN = zeros(size(L,1),nbrvar);
lineN = 1;
lineP = 1;
line = 1 ;
while line <= size(L,1)
    switch L(line,val)
        case 1
            cofP(lineP,:) = L(line,:);
            cofP(lineP,val) = 3;
            cofN(lineN,:) = [];
            lineP = lineP +1;
        case 2
            cofN(lineN,:) = L(line,:);
            cofN(lineN,val) = 3;
            cofP(lineP,:) = [];
            lineN = lineN +1;
        case 3
            cofN(lineN,:) = L(line,:);
            cofP(lineP,:) = L(line,:);
            lineP = lineP +1;
            lineN = lineN +1;
    end
    line = line+1;
end

% Etape 6
cofP = URP(cofP,nbrvar);
cofN = URP(cofN,nbrvar);
% pour effectuer un ET logique 
cofP(:,val) = ones(size(cofP,1),1); 
cofN(:,val) = ones(size(cofN,1),1)*2;
% pour effectuer un OU logique
% j'effectue les vérification suivant afin d'éviter les warning d'execution
% pendant la concaténation verticale.
if isempty(cofP)
    comp = cofN;
elseif isempty(cofN)
    comp = cofP;
else
    comp = [cofP;cofN];
end
return;
end
