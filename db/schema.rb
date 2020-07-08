# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  create_table :admin, primary_key: :email, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.string :password, limit: 100
    t.string :name, limit: 45
  end
  change_column :admin, :email, :string, limit: 100

  create_table :calculated_score, primary_key: :user_email, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.decimal :volunteer_score, precision: 10, scale: 5
    t.integer :attendance_score
    t.decimal :conversion_score, null: false
    t.decimal :final_score, precision: 10, scale: 5
    t.datetime :created_at, null: false
    t.datetime :modified_at, null: false
  end
  change_column :calculated_score, :user_email, :string, limit: 100

  create_table :status, primary_key: :user_email, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.boolean :is_paid
    t.boolean :is_printed_application_arrived
    t.boolean :is_passed_first_apply
    t.boolean :is_passed_interview
    t.boolean :is_final_submit
    t.datetime :submitted_at
    t.string :exam_code, limit: 6
  end
  change_column :status, :user_email, :string, limit: 100

  create_table :user, primary_key: :email, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.string :password, limit: 100, null: false
    t.integer :receipt_code, null: false
    t.string :apply_type, limit: 20
    t.string :additional_type, limit: 20
    t.string :grade_type, limit: 20
    t.boolean :is_daejeon
    t.string :name, limit: 15
    t.string :sex, limit: 20
    t.date :birth_date
    t.string :parent_name, limit: 15
    t.string :parent_tel, limit: 20
    t.string :applicant_tel, limit: 20
    t.text :address, limit: 250
    t.text :detail_address, limit: 250
    t.string :post_code, limit: 5
    t.string :user_photo, limit: 45
    t.string :home_tel, limit: 45
    t.string :self_introduction, limit: 1600
    t.string :study_plan, limit: 1600
    t.datetime :created_at
    t.datetime :modified_at
  end
  change_column :user, :email, :string, limit: 100

  create_table :school, primary_key: :school_code, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.string :school_name, limit: 45
    t.string :school_full_name, limit: 45, null: false
    t.string :school_address, limit: 100, null: false
  end
  change_column :school, :school_code, :string, limit: 10

  create_table :ged_application, primary_key: :user_email, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.integer :ged_average_score
    t.datetime :created_at, null: false
    t.datetime :modified_at, null: false
  end
  change_column :ged_application, :user_email, :string, limit: 100

  create_table :graduated_application, primary_key: :user_email, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.string :student_number, limit: 5
    t.string :school_code, limit: 10
    t.string :school_tel, limit: 20
    t.integer :volunteer_time
    t.integer :full_cut_count
    t.integer :period_cut_count
    t.integer :late_count
    t.integer :early_leave_count
    t.string :korean, limit: 6
    t.string :social, limit: 6
    t.string :history, limit: 6
    t.string :math, limit: 6
    t.string :science, limit: 6
    t.string :tech_and_home, limit: 6
    t.string :english, limit: 6
    t.datetime :created_at, null: false
    t.datetime :modified_at, null: false
  end
  change_column :graduated_application, :user_email, :string, limit: 100

  create_table :ungraduated_application, primary_key: :user_email, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.string :student_number, limit: 5
    t.string :school_code, limit: 10
    t.string :school_tel, limit: 20
    t.integer :volunteer_time
    t.integer :full_cut_count
    t.integer :period_cut_count
    t.integer :late_count
    t.integer :early_leave_count
    t.string :korean, limit: 6
    t.string :social, limit: 6
    t.string :history, limit: 6
    t.string :math, limit: 6
    t.string :science, limit: 6
    t.string :tech_and_home, limit: 6
    t.string :english, limit: 6
    t.datetime :created_at, null: false
    t.datetime :modified_at, null: false
  end
  change_column :ungraduated_application, :user_email, :string, limit: 100
end
