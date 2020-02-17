accuracy = zeros(100, 1);

for num_eig = 1:100
    accuracy(num_eig) = face_recognition(num_eig);
end

plot(accuracy, 'b*')