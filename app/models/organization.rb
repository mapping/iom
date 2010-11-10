# == Schema Information
#
# Table name: organizations
#
#  id                        :integer         not null, primary key
#  name                      :string(255)
#  description               :text
#  budget                    :integer
#  website                   :string(255)
#  staff                     :integer
#  twitter                   :string(255)
#  facebook                  :string(255)
#  hq_address                :string(255)
#  contact_email             :string(255)
#  contact_phone_number      :string(255)
#  donation_address          :string(255)
#  zip_code                  :string(255)
#  city                      :string(255)
#  state                     :string(255)
#  donation_phone_number     :string(255)
#  donation_website          :string(255)
#  site_specific_information :text
#  created_at                :datetime
#  updated_at                :datetime
#  logo_file_name            :string(255)
#  logo_content_type         :string(255)
#  logo_file_size            :integer
#  logo_updated_at           :datetime
#

class Organization < ActiveRecord::Base

  before_validation :clean_html

  validates_presence_of :name

  has_attached_file :logo, :styles => { :small => "60x60#" }

  private

    def clean_html
      %W{ name description website twitter facebook hq_address contact_phone_number contact_email donation_address zip_code city state donation_phone_number donation_website }.each do |att|
        eval("self.#{att} = Sanitize.clean(self.#{att}.gsub(/\r/,'')) unless self.#{att}.blank?")
      end
    end

end