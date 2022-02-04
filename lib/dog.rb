require 'pry'

class Dog
    attr_accessor :id
    def initialize args
        @id = nil
        args.each do |k,v|
            self.class.attr_accessor k
            self.send "#{k}=", v
        end
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id integer primary key,
                name text, 
                breed text
            );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs;
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            insert into dogs ( name, breed)
            values (?, ?);
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    
        self
    end

    def self.create dog
        new_dog = self.new dog
        new_dog.save
    end

    def self.new_from_db record
        self.new id:record[0],name:record[1],breed:record[2]
    end

    def self.all
        sql = <<-SQL
            select * from dogs;
        SQL

        DB[:conn].execute(sql).map do |record|
            self.new_from_db record
        end    
    end

    def self.find_by_name name
        sql = <<-SQL
            select * from dogs
            where name = ?
            limit 1
        SQL

        self.new_from_db DB[:conn].execute(sql, name).first
    end

    def self.find id
        sql = <<-SQL
            select * from dogs
            where id = ?;
        SQL

        self.new_from_db DB[:conn].execute(sql, id).first        
    end


end
