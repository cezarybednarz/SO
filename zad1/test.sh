make gen
./cmp
make dcl_easy
make ref

for i in `seq 1 10000`
do
    echo "test"$i;
    ./gen $i 10000 > moj.a;
    ./ref $(cat przyklady/_test_0_2.key) < moj.a > moj.b;
    ./dcl $(cat przyklady/_test_0_2.key) < moj.a > wzo.b; 
    diff moj.b wzo.b;
done
