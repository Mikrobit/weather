#!/usr/bin/env perl6

use v6;
use HTTP::Tinyish;
use Terminal::ANSIColor;

my $loc = @*ARGS[0] // "Perugia";
my $nation = @*ARGS[1] // "IT";

my $location = '/q/' ~ $nation ~ '/' ~ $loc;
#my $location = '/q/IT/Perugia';
#my $location = '/q/IT/Pisa';
my $api_base = 'http://api.wunderground.com/api/63e4bbdf041fb754/';
my $api_query = 'conditions';
my $format = '.json';

my $http = HTTP::Tinyish.new( agent => "Perl6 Weather experiment" );
my %res = $http.get( $api_base ~ $api_query ~ $location ~ $format );

my %r = from-json( %res<content> );
my %c = %r<current_observation>;

say colored("\n--[ " ~ %c<display_location><city> ~ "\n", 'bold cyan');
say colored("| Weather | " ~ %c<temp_c> ~ ' °C - ' ~ %c<weather>, 'bold green');
say         "| Wind    | " ~ %c<wind_degrees> ~ ' ' ~ %c<wind_dir> ~ ', ' ~ %c<wind_kph> ~ 'km/h';
#say         "| Rain    | " ~ %c<precip_today_metric> ~ ' mm' if %c<precip_today_metric> != 0;

$api_query = 'forecast10day';
%res = $http.get( $api_base ~ $api_query ~ $location ~ $format );

%r = from-json( %res<content> );
my %p = %r<forecast>;

say colored("\n--[ Forecast\n", 'bold cyan');
say colored(  "|     Date      |          Forecast        | Temperature | Wind max | Snow  |", 'bold cyan');

#              | Tuesday   13  | Chance of a Thunderstorm |  16° - 22°  | 19 km/h  | 0  cm |


for 0..9 -> $i {
    my %day = %p<simpleforecast><forecastday>[$i];
    printf( "| %-9s %-3s | %-24s |  %-2s° - %-2s°  | %-2s km/h  | %-2s cm | \n",# %-3s\n",
        %day<date><weekday>,
        %day<date><day>,
        %day<conditions>,
        %day<low><celsius>,
        %day<high><celsius>,
        %day<maxwind><kph>,
        %day<snow_allday><cm>,
#        %p<txt_forecast><forecastday>[$i]<fcttext_metric>
    );
}
say "";

