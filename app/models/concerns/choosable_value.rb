module ChoosableValue

  def import(from)
    #To be implemented this method should import the choosable options for each field from an external file
  end



  def self.bindungen
    ["Klebe", "HardCover", "Fadenheftung", "Heft"]
  end

  def self.prio
    ["a b c" ,"b","c",
     " a:pf",
   " a:sonder30",
   " pf=plichtex",
   " sonderdrucke",
   " 30 zu drucken",
   " vprab10",
    "vorabexzudrucken:10",
    "Monographie",
    "Sammelband",
    "Z; Anzahl der Bücher angeben, die an diesem Tag gebraucht wird",
    "SB=Sammelband mit Beiträgerversand",
   "SB0 = Sammelband ohne Beiträgerversand",
    "Lit = kein Druckmusterversand"]
  end

  def self.form

  end

  def self.datei

  end

  def self.formate
    ["A5", "A4", "22", "23", "24", "Sonder"]
  end

  def self.umschlaege
    ["wieReihe", "TeX", "InDesign", "Extern", "Schutzschlag"]
  end

  def self.druck_art

  end

  def self.vier_farb

  end

  def self.email

  end

  def self.sonder

  end

  def self.papiere
    ["o80", "w90", "km100", "kg120", "wg90"]
  end

  def self.muster_art
    #Musterarten
    ["digital", "papier"]
  end
end