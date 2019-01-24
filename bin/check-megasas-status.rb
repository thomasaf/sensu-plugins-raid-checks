#! /usr/bin/env ruby
# frozen_string_literal: true

#
#   check-raid
#
# DESCRIPTION:
#   Checks the status of all virtual drives of a particular controller
#
#   StorCli/StorCli64 requires root access
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: english
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Copyright 2014 Magnus Hagdorn <magnus.hagdorn@ed.ac.uk>
#   The University of Edinburgh
#   Modified for MegaSAS - 2018 - Thomas Frederiksen <thomas.frederiksen@jppol.dk>
#   Released under the same terms as Sensu (the MIT license); see LICENSE  for details.
#

require 'sensu-plugin/check/cli'
require 'English'
require 'json'

#
# Check MegaSAS
#
class CheckMegaSAS < Sensu::Plugin::Check::CLI
  option :megasascmd,
         description: 'the MegaCli executable',
         short: '-c CMD',
         long: '--command CMD',
         default: '/opt/MegaRAID/storcli/storcli64'

  option :controller,
         description: 'the controller to query',
         short: '-C ID',
         long: '--controller ID',
         proc: proc(&:to_i),
         default: 0
  # Main function
  #
  def run
    have_error = false
    error = ''
    # get number of virtual drives
    parsedata=JSON.parse(`#{config[:megasascmd]} /c#{config[:controller]} /vall show J `)
    parsedata['Controllers'][0]['Response Data']['Virtual Drives'].each do |i|
        # and check them in turn
        unless i['State'] == 'Optl'
            error = puts "error: Virtual Disk #{i['DG/VD']} state #{i['State']}"
            have_error = true
        end
    end
    if have_error
      critical error
    else
      ok
    end
  end
end