namespace :dbf do

  # path = ARGV.last
  # Should be fine like this.
  path = 'db/dbfs'

  # Some 'global' lookup tables.
  buch_d = {
    :name => 'name',
    :isbn => 'isbn',
    :issn => 'issn',
    :titel1 => 'tit1',
    :titel2 => 'tit2',
    :titel3 => 'tit3',
    :utitel1 => 'utit1',
    :utitel2 => 'utit2',
    :utitel3 => 'utit3',
    :seiten => 'seiten',
    :sammelband => 'sammelbd',
    :preis => 'preis',
    :spreis => 'spreis',
  }
  fachname = {
    'slv' => 'Slavistik',
    'sla' => 'Slavistik',
    'wiwi' => 'Wirtschaftswissenschaft',
    'mwi' => 'Medienwissenschaft',
    'ger' => 'Germanistik',
    'geo' => 'Geographie',
    'phi' => 'Philosophie',
    'päd' => 'Pädagogik',
    'eth' => 'Ethnologie/Anthropologie',
    'ang' => 'Anglistik/Amerikanistik',
    'soz' => 'Soziologie',
    'psy' => 'Psychologie',
    'gen' => 'Gender Studies',
    'his' => 'Geschichtswissenschaft',
    'theo' => 'Theologie',
    'afr' => 'African Studies',
    'med' => 'Medizin',
    'pol' => 'Politikwissenschaft'
  }
  hopf = {name: 'Hopf', mail: 'hopf@lit-verlag.de'}
  rainer = {name: 'Rainer', mail: 'rainer@lit-verlag.de'} 
  richter = {name: 'Richter', mail: 'richter@lit-verlag.de'}
  bellmann = {name: 'Bellmann', mail: 'bellmann@lit-verlag.de'}
  litb = {name: 'Lit Berlin', mail: 'berlin@lit-verlag.de'}
  litw = {name: 'Lit Wien', mail: 'wien@lit-verlag.de'}
  lektoren_dict = {
    'hf'  => hopf,
    'whf' => hopf,
    'hfch'=> hopf,
    'lit' => hopf,

    'rai' => rainer,
    'rainer'=> rainer,
    'me/rai'=> rainer,
    'we/rai'=> rainer,
    'lut/rai'=> rainer,

    'rit' => richter,

    'bel' => bellmann,

    'litb'=> litb,
    'ltib'=> litb,

    'wla' => litw,
    'wien'=> litw,
    'litw'=> litw,
  }
        
  ##
  # Import all (almost) data from the dbf files into rails.
  # Note: We 'destroy_all()' Autor, Reihe, Buch, Lektor and Fach(whatever this
  # is).
  desc "Import dbf files."
  task import: :environment do
    
    progressbar = ProgressBar.create( 
      :format         => '%E %bᗧ%i %p%%',
      :progress_mark  => ' ',
      :remainder_mark => '･',
      :smoothing => 0.3
    )
    
    faecher = []
    lektoren = []
    schriften = []
    laender = []

    reihen_path = File.join(path, "reihen", "REIHEN.DBF")
    cip_path = File.join(path, "cip", "CIPM.DBF")
    autoren_path = File.join(path, "autoren", "AUTOREN.DBF")
    zeit_path = File.join(path, "planung", "ZEIT.DBF")

    #TODO: überall prüfen ob abfrage eindeutig -> take

    autoren = DBF::Table.new(autoren_path)
    reihen = DBF::Table.new(reihen_path)
    cip = DBF::Table.new(cip_path)
    progressbar.total = autoren.record_count + reihen.record_count + cip.record_count
    
    Autor.destroy_all()
    autoren.each do |record|
      if record
        faecher.push(record.fach.downcase)
        faecher.push(record.fach2.downcase)
        faecher.push(record.fach3.downcase)
        laender.push(record.land)
        laender.push(record.dland)
        Autor.create(
          :fox_id => record.adrnr,
          :anrede => record.anrede,
          :vorname => record.vorname,
          :name => record.name,
          :email => record.email,
          :str => record.str,
          :plz => record.plz,
          :ort => record.ort,
          :tel => record.tel,
          :fax => record.fax,
          :institut => record.institut,
          :dienstadresse => (record.dienstadr == 2 ? true : false),
          :demail => record.demail,
          :dstr => record.dstr,
          :dplz => record.dplz,
          :dort => record.dort,
          :dtel => record.dtel,
          :dfax => record.dfax
        )
      end
      progressbar.increment
    end
    
    Reihe.destroy_all()
    reihen.each do |record|
      if record
        faecher.push(record.fach.downcase)
        faecher.push(record.fach2.downcase)
        faecher.push(record.fach3.downcase)
        lektoren.push(record.lektor.downcase)
        schriften.push(record.schrift.downcase)
        hgs = record.attributes.values[96...116].zip(record.attributes.values[116...136])#0 -> adrnr, 1 -> exemp
        
        reihe = Reihe.new(
          :name => record.r_name + record.r_n2,
          :r_code => record.r_code
        )
        
        hgs.each do |hg|
          unless hg[0].empty?
            a = Autor.where(["fox_id = ?", hg[0]]).first
            if a
              reihe.autoren.push(a)
            else
              progressbar.log 'HG not found: ' + hg[0]
            end
          end
        end
        reihe.save
      end
      progressbar.increment
    end

    Buch.destroy_all()
    cip.each do |record|
      unless record
        progressbar.increment
        next 
      end
      autoren = []
      lektoren.push(record.lektor.downcase)
      faecher.push(record.fach.downcase)
      
      buch = Buch.new(
        :name => record.name,
        :isbn => record.isbn,
        :issn => record.issn,
        :titel1 => record.tit1,
        :titel2 => record.tit2,
        :titel3 => record.tit3,
        :utitel1 => record.utit1,
        :utitel2 => record.utit2,
        :utitel3 => record.utit3,
        :seiten => record.seiten,
        :sammelband => record.sammelbd,
        :preis => record.preis,
        :spreis => record.spreis,
      )

      #autoren des buches suchen
      vorname = record.verf2
      nachname = record.verf1
      unless vorname.empty? or nachname.empty?
        autoren.push([vorname,nachname])
      end
      
      autoren.each do |autor|
        a = Autor.where(["vorname = ? and name = ?", autor[0], autor[1]]).first
        if a
          buch.autoren.push(a)
        end
      end
      
      # reihe suchen
      unless record.r_code.empty? or record.r_code == 'ohne'
        r = Reihe.where(["lower(r_code) = ?", record.r_code.downcase]).first
        if r
          buch.reihen.push(r)
        else
          progressbar.log 'reihe not found: ' + record.r_code
        end
      end
      
      # sanity tests.. , buch doppelt?, buch invalid?, ..
      begin
        unless buch.valid?
          if buch_double = Buch.where(isbn: buch.isbn).first
            buch = buch_double
            buch_d.each do |key, value|
              buch[key] = record.send(value) if buch[key].nil? or buch[key].empty?
            end
          else
            progressbar.log "Found invalid Buch, isbn is: '#{buch.isbn}'"
          end
        end
      rescue NoMethodError => e
        progressbar.log "'#{e}', but i dont care"
      end

      buch.save

      progressbar.increment
    end
    
    Lektor.destroy_all()
    lektoren.uniq.each do |lektor|

      this = lektoren_dict[lektor]
      name = this.nil? ? 'Unknown_' + lektor : this[:name]
      emailkuerzel = this.nil? ? 'unknown_' + lektor + '@invalid.com' : this[:mail]

      Lektor.create(
        :fox_name => lektor,
        :name => name,
        :emailkuerzel => emailkuerzel
      )
    end
    
    Fach.destroy_all()
    faecher.uniq.each do |fach|
      Fach.create(
        :fox_name => fach,
        :name => fachname[fach]
      )
    end
    
    
    task path.to_sym do ; end
  end

  ##
  # Dumps the db schema.
  desc "dump dbf schema"
  task schema: :environment do
    file = ARGV.last
    dbf = DBF::Table.new(file)
    puts dbf.schema
    task file.to_sym do ; end
  end

  ##
  # Only get new entries, dont delete anything.
  # Note: USELESS, we cant know creation time of dbf entries.
  desc "DONT USE. Import new entries from dbf files."
  task update: :environment do
    reihen_path = File.join(path, "reihen", "REIHEN.DBF")
    cip_path = File.join(path, "cip", "CIPM.DBF")
    autoren_path = File.join(path, "autoren", "AUTOREN.DBF")
    zeit_path = File.join(path, "planung", "ZEIT.DBF")

    autoren = DBF::Table.new(autoren_path)
    reihen = DBF::Table.new(reihen_path)
    cip = DBF::Table.new(cip_path)

    # Autoren
    autoren.each do |record|
      next if Autor.where('name = ? and vorname = ? and email = ?',
                          record.name, record.vorname, record.email).first
      begin
        a = Autor.create!(
          :fox_id => record.adrnr,
          :anrede => record.anrede,
          :vorname => record.vorname,
          :name => record.name,
          :email => record.email,
          :str => record.str,
          :plz => record.plz,
          :ort => record.ort,
          :tel => record.tel,
          :fax => record.fax,
          :institut => record.institut,
          :dienstadresse => (record.dienstadr == 2 ? true : false),
          :demail => record.demail,
          :dstr => record.dstr,
          :dplz => record.dplz,
          :dort => record.dort,
          :dtel => record.dtel,
          :dfax => record.dfax
        )
        puts "[+] creating Autor: #{a.name}, #{a.vorname}"
      rescue ActiveRecord::RecordInvalid => e
        puts "[-] failed Autor: #{e}"
      end
    end

    # Reihen
    reihen.each do |record|
      next if Reihe.where('name = ? and r_code = ?',
                          record.name, record.r_code).first
      reihe = Reihe.new(
        :name => record.r_name + record.r_n2,
        :r_code => record.r_code
      )
      hgs = record.attributes.values[96...116]
      hgs.each do |hg|
        unless hg.empty?
          a = Autor.where(["fox_id = ?", hg]).first
          reihe.autoren.push(a) if a
        end
      end
      puts "[+] creating Reihe: #{reihe.name}, #{reihe.r_code}"
      reihe.save!
    end

    # Buecher
    cip.each do |record|
      next unless record
      next if Buch.where('name = ? and isbn = ?',
                         record.name, record.isbn).first

      autoren = []
      buch = Buch.new(
        :name => record.name,
        :isbn => record.isbn,
        :issn => record.issn,
        :titel1 => record.tit1,
        :titel2 => record.tit2,
        :titel3 => record.tit3,
        :utitel1 => record.utit1,
        :utitel2 => record.utit2,
        :utitel3 => record.utit3,
        :seiten => record.seiten,
        :sammelband => record.sammelbd,
        :preis => record.preis,
        :spreis => record.spreis,
      )

      #autoren des buches suchen
      vorname = record.verf2
      nachname = record.verf1
      unless vorname.empty? or nachname.empty?
        autoren.push([vorname,nachname])
      end
      
      autoren.each do |autor|
        a = Autor.where(["vorname = ? and name = ?", autor[0], autor[1]]).first
        buch.autoren.push(a) if a
      end
      
      unless record.r_code.empty? or record.r_code == 'ohne'
        r = Reihe.where(["lower(r_code) = ?", record.r_code.downcase]).first
        buch.reihen.push(r) if r
      end
      
      # sanity tests.. , buch doppelt?, buch invalid?, ..
      begin
        unless buch.valid?
          if buch_double = Buch.where(isbn: buch.isbn).first
            buch = buch_double
            buch_d.each do |key, value|
              buch[key] = record.send(value) if buch[key].nil? or buch[key].empty?
            end
          else
            puts "Found invalid Buch, isbn is: '#{buch.isbn}'"
          end
        end
      rescue NoMethodError => e
        puts "'#{e}', but i dont care"
      end

      buch.save # Note: no '!', thus we discard 'invalid?' buecher.
    end # Buecher records

  end # task :update

end # namespace :dbf
