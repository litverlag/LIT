class AddTableNamesToGroup < ActiveRecord::Migration
  def change
  	add_column :groups, :tbl_ein_liste, :integer, default:0
  	add_column :groups, :tbl_lf, :integer, default:0
  	add_column :groups, :tbl_sreif, :integer, default:0
  	add_column :groups, :tbl_um, :integer, default:0
  	add_column :groups, :tbl_tit, :integer, default:0
  	add_column :groups, :tbl_preps, :integer, default:0
  	add_column :groups, :tbl_bi, :integer, default:0
  	add_column :groups, :tbl_rg, :integer, default:0
  	add_column :groups, :tbl_ebook, :integer, default:0
  	add_column :groups, :tbl_korr, :integer, default:0
  	add_column :groups, :tbl_pod, :integer, default:0
  end
end