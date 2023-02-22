---
title: "Armbian Boots to Display Chinese Character Stroke Order Learning"
date: 2023-02-18T20:04:12+08:00
draft: true
---

# 家庭数字显示屏自动化--小学汉字笔画，拼音展示

>  一直想折腾一个家庭数字内容显示屏，想了很久，之前做的都是打开一个播放器播放视频，内容比较单一
>  今天有时间用golang语言基于goframe框架做一个汉字笔顺，笔画展示，包括拼音显示，然后通过电视屏
>  和arm开发板小盒子（n1）自动化运行。运行程序系统环境 Debian Buster with Armbian Linux 5.1.15-aml-s905
>  目前自动开机用到的主要硬件设备小米开关，小米电视，小米智能音箱等设备

>  内容管理系统

>  n1开机自动运行程序    
   
   .desktop 程序是用来控制开机自启桌面程序  
   ```bash
		admin@amlbian:~$ cat ~/.config/autostart/ad.desktop 
		[Desktop Entry]
		Encoding=UTF-8
		Version=0.9.4
		Type=Application
		Name=ad
		Comment=ad
		#Exec=nohup mpv --playlist=/mnt/nfs/my_list.txt --loop-playlist=inf --fullscreen=yes &
		Exec=chromium  --noerrdialogs --disable-session-crashed-bubble --disable-infobars  --kiosk http://localhost:81/characters/show
		StartupNotify=false
		Terminal=false
		Hidden=false
   ```
>  内容控制程序
>  采用supervisor做开机自启go语言编写的内容控制程序
   
   
   ```bash 
        #/usr/bin/python /usr/local/bin/supervisord -c /etc/supervisord.conf
		
		[program:char]
		command=/root/character -c /root/config.yaml
		priority=-1
		autorestart=true
   ```