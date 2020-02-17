function accuracy = face_recognition(num_eig, use_smiles, show_faces)
    if nargin < 1
        % specify number of eigenvectors to use
        num_eig = 16;
    end
    
    if nargin < 2 || use_smiles == 1
        load('data/classdata_smile.mat')
        load('data/classdata_no_smile.mat')
    else
        load('data/classdata_train.mat')
        load('data/classdata_test.mat')
    end
    
    if nargin < 3
        show_faces = 0;
    end

    % flatten images into vectors
    train = reshape(grayfaces_train, size(grayfaces_train, 1) * size(grayfaces_train, 2), size(grayfaces_train, 3));
    test = reshape(grayfaces_test, size(grayfaces_test, 1) * size(grayfaces_test, 2), size(grayfaces_test, 3));

    % get covariance matrix
    train_adj = train - mean(train);
    R_train = train_adj * train_adj';

    % get eigenvectors of the covariance matrix
    [v, ~] = eigs(R_train, num_eig);

    if show_faces
        for i = 1 : num_eig
            subplot(ceil(sqrt(num_eig)), ceil(sqrt(num_eig)), i);
            imagesc(reshape(v(:,i), [64 64]));
            colormap('gray');
        end
    end

    % get faces in face space
    train_facespace = v' * train;
    test_facespace = v' * test;

    % nearest neighbor search
    % grabbed this from the solutions
    % this compares the faces from the test set and finds the closest
    % representation from the training set
    NN = knnsearch(test_facespace', train_facespace');

    % check accuracy
    accuracy = mean(subject_train(NN) == subject_test);
end