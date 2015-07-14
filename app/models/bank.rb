# -*- encoding : utf-8 -*-
class Bank
  def self.bank_name(swift); I18n.t("banks.#{swift}") end

  def self.banks
    {
      'BNLNGE22' => I18n.t('banks.BNLNGE22'),
      'TRESGE22' => I18n.t('banks.TRESGE22'),
      'CBASGE22' => I18n.t('banks.CBASGE22'),
      'CNSBGE22' => I18n.t('banks.CNSBGE22'),
      'CRTUGE22' => I18n.t('banks.CRTUGE22'),
      'DISNGE22' => I18n.t('banks.DISNGE22'),
      'HSBCGE22' => I18n.t('banks.HSBCGE22'),
      'UGEBGE22' => I18n.t('banks.UGEBGE22'),
      'TCZBGE22' => I18n.t('banks.TCZBGE22'),
      'TBCBGE22' => I18n.t('banks.TBCBGE22'),
      'IJSMGE22' => I18n.t('banks.IJSMGE22'),
      'DEVBGE22' => I18n.t('banks.DEVBGE22'),
      'KSBGGE22' => I18n.t('banks.KSBGGE22'),
      'LBRTGE22' => I18n.t('banks.LBRTGE22'),
      'PRSGGE22' => I18n.t('banks.PRSGGE22'),
      'MIBGGE22' => I18n.t('banks.MIBGGE22'),
      'BAGAGE22' => I18n.t('banks.BAGAGE22'),
      'CAVOGE22' => I18n.t('banks.CAVOGE22'),
      'HABGGE22' => I18n.t('banks.HABGGE22'),
      'REPLGE22' => I18n.t('banks.REPLGE22'),
      'IBAZGE22' => I18n.t('banks.IBAZGE22'),
      'ISBKGE22' => I18n.t('banks.ISBKGE22'),
      'FGEOGE22' => I18n.t('banks.FGEOGE22')
    }
  end
end
