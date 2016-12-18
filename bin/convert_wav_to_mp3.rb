#!/usr/bin/env ruby

Dir.glob("*.wav").each do |wav_file|
  puts " Converting #{wav_file} to mp3"
  mp3_file = wav_file.gsub('.wav', '.mp3')

  `sox '#{wav_file}' '#{mp3_file}'`
end

