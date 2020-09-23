load 'shortcuts_helper.rb'
require 'csv'
require 'date'

list=[]

big_list=["metaphysics.txt", "treatise.txt", "pure.txt"]

chunk_size=100

total=[]
big_list.each { |csvfile|
  csvname=csvfile.split("/")[-1]+"_CHUNK#{chunk_size}_#{rand(100000000)}"
  file=File.new(csvfile,'r')
  str=file.read; file.close

  final_list=str.chunk_and_clean(in_size=chunk_size, word_clean=nil, proportional=false)
  ans=final_list.mallet_model(15, -5.0/15); ## fifteen topics; alpha is 1-5/15.0

  n=ans[:chunks].length
  diff=[]
  0.upto(n-3) { |pos|
    rel_dist=(ans[:chunks][pos+2].kl(ans[:chunks][pos])-(ans[:chunks][pos+1].kl(ans[:chunks][pos])+ans[:chunks][pos+2].kl(ans[:chunks][pos+1])))
    diff << rel_dist
  }
  
  total << diff
}
