/* Brep, Binary Regular Expression Program
   Copyright (C) 2005 Eric Hennigan, Erik van Bronkhorst
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.
*/
#include <sys/stat.h>
#include <fcntl.h>
#include <regex.h>
#include <stdio.h>
#include <stdlib.h>
#include <argp.h>

#define REG_COMP_ERR -1

#define BUFSIZE 32768
#define MAX_MATCHES 32768
#define OVERLAP 1024

#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))

	const char *argp_program_version = "brep 1.0";
	const char *argp_program_bug_address = "<the.theorist@gmail.com>";
	static char doc[] =
		"Search for PATTERN in each FILE or standard input.\n\
Example: brep -i \"[0-9]*W[0-9]*N\" geo_cords.o";
	static char args_doc[] = "PATTERN FILE1 [FILES...]";

	static struct argp_option options[] = {
		{"head-size",            'h', "NUM", OPTION_ARG_OPTIONAL,  "Search only beginning NUM (default 1024) chars of input"},
		{"tail-size",            't', "NUM", OPTION_ARG_OPTIONAL,  "Search only last NUM (default 1024) chars of input"},
		{0,0,0,0, "Output Control:"},
		{"dirty",                'd', 0,     0,  "Dirty output"},
		{"after-context",        'a', "NUM", OPTION_ARG_OPTIONAL,  "Print NUM (default 10) chars after match"},
		{"before-context",       'b', "NUM", OPTION_ARG_OPTIONAL,  "Print NUM (default 10) chars before match"},
		{"char-number-begin",    'n', 0,     0,  "Print char number with output"},
		{"char-number-end",      'N', 0,     0,  "Print char number with output"},
		{"with-filename",        'f', 0,     0,  "Print the filename with each match"},
		{"files-with-matches",   'l', 0,     0,  "Print only FILE names containing matches"},
		{"files-without-matches",'L', 0,     0,  "Print only FILE names containing no matches"},
		{0,0,0,0, "Match Control:"},
		{"ignore-case",          'i', 0,     0,  "Case-insensitive search"},
		{"max-count",            'm', "NUM", 1,  "Stop after NUM matches"},
		{ 0 }
	};
	
	/* Used by main to communicate with parse_opt. */
	struct arguments {
		char *pattern;                /* PATTERN */
		char **files;                 /* [FILES...] */
		int out_after, out_before;    /* `-a', `-b' */
		int head_size, tail_size;     /* `-h', `-t' */
		int ignore_case;              /* `-i' */
		int out_charN, out_charn;     /* `-N', `-n' */
		int list_files;               /* `-l', `-L' */
		int max_matches;              /* `-m' */
		int out_filename;             /* `-f' */
		int out_dirty;                /* `-d' */
	} arguments;
	
	/* We read the file in pieces */
	struct buffer {
		char *string;
		int str_size;
		off_t filepos, absbeg, absend;
		regmatch_t bigmatch;
		int max_fill;
		int nfills;
	} buffer;

/************************************************************************/
/*                           parse_opt()                                */
/*    Parse a single option                                             */
/************************************************************************/
static error_t parse_opt (int key, char *arg, struct argp_state *state) {
	/* Get the input argument from argp_parse, which we
	know is a pointer to our arguments structure. */
	struct arguments *arguments = state->input;
	
	switch (key) {
		case 'a':
			arguments->out_after = arg ? atoi(arg) : 10;
			break;
		case 'b':
			arguments->out_before = arg ? atoi(arg) : 10;
			break;
		case 'i':
			arguments->ignore_case = 1;
			break;
		case 'n':
			arguments->out_charn = 1;
			break;
		case 'N':
			arguments->out_charN = 1;
			break;
		case 'h':
			arguments->head_size = arg ? atoi(arg) : 1024;
			break;
		case 't':
			arguments->tail_size = arg ? atoi(arg) : 1024;
			break;
		case 'l':
			arguments->list_files = 1;
			break;
		case 'L':
			arguments->list_files = -1;
			break;
		case 'm':
			arguments->max_matches = arg ? atoi(arg) : MAX_MATCHES;
			break;
		case 'f':
			arguments->out_filename = 1;
			break;
		case 'd':
			arguments->out_dirty = 1;
			break;

		case ARGP_KEY_NO_ARGS:
			argp_usage (state);
		
		case ARGP_KEY_ARG:
			/* Here we know that state->arg_num == 0, since we
			force argument parsing to end before any more arguments can
			get here. */
			arguments->pattern = arg;
		
			/* Now we consume all the rest of the arguments.
			state->next is the index in state->argv of the
			next argument to be parsed, which is the first string
			we're interested in, so we can just use
			&state->argv[state->next] as the value for
			arguments->files.
		
			In addition, by setting state->next to the end
			of the arguments, we can force argp to stop parsing here and
			return. */
			arguments->files = &state->argv[state->next];
			state->next = state->argc;
			break;
		
		default:
			return ARGP_ERR_UNKNOWN;
		}
	return 0;
}
	/* Our arg parser */
	static struct argp argp = { options, parse_opt, args_doc, doc };

/************************************************************************/
/*                            fillbuffer()                              */
/*  Fills the buffer.                                                   */
/*   If first time through then fill directly from file;                */
/*   Otherwise, move last 1024 bytes from end of buffer to beginning,   */
/*     and fill from there.                                             */
/*  Returns 1 if we read anything new, 0 otherwise                      */
/************************************************************************/
int fillbuffer( FILE *fid ) {
	int bufsize, bufsize2, j;
	
	if ( !buffer.nfills ) {
		buffer.filepos = ftello( fid );
		
		bufsize = fread( buffer.string, 1, buffer.str_size, fid );
		for( j=0; j<bufsize; j++)
			if( buffer.string[j] < ' ' )
				buffer.string[j] = ' ';
		buffer.string[bufsize]='\0';

		if (buffer.max_fill && buffer.max_fill < buffer.str_size) {
			buffer.string[buffer.max_fill] = '\0';
			fseeko( fid, 0, SEEK_END );
		}
	}
	else {
		memcpy( buffer.string, &buffer.string[buffer.str_size-OVERLAP], OVERLAP );
		bufsize = fread( &buffer.string[OVERLAP], 1, buffer.str_size-OVERLAP, fid );
		buffer.filepos = buffer.filepos+buffer.str_size-OVERLAP;
		
		for( j=OVERLAP; j<bufsize; j++)
			if( buffer.string[j] < ' ' )
				buffer.string[j] = ' ';
		buffer.string[OVERLAP+bufsize] = '\0';
		
		if( buffer.max_fill && buffer.max_fill < buffer.str_size + buffer.nfills*(buffer.str_size-OVERLAP) ) {
			/*buffer.string[buffer.str_size + buffer.nfills*(buffer.str_size-OVERLAP) - buffer.max_fill] = '\0';*/
			fseeko( fid, 0, SEEK_END );
		}
	}
	
	if (bufsize == 0)
		return 0;
	else {
		buffer.nfills++;
		return 1;
	}	
}


/************************************************************************/
/*                           print_match()                              */
/************************************************************************/
void print_match(int i, FILE *fid, regmatch_t match) {
	int size, j;
	off_t pos;
	char *s;
	int beg = buffer.filepos+match.rm_so;
	int end = buffer.filepos+match.rm_eo;
	
	if(arguments.out_filename)
		printf("%s:",arguments.files[i]);
	if(arguments.out_charn)
		printf("%d:",beg+1);
	if(arguments.out_charN)
		printf("%d:",end);
	if(arguments.out_before)
		beg = MAX(buffer.absbeg, beg-arguments.out_before);
	if(arguments.out_after)
		end = MIN(buffer.absend, end+arguments.out_after);
	
	pos = ftello( fid );
	fseeko(fid, beg, SEEK_SET);
		s = (char *)malloc(end-beg+1);
		size = fread(s, 1, end-beg, fid);
		s[size] = '\0';
	fseeko(fid, pos, SEEK_SET);
	
	if(!arguments.out_dirty) {
		for(j=0;j<size;j++)
			if (s[j] < ' ')
				s[j] = ' ';
	}

	printf("%s\n",s);
	free(s);
}

/************************************************************************/
/*                                main()                                */
/************************************************************************/
int main (int argc, char **argv) {
	FILE *fid;
	int i, j, err;
	int stop_filling, stop_matching, file_matched, nmatches;
	size_t nbytes; /*grabs the regerr size for errbuf allocation */
	char *errbuf;
	ssize_t bufsize;
	regex_t reg;
	regmatch_t match,previous_match;
	
	/* Default values. */
	arguments.out_after = 0;
	arguments.out_before = 0;
	arguments.ignore_case = 0;
	arguments.out_charn = 0;
	arguments.out_charN = 0;
	arguments.out_dirty = 0;
	arguments.head_size = 0;
	arguments.tail_size = 0;
	arguments.list_files = 0;
	arguments.max_matches = MAX_MATCHES;
	arguments.out_filename = 0;
	
	/* Parse our arguments; every option seen by parse_opt will be
	   reflected in arguments. */
	argp_parse (&argp, argc, argv, 0, 0, &arguments);

	/*printf ("PATTERN = %s\n", arguments.pattern);
	printf ("FILES = ");
	for ( i=0; arguments.files[i]; i++)
		printf (i == 0 ? "%s" : ", %s", arguments.files[i]);
	printf ("\n");
	printf ("Ignore-case = %s\ncharn = %s\ncharN = %s\nAfter = %d\nBefore = %d\nhead = %d\ntail = %d\nlist_files = %d\nmax_matches = %d\n",
		arguments.ignore_case ? "yes" : "no",
		arguments.out_charn ? "yes" : "no",
		arguments.out_charN ? "yes" : "no",
		arguments.out_after,
		arguments.out_before,
		arguments.head_size,
		arguments.tail_size,
		arguments.list_files,
		arguments.max_matches );*/
	
	/* Options Sanity Check */
	
	/* Setup structures */
	buffer.str_size = MAX(BUFSIZE, MAX(arguments.out_before, arguments.out_after+OVERLAP));
	buffer.string = (char *)malloc(buffer.str_size + 1);
	buffer.max_fill = 0;
	
	/* compile regexp */
	if(arguments.ignore_case)
		err = regcomp(&reg, arguments.pattern, REG_EXTENDED|REG_ICASE);
	else
		err = regcomp(&reg, arguments.pattern, REG_EXTENDED);
	if (err) {
		nbytes = regerror( err, &reg, (char *)NULL, (size_t)0);
		errbuf = (char *) malloc( nbytes );
		regerror( err, &reg, errbuf, nbytes );
		fprintf( stderr, "error %d compiling RE: \'%s\'\n%s\n", err, arguments.pattern, errbuf );
		free( errbuf );
		exit(-1);
	}
	
	/* hunt through all the files */
	for( i=0; arguments.files[i]; i++) {
		fid = fopen( arguments.files[i], "rb" );
		
		if (!fid) {
			fprintf( stderr, "error opening %s\n", arguments.files[i] );
			continue;
		}
		if(arguments.tail_size) {
			fseeko(fid, -arguments.tail_size, SEEK_END);
			buffer.filepos = buffer.absbeg = ftello( fid );
		}
		else
			fseeko( fid, 0, SEEK_SET ); buffer.filepos = buffer.absbeg = ftello( fid );
		if(arguments.head_size) {
			buffer.max_fill = arguments.head_size;
			buffer.absend = buffer.absbeg + buffer.max_fill;
		}
		else
			fseeko( fid, 0, SEEK_END ); buffer.absend = ftello( fid );
		fseeko( fid, buffer.filepos, SEEK_SET );
		
		
		nmatches = 1;
		file_matched = 0;
		stop_filling = 0;
		stop_matching = 0;
		buffer.nfills = 0;
		buffer.bigmatch.rm_so = -1;
		buffer.bigmatch.rm_eo = -1;
		while ( fillbuffer( fid ) && nmatches <= arguments.max_matches && !stop_filling) {
			match.rm_so = 0;
			match.rm_eo = 0;

			/* find matches loop */
			do {
				previous_match = match;
				err = regexec( &reg, &(buffer.string[previous_match.rm_eo]), 1, &match, REG_NOTBOL);
				match.rm_eo = previous_match.rm_eo + match.rm_eo;
				match.rm_so = previous_match.rm_eo + match.rm_so;
				
				if ( err == 0 ) { /*have a match*/
					file_matched = 1;
					nmatches++;

					if( arguments.list_files == 0 && (buffer.bigmatch.rm_so < buffer.filepos+match.rm_so) ) {
						buffer.bigmatch.rm_so = MAX( buffer.bigmatch.rm_so, buffer.filepos+match.rm_so );
						buffer.bigmatch.rm_eo = MAX( buffer.bigmatch.rm_eo, buffer.filepos+match.rm_eo );
						print_match(i, fid, match);
					}
					if( arguments.list_files == 1) /*print only file name of matches*/
						stop_matching = stop_filling = 1;
				}
				else if (err < 0 || 1 < err){ /*something really bad happened*/
					nbytes = regerror( err, &reg, (char *)NULL, (size_t)0);
					errbuf = (char *) malloc( nbytes );
					regerror( err, &reg, errbuf, nbytes );
					fprintf( stderr, "error %d executing RE: \'%s\'\n%s\n", err, arguments.pattern, errbuf );
					free( errbuf );
					exit(-1);
				}
			} while( err != 1 && nmatches <= arguments.max_matches && !stop_matching);
		}
		
		if(file_matched && arguments.list_files == 1) /*print only file name of matches*/
			printf( "%s\n", arguments.files[i] );
		if(!file_matched && arguments.list_files == -1) /*print only file name of non-matches*/
			printf( "%s\n", arguments.files[i] );
		
		fclose(fid);
	}
	
	return 0;
}

