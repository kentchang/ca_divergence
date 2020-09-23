require 'narray'
require 'parallel'

class Array
  def kl(second) # naieve KL, does not check for divergences
    
    d_kl=0.0
    
    ptot=self.sum*1.0
    qtot=second.sum*1.0
    
    self.length.times { |i|
      if (self[i] > 0) then
        d_kl += self[i]*Math::log2( (self[i]/(ptot+1e-100)+1e-64) / (second[i]/(qtot+1e-64)) )
      end
    }
    
    d_kl/(1e-64+ptot)
  end
  
  
end

class String 
  def clean(word_clean=nil, vocab=nil, no_cut=false)
    str=self.gsub(/[A-Z]{2,}/, " ") ## kill all blockcaps
    # set=["Book", "Chapter", "Contents", "Section", "Part", "Act", "Scene", "Persons of the Dialogue", "Dramatis Personae"]
    # set.each { |word|
    #   str=str.gsub(word, " ")
    # }
    
    if vocab == nil then
      str=str.gsub(/[^\p{L}]/, " ").downcase.gsub(/[\ ]+/, " ").gsub(/\ $/, "").gsub(/^\ /, "")
    else
      str=str.gsub(/\([^\)]+?\)/, " ").gsub(/[^\p{L}]/, " ").downcase.gsub(/[\ ]+/, " ").gsub(/\ $/, "").gsub(/^\ /, "")
    end
    if vocab == nil then
      vocab=Hash.new(0)
      str.split(" ").each { |word|
        vocab[word] += 1
      }
    end
    top_fifteen=vocab.keys.sort { |i,j| vocab[j] <=> vocab[i] }[0..14]
    ok=Hash.new(false)
    vocab.keys.each { |word|
      if (vocab[word] > 1) and (word.length > 1) and ((word_clean == nil) or ((word_clean != nil) and word_clean[word])) then
          ok[word]=true
      end
    }
    if !no_cut then
      top_fifteen.each { |word|
        ok[word]=false      
      }
    end
    str.split(" ").select { |i|
      ok[i]
    }.join(" ")
  end

  def word_dist(word_clean=nil, vocab=nil, no_cut=false)
    
    if vocab == nil then
      str_new=str.gsub(/[^\p{L}]/, " ").downcase.gsub(/[\ ]+/, " ").gsub(/\ $/, "").gsub(/^\ /, "")
    str_new
      str=str.gsub(/\([^\)]+?\)/, " ").gsub(/[^\p{L}]/, " ").downcase.gsub(/[\ ]+/, " ").gsub(/\ $/, "").gsub(/^\ /, "")
    end
    if vocab == nil then
      vocab=Hash.new(0)
      str_new.split(" ").each { |word|
        vocab[word] += 1
      }
    end
    top_fifteen=vocab.keys.sort { |i,j| vocab[j] <=> vocab[i] }[0..14]
    ok=Hash.new(false)
    vocab.keys.each { |word|
      if (vocab[word] > 1) and (word.length > 1) and ((word_clean == nil) or ((word_clean != nil) and word_clean[word])) then
          ok[word]=true
      end
    }
    if !no_cut then
      top_fifteen.each { |word|
        ok[word]=false      
      }
    end
  end
  
  def chunk_and_clean(in_size=100, word_clean=nil, proportional=false)
    str=self
    str_fix=str.clean(word_clean).split(" ")

    n=str_fix.length
    if proportional then
      chunk_size=(n*1.0/in_size).floor
    else
      chunk_size=in_size
    end
    n_times=(n*1.0/chunk_size).floor
    
    list=[]
    if n_times > 1 then
      (n_times-1).times { |pos|
        list << str_fix[pos*chunk_size..(pos+1)*chunk_size-1]
      }
      final=n_times*chunk_size
      if final < (str_fix.length-1) then
        if ((str_fix.length-final) < chunk_size/2) then
          list[-1] += str_fix[final..-1]
        else
          list << str_fix[final..-1]
        end
      end
    end
    list.collect { |i| i.join(" ") }
  end  
end

class Array
  
  def mallet_model(topics=15, alpha=0.1, final="/Users/simon/Desktop/WILL_ARGUMENT/mallet-2.0.8/bin/") # " ") # you need to provide a path to the MALLET bin direction
    list=self
    vocab=Hash.new(0)
    list.each { |text|
      text.split(" ").each { |word|
        vocab[word] += 1
      }
    }
    answer=[]
    rnd=rand(100000000)
    
    file=File.new("TEMP/sorted_wordlist_fulltext_#{rnd}.txt", 'w'); 
    count=0
    file.write("#{list.length}\n")
    vocab.keys.each { |word|
      file.write("#{count}\t#{word}\t#{vocab[word]}\n")
      count += 1
    };1
    file.close

    `mkdir TEMP/MALLET_#{rnd}`
    count=0
    list.each { |post|
        file_corpus=File.new("TEMP/MALLET_#{rnd}/DOC#{count}_#{rnd}.txt", 'w')
        file_corpus.write(post+"\n")
        file_corpus.close
        count += 1
    };1
    `#{final}mallet import-dir --input TEMP/MALLET_#{rnd} --output TEMP/topic-input.mallet_#{rnd} --keep-sequence`

    if alpha > 0 then
      str=`#{final}mallet train-topics --input TEMP/topic-input.mallet_#{rnd} --num-topics #{topics} --num-top-words 100 --output-doc-topics TEMP/topic-output.txt_#{rnd}  --num-iterations 1000 --alpha #{alpha} --output-topic-keys TEMP/keyset.txt_#{rnd} --inferencer-filename TEMP/inf_#{rnd} --evaluator-filename TEMP/eval_#{rnd}`
    else
      str=`#{final}mallet train-topics --input TEMP/topic-input.mallet_#{rnd} --num-topics #{topics} --num-top-words 100 --output-doc-topics TEMP/topic-output.txt_#{rnd}  --num-iterations 1000 --optimize-interval 10 --output-topic-keys TEMP/keyset.txt_#{rnd} --inferencer-filename TEMP/inf_#{rnd} --evaluator-filename TEMP/eval_#{rnd}`      
    end
    ### put something in here to clean stopwords?
    
    ans=Hash.new

    ans[:neg_ll]=-Array.new(1) { 
      `#{final}mallet evaluate-topics --input TEMP/topic-input.mallet_#{rnd} --evaluator TEMP/eval_#{rnd}`.to_f
    }.mean
    print "Topic value: #{ans[:neg_ll]}\n"
    
    file=File.new("TEMP/keyset.txt_#{rnd}", 'r')
    alpha=[]
    file.each_line { |line|
      alpha << line.split("\t")[1].to_f
    }
    file.close
    ans[:alpha]=alpha
    
    print "TEMP/topic-output.txt_#{rnd}\n"
    file=File.new("TEMP/topic-output.txt_#{rnd}", 'r')   
    ans[:chunks]=Array.new(list.length)
    file.each_line { |line|
      set=line.split("\t")

      topic_set=NArray.float(topics)
      topics.times { |i|
         topic_set[i]=set[2+i].to_f+1e-64
      }
      # num_found=set[2..-1].length/2
      # num_found.times { |i|
      #   topic_set[set[2+2*i].to_i]=set[2+2*i+1].to_f
      # }

      pos=set[1].split("DOC")[-1].split("_")[0].to_i
      ans[:chunks][pos]=topic_set
    }
    `rm -rf TEMP/*_#{rnd}`
    ans
  end
  
  
  def model(topics=10)
    list=self
    vocab=Hash.new(0)
    list.each { |text|
      text.split(" ").each { |word|
        vocab[word] += 1
      }
    }
    answer=[]
    
    file=File.new("sorted_wordlist_fulltext.txt", 'w'); 
    count=0
    file.write("#{list.length}\n")
    vocab.keys.each { |word|
      file.write("#{count}\t#{word}\t#{vocab[word]}\n")
      count += 1
    };1
    file.close

    file_corpus=File.new("corpus_fulltext.txt", 'w')
    list.each { |post|
        file_corpus.write(post+"\n")
    };1
    file_corpus.close

    ntopics=topics
    `./page.py #{ntopics} sorted_wordlist_fulltext.txt corpus_fulltext.txt topics_fulltext_#{ntopics}.txt topic_content_fulltext_#{ntopics}.txt lda_pickle_fulltext_#{ntopics}.dat`

    file=File.new("topics_fulltext_#{ntopics}.txt", 'r')
    start=Time.now
    pos=0
    file.each_line { |i|
      topic_set=NArray.float(ntopics)
      i.split(";")[0..-2].each { |topic_pair|
        nt=topic_pair.split(",")[0][1..-1].to_i
        pt=topic_pair.split(",")[1][0..-2].to_f
        topic_set[nt]=pt
      }
      remainder=1.0-topic_set.sum
      n_null=topic_set.eq(0).where.length
      topic_set[topic_set.eq(0).where]=remainder/n_null
      topic_set=topic_set/topic_set.sum
      answer << topic_set
    }
    file.close

    file_vocab=File.new("sorted_wordlist_fulltext.txt", 'r')
    lookup=Hash.new
    file_vocab.each_line { |line|
      set=line.split("\t")
      lookup[set[0].to_i]=set[1]
    };1
    file_vocab.close

    topic_list=Hash.new
    file=File.new("topic_content_fulltext_#{ntopics}.txt", 'r')
    count=0
    file.each_line { |i|
      topic_list[count]=eval(i.gsub("(", "[").gsub(")", "]"))
      topic_list[count].length.times { |i|
        topic_list[count][i]=[lookup[topic_list[count][i][0]], topic_list[count][i][1]]
      }
      count += 1
    }
    file.close
    
    output=Hash.new
    output[:topics]=topic_list
    output[:chunks]=answer
    output
  end

  def kl_dist
    list=self
    n=list.length
    kld=[]
    0.upto(n-2) { |pos|
      kld << list[pos].kl(list[pos+1])
    }
    min_gt_zero=kld.select { |i| i > 0 }.sort[0..2].mean
    kld.collect { |i| (i <= 0) ? min_gt_zero*rand : i }
  end
  
  def ml(mu, sigma, ntopics=10, n_rep=10, knn=2)
    list=self
    alpha=1.0/ntopics

    samples, sample_density=kl_sample(mu, sigma, ntopics, alpha, list.length, n_rep).sort
    ndata=sim.length

    if (sim.max < list.max) then
      -1e12
    else
      ml=0
      list.sort.each { |val|
        ind=samples.index { |i| i > val }
        px=(ind > 0) ? (sample_density[ind]+sample_density[ind-1])/2.0 : sample_density[ind]
        ml += Math::log(px)
        print "#{px}; #{Math::log(px)}\n"
      }
      ml
    end
  end
end

def will_model(filename)
  file=File.new(filename.gsub(".txt", ".csv"), 'r')
  ntopics=file.readline.split(",").select { |i| i.include?("_") }.collect { |i| i.split("_")[-1].to_i }.max+1
  list=[]
  file.each_line { |line|
    list << NArray.to_na(line.split(",")[0..ntopics-1].collect { |i| i.to_f })
    list[-1]=list[-1]/list[-1].sum
  }
  
  list
end

def kl_sample(mu=1.0, sigma=0.1, ntopics=10, alpha=1.0/10,  n_chunks=100, n_rep=10)
  r = GSL::Rng.alloc(GSL::Rng::TAUS, 1)
  alpha_vec=GSL::Vector.alloc(Array.new(ntopics) { alpha })
  kl_list=[]
  n_rep.times {
    vec_start=r.dirichlet(alpha_vec)
    n_chunks.times {
      jump=r.lognormal(mu, sigma)
      vec_next=r.dirichlet(alpha_vec) + jump*vec_start
      vec_next=(vec_next/vec_next.sum)
      kl_list << NArray.to_na(vec_next.to_a).kl(NArray.to_na(vec_start.to_a))
      vec_start=vec_next
    }    
  }
  samples=kl_list.collect { |i| (i < 1e-12) ? 1e-12*rand : i }.sort
  knn=10
  sample_density=kl_list.collect { |val|
    volume_list=samples.sort { |i,j| (i-val).abs <=> (j-val).abs }[0..knn-1]
    volume=(volume_list[-1]-val).abs
    px=knn/((n_chunks*n_rep)*volume)    
  }
  [samples, sample_density]
end


