// Global reference for checksum routines
// USAGE: #include "<relative-path-to-this-file>/checksum_ref.c"

// Checksum calculations 
// WARNING: DO NOT ACCESS ARRAY OUT OF BOUNDS 
// ***SAFE*** USAGE: check_a((char *)obj,sizeof(obj)); check_b((char *)obj,sizeof(obj)); 

unsigned char check_a(char * data, size_t n) {
        int i;
        unsigned char chka = 0x00;
        for (i = 0; i < n; i++) chka += data[i];
        return chka;
}

unsigned char check_b(char * data, size_t n) {
        int i;
        unsigned char chkb = 0x00;
        for (i = 0; i < n; i++) chkb += (n-i) * data[i];
        return chkb;
}
