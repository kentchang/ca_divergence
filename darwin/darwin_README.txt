# Darwin "Origin Of Species" Chapter-by-Chapter Topic Model

The text itself is from project Gutenberg, available at http://www.gutenberg.org/files/1228/1228-h/1228-h.htm; the chapters were split into separate files by hand, manually, and there was no text cleaning. The topic modeling was then done with the topicexplorer code; the file darwin_OS.tez file contains the full outputs of topicexplorer, see  http://inpho.github.io/topic-explorer/import_export.html for how to use this with topicexplorer itself if so desired. We thank Colin Allen for producing this file for us.

Jaimie Murdock and Colin Allen. (2015) Visualization Techniques for Topic Model Checking in Proceedings of the 29th AAAI Conference on Artificial Intelligence (AAAI-15). Austin, Texas, USA, January 25-29, 2015. http://inphoproject.org/papers/

The outputs of topicexplorer relevant for us are the four-topic model:

Chapter 0 ["Introduction", labelled I in the figure]: [1.0781322437010123e-05, 0.5300960615829137, 0.29331665822129743, 0.1765764988733518]
Chapter 1: [0.011799646010619681, 0.4845654630361089, 0.4419267421977341, 0.06170814875553734]
Chapter 2: [0.010769569217231312, 0.673813047478101, 0.2024519019239231, 0.11296548138074479]
Chapter 3: [0.010929453527323633, 0.616499175041248, 0.2178491075446228, 0.15472226388680568]
Chapter 4: [0.05773826785196444, 0.5965921022369329, 0.2500724978250653, 0.09559713208603741]
Chapter 5: [9.999700008999734e-06, 0.5093947181584553, 0.40421787346379623, 0.08637740867773969]
Chapter 6: [0.06528738850445982, 0.6043458261669533, 0.21310147594096238, 0.11726530938762449]
Chapter 7: [0.003329866805327787, 0.4048738050477981, 0.5273989040438383, 0.06439742410303588]
Chapter 8: [0.0027299181024569266, 0.5141445756627301, 0.4541263762087137, 0.028999130026099215]
Chapter 9: [0.3190004299871003, 0.3011109666709998, 0.08574742757717266, 0.29414117576472704]
Chapter 10: [0.31725048248552545, 0.3826585202443927, 0.12277631671049868, 0.17731468055958322]
Chapter 11: [0.01802927882884685, 0.3310467581296749, 0.08952641894324229, 0.5613975440982361]
Chapter 12: [0.019739210431582735, 0.39189432422703097, 0.09521619135234591, 0.49315027398904043]
Chapter 13: [0.05364785408583658, 0.5545678172873085, 0.3574257029718812, 0.03435862565497381]
Chapter 14: [0.15054397824087037, 0.5255589776408943, 0.203361865525379, 0.12053517859285627]


# Ruby code to compute the maximal enclosure for each text

## first, here's a Hash containing the topic breakdowns above

darwin={0=>[1.0781322437010123e-05, 0.5300960615829137, 0.29331665822129743, 0.1765764988733518], 1=>[0.011799646010619681, 0.4845654630361089, 0.4419267421977341, 0.06170814875553734], 10=>[0.31725048248552545, 0.3826585202443927, 0.12277631671049868, 0.17731468055958322], 11=>[0.01802927882884685, 0.3310467581296749, 0.08952641894324229, 0.5613975440982361], 12=>[0.019739210431582735, 0.39189432422703097, 0.09521619135234591, 0.49315027398904043], 13=>[0.05364785408583658, 0.5545678172873085, 0.3574257029718812, 0.03435862565497381], 14=>[0.15054397824087037, 0.5255589776408943, 0.203361865525379, 0.12053517859285627], 2=>[0.010769569217231312, 0.673813047478101, 0.2024519019239231, 0.11296548138074479], 3=>[0.010929453527323633, 0.616499175041248, 0.2178491075446228, 0.15472226388680568], 4=>[0.05773826785196444, 0.5965921022369329, 0.2500724978250653, 0.09559713208603741], 5=>[9.999700008999734e-06, 0.5093947181584553, 0.40421787346379623, 0.08637740867773969], 6=>[0.06528738850445982, 0.6043458261669533, 0.21310147594096238, 0.11726530938762449], 7=>[0.003329866805327787, 0.4048738050477981, 0.5273989040438383, 0.06439742410303588], 8=>[0.0027299181024569266, 0.5141445756627301, 0.4541263762087137, 0.028999130026099215], 9=>[0.3190004299871003, 0.3011109666709998, 0.08574742757717266, 0.29414117576472704]}

## then, let's quickly define a nice KL function

```{ruby}
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
```

## now let's build a CSV file that can be read in by Gephi

```{ruby}
file=File.new("enclosure_kl_darwin.csv", 'w')
file.write("Source, Target, Weight\n")
0.upto(14) { |finish|
  enc=Array.new(14) { |start|
    if start != finish then
      [start, (darwin[start].kl(darwin[finish])-darwin[finish].kl(darwin[start]))]
    else
      [start, 0]
    end
  }.sort { |i,j| j[1] <=> i[1] }[0]
  ### the largest asymmetry: "train on finish, encounter start" >> "train on start, encounter finish"
  ## this means that start encloses finish
  ## "who most encloses finish" -> look for the start that has highest
  ## then draw arroe from finish to enc[0] ("finish goes into")
  file.write("#{finish}, #{enc[0]}, #{enc[1]}\n")
}
file.close
```
