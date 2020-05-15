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
    t.string :password
    t.string :name
  end
  change_column :admin, :email, :string

  create_table :calculated_score, primary_key: :user_email, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.decimal :volunteer_score
    t.integer :attendance_score
    t.decimal :conversion_score, null: false
    t.decimal :final_score
    t.datetime :created_at, null: false
    t.datetime :modified_at, null: false
  end
  change_column :calculated_score, :user_email, :string

  create_table :status, primary_key: :user_email, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.boolean :is_paid
    t.boolean :is_printed_application_arrived
    t.boolean :is_passed_first_apply
    t.boolean :is_passed_interview
    t.boolean :is_final_submit
    t.datetime :submitted_at
    t.string :exam_core
  end
  change_column :status, :user_email, :string

  create_table :user, primary_key: :email, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.string :password, null: false
    t.integer :receipt_number, null: false, auto_increment: true
    t.string :apply_type
    t.string :additional_type
    t.string :grade_type
    t.boolean :is_daejeon
    t.string :name
    t.string :sex
    t.date :birth_date
    t.string :parent_name
    t.string :parent_tel
    t.string :applicant_tel
    t.text :address
    t.string :post_code
    t.string :user_photo
    t.string :home_tel
    t.text :self_introduction
    t.text :study_plan
    t.datetime :created_at
  end
  change_column :user, :email, :string

  create_table :school, primary_key: :school_code, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.string :school_name
    t.string :school_full_name, null: false
    t.string :school_address, null: false
  end
  change_column :school, :school_code, :string

  create_table :ged_application, primary_key: :user_email, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.integer :ged_average_score
    t.datetime :created_at, null: false
    t.datetime :modified_at, null: false
  end
  change_column :ged_application, :user_email, :string

  create_table :graduated_application, primary_key: :user_email, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.string :student_number
    t.string :school_code
    t.string :school_tel
    t.integer :volunteer_time
    t.integer :full_cut_count
    t.integer :period_cut_count
    t.integer :late_count
    t.integer :early_leave_count
    t.string :korean
    t.string :social
    t.string :history
    t.string :math
    t.string :science
    t.string :tech_and_home
    t.string :english
    t.datetime :created_at, null: false
    t.datetime :modified_at, null: false
  end
  change_column :graduated_application, :user_email, :string

  create_table :ungraduated_application, primary_key: :user_email, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.string :student_number
    t.string :school_code
    t.string :school_tel
    t.integer :volunteer_time
    t.integer :full_cut_count
    t.integer :period_cut_count
    t.integer :late_count
    t.integer :early_leave_count
    t.string :korean
    t.string :social
    t.string :history
    t.string :math
    t.string :science
    t.string :tech_and_home
    t.string :english
    t.datetime :created_at, null: false
    t.datetime :modified_at, null: false
  end
  change_column :ungraduated_application, :user_email, :string


end
