
require 'sinatra'
require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'mysql2', host: 'localhost',database: 'gitissues',username:'root',password: 'root')

get '/' do
  @to_do_issues=Issue.joins(assignee: :stage).where('stages.name=? and issues.state=?', 'READY','open').order("CAST(issues.created_on as DATETIME) DESC")
  @in_progress_issues=Issue.joins(assignee: :stage).where('(stages.name=? OR stages.name=?) and issues.state=?' , 'DEV','UI','open').order("CAST(issues.created_on as DATETIME) DESC")
  @qa_issues=Issue.joins(assignee: :stage).where('stages.name=? and issues.state=?', 'QA','open').order("CAST(issues.created_on as DATETIME) DESC")
  @uat_issues=Issue.joins(assignee: :stage).where('stages.name=? and issues.state=?' , 'UAT','open').order("CAST(issues.created_on as DATETIME) DESC")
  @events=Event.order("cast(created_on as datetime) desc").limit(10)
  erb :board
end

class Event < ActiveRecord::Base
end

class Issue < ActiveRecord::Base
	belongs_to :assignee

  def days_open
    DateTime.now.mjd-Date.parse(self.created_on).mjd
  end

  def category
      labels_arr=self.labels
      if labels_arr
        if labels_arr.include? "Enhancement"
          "Enhancement"
        elsif labels_arr.include? "WB Bug"
          "WB Bug"
        elsif labels_arr.include? "Prod Bug"
          "Prod Bug"
        else
          "No Category"
        end
      else
        "No Category"
      end
  end

  def priority
    labels_arr=self.labels
    if labels_arr
      if labels_arr.include? "Critical"
        "Critical"
      elsif labels_arr.include? "High"
        "High"
      elsif labels_arr.include? "Medium"
        "Medium"
      elsif labels_arr.include? "Low"
        "Low"
      else
        'Medium'
      end
    else
      "Medium"
    end
  end
end

class Assignment < ActiveRecord::Base
end

class Assignee < ActiveRecord::Base
	belongs_to :stage
end

class Stage < ActiveRecord::Base
end
