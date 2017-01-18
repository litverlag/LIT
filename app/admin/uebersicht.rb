ActiveAdmin.register Uebersicht do
  menu label: 'Uebersicht'
  menu priority:100

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

    column I18n.t('buecher_names.titel1'), sortable: 'buecher.titel1' do |p|
      p.buch.titel1 rescue '-'
    end

    column I18n.t('buecher_names.utitel1'), sortable: 'buecher.utitel1' do |p|
      p.buch.utitel1 rescue '-'
    end

    column I18n.t('buecher_names.issn'), sortable: 'buecher.issn' do |p|
      raw "#{p.buch.issn.gsub('-', '&#8209;')}" rescue '-'
    end

    column I18n.t('buecher_names.gewicht'), sortable: 'buecher.gewicht' do |p|
      p.buch.gewicht rescue '-'
    end

    column I18n.t('buecher_names.volumen'), sortable: 'buecher.volumen' do |p|
      p.buch.volumen rescue '-'
    end

    column I18n.t('buecher_names.format_bezeichnung'), sortable: 'buecher.format_bezeichnung' do |p|
      p.buch.format_bezeichnung rescue '-'
    end

    column I18n.t('buecher_names.papier_bezeichnung'), sortable: 'buecher.papier_bezeichnung' do |p|
      p.buch.papier_bezeichnung rescue '-'
    end

    column I18n.t('buecher_names.bindung_bezeichnung'), sortable: 'buecher.bindung_bezeichnung' do |p|
      p.buch.bindung_bezeichnung rescue '-'
    end

    column I18n.t('buecher_names.vier_farb'), sortable: 'buecher.vier_farb' do |p|
      p.buch.vier_farb rescue '-'
    end

    #column I18n.t('buecher_names.issn'), sortable: 'buecher.issn' do |p|
    #  p.buch.issn rescue '-'
    #end

  end
end
