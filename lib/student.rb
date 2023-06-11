require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade


  def initialize(id = nil, name , grade)
    @id    = id
    @name  = name
    @grade = grade
  end



  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
      SQL
    
    DB[:conn].execute(sql)
  end



  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
      SQL
    
      DB[:conn].execute(sql)
  end



  def save
    if self.id
      self.update
    else
      sql = ["INSERT INTO students (name, grade) VALUES(?, ?)",   #This is the query to insert the record in the db
             "SELECT last_insert_rowid() FROM students"]         #This is the query to retrieve the record id from the db.
      
      DB[:conn].execute(sql[0], self.name, self.grade)
      self.id = DB[:conn].execute(sql[1])[0][0]

      self

      #Another way to do the same thing although the above method is preferred since it provides better abstraction using an array:
      # sql = <<-SQL
      #   INSERT INTO students (name, grade) 
      #   VALUES(?, ?)
      #   SQL

      # DB[:conn].execute(sql, self.name, self.grade)

      # # sql = <<-SQL
      # #   SELECT last_insert_row_id() FROM students
      # #   SQL

      # self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]

      # self
    end
  end



  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
      SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)

    self
  end



  def self.new_from_db(row)
    self.new(row[0], row[1], row[2])
  end



  def self.create(name, grade)
    self.new(name, grade).save
  end



  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
      SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
end