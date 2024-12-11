############ Change This Part for Initial Executions ############

echo ----- STARTS -----
service_list=`cat 01_services_for_template_HIS.csv`
########### Define All Required Variables ##########

echo ----- Iterates List of Services -----
for service_item in $service_list
do
  sleep 1
  #  1. Get Job Name and Action
  echo $service_item
  
  cluster_name=$(echo $service_item | cut -d ";" -f1)
  echo "cluster_name= $cluster_name"

  container_name=$(echo $service_item | cut -d ";" -f2)
  echo "container_name= $container_name"

    if [ $cluster_name = "ecs_cluster_name" ]; then
        echo ----- This is Header, DO NOTHING -----
    else
        echo "1. Access Service Folder: svc-$container_name"
        
        cd "$container_name"

        pwd
        echo -------------------------
        echo "2. Terraform Init"

        terraform init

        echo -------------------------
        echo "3. Terraform Apply"

        terraform apply -var-file="vpce.tfvars" -auto-approve -lock=False

        echo -------------------------
        # echo "4. Remove Terraform State"

        # rm -r .terraform/ .terraform.lock.hcl

        echo -------------------------
        
        cd ../..

        pwd

    fi
done

