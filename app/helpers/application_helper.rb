module ApplicationHelper
  
  # ページごとにタイトルを返す
  def full_title(page_name = "")
    base_title = "AttendanceApp"
    if page_name.empty? # enpty?はその中身が空ならばtrueを返す
      base_title　# trueの場合は上で定義したbase_titleを返す
    else
      page_name + " | " + base_title # falseの場合（page_nameに何か入っている場合）の処理
    end
  end

end
