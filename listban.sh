#  !! add your free api key requested from https://ipinfo.io/account


cd /var/www/html/

rm listbaniptemp.txt
rm listjails.txt
rm listbanips2.txt
rm /var/lib/fail2ban/fail2ban.sqlite3copytemp

sudo cp /var/lib/fail2ban/fail2ban.sqlite3 /var/lib/fail2ban/fail2ban.sqlite3copytemp

echo "<html>"  > listban.html
echo "<META http-equiv=Content-Type content=\"text/html; charset=UTF-8\">"  >> listban.html
echo "<META content=\"MSHTML 6.00.2900.2912\" name=GENERATOR>"  >> listban.html
echo "<title>Fail2ban IPs</title>"  >> listban.html
echo "<head>"  >> listban.html
echo "<style>"  >> listban.html
echo "*{font-size:16px;}"  >> listban.html
echo "body{background-color:#ccc;}"  >> listban.html
echo "img{height:14px;width:14px;}"  >> listban.html
echo "p{font-size:18px;}"  >> listban.html

echo "table{background-color:#ccc;width:650px;border-spacing:0 4px;margin:0 auto;width:650px;}"  >> listban.html
echo "td{background-color:#fff;border-collapse:collapse;}"  >> listban.html
echo ".headers0{font-size:18px;background-color:#000;color:#fff;}"  >> listban.html
echo ".headers{font-size:30px;text-align:left;background-color:#000;color:#fff;}"  >> listban.html
echo ".box{display:flex;justify-content:space-around;}"  >> listban.html
echo ".hardware{background-color:#1E90FF;color:#fff;}"  >> listban.html
echo ".values{text-align:left;}"  >> listban.html
echo ".td_ip{text-align:left;}"  >> listban.html
echo ".td_country{text-align:left;}"  >> listban.html
echo ".td_city{text-align:left;}"  >> listban.html
echo ".td_loc{text-align:left;}"  >> listban.html

echo "#divmain{margin:0 auto;width:800px}"  >> listban.html
echo "#divtop{background-color:#fff;color:#000;font-size:24px;display:table;text-align:center;margin:0 auto;width:650px;}"  >> listban.html
echo "#divtop > .child {display: table-cell;vertical-align: middle;}"  >> listban.html

echo "#outerdiv {top:0px; width: 100%; height: 550px; position:fixed; text-align:center; z-index: 1;}"  >> listban.html
echo "#mapdiv {width:1000px;height:550px; margin:0px auto; display:inline-block}"  >> listban.html

echo "#divdata {top:560px; width: 100%; position: relative; text-align:center; }"  >> listban.html

echo "</style>"  >> listban.html
echo "</head>"  >> listban.html
echo "<body>"  >> listban.html

echo "<div id="outerdiv">"  >> listban.html
echo "<div id="mapdiv" />"  >> listban.html
echo "</div>"  >> listban.html
echo "</div>"  >> listban.html

echo "<div id=divdata>"  >> listban.html

echo "<div id=divmain>"  >> listban.html
echo "<div id=divtop>"  >> listban.html
echo "<p>$(date)</p>"  >> listban.html
echo "<p>Nombre de bans</p>"  >> listban.html

echo "<p>"  >> listban.html
sudo sqlite3 /var/lib/fail2ban/fail2ban.sqlite3copytemp "select count(*) from bans ;" >> /var/www/html/listban.html
echo "</p>"  >> listban.html
#echo -e "<br><br>"  >> listban.html
sudo sqlite3 /var/lib/fail2ban/fail2ban.sqlite3copytemp "SELECT name FROM jails;"  > listjails.txt

touch listbaniptemp.txt

zfile="listjails.txt"
while read line
do
zero="0"
result=$(sudo sqlite3 /var/lib/fail2ban/fail2ban.sqlite3copytemp "select count(*) from bans where jail = \"$line\";")
if [ $result != $zero ]
then
echo -e "<p>$line</p><p>$result</p>"  >> listban.html
sudo sqlite3 /var/lib/fail2ban/fail2ban.sqlite3copytemp "SELECT ip FROM bans where jail = \"$line\";"  >> listbaniptemp.txt
fi
done < "$zfile"

# check if unique ip
sort -u listbanips.txt  > listbanips2.txt
cp listbanips2.txt listbanips.txt

echo "</div>"  >> listban.html 
echo "</div>"  >> listban.html 

echo "<div id=divtable><table id=T1 cellspacing="10"><tr class=border_bottom><td class=headers>IP<td class=headers>Country<td class=headers>City<td class=headers>Location&nbsp;&nbsp;" >> /var/www/html/listban.html

zfile="listbaniptemp.txt"
while read line
do  
  if grep "$line" listbanips.txt
    then 
      grep -w "$line" listbanips.txt  >> listban.html
    else
      #Address not found so get the country and write in listbanips.txt 
      varCountry="$(curl http://ipinfo.io/$line/country/?token=---YOUR---API---KEY---)";
      varCity="$(curl http://ipinfo.io/$line/city/?token=---YOUR---API---KEY---)";      
      varLoc="$(curl http://ipinfo.io/$line/loc/?token=---YOUR---API---KEY---)";   

      echo "<tr class=\"border_bottom\">" >> listban.html 
      echo "<td class=\"values td_ip\">$line</td>" >> listban.html 
      echo "<td class=\"values td_country\">$varCountry</td>" >> listban.html  
      echo "<td class=\"values td_city\">$varCity</td>" >> listban.html  
      echo "<td class=\"values td_loc\">$varLoc</td>" >> listban.html 
      echo "</tr>" >> listban.html 
      
      echo "<tr class=\"border_bottom\"><td class=\"values td_ip\">$line</td><td class=\"values td_country\">$varCountry</td><td class=\"values td_city\">$varCity</td><td class=\"values td_loc\">$varLoc</td></tr>" >> listbanips.txt 
      
  fi  
done < "$zfile"

echo "</table>" >> listban.html 
echo "</div>"  >> listban.html
echo "</div>"  >> listban.html
echo "  "  >> listban.html
echo "  "  >> listban.html
echo "  "  >> listban.html

echo "$(cat  map_jscode.txt)" >> listban.html 

echo "  "  >> listban.html
echo "  "  >> listban.html
echo "  "  >> listban.html

echo "</body>" >> listban.html 
echo "</html>" >> listban.html 

rm listbaniptemp.txt
rm listjails.txt
rm listbanips2.txt
rm /var/lib/fail2ban/fail2ban.sqlite3copytemp

#database locked !!!!!!!!
#cd /var/lib/fail2ban/fail2ban.sqlite3copytemp
#fuser fail2ban.sqlite3copytemp
#kill -9 PID

#echo "" > /listban.sh
#nano /listban.sh