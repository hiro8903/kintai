class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  enum state: { "なし": 1, "申請中": 2, "承認": 3, "否認": 4 }
end
