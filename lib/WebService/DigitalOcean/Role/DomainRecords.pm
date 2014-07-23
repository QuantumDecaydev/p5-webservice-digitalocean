package WebService::DigitalOcean::Role::DomainRecords;
# ABSTRACT: Domain Records role for DigitalOcean WebService
use utf8;
use Moo::Role;
use feature 'state';
use Types::Standard qw/Str Int Object slurpy Dict Optional/;
use Type::Utils;
use Type::Params qw/compile/;

requires 'make_request';

# VERSION

sub domain_record_create {
    state $check = compile(Object,
        slurpy Dict[
            domain   => Str,
            type     => Str,
            name     => Optional[Str],
            data     => Optional[Str],
            priority => Optional[Int],
            port     => Optional[Int],
            weight   => Optional[Int],
        ],
    );
    my ($self, $opts) = $check->(@_);

    my $domain = delete $opts->{domain};

    return $self->make_request(POST => "/domains/$domain/records", $opts);
}

sub domain_record_list {
    state $check = compile(Object,
        slurpy Dict[
            domain => Str,
        ],
    );
    my ($self, $opts) = $check->(@_);

    return $self->make_request(GET => "/domains/$opts->{domain}/records");
}

sub domain_record_get {
    state $check = compile(Object,
        slurpy Dict[
            domain => Str,
            id     => Int,
        ],
    );
    my ($self, $opts) = $check->(@_);

    return $self->make_request(GET => "/domains/$opts->{domain}/records/$opts->{id}");
}

sub domain_record_delete {
    state $check = compile(Object,
        slurpy Dict[
            domain => Str,
            id     => Int,
        ],
    );
    my ($self, $opts) = $check->(@_);

    return $self->make_request(DELETE => "/domains/$opts->{domain}/records/$opts->{id}");
}

# TODO:
# domain_record_update

1;

=method $do->domain_record_create(%args)

=head3 Arguments

=over

=item C<Str> domain

The domain under which the record will be created.

=item C<Str> type

The type of the record (eg MX, CNAME, A, etc).

=item C<Str> name (optional)

The name of the record.

=item C<Str> data (optional)

The data (such as the IP address) of the record.

=item C<Int> priority (optional)

Priority, for MX or SRV records.

=item C<Int> port (optional)

The port, for SRV records.

=item C<Int> weight (optional)

The weight, for SRV records.

=back

Creates a new record for a domain.

    my $response = $do->domain_record_create(
        domain => 'example.com',
        type   => 'A',
        name   => 'www2',
        data   => '12.34.56.78',
    );

    my $id = $response->{content}{domain_record}{id};

=method $do->domain_record_delete(%args)

=head3 Arguments

=over

=item C<Str> domain

The domain to which the record belongs.

=item C<Int> id

The id of the record.

=back

Deletes the specified record.

    $do->domain_record_delete(
        domain => 'example.com',
        id     => 1215,
    );

=method $do->domain_record_get(%args)

=head3 Arguments

=over

=item C<Str> domain

The domain to which the record belongs.

=item C<Int> id

The id of the record.

=back

Retrieves details about a particular record, identified by id.

    my $response = $do->domain_record_get(
        domain => 'example.com',
        id     => 1215,
    );

    my $ip = $response->{content}{domain_record}{data};

=method $do->domain_record_list(%args)

=head3 Arguments

=over

=item C<Str> domain

The domain to which the records belong.

=back

Retrieves all the records for a particular domain.

    my $response = $do->domain_record_list(
        domain => 'example.com',
    );

    for (@{ $response->{content}{domain_records} }) {
        print "$_->{name} => $_->{data}\n";
    }
