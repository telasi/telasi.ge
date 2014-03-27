module Customer::Constants
  CAT_PERSONAL = 'personal'
  CAT_NOT_PERSONAL = 'not-personal'
  OWN_OWNER = 'owner'
  OWN_RENT  = 'rent'

  def category_name; Customer::Constants.cat_name(self.category) if self.respond_to?(:category) end
  def ownership_name; Customer::Constants.owner_name(self.ownership) if self.respond_to?(:ownership) end
  def cat_name(cat); cat == CAT_PERSONAL ? 'ფიზიკური' : 'იურიდიული' end
  def owner_name(owner); owner == OWN_OWNER ? 'მესაკუთრე' : 'ქირა/იჯარა' end

  module_function :cat_name, :owner_name
end
