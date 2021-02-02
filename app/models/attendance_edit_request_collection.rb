class AttendanceEditRequestCollection < ApplicationRecord
  # before_action :set_one_month, only: :initialize
  USER_NUM = 5  # 同時に作成する数
  attr_accessor :collection  # ここに作成した勤怠変更申請モデルが格納される

  # 初期化メソッド
  # def initialize(attributes = [])
  #   if attributes.present?
  #     self.collection = attributes.map do |value|
  #       AttendanceEditRequest.new(
  #         attendance_id: value[],
  #         requester_id: value[],
  #         requested_id: value[],
  #         end_scheduled_at: value[],
  #         content: value[],
  #         state: value[]
  #       )
  #     end
  #   else
  #     self.collection = USER_NUM.times.map{ User.new }
  #   end
  # end

  # レコードが存在するか確認するメソッド
  def persisted?
    false
  end

end
