class Translator

    @@wordRegex = /^[a-z\-]+, [A-Z]{3},( [A-Z][0-9a-z]*:[a-z\-]+,?)+$/
    @@grammarRegex = /^([A-Z][0-9a-z]*):( [A-Z]{3}(\{\d\})?,?)+$/

    def initialize(words_file, grammar_file)
      @langToGrammar = Hash.new
      @posToEnglishWord = Hash.new
      @engToPosToLangToTrans = Hash.new

      # Initialize grammar
      grammarf = File.open(grammar_file)
      line = grammarf.gets
      while line
        if line =~ @@grammarRegex
          arr = line.scan(/\w+/)
          @langToGrammar[arr[0]] = Array.new
          for i in 1..arr.size - 1
            if arr[i] =~ /\d/
              for j in 1..arr[i].to_i - 1
                @langToGrammar[arr[0]].push(arr[i - 1])
              end
            else
              @langToGrammar[arr[0]].push(arr[i])
            end
          end
        end
        line = grammarf.gets
      end

      # Initialize Lexicon
      wordf = File.open(words_file)
      line = wordf.gets
      while line
        if line =~ @@wordRegex
          arr = line.scan(/[\w\-?]+/)
          if !@posToEnglishWord.has_key?(arr[1])
            @posToEnglishWord[arr[1]] = Array.new
          end
          @posToEnglishWord[arr[1]].push(arr[0])
          if !@engToPosToLangToTrans.has_key?(arr[0])
            @engToPosToLangToTrans[arr[0]] = Hash.new
          end
          if !@engToPosToLangToTrans[arr[0]].has_key?(arr[1])
            @engToPosToLangToTrans[arr[0]][arr[1]] = Hash.new
          end
          i = 2
          while i < arr.size
            @engToPosToLangToTrans[arr[0]][arr[1]][arr[i]] = arr[i+1]
            i = i + 2
          end
          @engToPosToLangToTrans[arr[0]][arr[1]]["English"] = arr[0]
        end
        line = wordf.gets
      end

    end

    # part 1
  
    def updateLexicon(inputfile)
      f = File.open(inputfile)
      line = f.gets
      while line
        if line =~ @@wordRegex
          arr = line.scan(/[\w\-?]+/)
          if !@posToEnglishWord.has_key?(arr[1])                # if the POS is new
            @posToEnglishWord[arr[1]] = Array.new
          end
          @posToEnglishWord[arr[1]].push(arr[0])
          if !@engToPosToLangToTrans.has_key?(arr[0])           # if we have not seen the word before
            @engToPosToLangToTrans[arr[0]] = Hash.new
          end
          if !@engToPosToLangToTrans[arr[0]].has_key?(arr[1])   # if this is a new POS for the word
            @engToPosToLangToTrans[arr[0]][arr[1]] = Hash.new
          end
          i = 2
          while i < arr.size
            @engToPosToLangToTrans[arr[0]][arr[1]][arr[i]] = arr[i+1]
            i = i + 2
          end
          @engToPosToLangToTrans[arr[0]][arr[1]]["English"] = arr[0]
        end
        line = f.gets
      end
    end
  
    def updateGrammar(inputfile)
      f = File.open(inputfile)
      line = f.gets
      while line
        if line =~ @@grammarRegex
          arr = line.scan(/\w+/)
          @langToGrammar[arr[0]] = Array.new
          for i in 1..arr.size - 1
            if arr[i] =~ /\d/
              for j in 1..arr[i].to_i - 1
                @langToGrammar[arr[0]].push(arr[i - 1])
              end
            else
              @langToGrammar[arr[0]].push(arr[i])
            end
          end
        end
        line = f.gets
      end
    end

    # part 2
  
    def generateSentence(language, struct)
      if struct.class != Array
        if !@langToGrammar.has_key?(struct)
          return nil
        end
        posArr = @langToGrammar[struct]
      else
        posArr = struct
      end
      sentenceArr = Array.new
      for i in 0..posArr.size - 1
        word = nil
        if @posToEnglishWord.has_key?(posArr[i])
          for engWord in @posToEnglishWord[posArr[i]]
            if @engToPosToLangToTrans[engWord][posArr[i]].has_key?(language)
              word = @engToPosToLangToTrans[engWord][posArr[i]][language]
              break
            end
          end
        end
        if word == nil
          return nil
        else
          sentenceArr.push(word)
        end
      end
      return arrToSentence(sentenceArr)
    end
  
    def checkGrammar(sentence, language)
      sentenceArr = sentence.split
      posArr = @langToGrammar[language]
      i = 0
      for pos in posArr
        correct = false
        for engWord in @posToEnglishWord[pos]
          if @engToPosToLangToTrans[engWord][pos].has_key?(language)
            if @engToPosToLangToTrans[engWord][pos][language] == sentenceArr[i]
              correct = true
              i = i + 1
              break
            end
          end
        end
        if !correct
          return false
        end
      end
      return true
    end
  
    def changeGrammar(sentence, struct1, struct2)
      if struct1.class != Array
        posArr1 = @langToGrammar[struct1]
      else
        posArr1 = struct1
      end
      if struct2.class != Array
        posArr2 = @langToGrammar[struct2]
      else
        posArr2 = struct2
      end

      # Checking for matching set of POS
      posArr1copy = posArr1.sort
      posArr2copy = posArr2.sort
      for i in 0.. posArr1.size - 1
        if posArr1copy[i] != posArr2copy[i]
          return nil
        end
      end

      sentenceArr = sentence.split
      posToWordlist = Hash.new
      for i in 0..sentenceArr.size - 1
        if !posToWordlist.has_key?(posArr1[i])
          posToWordlist[posArr1[i]] = Array.new
        end
        posToWordlist[posArr1[i]].push(sentenceArr[i])
      end
      newSentenceArr = Array.new
      for i in 0..sentenceArr.size - 1
        newSentenceArr.push(posToWordlist[posArr2[i]].pop)
      end

      return arrToSentence(newSentenceArr)
    end

    # part 3
  
    def changeLanguage(sentence, language1, language2)
      sentenceArr = sentence.split
      posArr1 = @langToGrammar[language1]
      newSentenceArr = Array.new
      for i in 0..sentenceArr.size - 1

        # find english word
        wordFound = false
        for engWord in @engToPosToLangToTrans.keys
          if @engToPosToLangToTrans[engWord].has_key?(posArr1[i])
            if @engToPosToLangToTrans[engWord][posArr1[i]].has_key?(language1)
              if @engToPosToLangToTrans[engWord][posArr1[i]][language1] == sentenceArr[i]
                wordFound = true
                englishTranslation = engWord
                break
              end
            end
          end
        end
        if !wordFound
          return nil
        end

        # find translation in language2
        if @engToPosToLangToTrans[englishTranslation][posArr1[i]].has_key?(language2)
          translation = @engToPosToLangToTrans[englishTranslation][posArr1[i]][language2]
        else
          return nil
        end

        # add to newSentenceArr
        newSentenceArr.push(translation)

      end
      return arrToSentence(newSentenceArr)
    end
  
    def translate(sentence, language1, language2)
      sentenceArr = sentence.split
      if (sentenceArr.size != @langToGrammar[language1].size || sentenceArr.size != @langToGrammar[language2].size)
        return nil
      end

      changedLanguage = changeLanguage(sentence, language1, language2)
      if changedLanguage == nil
        return nil
      end
      return changeGrammar(changedLanguage, language1, language2)
    end

    def arrToSentence(arr)
      sentence = arr[0]
      for i in 1..arr.size-1
        sentence = sentence.to_s + " " + arr[i].to_s
      end
      return sentence
    end

  end  