import print_utils
method g<S>(a : S) : S {
    return a;
}

method f<L,X,Z>(a : L, b : X, c:Z) : L {
    return g(b) + a;
}

process Main(){
    print_int(f(g(1), 2, 2.1));    
}
