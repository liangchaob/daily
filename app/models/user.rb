class User < ApplicationRecord
  # 扩展 Dragonfly 头像模块
  extend Dragonfly::Model
  include Avatarable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # 邮箱唯一验证
  validates :email, presence: true, uniqueness: true
  # 昵称唯一验证
  validates :code, presence: true, uniqueness: true
  # 名字必须填写验证
  validates :name, presence: true


  # 挂载头像
  mount_uploader :avatar_attachment, AvatarAttachmentUploader

  # 团队关系
  # 一个用户只隶属于同一个团队
  belongs_to :team, optional: true

  # n:m 管理团队
  has_many :teammanager_relationships
  has_many :manager_teams, through: :teammanager_relationships, source: :team

  # 项目管理
  # 1:n 创建项目
  has_many :projects
  # 改名一对多关系为 build_projects : builder
  has_many :build_projects, class_name: "Project"

  # n:m 参与项目
  has_many :projectparticipated_relationships
  has_many :participated_projects, through: :projectparticipated_relationships, source: :project

  # n:m 管理项目
  has_many :projectmanager_relationships
  has_many :manage_projects, through: :projectmanager_relationships, source: :project

  # 搜索用户
  def self.search(search)
    if search
      where('name LIKE ? or code LIKE ?',"%#{search}%","%#{search}%")
    else
      scoped
    end
  end

  # 全名
  def name_pinyin
    Pinyin.t(self.name)
  end

  # 头像字符
  def avatar_text
    name_pinyin.chr
  end


  # 判断是否是管理员
  def is_admin?
    self.is_admin
  end

  # 设置为管理员
  def set_admin!
    self.is_admin = true
    self.save
  end

  # 取消管理员
  def cancel_admin!
    self.is_admin = false
    self.save
  end

end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string
#  title                  :string
#  code                   :string
#  phone                  :string
#  description            :text
#  team_id                :integer
#  is_admin               :boolean          default(FALSE)
#  password_resetting     :boolean          default(TRUE)
#  avatar_attachment      :string
#
# Indexes
#
#  index_users_on_code                  (code) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
