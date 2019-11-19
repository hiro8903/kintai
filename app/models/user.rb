class User < ApplicationRecord
  # 存在性（presence）,長さの検証（length）,フォーマットの検証（format）,一意性の検証（unique）
  validates :name,  presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i # 現実的に実践可能な正規表現を定数として定義
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX }, # formatというオプション
                    uniqueness: true
  # has_secure_password は入力されたパスワードをそのままの文字列ではなく、
  # ハッシュ化（入力されたデータ（パスワード）を元に戻せないデータにする処理）
  # した状態の文字列でデータベースに保存する。
  # この機能を利用するにはbcryptと言うgemをインストールし、
  # モデルにpassword_digestというカラムを含める必要がある。
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

end
