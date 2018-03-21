#! /bin/bash

#global variables
my_used_db=""
pk_value=""


#todo: db,table,col must start with alpha.
#      menu.
#display row or table.


#create db engine folder.
if [ ! -d ~/my_DB_Engine ]
then
mkdir -p ~/my_DB_Engine;
fi


#create a database file.
create_db(){
  echo "please enter a db name: "
  read add_db
  while [[ -d ~/my_DB_Engine/$add_db || $add_db = "" ]];do
    echo "please enter a valid db name!"
    read add_db
  done
  if [ ! -d ~/my_DB_Engine/$add_db ];then 
    mkdir  ~/my_DB_Engine/$add_db
    echo "$add_db has been created!"
  fi
}


#delete a databse file.
delete_db(){
  echo "please enter the db you want to delete: "
  read remove_db
  while [[ ! -d ~/my_DB_Engine/$remove_db || $remove_db = "" ]];do
    echo "please eneter a valid db name!"
    read remove_db
  done
  rm -r ~/my_DB_Engine/$remove_db
  echo "$remove_db has been deleted successfully!"
}


#use db.
use_db(){
  echo "please enter the db you want to use: "
  read use_db
  while [[ ! -d ~/my_DB_Engine/$use_db || $use_db = "" ]];do
    echo "please enter a valid db name!"
    read use_db
  done
  echo "$use_db opened!"
  my_used_db=$use_db
}


#create table.
create_table(){
  echo "please enter the table name: "
  read create_table
  while [[ -f ~/my_DB_Engine/$my_used_db/$create_table || $create_table = "" ]];do
    echo "please enter a valid table name!"
    read create_table
  done
  touch ~/my_DB_Engine/$my_used_db/$create_table
  echo "$create_table has been created successfully!"
  #create cols
  echo "please enter the number of fields you want to create: "
  read no_cols
  i="0"
  declare -a arr
  declare -a arr_append
  while [[ i -lt no_cols ]]; do
    echo "please enter column name: "
    read col_name
    while [[ " ${arr[*]} " == *" $col_name "* ]];do
      echo "this coloumn already exists!"
      read col_name
    done
    eval "arr+=($col_name)"
    eval "arr_append+=($col_name)"
    echo "field: ${arr[$i]}"
    echo "please select the number of data type [1-interger, 2-String]"
    PS3="type: "
    select type in Integer String
    do
      case $type in
        Integer)
          echo "int"
          break 1
          ;;
        String)
          echo "string"
          break 1
          ;;
        *)
          echo "please enter a valid option!"
          ;;
      esac 
    done
    echo "$col_name $type" >> ~/my_DB_Engine/$my_used_db/$create_table
    i=$[$i+1]
  done
  #pk
  echo "please select a primary key: "
  echo "options are: ${arr[@]}"
  read pk
  while [[ " ${arr[*]} " != *" $pk "* ]];do
    echo "please enter a valid pk!"
    read pk
  done
  for i in "${arr[@]}"; do
        if [[ "$i" = "$pk" ]]; then
          eval "arr+=($pk)"
          echo "$pk has been set successfully"
          echo "Note that pk is not null and unique."
          echo "pk $pk" >> ~/my_DB_Engine/$my_used_db/$create_table
          break
        else
          let i++;
        fi
  done
  #save in file db_name, cols_name, pk
  echo "append array: ${arr[@]}"
}
 

#insert into table.
insert_table(){
  echo "please enter the table name you want to insert data into: "
  read table_name
  while [[ ! -f ~/my_DB_Engine/$my_used_db/$table_name || $table_name = "" ]];do
    echo "please enter a valid table name: "
    read table_name
  done
  declare -a arr_insert
  declare -a arr_inserted
  #get first word in each file until pk
  #while
  ar=($(cut -d' ' -f1 ~/my_DB_Engine/$my_used_db/$table_name))
  arr_type=($(cut -d' ' -f2 ~/my_DB_Engine/$my_used_db/$table_name))
  for j in "${ar[@]}"; do
    if [ "$j" = "pk" ];then
      pk_value="$(grep -oP "pk\s+\K\w+" ~/my_DB_Engine/$my_used_db/$table_name)"
      echo "pk: $pk_value"
      break 1
    else
      eval "arr_insert+=($j)"
      let j++;
    fi
  done

  #count array size
  c="0"
  while [[ c -lt ${#arr_insert[@]} ]];do
    echo "please enter ${arr_insert[c]}: "
    read value
    if [[ ${arr_type[c]} = "Integer" ]];then
      re='^[0-9]+$'
      while [[ ! $value =~ $re ]] ; do
         echo "please enter a valid integer!"
         read value
      done
      #if the coloumn is pk.
      if [[ ${arr_insert[c]} = $pk_value ]];then
        #get col number.
        col_no="$(grep -n "$pk_value" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1 | head -1)"
        col_no=$[$col_no-1]
        if [[ $col_no = $c ]];then
          x=$[$col_no+1]
          res="$(cut -d ' ' -f $x ~/my_DB_Engine/$my_used_db/$table_name | grep -w "$value" )"
          #pk must be unique and not null
          while [[ ! "$res" = "" || $value = "" || ! $value =~ $re ]];do
            echo "please enter a valid input."
            echo "Note: pk must be unique and not null!"
            read value
            res="$(cut -d ' ' -f $x ~/my_DB_Engine/$my_used_db/$table_name | grep -w "$value" )"
          done
        fi
      fi
      eval "arr_inserted+=($value)"
    elif [[ ${arr_type[c]} = "String" ]];then
      re='^[a-zA-Z]\w{0,127}$'
      while [[ ! $value =~ $re ]] ; do
         echo "please enter a valid integer!"
         echo "PS: String must start with alphabetic character."
         read value
      done
      #if the coloumn is pk.
      if [[ ${arr_insert[c]} = $pk_value ]];then
        #get col number.
        col_no="$(grep -n "$pk_value" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1 | head -1)"
        col_no=$[$col_no-1]
        if [[ $col_no = $c ]];then
          x=$[$col_no+1]
          res="$(cut -d ' ' -f $x ~/my_DB_Engine/$my_used_db/$table_name | grep -w "$value" )"
          #pk must be unique and not null
          while [[ ! "$res" = "" || $value = "" || ! $value =~ $re ]];do
            echo "please enter a valid input."
            echo "PS: pk must be unique and not null!"
            read value
            res="$(cut -d ' ' -f $x ~/my_DB_Engine/$my_used_db/$table_name | grep -w "$value" )"
          done
        fi
      fi
      eval "arr_inserted+=($value)"
    fi
    c=$[$c+1]
  done
  echo "( ${arr_inserted[@]} ) have been inserted into $table_name successfully!"
  echo ${arr_inserted[@]} >> ~/my_DB_Engine/$my_used_db/$table_name
}


#calling

#create_db
#delete_db
use_db
#create_table
insert_table
 
