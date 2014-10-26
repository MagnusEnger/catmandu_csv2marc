#!/usr/bin/perl 

=head1 SYNOPSIS

  $ perl csv2marc.pl
  $ cat records.marcxml | xmllint --format -

=cut

use Catmandu::Importer::CSV;
use Catmandu::Exporter::MARC;
use Getopt::Long;
use Data::Dumper;
use Pod::Usage;
use Modern::Perl;

my $importer = Catmandu::Importer::CSV->new(
    file => 'data.csv',
);
my $exporter = Catmandu::Exporter::MARC->new(
    file                 => "records.marcxml", 
    type                 => "XML",
    xml_declaration      => 1,
    collection           => 1,
    skip_empty_subfields => 1,
);

my $record_count = 0;
my $n = $importer->each(sub {
    
    # Get the record
    my $rec = $_[0];
    
    # Build up the record
    my $data = {
        record => [
            ['001', undef, undef, undef, $record_count],
            ['020', ' ', ' ', 'a',  $rec->{ 'isbn' }],
            ['100', ' ', ' ', 'a',  $rec->{ 'author' }],
            ['245', ' ', ' ', 
                'a',  $rec->{ 'title' }, 
                'b',  $rec->{ 'subtitle' },
            ],
        ],
    };
    
    # Add items according to the Koha frameworks
    for ( 1..$rec->{ 'copies' } ) {
        push @{ $data->{ record } }, [ '952', ' ', ' ', 'a', 'MYLIB', 'b', 'MYLIB' ];
    }
    
    # Add the record to the exporter
    $exporter->add($data);

    # Count processed records and bail out if we reached the limit
    $record_count++;
    
});

$exporter->commit;

say "$record_count records processed";
