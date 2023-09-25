echo "--------------------------------------------------------------------------------------"
echo "Removing backup file - NEEDS SUDO PASSWORD"
sudo rm -rf data-slave
echo "--------------------------------------------------------------------------------------"
echo "Undoing the compose configuration"
echo "--------------------------------------------------------------------------------------"
docker-compose down -v