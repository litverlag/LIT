## app/helpers/status_options_adapter.rb
# Adapter to make the different options for the status available in the app/views/active_admin/resource/_newInput.erb
#
#
class StatusOptionsAdapter



  def self.option(status)
    case status
      when :statusbildpr
        $BILDPR_STATUS
      when :statusbinderei
        $BINDEREI_STATUS
      when :statusdruck
        $DRUCK_STATUS
      when :statusfinal
        $FINAL_STATUS
      when :statusoffsch
        $OFFSCH_STATUS
      when :statuspreps
        $PREPS_STATUS
      when :statusrg
        $RG_STATUS
      when :statussatz
        $SATZ_STATUS
      when  :statustitelei
        $TITELEI_STATUS
      when :statusumschl
        $UMSCHL_STATUS
    end
  end
end




