function Image = func_getMean_nd2(reader)
    N = reader.getSizeT;
    Matrix_sum = zeros(size(bfGetPlane(reader,1)));
    pw = PoolWaitbar(N, 'computing average...');
    parfor i = 1:N
        MatrixSlice = double(bfGetPlane(reader,i));
        Matrix_sum = Matrix_sum + MatrixSlice;
        increment(pw)
    end
    Matrix = Matrix_sum/N;
    Image = uint16(Matrix);
end