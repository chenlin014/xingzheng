{
	if (length($2) == 2) {
		printf("%s\t%s\t%s\n", $1, $2,
		       $2substr($2,length($2)))
	} else {
		print $1"\t"$2
	}
}
