class Person < ActiveRecord::Base
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

  has_many :group_activities, dependent: :destroy
  has_many :group_people, dependent: :destroy
  has_many :groups, through: :group_people
  has_many :messages

  mount_uploader :image, ImageUploader

  def self.omniauth(auth)
    dummy       = Devise.friendly_token[0,20]
    info        = auth.info
    credentials = auth.credentials

    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider   = auth.provider
      user.uid        = auth.uid
      user.name       = info.name
      user.image      = info.image
      user.token      = credentials.token
      user.email      = info.email || "#{dummy}@itsrudolph.com"
      user.expires_at = Time.at(credentials.expires_at)
      user.password   = dummy
      user.save!
    end
  end

  def apply_omniauth(auth)
    dummy       = Devise.friendly_token[0,20]
    info        = auth.info
    credentials = auth.credentials

    update_attributes(provider: auth.provider,
                      uid: auth.uid,
                      name: info.name,
                      image: info.image,
                      token: credentials.token,
                      email: info.email || email || "#{dummy}@itsrudolph.com",
                      expires_at: Time.at(credentials.expires_at),
                      password: dummy)
  end

  def first_name
    name ? name.split(' ').first : email.split('@').first
  end

  def invited?
    invitation_token && !invitation_accepted_at
  end

  def photo_by_size(size = 'normal')
    return "http://graph.facebook.com/#{uid}/picture?type=#{size}" if uid
    return image_url if image_url
    'placeholder.png'
  end

  def status(group)
    invited? || !confirmed?(group) ? 'pending' : 'active'
  end

  def can_be_invited?
    !invitation_created_at || Time.now - invitation_created_at > 1.minute
  end

  def is_admin?(group)
    self == group.try(:admin)
  end

  def is_member?(group)
    group.people.include?(self)
  end

  def confirmed?(group)
    group_person(group).try(:confirmed)
  end

  def is_admin_of
    groups.select{|group| is_admin?(group)}
  end

  def group_person(group)
    GroupPerson.where(person: self, group: group).first
  end

  def wishlist_description(group)
    group_person(group).try(:wishlist_description)
  end

  def wishlist_items(group)
    group_person(group).try(:wishlist_items)
  end

  def error_messages
    errors.full_messages.join(', ')
  end

end
