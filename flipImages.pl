#!/usr/bin/perl
########################################################################
# flipImages.pl        --- Squid Script (Flips images vertical)        #
# g0tmi1k 2011-03-25   --- Original Idea: http://www.ex-parrot.com/pete#
########################################################################
# Note ~ Requires ImageMagick                                          #
#    sudo apt-get -y install imagemagick                               #
########################################################################
use IO::Handle;
use LWP::Simple;
use POSIX strftime;

$debug = 1;                               # Debug mode - create log file
$ourIP = "127.0.0.1";                  # Our IP address
$baseDir = "/home/wjk/phishing/static/tmp";                # Needs be writable by 'nobody'
$baseURL = "http://".$ourIP."/tmp";       # Location on websever
$mogrify = "/usr/bin/mogrify";            # Path to mogrify

$|=1;
$flip = 0;
$count = 0;
$pid = $$;

if ($debug == 1) { open (DEBUG, '>>./flipImages_debug.log'); }
autoflush DEBUG 1;

print DEBUG "########################################################################\n";
#print DEBUG strftime ("%d%b%Y-%H:%M:%S\t Server: $baseURL/\n",localtime(time()));
print DEBUG "########################################################################\n";
while (<>) {
   chomp;
   ($channel,$uri) = ( ); 
   ($channel,$uri) = split;
   if ($debug == 1) { print DEBUG "INPUT: $_\n"; }
   if (($uri =~ /(.*\.(gif|png|bmp|tiff|ico|jpg|jpeg))$/i) && (!($uri =~ /wjk-surface/))&&(!($uri =~ /localhost/))&&(!($uri =~ /127.0.0.1/))&&(!($uri =~ /(.*\.(wjk))/)) ){                         # Image format(s)
      $url = $uri;                                                                 # Get URL
      if ($debug == 1) { print DEBUG "Input: $url\n"; }                          # Let the user know

      $ext = ($url =~ m/([^.]+)$/)[0];                                           # Get the file extension
      $file = "$baseDir/$pid-$count.$ext";                                       # Set filename + path (Local)
      $filename = "$pid-$count.$ext";                                            # Set filename        (Remote)

      getstore($url,$file);                                                      # Save image
      system("chmod", "a+r", "$file");                                           # Allow access to the file
      if ($debug == 1) { print DEBUG "Fetched image: $file\n"; }                 # Let the user know

      $flip = 1;                                                                 # We need to do something with the image
   }
   else {                                                                        # Everything not a image
      print $channel."\n";                                                              # Just let it go
      if ($debug == 1) { print DEBUG "Pass: $_\n"; }                             # Let the user know
   }

   if ($flip == 1) {                                                             # Do we need to do something?
      system("$mogrify", "-flip", "$file");
      system("chmod", "a+r", "$file");
      if ($debug == 1) { print DEBUG "Flipped: $file\n"; }

      print $channel."$baseURL/$filename\n";
      if ($debug == 1) { print DEBUG "Output: $baseURL/$filename, From: $url\n"; }
   }
   $flip = 0;
   $count++;
}

close (DEBUG);
