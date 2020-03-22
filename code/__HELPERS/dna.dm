//////////////////////////////////////////////////////////
//A bunch of helpers to make genetics less of a headache//
//////////////////////////////////////////////////////////

#define GET_INITIALIZED_MUTATION(A) GLOB.all_mutations[A]
#define GET_GENE_STRING(A, B) (B.mutation_index[A])
#define GET_SEQUENCE(A) (GLOB.full_sequences[A])
#define GET_MUTATION_TYPE_FROM_ALIAS(A) (GLOB.alias_mutations[A])

