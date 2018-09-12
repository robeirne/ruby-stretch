#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'pathname'
require 'pp'
require 'vips'

# Parse command line options
class OptparseExample
  # Return a structure describing the options.
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.scale_width = 1.0
    options.scale_height = 1.0
    options.outdir = ''
    options.outfile = ''
    options.verbose = false

    opt_parser = OptionParser.new do |opts|
      opts.banner = 'Usage: example.rb [options]'

      opts.separator ''
      opts.separator 'Specific options:'

      opts.on(
        '-x', '--scale-width SCALEWIDTH', Float, 'Set width scale (0-1)'
      ) do |x|
        options.scale_width = x
      end

      opts.on(
        '-y', '--scale-height SCALEHEIGHT', Float, 'Set width scale (0-1)'
      ) do |y|
        options.scale_height = y
      end

      opts.on(
        '-O', '--output-dir OUTPUTDIR', String, 'Define output directory name'
      ) do |dir|
        options.outdir = dir
      end

      opts.on(
        '-o', '--output-file OUTPUTFILE', String, 'Define output file name'
      ) do |file|
        options.outfile = file
      end

      opts.separator ''
      opts.separator 'Common options:'

      opts.on(
        '-v', '--[no-]verbose', 'Run verbosely'
      ) do |v|
        options.verbose = v
      end

      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)
    options
  end
end

# Print usage if no arguments
ARGV << '-h' if ARGV.empty?

options = OptparseExample.parse(ARGV)
# pp options
# pp ARGV

def validate_file(file)
  return true if File.file?(file)
end

def path_maker(infile, spec_dir, spec_file)
  inpath  = Pathname.new(infile)
  # in_dir  = inpath.dirname
  # in_base_ext = inpath.basename
  in_base = inpath.basename '.*'
  # in_ext  = inpath.extname

  outpath = Pathname.new('')

  outpath = outpath.join(spec_dir) unless spec_dir.empty?

  outpath = if spec_file.empty?
              outpath.join(in_base)
            else
              outpath.join(spec_file)
            end

  outpath = outpath.sub_ext('_pp.tif') if outpath.extname.empty?

  outpath.to_s
end

valid_files = []
ARGV.each do |arg|
  valid_files.push(arg) if validate_file(arg)
end

valid_files.each do |file|
  output_file = path_maker(file, options.outdir, options.outfile)
  puts "#{file}\t>>\t#{output_file}"
  image = Vips::Image.new_from_file file
  image.resize(
    options.scale_width, vscale: options.scale_height
  ).write_to_file output_file
end
