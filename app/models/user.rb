class User < ApplicationRecord
  # Attendanceモデルと１対多という関連付けさせ、ユーザーが削除された時に、
  # そのユーザーの持つAttendanceモデルのデータも一緒に削除されるようになります。
  has_many :attendances, dependent: :destroy

  # MonthlyRequestモデルと関連付けをさせている
  has_many :active_monthly_requests, class_name:  "MonthlyRequest",
                                      foreign_key: "requester_id",
                                      dependent:   :destroy
  has_many :monthly_requesting, through: :active_monthly_requests, source: :requested

  has_many :passive_active_monthly_requests, class_name:  "MonthlyRequest",
                                   foreign_key: "requested_id",
                                   dependent: :destroy
  has_many :monthly_requesters, through: :passive_active_monthly_requests, source: :requester

  # OverTimeRequestモデルと関連付けをさせている
  has_many :over_time_requests, foreign_key: "requested_id", dependent: :destroy
  has_many :over_time_requests, foreign_key: "requester_id", dependent: :destroy
  has_many :over_time_requesting, through: :over_time_requests, source: :requested

   # AttendanceEditRequestモデルと関連付けをさせている
   has_many :attendance_edit_requests, foreign_key: "requested_id", dependent: :destroy
   has_many :attendance_edit_requests, foreign_key: "requester_id", dependent: :destroy
   has_many :attendance_edit_requesting, through: :attendance_edit_requests, source: :requested

  # ユーザーを古い順に並べる
  default_scope -> { order(created_at: :asc) }
  # 「remember_token」という仮想の属性を作成します。
  attr_accessor :remember_token
  before_save { self.email = email.downcase }
  # 存在性（presence）,長さの検証（length）,フォーマットの検証（format）,一意性の検証（unique）
  validates :name,  presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i # 現実的に実践可能な正規表現を定数として定義
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX }, # formatというオプション
                    uniqueness: true
  validates :affiliation, length: { in: 2..50 }, allow_blank: true
  validates :employee_number, presence: true, uniqueness: true
  validates :uid, allow_blank: true, uniqueness: true
  validates :basic_work_time, presence: true
  validates :work_time, presence: true
  # has_secure_password は入力されたパスワードをそのままの文字列ではなく、
  # ハッシュ化（入力されたデータ（パスワード）を元に戻せないデータにする処理）
  # した状態の文字列でデータベースに保存する。
  # この機能を利用するにはbcryptと言うgemをインストールし、
  # モデルにpassword_digestというカラムを含める必要がある。
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返します。
  def User.digest(string)
    cost = 
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返します。
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # ランダムなトークンを返します。
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # トークンがダイジェストと一致すればtrueを返します。
  def authenticated?(remember_token)
    # ダイジェストが存在しない場合はfalseを返して終了します。
    # 複数ブラウザでログインしていた場合に片方だけログアウトし、もう片方でブラウザを終了させ、再度開いた際に発生するバグ対策。
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token) # トークンがダイジェストと一致すればtrueを返します。
  end

  # ユーザーのログイン情報を破棄します。
  def forget
    update_attribute(:remember_digest, nil)
  end

  # 選択されたCSVファイルを読み込んでユーザー登録をする。
  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      user = find_by(id: row["id"]) || new
      user.attributes = row.to_hash.slice(*updatable_attributes)
      user.save! if user.valid?
    end
  end

  # CSVファイルからユーザー情報をインポートする際に登録する属性
  def self.updatable_attributes
    ["id", 'name', 'email', 'password', 'admin', 'affiliation', 'basic_work_time', 'designated_work_start_time', 'designated_work_end_time', 'superior', 'employee_number', 'uid']
  end

  
end