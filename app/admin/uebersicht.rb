ActiveAdmin.register Uebersicht do
  menu label: 'Uebersicht'
  menu priority:100
	config.filters = false

	scope I18n.t("scopes_names.alle_filter"), :alle_filter
  scope(I18n.t("scopes_names.unfertig_filter")){|s|
    s.where("status_final.status <> ?", I18n.t("scopes_names.fertig_filter"))
  }

  controller do
    include PrintReport

    # Only for that .odt-report, thus kinda useless.
    def index
      super do |format|#index!, html
        format.odt {print_report("projekt_report", method(:projekt))}
      end
    end

    # Need to join book and stuff, so we can easily sort that.
    def scoped_collection
      super.includes [
        :buch,
      ]
    end
  end

  index download_links: [:odt, :csv] do

    column I18n.t("gprod_names.projektname"), sortable: :projektname do |p|
      link_to(raw("#{p.projektname} (#{p.buch.short_isbn.gsub('-', '&#8209;')})"),
              "/admin/projekte/#{p.id}") rescue '-'
    end

		column I18n.t("buecher_names.isbn") do |p|
			raw "#{p.buch.isbn.gsub('-', '&#8209;')}" rescue '-'
		end

		column I18n.t("gprod_names.auflage"), sortable: :auflage do |p|
			if p.gesicherte_abnahme
				raw "#{p.auflage} (#{p.gesicherte_abnahme})"
			else
				p.auflage
			end
		end

		column I18n.t("gprod_names.druck_art"), sortable: :druck_art do |p|
      p.druck_art
		end

    column I18n.t('buecher_names.papier_bezeichnung'), sortable: 'buecher.papier_bezeichnung' do |p|
      p.buch.papier_bezeichnung rescue '-'
    end

    column I18n.t('buecher_names.format_bezeichnung'), sortable: 'buecher.format_bezeichnung' do |p|
      p.buch.format_bezeichnung rescue '-'
    end

    column I18n.t('buecher_names.umschlag_bezeichnung'), sortable: 'buecher.umschlag_bezeichnung' do |p|
      p.buch.umschlag_bezeichnung rescue '-'
    end

		column I18n.t("search_labels.lektor"), sortable: 'lektoren.name' do |p|
			p.lektor.fox_name rescue '-'
		end

    column I18n.t('buecher_names.seiten'), sortable: 'buecher.seiten' do |p|
      p.buch.seiten rescue '-'
    end

		column I18n.t("buecher_names.r_code") do |p|
			link_to(p.buch.reihen.first.r_code, "/admin/reihen/#{p.buch.reihen.first.id}") rescue "-"
		end

		column I18n.t("gprod_names.bilder"), sortable: :bilder do |p|
				p.bilder
		end

    column I18n.t('buecher_names.vier_farb'), sortable: 'buecher.vier_farb' do |p|
      p.buch.vier_farb rescue '-'
    end

		column I18n.t("gprod_names.lektor_bemerkungen_public"),
      sortable: :lektor_bemerkungen_public do |p|
				p.lektor_bemerkungen_public
		end

  end
end
