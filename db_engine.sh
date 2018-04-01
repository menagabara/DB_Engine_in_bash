#! /bin/bash

#global variables.
my_used_db=""
pk_value=""
colsno=""

#to-do can't insert reserved word.


#create db engine folder.
if [ ! -d ~/my_DB_Engine ];then
	mkdir -p ~/my_DB_Engine;
fi


#create a database file.
create_db(){
	echo "please enter the db you want to create: "
  	read add_db
  	re='^[a-zA-Z]\w{0,127}$'

  	while [[ -d ~/my_DB_Engine/$add_db || $add_db = "" || ! $add_db =~ $re ]];do
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
	if [ "$(ls -A ~/my_DB_Engine)" ];then
		echo "please enter the db you want to delete: "
		read remove_db
		re='^[a-zA-Z]\w{0,127}$'

		while [[ ! -d ~/my_DB_Engine/$remove_db || $remove_db = "" || ! $remove_db =~ $re ]];do
			echo "please eneter a valid db name!"
	    		read remove_db
	  	done

	  	rm -r ~/my_DB_Engine/$remove_db
		echo "$remove_db has been deleted successfully!"
	else
		echo "There're no databases yet!"
	fi
}


#use db.
use_db(){
	if [ "$(ls -A ~/my_DB_Engine)" ];then
		echo "please enter the db you want to use: "
	  	read use_db
	  	re='^[a-zA-Z]\w{0,127}$'

	  	while [[ ! -d ~/my_DB_Engine/$use_db || $use_db = "" || ! $use_db =~ $re ]];do
		    	echo "please enter a valid db name!"
		    	read use_db
	  	done

	  	echo "$use_db opened!"
	  	my_used_db=$use_db
	else
		echo "There're no databases yet!"
		break 1
	fi	
}


#show dbs.
show_dbs(){
	if [ "$(ls -A ~/my_DB_Engine)" ];then
		ls -d ~/my_DB_Engine/*/ | xargs -n 1 basename
	else
		echo "There're no databases yet!"
	fi
}


#create table.
create_table(){
  	echo "please enter the table name: "
  	read create_table
  	re='^[a-zA-Z]\w{0,127}$'

  	while [[ -f ~/my_DB_Engine/$my_used_db/$create_table || $create_table = "" || ! $create_table =~ $re ]];do
    		echo "please enter a valid table name!"
    		read create_table
  	done

  	touch ~/my_DB_Engine/$my_used_db/$create_table
  	echo "$create_table has been created successfully!"

  	#create cols
  	echo "please enter the number of fields you want to create: "
  	read no_cols
	re='^[0-9]+$'

	while [[ ! $no_cols =~ $re || $no_cols = 0 ]];do
		echo "Please enter a valid number!"
		read no_cols
	done
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
		
		re='^[a-zA-Z]\w{0,127}$'
    		while [[ ! $col_name =~ $re || $col_name = "pk" ]];do
      			echo "Please enter a valid coloumn name!"
      			read col_name
    		done

    		eval "arr+=($col_name)"
    		eval "arr_append+=($col_name)"
    		echo "field: ${arr[$i]}"

    		echo "please select the number of data type [1-interger, 2-String]"

    		select type in Integer String;do
	      		case $type in
				Integer)
		  			echo "int"
		  			break
		  			;;
				String)
			  		echo "string"
			  		break
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
          		echo "$pk has been set as primary key successfully!"
          		echo "Note that pk is not null and unique."
          		echo "pk $pk" >> ~/my_DB_Engine/$my_used_db/$create_table
          		break
        	else
          		let i++;
        	fi
  	done
}


#insert into table.
insert_table(){
	if [ "$(find ~/my_DB_Engine/$my_used_db/ -type f)" ];then 
		echo "please enter the table name you want to insert data into: "
		read table_name
	  	while [[ ! -f ~/my_DB_Engine/$my_used_db/$table_name || $table_name = "" ]];do
	    		echo "please enter a valid table name: "
	    		read table_name
	  	done
	 
	  	declare -a arr_insert
	  	declare -a arr_inserted
		declare -a ar_type
	  
		#get first word in each file until pk
	  	ar=($(cut -d' ' -f1 ~/my_DB_Engine/$my_used_db/$table_name))
	  	arr_type=($(cut -d' ' -f2 ~/my_DB_Engine/$my_used_db/$table_name))
	
		if [[ -s ~/my_DB_Engine/$my_used_db/$table_name ]] ; then
			
			s=0
		  	for j in "${ar[@]}"; do

		    		if [ "$j" = "pk" ];then
		      			pk_value="$(grep -oP "pk\s+\K\w+" ~/my_DB_Engine/$my_used_db/$table_name)"
		      			echo "pk: $pk_value"
		      			break 1
		    		else
		      			eval "arr_insert+=($j)"
					eval "ar_type+=(${ar_type[s]})"
		      			let j++;
		    		fi
				s=$[$s+1]
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
					while [[ $value = "pk" ]] ; do
			 			echo "This word is reserved!"
			 			read value
		      			done

					#if the coloumn is pk.
			      		if [[ ${arr_insert[c]} = $pk_value ]];then

						#get col number.
						col_no="$(grep -n "$pk_value" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1 | head -1)"
						col_no=$[$col_no-1]

						#check if value exists.
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
		     			 	echo "please enter a valid String!"
			 			echo "PS: String must start with alphabetic character and could only contains (a-z,1-9, _)."
			 			read value
		      			done
					while [[ $value = "pk" ]] ; do
			 			echo "This word is reserved!"
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
			  
							#pk must be unique and not null.
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
		else
			echo "The table was corrupted! Please Delete it!"
		fi
		
	else
		echo "There're no tables yet!"
	fi
}


#alter table.
alter_table(){
	if [ "$(find ~/my_DB_Engine/$my_used_db/ -type f)" ];then 
		declare -a fields
		declare -a datatypes
	  	echo "please enter the table you want to update: "
	  	read table_name

		while [[ ! -f ~/my_DB_Engine/$my_used_db/$table_name || $table_name = "" ]];do
			echo "please enter a valid table name: "
			read table_name
		done

		done=0
		if [[ -s ~/my_DB_Engine/$my_used_db/$table_name ]] ; then

			while (( !done )); do
				ar=()
				arr_type=()
				datatypes=()
				fields=()
				ar=($(cut -d' ' -f1 ~/my_DB_Engine/$my_used_db/$table_name))
				arr_type=($(cut -d' ' -f2 ~/my_DB_Engine/$my_used_db/$table_name))

				#get all lines until pk.
				#search in this coloumn.
				line="$(grep -nw "$pk" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1)"
				i=0
				for j in "${ar[@]}"; do

					if [ "$j" = "pk" ];then
						pk_value="$(grep -oP "pk\s+\K\w+" ~/my_DB_Engine/$my_used_db/$table_name)"
						eval "datatypes+=(${arr_type[i]})"
						break 1
					else
						eval "fields+=($j)"
						eval "datatypes+=(${arr_type[i]})"
						let j++;
					fi
					i=$[$i+1]
				done

				echo ""
				options=("Rename table." "Rename field." "Change datatype." "Change primary key." "Quit.")
				echo "Choose an option:"
				echo ""

				select op in "${options[@]}"; do
					case $REPLY in
						1)
							echo "Please reenter the table you want to rename: "
						  	read table_name

							while [[ ! -f ~/my_DB_Engine/$my_used_db/$table_name || $table_name = "" ]];do
								echo "please enter a valid table name: "
								read table_name
							done

							echo "Please enter the new table name: "
							read new_table
						  	re='^[a-zA-Z]\w{0,127}$'

						  	while [[ -f ~/my_DB_Engine/$my_used_db/$new_table || $new_table = "" || ! $new_table =~ $re ]];do
						    		echo "please enter a valid table name!"
						    		read new_table
						  	done

							mv ~/my_DB_Engine/$my_used_db/$table_name ~/my_DB_Engine/$my_used_db/$new_table
							table_name=`echo $new_table`

							break
							;;
						2)
							z=0
							echo "Please select the field you want to alter: " ${fields[@]}
							read field
							test=1

							while [[ $test = 1 ]];do
								for i in ${fields[@]};do
									if [ $i = $field ];then
										break 2
									fi
									z=$[$z+1]
								done
								echo "Please enter a valid input!"
								read field
							done

							echo "Please enter the new column name: "
							read col_name

					    		while [[ " ${fields[*]} " == *" $col_name "* ]];do
								if [[ $col_name = $field ]];then
									break 1
								fi
					      			echo "this coloumn already exists!"
					      			read col_name
					    		done

					    		while [[ ! $col_name =~ $re ]];do
					      			echo "Please enter a valid coloumn name!"
					      			read col_name
					    		done
							sed -i "0,/`echo $field`/{s/`echo $field`/`echo $col_name`/}" ~/my_DB_Engine/$my_used_db/$table_name

							echo ${datatypes[-1]}
							if [[ $field = ${datatypes[-1]} ]];then
								sed -i "0,/`echo $field`/{s/`echo $field`/`echo $col_name`/}" ~/my_DB_Engine/$my_used_db/$table_name
							fi
							ar=()
							arr_type=()
							datatypes=() 
							fields=()
							break
							;;
						3)
							echo "Please select the field you want to alter its datatype: " ${fields[@]}
							read field
							test=1
							z=0

							while [[ $test = 1 ]];do
								for i in ${fields[@]};do
									if [ $i = $field ];then
										break 2
									fi
									z=$[$z+1]
								done
								echo "Please enter a valid input!"
								read field
							done

							#get current datatype.
							current_datatype=${datatypes[z]}
							line=$[$z+1]
							echo $z 
							options=("Integer" "String")
					    		select type in ${options[@]};do
						      		case $type in
									Integer)
										if [[ $field = ${datatypes[-1]}  ]];then
										echo "hhh"
											echo "PS: Note that by changine the datatype of the pk, all the rows in this table will be deleted."
											echo "Do you really want to change it?"

									    		select t in Yes No;do
										      		case $t in
													Yes)
														sed -i "${line}s/ `echo $current_datatype`/`echo " "$type`/" ~/my_DB_Engine/$my_used_db/$table_name
														sed -i "/pk/q" ~/my_DB_Engine/$my_used_db/$table_name
													
														echo "Altered!"
														break
														;;
													No)
														echo "Cancelled!"
														break
														;;
													*)
												  		echo "please enter a valid option!"
												  		;;
												esac
											done
													
										else
											sed -i "${line}s/ `echo $current_datatype`/`echo " "$type`/" ~/my_DB_Engine/$my_used_db/$table_name
										fi

							  			break
							  			;;
									String)
										if [[ $field = ${datatypes[-1]}  ]];then
	echo "h"
											echo "PS: Note that by changine the datatype of the pk, all the rows in this table will be deleted."
											echo "Do you really want to change it?"

									    		select t in Yes No;do
										      		case $t in
													Yes)
														sed -i "${line}s/ `echo $current_datatype`/`echo " "$type`/" ~/my_DB_Engine/$my_used_db/$table_name
														sed -i "/pk/q" ~/my_DB_Engine/$my_used_db/$table_name
														echo "Altered!"
														break
														;;
													No)
														echo "Cancelled!"
														break
														;;
													*)
												  		echo "Please enter a valid option!"
												  		;;
												esac
											done	
										else
											sed -i "${line}s/ `echo $current_datatype`/`echo " "$type`/" ~/my_DB_Engine/$my_used_db/$table_name
										fi
							  			break
							  			;;
									*)
								  		echo "Please enter a valid option!"
								  		;;
								esac 
					    		done
						

							break
							;;
						4)
							echo "Please select the new pk value: " ${fields[@]}
							read pk
							test=1
							z=0

							while [[ $test = 1 ]];do
								for i in ${fields[@]};do
									if [[ $i = $pk ]];then
										break 2
									fi
									z=$[$z+1]
								done
								echo "Please enter a valid input!"
								read field
							done

							if [[ $pk = $pk_value ]];then
								sed -i "s/pk .*$/pk `echo $pk`/g" ~/my_DB_Engine/$my_used_db/$table_name
							else
								echo "PS: Note that by changine the pk, all the rows in this table will be deleted."
								echo "Do you really want to change it?"

						    		select t in Yes No;do
							      		case $t in
										Yes)
											sed -i "s/pk .*$/pk `echo $pk`/g" ~/my_DB_Engine/$my_used_db/$table_name
											sed -i "/pk/q" ~/my_DB_Engine//$my_used_db/$table_name
											echo "Altered!"
											break 1
											;;
										No)
											echo "Cancelled!"
											break 1
											;;
										*)
									  		echo "Please enter a valid option!"
									  		;;
									esac
								done	
							fi
							break 
							;;
						5)
							break 
							;;
						*)
							echo "Invalid option!"
							;;
					esac
				done

				echo "Do you want to do another operation?"
				select op in "Yes" "No"; do
					case $REPLY in
						1) break ;;
						2) done=1; break ;;
						*) echo "Invalid option!" ;;
					esac
				done
			done
		else
			echo "The table was corrupted! Please delete it!"
		fi
	else
		echo "There're no tables yet!"
	fi
}


#update table's field.
update_table(){
	if [ "$(find ~/my_DB_Engine/$my_used_db/ -type f)" ];then 
		declare -a arr_insert
		declare -a arr_inserted
	  	echo "please enter the table you want to update: "
	  	read table_name

		while [[ ! -f ~/my_DB_Engine/$my_used_db/$table_name || $table_name = "" ]];do
			echo "please enter a valid table name: "
			read table_name
		done
		if [[ -s ~/my_DB_Engine/$my_used_db/$table_name ]] ; then
			check=""
			check=$(sed -n '/^pk/{n;p}' ~/my_DB_Engine/$my_used_db/$table_name)
			if [ -z "$check" ];then
				echo "The table is empty!"
			else
				ar=($(cut -d' ' -f1 ~/my_DB_Engine/$my_used_db/$table_name))
				arr_type=($(cut -d' ' -f2 ~/my_DB_Engine/$my_used_db/$table_name))	
				echo "please enter the pk of the field you want to update: "
				read pk 
	
				#search in this coloumn.
				line="$(grep -nw "$pk" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1)"

				for j in "${ar[@]}"; do
					if [ "$j" = "pk" ];then
						pk_value="$(grep -oP "pk\s+\K\w+" ~/my_DB_Engine/$my_used_db/$table_name)"
						break 1
					else
						eval "arr_insert+=($j)"
						let j++;
					fi
				done

				#count array size
				c="0"

				#get pk field associated type.
				while [[ c -lt ${#arr_insert[@]} ]];do
					get_col=$[$c+1]
					if [[ ${arr_insert[c]} = $pk_value ]];then
						if [[ ${arr_type[c]} = "Integer" ]];then
							re='^[0-9]+$'
			
							while [[ $line = "" || ! $pk =~ $re ]];do
								echo "this pk doesn't exist!"
								read pk
								line="$(grep -nw "$pk" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1)"
							done
						elif [[ ${arr_type[c]} = "String" ]];then
							re='^[a-zA-Z]\w{0,127}$'

							while [[ $line = "" || ! $pk =~ $re ]];do
								echo "this pk doesn't exist!"
								read pk
								line="$(grep -nw "$pk" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1)"
							done
						fi
						x="$(cat ~/my_DB_Engine/$my_used_db/$table_name | cut -d ' ' -f $get_col | grep -w $pk)"
						while [[ $x = "" ]];do
							echo "this pk doesn't exist!"
						  	read pk
							x="$(cat ~/my_DB_Engine/$my_used_db/$table_name | cut -d ' ' -f $get_col | grep -w $pk)"
						done
						
						break 1
					fi

					c=$[$c+1]
				done

				c="0"
				while [[ c -lt ${#arr_insert[@]} ]];do

					if [[ ${arr_type[c]} = "Integer" ]];then
						re='^[0-9]+$'
						echo "please enter the new ${arr_insert[c]}: "
						read value
			
						while [[ ! $value =~ $re ]] ; do
							echo "please enter a valid integer!"
							read value
						done

						#if the coloumn is pk.
						if [[ ${arr_insert[c]} = $pk_value ]];then
				
							#get col number.
							col_no="$(grep -n "$pk_value" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1 | head -1)"
							col_no=$[$col_no-1]

							#check if value exists.
							if [[ $col_no = $c ]];then
								x=$[$col_no+1]
								line="$(grep -nw "$pk" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1)"

								#pk must be unique and not null
								check=1
								while [[ ! $check = 2 ]];do
									if [ $value = $pk ];then
										check=2
										break 1
								    	else							
										exists=$(cat ~/my_DB_Engine/$my_used_db/$table_name | tr -s ' ' | cut -d ' ' -f $x)
										double_check=1
										for v in $exists; do 
											if [[ $v = $value ]];then
												check=1
												double_check=$[$double_check+1]
											fi								
										done
										if [[ $double_check = 1 ]];then
											break 1
										fi
										echo "This pk already exists!"
										read value
									fi
								done
							fi
						fi

						eval "arr_inserted+=($value)"	

					elif [[ ${arr_type[c]} = "String" ]];then
							re='^[a-zA-Z]\w{0,127}$'
							echo "please enter the new ${arr_insert[c]}: "
							read value

							while [[ ! $value =~ $re ]] ; do
								echo "please enter a valid String!"
								echo "PS: String must start with alphabetic character and could only contains ( a-z, 1-9, _ )."
								read value
							done

							#if the coloumn is pk.
							if [[ ${arr_insert[c]} = $pk_value ]];then

							#get col number.
							col_no="$(grep -n "$pk_value" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1 | head -1)"
							col_no=$[$col_no-1]
							echo $col_no

							if [[ $col_no = $c ]];then
								x=$[$col_no+1]
								line="$(grep -nw "$pk" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1)"
						
								#pk must be unique and not null
								#while [[ "$line" = "" || $value = "" || ! $value =~ $re || $value = "pk" ]];do 
								check=1
								while [[ ! $check = 2 || "$line" = "" || $value = "" || ! $value =~ $re || $value = "pk" ]];do
									if [ $value = $pk ];then
										check=2
										break 1
								    	else							
										exists=$(cat ~/my_DB_Engine/$my_used_db/$table_name | tr -s ' ' | cut -d ' ' -f $x)
										double_check=1
										for v in $exists; do 
											if [[ $v = $value ]];then
												check=1
												double_check=$[$double_check+1]
											fi								
										done
										if [[ $double_check = 1 ]];then
											break 1
										fi
										echo "This pk already exists!"
										read value
									fi
								done
							fi
						fi
		
						eval "arr_inserted+=($value)"
					fi

					c=$[$c+1]
				done
				echo ${arr_inserted[@]}

				#update the line.
				sed -i "${line}s/.*/`echo ${arr_inserted[@]}`/" ~/my_DB_Engine/$my_used_db/$table_name 
			fi
		else
			echo "The table is empty!"
		fi
	else
		echo "There're no tables yet!"
	fi
}


delete_table(){
	if [ "$(find ~/my_DB_Engine/$my_used_db/ -type f)" ];then 
		echo "please enter the table you want to delete: "
		read table_name

		while [[ ! -f ~/my_DB_Engine/$my_used_db/$table_name || $table_name = "" ]];do
			echo "please enter a valid table name: "
			read table_name
		done

		rm ~/my_DB_Engine/$my_used_db/$table_name
		echo " $table_name has been removed successfully!"
	else
		echo "There're no tables yet!"
	fi
}


delete_row(){
	if [ "$(find ~/my_DB_Engine/$my_used_db/ -type f)" ];then 

		echo "please enter the table you want to delete a row from: "
		read table_name

		while [[ ! -f ~/my_DB_Engine/$my_used_db/$table_name || $table_name = "" ]];do
			echo "please enter a valid table name: "
			read table_name
		done

		ar=($(cut -d' ' -f1 ~/my_DB_Engine/$my_used_db/$table_name))
		arr_type=($(cut -d' ' -f2 ~/my_DB_Engine/$my_used_db/$table_name))
		
		if [[ -s ~/my_DB_Engine/$my_used_db/$table_name ]] ; then
			check=""
			check=$(sed -n '/^pk/{n;p}' ~/my_DB_Engine/$my_used_db/$table_name)

			if [ -z "$check" ];then
				echo "The table is empty!"
			else
				echo "please enter the pk of the field you want to delete: "
				read pk 
	
				#search in this coloumn.
				line="$(grep -nw "$pk" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1)"

				for j in "${ar[@]}"; do
					if [ "$j" = "pk" ];then
						pk_value="$(grep -oP "pk\s+\K\w+" ~/my_DB_Engine/$my_used_db/$table_name)"
						break 1
						else
						eval "arr_insert+=($j)"
						let j++;
					fi
				done

				#count array size
				c="0"
	
				#get pk field associated type.
				while [[ c -lt ${#arr_insert[@]} ]];do
					get_col=$[$c+1]
					if [[ ${arr_insert[c]} = $pk_value ]];then

						if [[ ${arr_type[c]} = "Integer" ]];then
							re='^[0-9]+$'

							while [[ $line = "" || ! $pk =~ $re ]];do
								echo "this pk doesn't exist!"
								read pk
								line="$(grep -nw "$pk" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1)"

							done
						elif [[ ${arr_type[c]} = "String" ]];then
							re='^[a-zA-Z]\w{0,127}$'

							while [[ $line = "" || ! $pk =~ $re ]];do
								echo "this pk doesn't exist!"
								read pk
								line="$(grep -nw "$pk" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1)"

							done
						fi
						x="$(cat ~/my_DB_Engine/$my_used_db/$table_name | cut -d ' ' -f $get_col | grep -w $pk)"
						while [[ $x = "" ]];do
							echo "this pk doesn't exist!"
						  	read pk
							x="$(cat ~/my_DB_Engine/$my_used_db/$table_name | cut -d ' ' -f $get_col | grep -w $pk)"
						done
						lineno="$(grep -wn "$pk" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f1)"
						break 1
					fi
					c=$[$c+1]
				done
				#delete the line.
				sed -i -e ${lineno}d ~/my_DB_Engine/$my_used_db/$table_name
				echo "Deleted!"
			fi
		else
			echo "The table is empty!"
		fi
		
	else
		echo "There're no tables yet!"
	fi
}


#show all tables.
show_tables(){
	if [ "$(find ~/my_DB_Engine/$my_used_db/ -type f)" ];then 
		find ~/my_DB_Engine/$my_used_db/ -maxdepth 1 -type f | tr '\n' '\0' | xargs -0 -n 1 basename  
	else
		echo "There're no tables yet!"
	fi
}


#view table.
view_table(){
	if [ "$(find ~/my_DB_Engine/$my_used_db/ -type f)" ];then 
		echo "please enter the table you want to display: "
		read table_name

		while [[ ! -f ~/my_DB_Engine/$my_used_db/$table_name || $table_name = "" ]];do
			echo "please enter a valid table name: "
			read table_name
		done

		if [[ -s ~/my_DB_Engine/$my_used_db/$table_name ]] ; then
			check=""
			check=$(sed -n '/^pk/{n;p}' ~/my_DB_Engine/$my_used_db/$table_name)
			if [ -z "$check" ];then
				echo "The table is empty!"
			else
				#cat ~/my_DB_Engine/$my_used_db/$table_name
				sed '1,/pk/d' ~/my_DB_Engine/$my_used_db/$table_name			
			fi
		else
			echo "The table is empty!"
		fi
	else
		echo "There're no tables yet!"
	fi
}


view_row(){
	if [ "$(find ~/my_DB_Engine/$my_used_db/ -type f)" ];then 
		echo "please enter the table you want to display a row from: "
		read table_name

		while [[ ! -f ~/my_DB_Engine/$my_used_db/$table_name || $table_name = "" ]];do
			echo "please enter a valid table name: "
			read table_name
		done

		declare -a ar_type
		ar=($(cut -d' ' -f1 ~/my_DB_Engine/$my_used_db/$table_name))
		arr_type=($(cut -d' ' -f2 ~/my_DB_Engine/$my_used_db/$table_name))

		if [[ -s ~/my_DB_Engine/$my_used_db/$table_name ]] ; then
			check=""
			check=$(sed -n '/^pk/{n;p}' ~/my_DB_Engine/$my_used_db/$table_name)

			if [ -z "$check" ];then
				echo "The table is empty!"
			else
			
				echo "please enter the pk of the field you want to display: "
				read pk 

				#search in this coloumn.
				line="$(grep -nw "$pk" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1)"
				s=0
				for j in "${ar[@]}"; do
					if [ "$j" = "pk" ];then
						pk_value="$(grep -oP "pk\s+\K\w+" ~/my_DB_Engine/$my_used_db/$table_name)"
						break 1
						else
						eval "arr_insert+=($j)"
						let j++;
					fi
					eval "ar_type+=(${arr_type[$s]})"
					s=$[$s+1]
				done

				#count array size
				c="0"
				#get pk field associated type.
				while [[ c -lt ${#arr_insert[@]} ]];do
					if [[ ${arr_insert[c]} = $pk_value ]];then
						get_col=$[$c+1]
						if [[ ${arr_type[c]} = "Integer" ]];then
							re='^[0-9]+$'

							while [[ $line = "" || ! $pk =~ $re ]];do
								echo "this pk doesn't exist!"
								read pk
								line="$(grep -nw "$pk" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1)"

							done
						elif [[ ${arr_type[c]} = "String" ]];then
							re='^[a-zA-Z]\w{0,127}$'

							while [[ $line = "" || ! $pk =~ $re ]];do
								echo "this pk doesn't exist!"
								read pk
								line="$(grep -nw "$pk" ~/my_DB_Engine/$my_used_db/$table_name | cut -d: -f 1)"

							done
						fi

						x="$(cat ~/my_DB_Engine/$my_used_db/$table_name | cut -d ' ' -f $get_col | grep -w $pk)"
						while [[ $x = "" ]];do
							echo "this pk doesn't exist!"
						  	read pk
							x="$(cat ~/my_DB_Engine/$my_used_db/$table_name | cut -d ' ' -f $get_col | grep -w $pk)"
						done
							
						break 1
					fi

					c=$[$c+1]
				done

			echo "$(grep -w "$pk" ~/my_DB_Engine/$my_used_db/$table_name)"
			fi
		else
			echo "The table is empty!"		
		fi
	else
		echo "There're no tables yet!"
		
	fi
}


#Menu.

PS3="Please enter your choice:  "


db_options(){
	all_done=0
	while (( !all_done )); do
		echo ""
		options=("Show all DBs." "Create DB." "Use DB." "Delete DB." "Quit.")
		echo "Choose an option:"
		echo ""
		find ~/my_DB_Engine -maxdepth 1 -type f -print0 | xargs -r -0 rm
		select opt in "${options[@]}"; do
		        case $REPLY in
				1)
					show_dbs
					break
					;;
				2)
					create_db
					break
					;;
				3)
					use_db
					table_options
					break
					;;
				4)
					delete_db
					break
					;;
				5)
					break 2
					;;
				*)
					echo "Invalid option!"
					;;
		        esac
		done

		echo "Do you want to do another operation?"
		select opt in "Yes" "No"; do
		        case $REPLY in
		                1) break ;;
				2) all_done=1; break ;;
		                *) echo "Invalid option!" ;;
		        esac
		done
	done
}


table_options(){
	all=0
	while (( !all )); do
		echo ""
		options=("Create table." "View table," "Delete table." "Insert into table." "Update row."  "View row." "Delete row." "Alter table." "Show tables." "Back." "Quit.")
		echo "Choose an option:"
		echo ""
		#if [ "$(ls -A ~/my_DB_Engine/$my_used_db)" ];then
		#	rm -R -- ~/my_DB_Engine/$my_used_db/*/
		#fi
		select opt in "${options[@]}"; do
			case $REPLY in
				1)
					create_table
					break
					;;
				2)
					view_table
					break
					;;
				3)
					delete_table
					break
					;;
				4)
					insert_table
					break	
					;;
				5)
					update_table
					break				
					;;
				6)	
					view_row
					break	
					;;
				7)
					delete_row
					break
					;;
				8)
					alter_table
					break
					;;
				9)
					show_tables
					break
					;;
				10)
					break 2
					;;
				11)
					break 4
					;;
				*)
					echo "invalid option"
					;;
			esac
		done

		echo "Do you want to do another operation?"
		select opt in "Yes" "No"; do
			case $REPLY in
				1) break ;;
				2) all=1; break ;;
				*) echo "Invalid option!" ;;
			esac
		done
	done
}

#calling.


db_options
