class User < ActiveRecord::Base
  before_save { self.email = self.email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :bio, length: { maximum: 140 }
  validates :location, length: { maximum: 20 }
  has_secure_password
  has_many :microposts
  has_many :following_relationships, class_name:  "Relationship",
                                     foreign_key: "follower_id",
                                     dependent:   :destroy
  # ralationshipsテーブル
  # (follower_id)user_id  (followed_id)user_id
  # @user.following_relationships << Relationshipクラスのインスタンスのリスト
  has_many :following_users, through: :following_relationships, source: :followed
  # フォローされている人の一覧、フォローしている人の一覧を取得するには
  # 関連テーブル(relationships)を通して、ユーザーのリストを取得したい。
  # @user.followings << Userクラスのインスタンスのリスト
  
  has_many :follower_relationships, class_name:  "Relationship",
                                    foreign_key: "followed_id",
                                    dependent:   :destroy
  has_many :follower_users, through: :follower_relationships, source: :follower

  # 他のユーザーをフォローする
  def follow(other_user)
    # relationshipsテーブルには
    # follower_id < 自分UserのID
    # followed_id < 相手のID
    # Relationship.find_or_create_by(following_id: self.id, followed_id: other_user.id)
    following_relationships.find_or_create_by(followed_id: other_user.id)
  end

  # フォローしているユーザーをアンフォローする
  def unfollow(other_user)
    following_relationship = following_relationships.find_by(followed_id: other_user.id)
    following_relationship.destroy if following_relationship
  end

  # あるユーザーをフォローしているかどうか？
  def following?(other_user)
    following_users.include?(other_user)
  end
  
  def feed_items
    Micropost.where(user_id: following_user_ids + [self.id])
  end
end