import print_utils
process Main(){
    var x : box<int>;
    {
        x = box(3);
        *x = *x + 1;
        print_int(*x); 
        print_newline();
        drop(x)
    }
    * x = * x + 1;
    print_int(*x); print_newline()
}