package Class;
use strict;

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = {};
	$self->{NAME} = undef;
	$self->{EXPR} = undef;
	$self->{METAEXPR} = undef;
	$self->{TYPE} = undef;
	$self->{META} = 0;
	$self->{INST} = 0;
	$self->{METHODS} = [];
	$self->{NUM_METHODS} = 0;
	$self->{GROUP} = undef;
	bless($self, $class);
	return $self;
}

##################### #
# Setters and Getters #
# #####################
sub name {
	my $self = shift;
	if(@_) { $self->{NAME} = shift; }
	return $self->{NAME};
}

sub expression {
	my $self = shift;
	if(@_) { $self->{EXPR} = shift; $self->type("id"); }
	return $self->{EXPR} if $self->{EXPR};
	return "objc_getClass(\"".$self->{NAME}."\")";
}

sub metaexpression {
	my $self = shift;
	if(@_) { $self->{METAEXPR} = shift; }
	return $self->{METAEXPR} if $self->{METAEXPR};
	return "objc_getMetaClass(\"".$self->{NAME}."\")";
}

sub type {
	my $self = shift;
	if(@_) { $self->{TYPE} = shift; }
	return $self->{TYPE} if $self->{TYPE};
	return $self->{NAME}."*";
}

sub hasmetahooks {
	my $self = shift;
	if(@_) { $self->{META} = shift; }
	return $self->{META};
}

sub hasinstancehooks {
	my $self = shift;
	if(@_) { $self->{INST} = shift; }
	return $self->{INST};
}

sub group {
	my $self = shift;
	if(@_) { $self->{GROUP} = shift; }
	return $self->{GROUP};
}

##### #
# END #
# #####

sub addMethod {
	my $self = shift;
	my $hook = shift;
	push(@{$self->{METHODS}}, $hook);
	$self->{NUM_METHODS}++;
}

sub initializers {
	my $self = shift;
	my $return = "";
	$return .= "Class \$\$meta\$".$self->{NAME}." = ".$self->metaexpression."; " if $self->{META};
	$return .= "Class \$\$".$self->{NAME}." = ".$self->expression."; " if $self->{INST};
	foreach(@{$self->{METHODS}}) {
		$return .= $_->buildHookCall;
	}
	return $return;
}

1;