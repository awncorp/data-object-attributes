package Data::Object::Attributes;

use 5.014;

use strict;
use warnings;
use registry;
use routines;

use Moo;

# VERSION

# BUILD

my $builders = {};

fun import($class, @args) {
  my $has = (my $target = caller)->can('has') or return;

  no strict 'refs';
  no warnings 'redefine';

  *{"${target}::has"} = generate([$class, $target], $has);

  return;
}

fun generate($info, $orig) {
  # generate "has" keyword

  return fun(@args) { @_ = options($info, @args); goto $orig };
}

$builders->{new} = fun($info, $name, %opts) {
  if (delete $opts{new}) {
    $opts{builder} = "new_${name}";
    $opts{lazy} = 1;
  }

  return (%opts);
};

$builders->{bld} = fun($info, $name, %opts) {
  $opts{builder} = delete $opts{bld};

  return (%opts);
};

$builders->{clr} = fun($info, $name, %opts) {
  $opts{clearer} = delete $opts{clr};

  return (%opts);
};

$builders->{crc} = fun($info, $name, %opts) {
  $opts{coerce} = delete $opts{crc};

  return (%opts);
};

$builders->{def} = fun($info, $name, %opts) {
  $opts{default} = delete $opts{def};

  return (%opts);
};

$builders->{hnd} = fun($info, $name, %opts) {
  $opts{handles} = delete $opts{hnd};

  return (%opts);
};

$builders->{isa} = fun($info, $name, %opts) {
  return (%opts) if ref($opts{isa});

  my $registry = registry::access($info->[1]);

  return (%opts) if !$registry;

  my $constraint = $registry->lookup($opts{isa});

  return (%opts) if !$constraint;

  $opts{isa} = $constraint;

  return (%opts);
};

$builders->{lzy} = fun($info, $name, %opts) {
  $opts{lazy} = delete $opts{lzy};

  return (%opts);
};

$builders->{opt} = fun($info, $name, %opts) {
  delete $opts{opt};

  $opts{required} = 0;

  return (%opts);
};

$builders->{pre} = fun($info, $name, %opts) {
  $opts{predicate} = delete $opts{pre};

  return (%opts);
};

$builders->{rdr} = fun($info, $name, %opts) {
  $opts{reader} = delete $opts{rdr};

  return (%opts);
};

$builders->{req} = fun($info, $name, %opts) {
  delete $opts{req};

  $opts{required} = 1;

  return (%opts);
};

$builders->{tgr} = fun($info, $name, %opts) {
  $opts{trigger} = delete $opts{tgr};

  return (%opts);
};

$builders->{use} = fun($info, $name, %opts) {
  if (my $use = delete $opts{use}) {
    $opts{builder} = $builders->{use_builder}->($info, $name, @$use);
    $opts{lazy} = 1;
  }

  return (%opts);
};

$builders->{use_builder} = fun($info, $name, $sub, @args) {
  return fun($self) {
    @_ = ($self, @args);

    my $point = $self->can($sub) or do {
      require Carp;

      my $class = $info->[1];

      Carp::confess("has '$name' cannot 'use' method '$sub' via package '$class'");
    };

    goto $point;
  };
};

$builders->{wkr} = fun($info, $name, %opts) {
  $opts{weak_ref} = delete $opts{wkr};

  return (%opts);
};

$builders->{wrt} = fun($info, $name, %opts) {
  $opts{writer} = delete $opts{wrt};

  return (%opts);
};

fun options($info, $name, %opts) {
  %opts = (is => 'rw') unless %opts;

  %opts = (%opts, $builders->{new}->($info, $name, %opts)) if defined $opts{new};
  %opts = (%opts, $builders->{bld}->($info, $name, %opts)) if defined $opts{bld};
  %opts = (%opts, $builders->{clr}->($info, $name, %opts)) if defined $opts{clr};
  %opts = (%opts, $builders->{crc}->($info, $name, %opts)) if defined $opts{crc};
  %opts = (%opts, $builders->{def}->($info, $name, %opts)) if defined $opts{def};
  %opts = (%opts, $builders->{hnd}->($info, $name, %opts)) if defined $opts{hnd};
  %opts = (%opts, $builders->{isa}->($info, $name, %opts)) if defined $opts{isa};
  %opts = (%opts, $builders->{lzy}->($info, $name, %opts)) if defined $opts{lzy};
  %opts = (%opts, $builders->{opt}->($info, $name, %opts)) if defined $opts{opt};
  %opts = (%opts, $builders->{pre}->($info, $name, %opts)) if defined $opts{pre};
  %opts = (%opts, $builders->{rdr}->($info, $name, %opts)) if defined $opts{rdr};
  %opts = (%opts, $builders->{req}->($info, $name, %opts)) if defined $opts{req};
  %opts = (%opts, $builders->{tgr}->($info, $name, %opts)) if defined $opts{tgr};
  %opts = (%opts, $builders->{use}->($info, $name, %opts)) if defined $opts{use};
  %opts = (%opts, $builders->{wkr}->($info, $name, %opts)) if defined $opts{wkr};
  %opts = (%opts, $builders->{wrt}->($info, $name, %opts)) if defined $opts{wrt};

  $name = "+$name" if delete $opts{mod} || delete $opts{modify};

  return ($name, %opts);
}

1;
