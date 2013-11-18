/* Bep, Binary Stream Editor
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

#define MAX_REPS 32768

	const char *argp_program_version = "bed 1.0";
	const char *argp_program_bug_address = "<the.theorist@gmail.com>";
	static char doc[] =
		"Substitute PATTERN with REPLACEMENT as FIN is copied to FOUT";
	static char args_doc[] = "\"[start,end][,skip]/PATTERN/REPLACEMENT/\" FIN FOUT";
	
	static struct argp_option options[] = {
		/*{0,0,0,0, "Output Control:"},*/
		{"head-size",            'h', "NUM",  OPTION_ARG_OPTIONAL, "Copy over only first NUM chars"},
		{"tail-size",            't', "NUM",  OPTION_ARG_OPTIONAL, "Copy over only last NUM chars"},
		{"after-padding",        'a', "TEXT", OPTION_ARG_OPTIONAL, "Pad REPLACEMENT by appending TEXT"},
		{"before-padding",       'b', "TEXT", OPTION_ARG_OPTIONAL, "Pad REPLACEMENT by prepending TEXT"},
		{"chop",                 'c', "NUM",  OPTION_ARG_OPTIONAL, "Force REPLACEMENT to fit in NUM chars (default sizeof(PATTERN))"},
		{0,0,0,0, "Match Control:"},
		{"ignore-case",          'i', 0,      0, "Case-insensitive matching"},
		{ 0 }
	};
	
	/* Used by main to communicate with parse_opt. */
	struct arguments {
		char *command;    /* [start,end][,skip]/PATTERN/REPLACEMENT/ */
		char *fin;        /* FIN */
		char *fout;       /* FOUT */
		int ignore_case;  /* `-i' */
		int head_size;    /* `-h' */
		int tail_size;    /* `-t' */
		char *after;      /* `-a' */
		char *before;     /* `-b' */
		int chop;         /* `-c' */
	} arguments;
	
	struct buffer {
		char *clean;
		off_t filepos;
		long size;
	} buffer;
	
	struct command {
		char *pattern;
		char *replace;
		int start, end, skip;
	} command;

/************************************************************************/
/*                           parse_opt()                                */
/*    Parse a single option                                             */
/************************************************************************/
static error_t parse_opt (int key, char *arg, struct argp_state *state) {
	/* Get the input argument from argp_parse, which we
	know is a pointer to our arguments structure. */
	struct arguments *arguments = state->input;
	
	switch (key) {
		case 'h':
			arguments->head_size = arg ? atoi(arg) : 1024;
			break;
		case 't':
			arguments->tail_size = arg ? atoi(arg) : 1024;
			break;
		case 'a':
			arguments->after = arg;
			break;
		case 'b':
			arguments->before = arg;
			break;
		case 'c':
			arguments->chop = arg ? atoi(arg) : -1;
			break;
		case 'i':
			arguments->ignore_case = 1;
			break;
		
		case ARGP_KEY_NO_ARGS:
			argp_usage (state);
		
		case ARGP_KEY_ARG:
			/* Here we know that state->arg_num == 0, since we
			force argument parsing to end before any more arguments can
			get here. */
			arguments->command = arg;
		
			/* Now we consume all the rest of the arguments.
			state->next is the index in state->argv of the
			next argument to be parsed, which is the first string
			we're interested in, so we can just use
			&state->argv[state->next] as the value for
			arguments->files.
		
			In addition, by setting state->next to the end
			of the arguments, we can force argp to stop parsing here and
			return. */
			arguments->fin = state->argv[state->next];
			arguments->fout = state->argv[state->next+1];
			/*arguments->files = &state->argv[state->next];*/
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
/*                          parse_command()                             */
/*    Parse [start,end][,skip]/PATTERN/REPLACEMENT/                     */
/************************************************************************/
void parse_command(char *c) {
	int i,j,err;
	regex_t reg;
	size_t nbytes; /*grabs the regerr size for errbuf allocation */
	char *errbuf;
	regmatch_t match[6];
	char *pattern = "^([0-9]*),*([0-9]*),*([0-9]*)/(.*)/(.*)/";
	char s[sizeof(c)];
	
	err = regcomp(&reg, pattern, REG_EXTENDED|REG_ICASE);
	if (err) {
		nbytes = regerror( err, &reg, (char *)NULL, (size_t)0);
		errbuf = (char *) malloc( nbytes );
		regerror( err, &reg, errbuf, nbytes );
		fprintf( stderr, "error %d parsing command: \'%s\'\n%s\n", err, c, errbuf );
		free( errbuf );
		exit(-1);
	}
	
	err = regexec( &reg, c, 6, match, 0);
	if (err == 0) { /*have matched*/
		/*for ( i=0; i<6; i++ ) {
			printf("match%d %d,%d\t\t",i,match[i].rm_so,match[i].rm_eo);
			for ( j=match[i].rm_so; j<match[i].rm_eo; j++)
				printf("%c",c[j]);
			printf("\n");
		}*/
		
		for ( i=0, j=match[1].rm_so; j<match[1].rm_eo; i++, j++)
			s[i] = c[j];
		s[i] = '\0';
		command.start = atoi(s) ? atoi(s) : 0;
		
		for ( i=0, j=match[2].rm_so; j<match[2].rm_eo; i++, j++)
			s[i] = c[j];
		s[i] = '\0';
		command.end = atoi(s) ? atoi(s) : MAX_REPS;
		
		for ( i=0, j=match[3].rm_so; j<match[3].rm_eo; i++, j++)
			s[i] = c[j];
		s[i] = '\0';
		command.skip = atoi(s) ? atoi(s) : 1;
		
		command.pattern = (char *)malloc(match[4].rm_eo-match[4].rm_so+1);
		for ( i=0, j=match[4].rm_so; j<match[4].rm_eo; i++, j++)
			command.pattern[i] = c[j];
		command.pattern[i] = '\0';
		
		command.replace = (char *)malloc(match[5].rm_eo-match[5].rm_so+1);
		for ( i=0, j=match[5].rm_so; j<match[5].rm_eo; i++, j++)
			command.replace[i] = c[j];
		command.replace[i] = '\0';
		
		/*printf("c.start = %d\nc.end = %d\nc.skip = %d\nc.pattern = %s\nc.replacement = %s\n\n",
			command.start,
			command.end,
			command.skip,
			command.pattern,
			command.replace );*/
	}
	else {
		fprintf( stderr, "error parsing command: \'%s\'\n", c );
		exit(-1);
	}	
}

/************************************************************************/
/*                           fill_buffer()                              */
/*  Fills both clean and dirty buffers.                                 */
/************************************************************************/
void fill_buffer( FILE *fid ) {
	int i, size;
	off_t end, beg;

	fseeko( fid, 0, SEEK_END ); end = ftello( fid );
	fseeko( fid, 0, SEEK_SET ); beg = ftello( fid );

	if(arguments.tail_size) {
		fseeko(fid, -arguments.tail_size, SEEK_END);
		beg = ftello( fid );
	}
	if(arguments.head_size) {
		fseeko( fid, arguments.head_size, SEEK_CUR);
		end = ftello( fid );
	}
	
	buffer.clean = (char *)malloc( end-beg+1 );
	if ( !buffer.clean ) {
		fprintf( stderr, "error allocating memory for buffer\n" );
		exit(-3);
	}

	fseeko( fid, beg, SEEK_SET );
	buffer.filepos = ftello( fid );
	size = fread( buffer.clean, 1, end-beg, fid );
	if (size < end-beg ) {
		fprintf( stderr, "error reading in buffer\n" );
		exit(-3);
	}
	buffer.size = size;
	
	for( i=0; i<size; i++)
		if (buffer.clean[i] < ' ' )
			buffer.clean[i] = ' ';
	buffer.clean[i] = '\0';
	fseeko(fid, beg, SEEK_SET);
}

/************************************************************************/
/*                                htoi()                                */
/* Convert 2 char hex string to an ascii char                           */
/************************************************************************/
unsigned char htoi (char *s) {
	int i;
	unsigned char ret=0;
	
	for ( i=0; i<2; i++ )
		switch (s[i]) {
			case 'f':
			case 'F':
				ret += 15*( i ? 1 : 16 );
				break;
			case 'e':
			case 'E':
				ret += 14*( i ? 1 : 16 );
				break;
			case 'd':
			case 'D':
				ret += 13*( i ? 1 : 16 );
				break;
			case 'c':
			case 'C':
				ret += 12*( i ? 1 : 16 );
				break;
			case 'b':
			case 'B':
				ret += 11*( i ? 1 : 16 );
				break;
			case 'a':
			case 'A':
				ret += 10*( i ? 1 : 16 );
				break;
			case '9':
				ret += 9*( i ? 1 : 16 );
				break;
			case '8':
				ret += 8*( i ? 1 : 16 );
				break;
			case '7':
				ret += 7*( i ? 1 : 16 );
				break;
			case '6':
				ret += 6*( i ? 1 : 16 );
				break;
			case '5':
				ret += 5*( i ? 1 : 16 );
				break;
			case '4':
				ret += 4*( i ? 1 : 16 );
				break;
			case '3':
				ret += 3*( i ? 1 : 16 );
				break;
			case '2':
				ret += 2*( i ? 1 : 16 );
				break;
			case '1':
				ret += 1*( i ? 1 : 16 );
				break;
			case '0':
				break;
			default:
				fprintf( stderr, "error converting hex %s to integer", s);
				return 0;
		}
	return ret;
}

/************************************************************************/
/*                           write_match()                              */
/*  Parses the grill notation for character insertion on                */
/*    REPLACEMENT, before, and after fields.                            */
/*  Places the filepos of fidi to just after the matching regex         */
/************************************************************************/
void write_match( regmatch_t *match, FILE* fidi, FILE* fido ) {
	int i, j, p;
	char replacement[match[0].rm_eo-match[0].rm_so+sizeof(command.replace)+sizeof(arguments.before)+sizeof(arguments.after)];
	int size = 0;
	
	/*
	for ( i=0; i<10; i++ ) {
		printf("match%d %d,%d\t\t",i,match[i].rm_so,match[i].rm_eo);
		printf("\n");
	}*/
	
	/* scan command.replace finding metachars, and making substutitions */
	for( i=0; command.replace[i]; i++ ) {
		if (command.replace[i] == '\\') {
			char s2[2];
			s2[0] = command.replace[++i];
			s2[1] = '\0';
			p = atoi(s2);
			
			char s[match[p].rm_eo-match[p].rm_so];
			fseeko( fidi, match[p].rm_so, SEEK_CUR);
			fread( s, 1, match[p].rm_eo-match[p].rm_so, fidi );
			fseeko( fidi, match[p].rm_so-match[p].rm_eo, SEEK_CUR );
			
			memcpy( &replacement[size], s, match[p].rm_eo-match[p].rm_so );
			size +=match[p].rm_eo-match[p].rm_so;
		}
		else if (command.replace[i] == '#' ) {
			char s2[3];
			s2[0] = command.replace[++i];
			s2[1] = command.replace[++i];
			s2[2] = '\0';
			
			replacement[size++] = htoi(s2);
		}
		else {
			replacement[size++] = command.replace[i];
		}
	}

/* if chop==0 size modifying substutition
   if chop==1,2,3.... fill/trunc to NUM
   if chop==-1  fill/trunc to sizeof(PATTERN) */

/*write_size = size;
	/* adjust for padding or truncation */
/*	if (arguments.chop < 0)
		write_size = match[0].rm_eo-match[0].rm_so;
	else if (arguments.chop > 0 )
		write_size = arguments.chop
	
	if (write_size < size ) /* truncation */
/*		size = write_size
	else if (write_size > size) { /* padding */
/*		if (arguments.before) { /* pad beginning */
/*			for(
*/
	
	/*printf("TO FILE: ");
	for( i=0; i<size; i++)
		if ( replacement[i] < ' ')
			printf(" ");
		else
			printf( "%c", replacement[i] );
	printf("\n");*/

	/* write replacement, and seek infile to after match occured */
	fwrite( replacement, 1, size, fido );
	fseeko( fidi, match[0].rm_eo-match[0].rm_so, SEEK_CUR );
}


/************************************************************************/
/*                                main()                                */
/************************************************************************/
int main( int argc, char **argv) {
	int i, j, err;
	FILE *fidi, *fido;
	size_t nbytes; /*grabs the regerr size for errbuf allocation */
	char *errbuf;
	size_t bufsize;
	regex_t reg;
	regmatch_t match[10], previous_match;
	
	/* Default values. */
	arguments.ignore_case = 0;
	arguments.head_size = 0;
	arguments.tail_size = 0;
	arguments.chop = 0;
	
	
	/* Parse our arguments; every option seen by parse_opt will be
	   reflected in arguments. */
	argp_parse (&argp, argc, argv, 0, 0, &arguments);
	
	/* Options Sanity Check */
	
	/*
	printf ("COMMAND = %s\n", arguments.command);
	printf ("FIN = %s\n", arguments.fin);
	printf ("FOUT = %s\n",arguments.fout);
	printf ("head-size: %d\ntail-size: %d\nafter: %s\nbefore: %s\nchop: %d\nignore-case: %d\n\n",
		arguments.head_size,
		arguments.tail_size,
		arguments.after,
		arguments.before,
		arguments.chop,
		arguments.ignore_case );*/
	
	parse_command(arguments.command);
	
	/* Setup */
	fidi = fopen( arguments.fin, "rb" );
	if (!fidi) {
		fprintf( stderr, "error opening %s\n", arguments.fin );
		exit(-2);
	}
	
	fido = fopen( arguments.fout, "wb" );
	if (!fido) {
		fprintf( stderr, "error opening %s\n", arguments.fout );
		exit(-2);
	}
	
	fill_buffer(fidi);
	
	/* compile regexp for searching buffer */
	if(arguments.ignore_case)
		err = regcomp(&reg, command.pattern, REG_EXTENDED|REG_ICASE);
	else
		err = regcomp(&reg, command.pattern, REG_EXTENDED);
	if (err) {
		nbytes = regerror( err, &reg, (char *)NULL, (size_t)0);
		errbuf = (char *) malloc( nbytes );
		regerror( err, &reg, errbuf, nbytes );
		fprintf( stderr, "error %d compiling RE: \'%s\'\n%s\n", err, command.pattern, errbuf );
		free( errbuf );
		exit(-1);
	}
	
	/* Perform substutitions */
	match[0].rm_eo = 0;
	match[0].rm_so = 0;
	for( i=1; i<=command.end; i++ ) {
		previous_match.rm_eo = previous_match.rm_eo + match[0].rm_eo;
		previous_match.rm_so = previous_match.rm_so + match[0].rm_so;
		
		err = regexec( &reg, &(buffer.clean[previous_match.rm_eo]), 10, match, REG_NOTBOL);

		if  ( (err==0) ) { /* have match */
			/* copy over file up to match */
				char s[match[0].rm_so];
				bufsize = fread( s, 1, match[0].rm_so, fidi);
				fwrite( s, 1, bufsize, fido);
				
			if ( ((i-command.start)%command.skip==0) && (i-command.start>=0) ) { /* is valid to replace match */
				write_match( match, fidi, fido );
			}
			else { /* copy match */
				char s[match[0].rm_eo-match[0].rm_so];
				bufsize = fread( s, 1, match[0].rm_eo-match[0].rm_so, fidi );
				fwrite( s, 1, bufsize, fido );
			}
		}
		else if ( err < 0 || 1 > err) { /*something really bad happened*/
			nbytes = regerror( err, &reg, (char *)NULL, (size_t)0);
			errbuf = (char *) malloc( nbytes );
			regerror( err, &reg, errbuf, nbytes );
			fprintf( stderr, "error %d executing RE: \'%s\'\n%s\n", err, command.pattern, errbuf );
			free( errbuf );
			exit(-1);
		}
	}
	
	/* have finished our matchings, copy over the rest of the file */
	char s[65536];
	while ( (bufsize = fread( s, 1, 65536, fidi )) !=0 )
		fwrite( s, 1, bufsize, fido );

	
	fclose(fidi);
	fclose(fido);
	free(buffer.clean);
	free(command.pattern);
	free(command.replace);
	return 0;
}
