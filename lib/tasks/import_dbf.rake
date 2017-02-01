namespace :dbf do

  # path = ARGV.last
  # Should be fine like this.
  path = 'db/dbfs'

  #status vars for logging
  empty_records = {
    :autoren => 0,
    :reihen => 0,
    :buch => 0,
  }
  association_error = {
    :reiheUnknownAuthor => 0,
    :reiheMultiAuthor => 0,
    :buchUnknownAutor => 0,
    :buchUnknownReihe => 0,
    :buchMultiAutor => 0,
    :buchMultiReihe => 0,
  }

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
  #[mpd][todo] was ist mit: Schweiz und anderen lektoren, was ist mit alten lektoren? ggf auch hinzufuegen um invalide einträge zu erkennen
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

    progressbar.log "[LOG][BEGIN] reading dbf files"
    autoren = DBF::Table.new(autoren_path)
    reihen = DBF::Table.new(reihen_path)
    cip = DBF::Table.new(cip_path)
    progressbar.total = autoren.record_count + reihen.record_count + cip.record_count
    progressbar.log "[LOG][DONE] reading dbf files"

    progressbar.log "[LOG][BEGIN] deleting Autor db"
    Autor.delete_all() #delete_all ist much faster, and appropiate here because no relations are stored in author db
    progressbar.log "[LOG][DONE] deleting Autor db"

    progressbar.log "[LOG][BEGIN] import Authors"
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
      else
        empty_records[:autoren] += 1
      end
      progressbar.increment
    end
    progressbar.log "[LOG][DONE] import Authors - #{empty_records[:autoren]} Records where empty"

    progressbar.log "[LOG][BEGIN] import Reihen into db"
    Reihe.delete_all() #delete_all is fine to be used here, associated authors are already deleted
    reihen.each do |record|
      if record
        faecher.push(record.fach.downcase)
        faecher.push(record.fach2.downcase)
        faecher.push(record.fach3.downcase)
        lektoren.push(record.lektor.downcase)
        schriften.push(record.schrift.downcase)

        #[mpd] why the zip if it's not used later?
        hgs = record.attributes.values[96...116].zip(record.attributes.values[116...136])#0 -> adrnr, 1 -> exemp

        reihe = Reihe.new(
          :name => record.r_name + record.r_n2,
          :r_code => record.r_code
        )

        hgs.each do |hg|
          unless hg[0].empty?
            #[mpd][TODO] handle in some way not unique
            a = Autor.where(["lower(fox_id) = ?", hg[0].downcase])

            if a.count > 1
              progressbar.log "[WARNING] For Reihe - r_code: #{record.r_code} - #{a.count} Authors for fox_id: #{hg[0]}"
            end

            a = a.first
            if a
              reihe.autoren.push(a)
            else
              #[mpd][TODO] maybe save at least in a string field if not relatabel to a author
              progressbar.log "[ERROR] For Reihe - r_code: #{record.r_code} - Herausgeber not found, fox_id: #{hg[0]}"
            end
          end
        end
        reihe.save
      else
        empty_records[:reihen] += 1
      end
      progressbar.increment
    end
    progressbar.log "[LOG][DONE] import Reihen into db - #{empty_records[:reihen]} Records where empty"

    progressbar.log "[LOG][BEGIN] deleting Buch db"
    Buch.delete_all()
    progressbar.log "[LOG][DONE] deleting Buch db"

    progressbar.log "[LOG][BEGIN] import Buch"
    cip.each do |record|
      unless record
        progressbar.increment
        empty_records[:buch] += 1
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

      #[mpd][status] half of the books half currently no author relation
      #[mpd][TODO] maybe add boolean to indicate whether that relation has been confirmed by a human.
      #[mpd] why a loop if there is only one entry in it?
      autoren.each do |autor|
        #[mpd][bug] what if multiple authors with the same name exist??? -> then incorrect relation
        a = Autor.where(["lower(vorname) = ? and lower(name) = ?", autor[0].downcase, autor[1].downcase])

        if a.count > 1
          progressbar.log "[WARNING]For Buch - ISBN: #{record.isbn}, ERSCHIENEN: #{record.erschienen} - #{a.count} Authors found: #{autor[0]}, #{autor[1]}"
          association_error[:buchMultiAutor] +=1
        end

        a = a.first
        if a
          buch.autoren.push(a)
        else
          progressbar.log "[ERROR]For Buch - ISBN: #{record.isbn}, ERSCHIENEN: #{record.erschienen} - Author: #{autor[0]}, #{autor[1]} not found in Author db"
          association_error[:buchUnknownAutor] +=1
        end
        #[mpd][TODO] save at least the name if not be able to link with an authors record
      end

      # reihe suchen
      unless record.r_code.empty? or record.r_code.to_s == 'ohne'
        #[mpd][TODO] print error if not unique and handle in some way
        r = Reihe.where(["lower(r_code) = ?", record.r_code.downcase])

        if r.count > 1
          progressbar.log "[WARNING] For Buch - ISBN: #{record.isbn}, ERSCHIENEN: #{record.erschienen} - #{r.count} Reihen for r_code: #{record.r_code}"
          association_error[:buchMultiReihe] +=1
        end

        r = r.first

        if r
          buch.reihen.push(r)
        else
          progressbar.log "[WARNING] For Buch - ISBN: #{record.isbn}, ERSCHIENEN: #{record.erschienen} - Reihe not found, r_code: #{record.r_code}"
          association_error[:buchUnknownReihe] +=1
        end
      end
      #[mpd][TODO] save at least the name if not be able to link with an authors record

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
        progressbar.log "'#{e}', Occured during valid test"
      end

      buch.save

      progressbar.increment
    end
    progressbar.log "[LOG][DONE] import Buch - #{empty_records[:buch]} Records where empty"

    progressbar.log "[LOG][BEGIN] deleting Lektor"
    Lektor.destroy_all()
    progressbar.log "[LOG][DONE] deleting Lektor"

    progressbar.log "[LOG][BEGIN] import Lektor"
    lektoren.uniq.each do |lektor|
      #[mpd][todo] differentiate between old lektors and invalid entries
      this = lektoren_dict[lektor]
      name = this.nil? ? 'Unknown_' + lektor : this[:name]
      emailkuerzel = this.nil? ? 'unknown_' + lektor + '@invalid.com' : this[:mail]

      Lektor.create(
        :fox_name => lektor,
        :name => name,
        :emailkuerzel => emailkuerzel
      )
    end
    progressbar.log "[LOG][DONE] import Lektor"

    #[mpd][status] seems mostly ok
    progressbar.log "[LOG][BEGIN] import Fach"
    Fach.destroy_all()
    faecher.uniq.each do |fach|
      Fach.create(
        :fox_name => fach,
        :name => fachname[fach]
      )
    end
    progressbar.log "[LOG][DONE] import Fach"

    progressbar.log "STATUS: #{association_error.to_s}"

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


=begin
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
=end
end # namespace :dbf
