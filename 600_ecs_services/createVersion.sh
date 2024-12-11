
# get input for new service name (name will be folder name)

# copy and create template

############ Change This Part for Initial Executions ############

echo ----- STARTS -----
service_list=`cat 01_services_for_template.csv`
########### Define All Required Variables ##########

echo ----- Iterates List of Services -----
for service_item in $service_list
do
  sleep 1
  #  1. Get Job Name and Action
  echo $service_item
  
  container_name=$(echo $service_item | cut -d ";" -f1)
  echo "container_name= $container_name"

    
        #echo "1. go to  Service Folder $container_name"
        #cd $container_name

        echo ----------------------------------------
        
        echo "2. Copy Template folder to new folder svc-$container_name"
        cp -R -p 000template/. $container_name
        number_of_files=$(ls $container_name | wc -l)

        echo "- Number of Files inside svc-$container_name: $number_of_files"
        
        echo ----------------------------------------
        
        echo "3. Replacing Value on apps.tfvars inside folder svc-$container_name"

        sed -i "s%<container_name>%$container_name%" $container_name/version.tf
        echo -------- NEXT Service --------
 
done


echo ----- ENDS -----
echo ----- ---- -----
echo ----- ---- -----
