namespace :dbf do
  desc "Import dbf files."
  task import: :environment do

		# Should be fine like this.
		#path = ARGV.last
    path = 'db/dbfs'
    
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
    
		lektorname = {
			'hf'  => 'Hopf',
			'whf' => 'Hopf',
			'ch'	=> 'Unknown_ch',
			'hfch'=> 'wtf_hfch',
			'rai' => 'Rainer',
			'bel' => 'Bellman',
			'opa' => 'Unknown_opa',
			'litb'=> 'Lit Berlin',
			'wla' => 'Lit Wien',
			'web' => 'Unknown_web'
		}
		lektoremailkuerzel = {
			'hf'  => 'hopf@lit-verlag.de',
			'whf' => 'hopf@lit-verlag.de',
			'ch'	=> 'Unknown_ch@invalid.com',
			'hfch'=> 'wtf_is_hfch@invalid.com',
			'rai' => 'rainer@lit-verlag.de',
			'rit' => 'richter@lit-verlag.de',
			'bel' => 'bellmann@lit-verlag.de',
			'opa' => 'Unknown_opa@invalid.com',
			'litb'=> 'berlin@lit-verlag.de',
			'wla' => 'wien@lit-verlag.de',
			'wien'=> 'wien@lit-verlag.de',
			'web' => 'Unknown_web@invalid.com'
		}

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
      if record
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
        
        unless record.r_code.empty? or record.r_code == 'ohne'
          r = Reihe.where(["lower(r_code) = ?", record.r_code.downcase]).first
          if r
            buch.reihen.push(r)
          else
            progressbar.log 'reihe not found: ' + record.r_code
          end
        end
        
				# sanity test.. 
				# a single isbn entry exists with the content 'alt', WTF..
				puts "Found invalid Buch, isbn is: '#{buch.isbn}'" unless buch.valid?
        buch.save if /[0-9]/.match(buch.isbn)
      end
      progressbar.increment
    end
    
    #TODO: hier verknüpfungen herstellen
    Lektor.destroy_all()
    lektoren.uniq.each do |lektor|
      Lektor.create(
        :fox_name => lektor,
        :name => lektorname[lektor],
				:emailkuerzel => lektoremailkuerzel[lektor]
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

  desc "dump dbf schema"
  task schema: :environment do
    file = ARGV.last
    dbf = DBF::Table.new(file)
    puts dbf.schema
    task file.to_sym do ; end
  end

end
