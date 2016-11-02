#!/bin/bash 
# Shamelessly stolen from https://forums.gentoo.org/viewtopic-p-7578926.html#7578926

#### Clear #### 
                
iptables -F    
iptables -X    
                
#++++++++++++++ 


#### Policy #################### 
                              
iptables -P INPUT   DROP      
iptables -P FORWARD DROP      
iptables -P OUTPUT  DROP     
             
#+++++++++++++++++++++++++++++++ 


##### CUSTOM CHAINS #################################################################### 
                                                                                       
# Icmp                                                                                 
iptables -N ICMP                                                                       
iptables -A ICMP -m limit --limit 15/minute -j LOG --log-prefix "ICMP: "               
iptables -A ICMP -j DROP                                                               
                                                                                       
# Bad Flags, Bogus etc.                                                                
iptables -N BOGUS                                                                      
iptables -A BOGUS -m limit --limit 15/minute -j LOG  --log-prefix "Bogus: "            
iptables -A BOGUS -j DROP                                                              
                                                                                       
# Lan Spoof                                                                            
iptables -N LANSPOOF                                                                   
iptables -A LANSPOOF -m limit --limit 15/minute -j LOG --log-prefix "LanSpoof: "       
iptables -A LANSPOOF -j DROP                                                           
                                                                                       
# Loopback Spoof                                                                       
iptables -N LOOPSPOOF                                                                  
iptables -A LOOPSPOOF -m limit --limit 15/minute -j LOG --log-prefix "LoopSpoof: "     
iptables -A LOOPSPOOF -j DROP                                                          
                                                                                       
# Final Firewall                                                                      
iptables -N FIREWALL                                                                   
iptables -A FIREWALL -m limit --limit 15/minute -j LOG --log-prefix "Firewall: "       
iptables -A FIREWALL -j DROP                         
                                     
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 


##### INPUT BLOCK ############################################################################## 
                                     
# Drop all ICMP                                  
iptables -A INPUT -p icmp -j ICMP                         
                                     
# LAN Spoof                                                                                   
iptables -A INPUT -i eth0 -s 192.168.0.0/24 -j LANSPOOF                                       
iptables -A INPUT -i wlan0 -s 192.168.0.0/24 -j LANSPOOF                                      
                                                                                              
# Loopback Spoof                                                                              
iptables -A INPUT ! -i lo -s 127.0.0.0/8 -j LOOPSPOOF                                         
                                                                                              
# Fragments                                                                                   
iptables -A INPUT -f -j BOGUS                                                                 
                                                                                              
# Bogus packets                                                                               
iptables -A INPUT -m conntrack --ctstate INVALID -j BOGUS                                      
                                     
iptables -A INPUT -p tcp --tcp-flags FIN,ACK FIN -j BOGUS                                     
iptables -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j BOGUS                                     
iptables -A INPUT -p tcp --tcp-flags ACK,URG URG -j BOGUS                                     
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j BOGUS                                 
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j BOGUS                                 
iptables -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j BOGUS                                 
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j BOGUS                                         
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j BOGUS                                        
iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j BOGUS                                 
iptables -A INPUT -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j BOGUS                             
iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j BOGUS             
iptables -A INPUT -m conntrack --ctstate NEW,RELATED -p tcp ! --tcp-flags ALL SYN -j BOGUS    
                                     
                                     
#----- INPUT ACCEPT ---------------------------------------------------------------------------- 
                                     
# Already established and related                                                 
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT            
                                     
# Loopback                                                                        
iptables -A INPUT -i lo -j ACCEPT                                                 
                                     
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 



##### OUTPUT BLOCK ##################################################################### 
                                  
# Drop all ICMP                               
iptables -A OUTPUT -p icmp -j ICMP                      
                                  
# Bogus packets                               
iptables -A OUTPUT -m conntrack --ctstate INVALID -j BOGUS             
                                  
#---- OUTPUT ACCEPT -------------------------------------------------------------------- 
                                  
# Loopback                               
iptables -A OUTPUT -o lo -j ACCEPT                      
                                  
# DNS                                  
iptables -A OUTPUT -p udp --dport 53 -d 208.67.222.222 -j ACCEPT          
iptables -A OUTPUT -p udp --dport 53 -d 208.67.220.220 -j ACCEPT          
                                  
# Services                               
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT                   
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT                                     
iptables -A OUTPUT -p tcp --dport 873 -j ACCEPT                               
                                  
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 



##### FORWARD BLOCK #################################################################### 
                                  
# Bogus Packets                               
iptables -A FORWARD -m conntrack --ctstate INVALID -j BOGUS             
                                  
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 



##### FINAL CATCH ALL ########## 
             
iptables -A INPUT  -j FIREWALL    
iptables -A OUTPUT -j FIREWALL    
             
#+++++++++++++++++++++++++
