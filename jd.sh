#!/bin/sh
#
# Copyright (C) 2020 luci-app-jd-dailybonus <jerrykuku@qq.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#
#set -x


#url=https://gitee.com/lxk0301/jd_scripts/raw/master

red="\033[31m"
green="\033[32m"
yellow="\033[33m"
white="\033[0m"

#获取当前脚本目录copy脚本之家
Source="$0"
while [ -h "$Source"  ]; do
    dir_file="$( cd -P "$( dirname "$Source"  )" && pwd  )"
    Source="$(readlink "$Source")"
    [[ $Source != /*  ]] && Source="$dir_file/$Source"
done
dir_file="$( cd -P "$( dirname "$Source"  )" && pwd  )"
dir_file_js="$dir_file/js"

#检测当前位置
openwrt_script="/usr/share/jd_openwrt_script"
openwrt_script_config="/usr/share/jd_openwrt_script/script_config"
if [ "$dir_file" == "$openwrt_script/JD_Script" ];then
	script_dir="$openwrt_script_config"
	prompt=""
else
	script_dir="$dir_file"
	prompt="检测到你使用本地安装方式安装脚本，此方式后面会逐渐放弃，请按github：https://github.com/ITdesk01/jd_openwrt_script 重新编译插件"
fi

ccr_js_file="$dir_file/ccr_js"
run_sleep=$(sleep 1)

version="2.2"
cron_file="/etc/crontabs/root"
node="/usr/bin/node"
sys_model=$(cat /tmp/sysinfo/model | awk -v i="+" '{print $1i$2i$3i$4}')
uname_version=$(uname -a | awk -v i="+" '{print $1i $2i $3}')
wan_ip=$(ubus call network.interface.wan status | grep \"address\" | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

#Server酱
wrap="%0D%0A%0D%0A" #Server酱换行
wrap_tab="     "
line="%0D%0A%0D%0A---%0D%0A%0D%0A"
current_time=$(date +"%Y-%m-%d")
by="#### 脚本仓库地址:https://github.com/ITdesk01/JD_Script/tree/main 核心JS采用lxk0301开源JS脚本"
SCKEY=$(grep "let SCKEY" $script_dir/sendNotify.js  | awk -F "'" '{print $2}')




start_script="脚本开始运行，当前时间：`date "+%Y-%m-%d %H:%M"`"
stop_script="脚本结束，当前时间：`date "+%Y-%m-%d %H:%M"`"
script_read=$(cat $dir_file/script_read.txt | grep "我已经阅读脚本说明"  | wc -l)

task() {
	cron_version="3.00"
	if [[ `grep -o "JD_Script的定时任务$cron_version" $cron_file |wc -l` == "0" ]]; then
		echo "不存在计划任务开始设置"
		task_delete
		task_add
		echo "计划任务设置完成"
	elif [[ `grep -o "JD_Script的定时任务$cron_version" $cron_file |wc -l` == "1" ]]; then
			echo "计划任务与设定一致，不做改变"
			cron_help="$green定时任务与设定一致$white"
	fi
}

task_add() {
cat >>/etc/crontabs/root <<EOF
#**********这里是JD_Script的定时任务$cron_version版本#100#**********#
0 0 * * * $dir_file/jd.sh run_0  >/tmp/jd_run_0.log 2>&1 #0点0分执行全部脚本#100#
0 2-23/1 * * * $dir_file/jd.sh run_01 >/tmp/jd_run_01.log 2>&1 #种豆得豆收瓶子#100#
0 2-23/2 * * * $dir_file/jd.sh run_02 >/tmp/jd_run_02.log 2>&1 #摇钱树#100#
*/30 2-23 * * * $dir_file/jd.sh run_030 >/tmp/jd_run_030.log 2>&1 #两个工厂#100#
10 2-22/3 * * * $dir_file/jd.sh run_03 >/tmp/jd_run_03.log 2>&1 #天天加速 3小时运行一次，打卡时间间隔是6小时#100#
40 6-18/6 * * * $dir_file/jd.sh run_06_18 >/tmp/jd_run_06_18.log 2>&1 #不是很重要的，错开运行#100#
5 7 * * * $dir_file/jd.sh run_07 >/tmp/jd_run_07.log 2>&1 #不需要在零点运行的脚本#100#
35 10,15,20 * * * $dir_file/jd.sh run_10_15_20 >/tmp/jd_run_10_15_20.log 2>&1 #不是很重要的，错开运行#100#
10 8,12,16 * * * $dir_file/jd.sh run_08_12_16 >/tmp/jd_run_08_12_16.log 2>&1 #宠汪汪兑换礼品#100#
00 22 * * * $dir_file/jd.sh update_script that_day >/tmp/jd_update_script.log 2>&1 #22点更新JD_Script脚本#100#
5 9,11,19,22 * * * $dir_file/jd.sh update >/tmp/jd_update.log 2>&1 #9,11,19,22点05分更新lxk0301脚本#100#
*/30 1-22 * * * $dir_file/jd.sh joy >/tmp/jd_joy.log 2>&1 #1-22,每半个小时kill joy并运行一次joy挂机#100#
55 23 * * * $dir_file/jd.sh kill_joy >/tmp/jd_kill_joy.log 2>&1 #23点55分关掉joy挂机#100#
0 11 */7 * *  $node $dir_file/js/jd_price.js >/tmp/jd_price.log #每7天11点执行京东保价#100#
10-20/5 12 * * * $node $dir_file_js/jd_live.js	>/tmp/jd_live.log #京东直播#100#
30,31 20-23/1 20,23,28 4 * $node $dir_file_js/jd_live_redrain.js >/tmp/jd_live_redrain.log	#超级直播间红包雨#100#
###########100##########请将其他定时任务放到底下###############
#**********这里是backnas定时任务#100#******************************#
0 */4 * * * $dir_file/jd.sh backnas  >/tmp/jd_backnas.log 2>&1 #每4个小时备份一次script,如果没有填写参数不会运行#100#
############100###########请将其他定时任务放到底下###############
EOF
	/etc/init.d/cron restart
	cron_help="$yellow定时任务更新完成，记得看下你的定时任务$white"
}

task_delete() {
        sed -i '/#100#/d' /etc/crontabs/root >/dev/null 2>&1
}

ds_setup() {
	echo "JD_Script删除定时任务设置"
	task_delete
	echo "JD_Script删除全局变量"
	sed -i '/JD_Script/d' /etc/profile >/dev/null 2>&1
	source /etc/profile
	echo "JD_Script定时任务和全局变量删除完成，脚本彻底不会自动运行了"
}

update() {
	if [ ! -d $dir_file/git_clone ];then
		mkdir $dir_file/git_clone
	fi

	if [ ! -d $dir_file/git_clone/lxk0301 ];then
		git clone -b master git@gitee.com:lxk0301/jd_scripts.git $dir_file/git_clone/lxk0301
	else
		cd $dir_file/git_clone/lxk0301
		git fetch --all
		git reset --hard origin/master
	fi
	echo -e "$green update$start_script $white"
	echo -e "$green开始下载JS脚本，请稍等$white"
#cat script_name.txt | awk '{print length, $0}' | sort -rn | sed 's/^[0-9]\+ //'按照文件名长度降序：
#cat script_name.txt | awk '{print length, $0}' | sort -n | sed 's/^[0-9]\+ //' 按照文件名长度升序

cat >$dir_file/config/tmp/lxk0301_script.txt <<EOF
	jd_bean_sign.js			#京东多合一签到
	jx_sign.js			#京喜app签到长期
	jd_fruit.js			#东东农场
	jd_jxnc.js			#京喜农场
	jd_pet.js			#东东萌宠
	jd_plantBean.js			#种豆得豆
	jd_superMarket.js		#东东超市
	jd_blueCoin.js			#东东超市兑换奖品
	jd_dreamFactory.js		#京喜工厂
	jd_jdfactory.js			#东东工厂
	jd_joy_feedPets.js 		#宠汪汪单独喂食
	jd_joy.js			#宠汪汪
	jd_joy_reward.js 		#宠汪汪兑换奖品
	jd_crazy_joy.js			#crazyJoy任务
	jd_crazy_joy_coin.js		#crazy joy挂机领金币/宝箱专用
	jd_car_exchange.js		#京东汽车兑换，500赛点兑换500京豆
	jd_car.js			#京东汽车，签到满500赛点可兑换500京豆，一天运行一次即可
	jd_club_lottery.js		#摇京豆
	jd_shop.js			#进店领豆
	jd_bean_home.js			#领京豆额外奖励
	jd_rankingList.js		#京东排行榜签到得京豆
	jd_cash.js			#签到领现金，每日2毛～5毛长期
	jd_jdzz.js			#京东赚赚长期活动
	jd_lotteryMachine.js 		#京东抽奖机
	jd_necklace.js			#点点券
	jd_syj.js			#赚京豆
	jd_redPacket.js			#全民开红包
	jd_kd.js			#京东快递签到 一天运行一次即可
	jd_small_home.js		#东东小窝
	jd_speed.js			#天天加速
	jd_pigPet.js			#金融养猪
	jd_daily_egg.js 		#京东金融-天天提鹅
	jd_sgmh.js			#闪购盲盒长期活动
	jd_ms.js			#京东秒秒币
	jd_price.js			#京东保价
	jd_speed_sign.js		#京东极速版签到+赚现金任务
	jd_delCoupon.js			#删除优惠券（默认不运行，有需要手动运行）
	jd_crazy_joy_bonus.js		#监控crazyJoy分红狗(默认不运行，欧皇自己设置定时任务)
	jd_cfd.js			#京喜财富岛
	jd_live.js			#京东直播
	jd_jxd.js			#京小兑
	jd_live_redrain.js 		#超级直播间红包雨
	jd_mohe.js			#5G超级盲盒2021-03-19到2021-04-30 白天抽奖基本没有京豆，4小时运行一次收集热力值
	jd_carnivalcity.js		#京东手机狂欢城活动2021-4-1至2021-4-20
	jd_nzmh.js			#女装盲盒2021-4-1至2021-4-31
	jd_moneyTree.js 		#摇钱树
	jd_get_share_code.js		#获取jd所有助力码脚本
	jd_bean_change.js		#京豆变动通知(长期)
	jd_unsubscribe.js		#取关京东店铺和商品
EOF


cp  $dir_file/git_clone/lxk0301/activity/jd_unbind.js	$dir_file_js/jd_unbind.js #注销京东会员卡

for script_name in `cat $dir_file/config/tmp/lxk0301_script.txt | awk '{print $1}'`
do
	echo -e "$yellow copy $green$script_name$white"
	cp  $dir_file/git_clone/lxk0301/$script_name  $dir_file_js/$script_name
	sleep 1
done


if [ $(date "+%-H") -ge 10 ]; then
	echo "大于10点，不拉取和尚库"
else

url2="https://share.r2ray.com/dust/i-chenzhe"
cat >$dir_file/config/tmp/i-chenzhe_script.txt <<EOF
	z_fanslove.js			#粉丝互动
	z_shake.js  			#超级摇一摇
	z_marketLottery.js 		#京东超市-大转盘
	z_mother_jump.js		#新一期母婴跳一跳开始咯
	z_entertainment.js		#百变大咖秀
EOF


for script_name in `cat $dir_file/config/tmp/i-chenzhe_script.txt | awk '{print $1}'`
do
	url="$url2"
	wget $url2/$script_name -O $dir_file_js/$script_name
	update_if
done

url3="https://share.r2ray.com/dust/normal"
cat >$dir_file/config/tmp/monk-normal.txt <<EOF
	monk_shop_lottery.js 		#店铺大转盘
	monk_inter_shop_sign.js 	#interCenter渠道店铺签到
	monk_shop_follow_sku.js 	#关注有礼
	monk_skyworth.js 		#创维408下班全勤奖
EOF

for script_name in `cat $dir_file/config/tmp/monk-normal.txt | awk '{print $1}'`
do
	url="$url3"
	wget $url3/$script_name -O $dir_file_js/$script_name
	update_if
done

url4="https://share.r2ray.com/dust/car"
cat >$dir_file/config/tmp/monk-car.txt <<EOF
	monk_shop_add_to_car.js 	#加购有礼
	monk_skyworth_car.js 		#创维408下班全勤奖
EOF

for script_name in `cat $dir_file/config/tmp/monk-car.txt | awk '{print $1}'`
do
	url="$url4"
	wget $url4/$script_name -O $dir_file_js/$script_name
	update_if
done


url5="https://share.r2ray.com/dust/member"
cat >$dir_file/config/tmp/monk-member.txt <<EOF
	monk_pasture.js			#有机牧场
	monk_vinda.js			#“韧”性探索 空降好礼
EOF

for script_name in `cat $dir_file/config/tmp/monk-member.txt | awk '{print $1}'`
do
	url="$url5"
	wget $url5/$script_name -O $dir_file_js/$script_name
	update_if
done

fi

#将所有文本汇总
echo > $dir_file/config/collect_script.txt
for i in `ls  $dir_file/config/tmp`
do
	cat $dir_file/config/tmp/$i >> $dir_file/config/collect_script.txt
done

cat >>$dir_file/config/collect_script.txt <<EOF
	monk_shop_lottery.js 		#店铺大转盘
	getJDCookie.js			#扫二维码获取cookie有效时间可以90天
	jx_products_detail.js		#京喜工厂商品列表详情
	z_entertainment.js		#百变大咖秀
	jd_try.js 			#京东试用
	jd_gyec.js			#工业爱消除
	jd_xxl.js			#东东爱消除
	jd_xxl_gh.js			#个护爱消除，完成所有任务+每日挑战
	jd_opencard.js			#开卡活动，一次性活动，运行完脚本获得53京豆，进入入口还可以开卡领30都
	jd_friend.js			#JOY总动员 一期的活动
	jd_unbind.js 			#注销京东会员卡
	jdDreamFactoryShareCodes.js	#京喜工厂ShareCodes
	jdFruitShareCodes.js		#东东农场ShareCodes
	jdPetShareCodes.js		#东东萌宠ShareCodes
	jdPlantBeanShareCodes.js	#种豆得豆ShareCodes
	jdFactoryShareCodes.js		#东东工厂ShareCodes
	jdJxncShareCodes.js		#京喜农场ShareCodes
EOF

	wget https://raw.githubusercontent.com/whyour/hundun/master/quanx/jx_products_detail.js -O $dir_file_js/jx_products_detail.js #京喜工厂商品列表详情
	wget https://raw.githubusercontent.com/ZCY01/daily_scripts/main/jd/jd_try.js -O $dir_file_js/jd_try.js #京东试用


	if [ $? -eq 0 ]; then
		echo -e ">>$green脚本下载完成$white"
	else
		clear
		echo "脚本下载没有成功，重新执行代码"
		update
	fi
	chmod 755 $dir_file_js/*
	additional_settings
	concurrent_js_update
	echo -e "$green update$stop_script $white"
	task #更新完全部脚本顺便检查一下计划任务是否有变

}

update_if() {
	if [ $? -eq 0 ]; then
			echo -e ""
	else
		num="1"
		eeror_num="1"
		while [[ ${num} -gt 0 ]]; do
			wget $url/$script_name -O $dir_file_js/$script_name
			if [ $? -eq 0 ]; then
				num=$(expr $num - 1)
			else
				if [ $eeror_num -gt 10 ];then
					echo "下载$eeror_num次都失败，跳过这个下载"
					num=$(expr $num - 1)
				else
					echo -e "下载失败继续下载"
					eeror_num=$(expr $eeror_num + 1)
				fi
			fi
		done
	fi
}

update_script() {
	echo -e "$green update_script$start_script $white"
	cd $dir_file
	git fetch --all
	git reset --hard origin/main
	echo -e "$green update_script$stop_script $white"
}


run_0() {
cat >/tmp/jd_tmp/run_0 <<EOF
	jd_blueCoin.js  	#东东超市兑换，有次数限制，没时间要求
	jd_car_exchange.js   #京东汽车兑换，500赛点兑换500京豆
	jd_car.js #京东汽车，签到满500赛点可兑换500京豆，一天运行一次即可
	jx_sign.js #京喜app签到长期
	jd_lotteryMachine.js #京东抽奖机
	jd_cash.js #签到领现金，每日2毛～5毛长期
	jd_sgmh.js #闪购盲盒长期活动
	jd_jdzz.js #京东赚赚长期活动
	jd_small_home.js #东东小窝
	z_entertainment.js		#百变大咖秀
	monk_inter_shop_sign.js #interCenter渠道店铺签到
	jd_nzmh.js			#女装盲盒2021-4-1至2021-4-31
	jd_syj.js #十元街签到,一天一次即可，一周30豆子
	monk_shop_add_to_car.js #加购有礼
	monk_skyworth.js #创维408下班全勤奖
EOF
	echo -e "$green run_0$start_script $white"

	for i in `cat /tmp/jd_tmp/run_0 | awk '{print $1}'`
	do
		$node $dir_file_js/$i
		$run_sleep
	done

	run_08_12_16
	run_06_18
	run_10_15_20
	run_01
	run_03
	run_030
	$node $dir_file_js/jd_crazy_joy.js #crazyJoy任务
	echo -e "$green run_0$stop_script $white"
}

run_020() {
	echo -e "$green run_020$start_script $white"
	echo "run_020暂时没有东西"
	echo -e "$green run_020$stop_script $white"
}

run_030() {
	echo -e "$green run_030$start_script $white"
	$node $dir_file_js/jd_dreamFactory.js #京喜工厂 45分钟运行一次
	$node $dir_file_js/jd_jdfactory.js #东东工厂，不是京喜工厂
	echo -e "$green run_030$stop_script $white"
}

run_045() {
	echo -e "$green run_045$start_script $white"
	echo "run_045暂时没有东西"
	echo -e "$green run_045$stop_script $white"
}

run_01() {
	echo -e "$green run_01$start_script $white"
	$node $dir_file_js/jd_plantBean.js #种豆得豆，没时间要求，一个小时收一次瓶子
	$node $dir_file_js/jd_joy_feedPets.js  #宠汪汪喂食一个小时喂一次
	echo -e "$green run_01$stop_script $white"
}

run_02() {
	echo -e "$green run_02$start_script $white"
	$node $dir_file_js/jd_moneyTree.js #摇钱树
	if [ $(date "+%-H") -ge 13 ]; then
 		export PASTURE_EXCHANGE_KEYWORD="1京豆"
	else
 		export PASTURE_EXCHANGE_KEYWORD="10京豆"
	fi
	$node $dir_file_js/monk_pasture.js #有机牧场
	echo -e "$green run_02$stop_script $white"
}

run_03() {
	echo -e "$green run_03$start_script $white"
	$node $dir_file_js/jd_speed.js #天天加速 3小时运行一次，打卡时间间隔是6小时
	$node $dir_file_js/jd_mohe.js	#5G超级盲盒2021-03-19到2021-04-30 白天抽奖基本没有京豆，4小时运行一次收集热力值
	echo -e "$green run_03$stop_script $white"
}


run_06_18() {
cat >/tmp/jd_tmp/run_06_18 <<EOF
	jd_blueCoin.js  #东东超市兑换，有次数限制，没时间要求
	jd_shop.js #进店领豆，早点领，一天也可以执行两次以上
	jd_fruit.js #东东水果，6-9点 11-14点 17-21点可以领水滴
	jd_joy.js #jd宠汪汪，零点开始，11.30-15:00 17-21点可以领狗粮
	jd_pet.js #东东萌宠，跟手机商城同一时间
	jd_joy_steal.js #可偷好友积分，零点开始，六点再偷一波狗粮
	jd_daily_egg.js #天天提鹅蛋，需要有金融app，没有顶多报错问题不大
	jd_pigPet.js #金融养猪，需要有金融app，没有顶多报错问题不大
	jd_superMarket.js #东东超市,6点 18点多加两场用于收金币
EOF
	echo -e "$green run_06_18$start_script $white"

	for i in `cat /tmp/jd_tmp/run_06_18 | awk '{print $1}'`
	do
		$node $dir_file_js/$i
		$run_sleep
	done

	echo -e "$green run_06_18$stop_script $white"
}

run_07() {
cat >/tmp/jd_tmp/run_07 <<EOF
	jx_sign.js #京喜app签到长期
	jd_rankingList.js #京东排行榜签到领京豆
	jd_syj.js #十元街签到,一天一次即可，一周30豆子
	jd_kd.js #京东快递签到 一天运行一次即可
	jd_bean_home.js #领京豆额外奖励
	jd_club_lottery.js #摇京豆，没时间要求
	jd_jdzz.js #京东赚赚长期活动
	jd_jxnc.js #京喜农场
	jd_ms.js #京东秒秒币 一个号大概60
	jd_sgmh.js #闪购盲盒长期活动
	jd_speed_sign.js #京东极速版签到+赚现金任务
	z_fanslove.js #粉丝互动
	z_shake.js  #超级摇一摇
	jd_jxd.js #京小兑
	z_marketLottery.js 		#京东超市-大转盘
	z_mother_jump.js		#新一期母婴跳一跳开始咯
	z_entertainment.js		#百变大咖秀
	monk_shop_follow_sku.js #关注有礼
	jd_cash.js #签到领现金，每日2毛～5毛长期
	jd_carnivalcity.js		#京东手机狂欢城活动2021-4-1至2021-4-20
	monk_shop_lottery.js		#店铺大转盘
	monk_skyworth_car.js #创维408下班全勤奖
	monk_vinda.js	#“韧”性探索 空降好礼
	jd_unsubscribe.js 		#取关店铺，没时间要求
EOF
	echo -e "$green run_07$start_script $white"

	for i in `cat /tmp/jd_tmp/run_07 | awk '{print $1}'`
	do
		$node $dir_file_js/$i
		$run_sleep
	done

	#$node $dir_file_js/jd_unbind.js #注销京东会员卡
	echo -e "$green run_07$stop_script $white"
}

run_08_12_16() {
cat >/tmp/jd_tmp/run_08_12_16 <<EOF
	jd_joy_reward.js #宠汪汪积分兑换奖品，有次数限制，每日京豆库存会在0:00、8:00、16:00更新，经测试发现中午12:00也会有补发京豆
EOF
	echo -e "$green run_08_12_16$start_script $white"

	for i in `cat /tmp/jd_tmp/run_08_12_16 | awk '{print $1}'`
	do
		$node $dir_file_js/$i
		$run_sleep
	done

	echo -e "$green run_08_12_16$stop_script $white"
}

run_10_15_20() {
cat >/tmp/jd_tmp/run_10_15_20 <<EOF
	jd_superMarket.js #东东超市,0 10 15 20四场补货加劵
	jd_cfd.js #京东财富岛 有一日三餐任务
EOF

	echo -e "$green run_10_15_20$start_script $white"

	for i in `cat /tmp/jd_tmp/run_10_15_20 | awk '{print $1}'`
	do
		$node $dir_file_js/$i
		$run_sleep
	done
	$node $openwrt_script/JD_Script/js/jd_necklace.js  #点点券 大佬0,20领一次先扔这里后面再改
	echo -e "$green run_10_15_20$stop_script $white"
}


joy(){
	#crazy joy挂机领金币/宝箱专用
	echo -e "$green joy挂机领金币$start_script $white"
	kill_joy
	$node $dir_file_js/jd_crazy_joy_coin.js &
	echo -e "$green joy挂机领金币$stop_script $white"
}

kill_joy() {
	echo -e "$green  执行kill_joy$start_script $white"
	pid=$(ps -ww | grep "jd_crazy_joy_coin.js" | grep -v grep | awk '{print $1}')
	if [ $(echo $pid |wc -l ) == "1" ];then
		echo -e "$yellow发现joy后台程序开始清理，请稍等$white"
		for joy_pid in `echo $pid`
		do
			echo "kill $joy_pid"
			kill -9 $joy_pid
			sleep 2
		done
		echo -e "$green joy后台程序清理完成$white"
	else
		echo "$green没有运行的joy后台$white"
	fi
	echo -e "$green 执行kill_joy$stop_script $white"
}

script_name() {
	clear
	echo -e "$green 显示所有JS脚本名称与作用$white"
	cat $dir_file/config/collect_script.txt
}


jx() {
	echo -e "$green 查询京喜商品生产所用时间$start_script $white"
	$node $dir_file_js/jx_products_detail.js
	echo -e "$green 查询完成$stop_script $white"
}

jd_sharecode() {
	echo -e "$green 查询京东助力码$start_script $white"
	$node $dir_file_js/jd_get_share_code.js #获取jd所有助力码脚本
	echo -e "$green查询完成$start_script $white"
	echo ""
	jd_sharecode_if
}
jd_sharecode_if() {
	echo -e "$green============是否生成提交助力码格式，方便提交助力码，1.生成 2.不生成============$white"
	read -p "请输入：" code_Decide
	if [ "$code_Decide" == "1" ];then
		jd_sharecode_generate
	elif [ "$code_Decide" == "2" ];then
		echo "不做任何操作"
	else
		echo "请不要随便乱输！！！"
		jd_sharecode_if
	fi

}
jd_sharecode_generate() {
read -p "请输入你的名字和进群时间（例子：zhangsan_20210314，注意zhangsan是个例子，请写自己的名字～～～）：" you_name
$node $dir_file_js/jd_get_share_code.js >/tmp/get_share_code

cat > /tmp/code_name <<EOF
京东农场 fr
京东萌宠 pet
种豆得豆 pb
京喜工厂 df
京东赚赚 jdzz
crazyJoy crazyJoy
签到领现金 jdcash
闪购盲盒 jdsgmh
财富岛 cfd
EOF


code_number="0"
echo -e "$green============整理$you_name的Code============$white"

for i in `cat /tmp/code_name | awk '{print $1}'`
do
	code_number=$(expr $code_number + 1)
	o=$(cat /tmp/get_share_code | grep  "$i" | wc -l)
	p=$(cat /tmp/code_name | awk -v  a="$code_number" -v b="$you_name"  -v c="_" 'NR==a{print b c$2}')
	echo ""
	cat /tmp/get_share_code | grep  "$i" | awk -F '】' '{print $2}' | sed ':t;N;s/\n/@/;b t'  | sed "s/$/\"/" | sed "s/^/$i有$o个\Code：$p=\"/"
	echo ""
done
echo -e "$green============整理完成，可以提交了（没加群的忽略）======$white"

}

concurrent_js_run_07() {
	$node $openwrt_script/JD_Script/js/jd_redPacket.js #京东全民开红包，没时间要求
	$node $openwrt_script/JD_Script/js/jd_bean_change.js #京豆变更
	checklog #检测log日志是否有错误并推送
}

concurrent_js() {
	if [ $(ls $ccr_js_file/ | wc -l ) -gt "0" ];then
		for i in `ls $ccr_js_file/`
		do
			dir_file_js="$ccr_js_file/$i"
			$action &
		done
	else
		echo -e "$green>>并发文件夹为空开始下载$white"
			update
			concurrent_js_if
	fi
}

concurrent_js_update() {
	if [ "$ccr_if" == "yes" ];then
		rm -rf $ccr_js_file/*
		js_cookie=$(cat $openwrt_script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | grep -v "//'" |grep -v "// '")
		js_amount=$(echo "$js_cookie" |wc -l)

		while [[ ${js_amount} -gt 0 ]]; do
			mkdir $ccr_js_file/js_$js_amount
			cp $script_dir/jdCookie.js $ccr_js_file/js_$js_amount/jdCookie.js

			if [ ! -L "$ccr_js_file/js_$js_amount/sendNotify.js" ]; then
				rm -rf $$ccr_js_file/js_$js_amount/sendNotify.js
				ln -s $script_dir/sendNotify.js $ccr_js_file/js_$js_amount/sendNotify.js
			fi

			js_cookie_obtain=$(echo "$js_cookie" | awk -v a="$js_amount" 'NR==a{ print $0}') #获取pt
			sed -i '/pt_pin/d' $ccr_js_file/js_$js_amount/jdCookie.js >/dev/null 2>&1
			sed -i "5a $js_cookie_obtain" $ccr_js_file/js_$js_amount/jdCookie.js

			for i in `ls $dir_file_js | grep -v 'jdCookie.js\|sendNotify.js'`
			do
				cp $dir_file_js/$i $ccr_js_file/js_$js_amount/$i
			done

			js_amount=$(($js_amount - 1))
		done
	fi
}

concurrent_js_clean(){
		if [ "$ccr_if" == "yes" ];then
			echo -e "$yellow收尾一下$white"
			for i in `ps -ww | grep "$action" | grep -v 'grep\|kill_ccr' | awk '{print $1}'`
			do
				echo "开始kill $i"
				kill -9 $i
			done
		fi
}

kill_ccr() {
	if [ "$ccr_if" == "yes" ];then
		echo -e "$green>>终止并发程序启动。请稍等。。。。$white"
		if [ `ps -ww | grep "js$" | grep -v "jd_crazy_joy_coin.js" | awk '{print $1}' |wc -l` == "0" ];then
			sleep 2
			echo ""
			echo -e "$green我曾经跨过山和大海，也穿过人山人海。。。$white"
			sleep 2
			echo -e "$green直到来到你这里。。。$white"
			sleep 2
			echo -e "$green逛了一圈空空如也，你确定不是在消遣我？？？$white"
			sleep 2
			echo -e "$green后台都没有进程妹子，散了散了。。。$white"
		else
			for i in `ps -ww | grep "js$" | grep -v "jd_crazy_joy_coin.js" | awk '{print $1}'`
			do
				kill -9 $i
				echo "kill $i"
			done
			concurrent_js_clean
			clear
			echo -e "$green再次检测一下并发程序是否还有存在$white"
			if [ `ps -ww | grep "js$" | grep -v "jd_crazy_joy_coin.js" | awk '{print $1}' |wc -l` == "0" ];then
				echo -e "$yellow>>并发程序已经全部结束$white"
			else
				echo -e "$yellow！！！检测到并发程序还有存在，再继续杀，请稍等。。。$white"
				sleep 1
				kill_ccr
			fi
		fi
	else
		echo -e "$green>>你并发开关都没有打开，我终止啥？？？$white"
	fi
}

if_ps() {
	sleep 10
	ps_if=$(ps -ww | grep "js$" | grep -v "jd_crazy_joy_coin.js" | awk '{print $1}' |wc -l)
	num1="10"
	num2="20"
	num3="30"

	echo -e "$green>>开始第一次检测上一个并发程序是否结束($num1秒)$white"
	sleep $num1
	echo ""
	if [ "$ps_if" == "0" ];then
		echo -e "$green>>开始第二次检测上一个并发程序是否结束($num2秒)$white"
		sleep $num2
		if [ "$ps_if" == "0" ];then
			echo -e "$green>>开始第三次检测上一个并发程序是否结束($num3秒)$white"
			sleep $num3
			if [ "$ps_if" == "0" ];then
				echo -e "$yellow>>并发程序已经结束$white"
			else
				sleep $num3
				echo -ne "$green第三次检测到并发程序还在继续，$num3秒以后再检测$white"
				if_ps
			fi
			
		else
			sleep $num2
			echo -ne "$green第二次检测到并发程序还在继续，$num2秒以后再检测$white"
			if_ps
		fi
	else
		sleep $num1
		echo -ne "$green第一次检测到并发程序还在继续，$num1秒以后再检测$white"
		if_ps
	fi
	#for i in `ps -ww | grep "jd.sh run_" | grep -v grep | awk '{print $1}'`;do kill -9 $i ;done
}

concurrent_js_if() {
	if [ "$ccr_if" == "yes" ];then
		echo -e "$green>>检测到开启了账号并发模式$white"
		case "$action1" in
		run_0)
			action="$action1"
			$node $openwrt_script/JD_Script/js/jd_bean_sign.js "" #京东多合一签到
			concurrent_js && if_ps
			if [ ! $action2 ];then
				if_ps
				concurrent_js_clean
			else
				case "$action2" in
				run_07)
					action="$action2"
					$node $openwrt_script/JD_Script/js/jd_bean_sign.js "" #京东多合一签到
					concurrent_js && if_ps
					concurrent_js_run_07 && if_ps
					concurrent_js_clean
				;;
				esac
			fi
		;;
		run_07)
			action="$action1"
			$node $openwrt_script/JD_Script/js/jd_bean_sign.js "" #京东多合一签到
			concurrent_js && if_ps
			concurrent_js_run_07 && if_ps
			concurrent_js_clean
		;;
		run_03)
			run_03
		;;
		run_01|run_06_18|run_02|run_045|run_08_12_16|run_030|run_020)
			action="$action1"
			concurrent_js
			if_ps
			concurrent_js_clean
		;;
		esac
	else
		case "$action1" in
			run_0)
			$node $dir_file_js/jd_bean_sign.js "" #京东多合一签到
			$action1
			;;
			run_07)
			$node $dir_file_js/jd_bean_sign.js "" #京东多合一签到
			$action1
			concurrent_js_run_07
			;;
			run_01|run_06_18|run_10_15_20|run_03|run_02|run_045|run_08_12_16|run_07|run_030|run_020)
			$action1
			;;
		esac

		if [[ -z $action2 ]]; then
			echo ""
		else
			case "$action2" in
			run_0)
			$node $dir_file_js/jd_bean_sign.js "" #京东多合一签到
			$action2
			;;
			run_07)
			$node $dir_file_js/jd_bean_sign.js "" #京东多合一签到
			$action2
			concurrent_js_run_07
			;;
			run_01|run_06_18|run_10_15_20|run_03|run_02|run_045|run_08_12_16|run_07|run_030|run_020)
			$action2
			;;
		esac
		fi
	fi
}


checktool() {
	i=1
	while [ 100 -ge 0 ];do
		ps_check=$(ps -ww |grep "JD_Script" | grep -v "grep" |awk '{print $1}' | wc -l )
		echo "---------------------------------------------------------------------------"
		echo -e  "		检测者工具第$green$i$white次循环输出(ctrl+c终止)"
		echo "---------------------------------------------------------------------------"
		echo "负载情况：`uptime`"
		echo ""
		echo "进程状态："
		if [ "$ps_check" == "0"  ];then
			echo ""
			echo "	没有检测到并发进程"
		else
			ps -ww | grep "JD_Script" |grep -v 'grep\|checktool'
		fi
		sleep 2
		clear
		i=`expr $i + 1`
	done
}

getcookie() {
	#彻底完成感谢echowxsy大力支持
	echo ""
	echo -e "$yellow 温馨提示，如果你已经有cookie，不想扫码直接添加，可以用$green sh \$jd addcookie$white 增加cookie $green sh \$jd delcookie$white 删除cookie"
	$node $dir_file_js/getJDCookie.js && addcookie
}

addcookie() {
	
	if [ `cat /tmp/getcookie.txt | wc -l` == "1"  ];then
		clear
		you_cookie=$(cat /tmp/getcookie.txt)
		rm -rf /tmp/getcookie.txt
		echo -e "\n$green已经获取到cookie，稍等。。。$white"
		sleep 1
	else
		clear
		echo "---------------------------------------------------------------------------"
		echo -e "		新增cookie或者更新cookie"
		echo "---------------------------------------------------------------------------"
		echo ""
		echo -e "$green例子：$white"
		echo ""
		echo -e "$green pt_key=jd_10086jd_10086jd_10086jd_10086jd_10086jd_10086jd_10086;pt_pin=jd_10086; //二狗子$white"
		echo ""
		echo -e "$yellow pt_key=$green密码  $yellow pt_pin=$green 账号  $yellow// 二狗子 $green(备注这个账号是谁的)$white"
		echo ""
		echo -e "$yellow 请不要乱输，如果输错了可以用$green sh \$jd delcookie$yellow删除,\n 或者你手动去$green$script_dir/jdCookie.js$yellow删除也行\n$white"
		echo "---------------------------------------------------------------------------"
		read -p "请填写你获取到的cookie(一次只能一个cookie)：" you_cookie
		if [[ -z $you_cookie ]]; then
			echo -e "$red请不要输入空值。。。$white"
			exit 0
		fi
	fi
	echo -e "$yellow\n开始为你查找是否存在这个cookie，有就更新，没有就新增。。。$white\n"
	sleep 2
	new_pt=$(echo $you_cookie)
	pt_pin=$(echo $you_cookie | awk -F "pt_pin=" '{print $2}' | awk -F ";" '{print $1}')
	pt_key=$(echo $you_cookie | awk -F "pt_key=" '{print $2}' | awk -F ";" '{print $1}')

	if [ `cat $script_dir/jdCookie.js | grep "$pt_pin" | wc -l` == "1" ];then
		echo -e "$green检测到 $yellow${pt_pin}$white 已经存在，开始更新cookie。。$white\n"
		sleep 2
		old_pt=$(cat $script_dir/jdCookie.js | grep "$pt_pin" | sed -e "s/',//g" -e "s/'//g")
		old_pt_key=$(cat $script_dir/jdCookie.js | grep "$pt_pin" | awk -F "pt_key=" '{print $2}' | awk -F ";" '{print $1}')
		sed -i "s/$old_pt_key/$pt_key/g" $script_dir/jdCookie.js
		echo -e "$green 旧cookie：$yellow${old_pt}$white\n\n$green更新为$white\n\n$green   新cookie：$yellow${new_pt}$white\n"
		echo  "------------------------------------------------------------------------------"
	else
		echo -e "$green检测到 $yellow${pt_pin}$white 不存在，开始新增cookie。。$white\n"
		sleep 2
		cookie_quantity=$( cat $script_dir/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l)
		i=$(expr $cookie_quantity + 5)
		if [ $i == "5" ];then
			sed -i "5a \  '$you_cookie\'," $script_dir/jdCookie.js
		else
			sed -i "$i a\  '$you_cookie\'," $script_dir/jdCookie.js
		fi
		echo -e "\n已将新cookie：$green${you_cookie}$white\n\n插入到$yellow$script_dir/jdCookie.js$white 第$i行\n"
		cookie_quantity1=$( cat $script_dir/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l)
		echo  "------------------------------------------------------------------------------"
		echo -e "$yellow你增加了账号：$green${pt_pin}$white$yellow 现在cookie一共有$cookie_quantity1个，具体以下：$white"
		cat $script_dir/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | sed -e "s/',//g" -e "s/'//g"
		echo  "------------------------------------------------------------------------------"
	fi

	echo ""
	read -p "是否需要继续获取cookie（1.需要  2.不需要 ）：" cookie_continue
	if [ "$cookie_continue" == "1" ];then
		echo "请稍等。。。"
		sleep 1
		clear
		getcookie
	elif [ "$cookie_continue" == "2" ];then
		echo "退出脚本。。。"
		exit 0
	elif [ "$cookie_continue" == "3" ];then
		sleep 1
		clear
		addcookie
	else
		echo "请不要乱输，退出脚本。。。"
		exit 0
	fi

}

delcookie() {
	cookie_quantity=$(cat $script_dir/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l)
	if [ `cat $script_dir/jdCookie.js | grep "$pt_pin" | wc -l` -ge "1" ];then
		echo "---------------------------------------------------------------------------"
		echo -e "		删除cookie"
		echo "---------------------------------------------------------------------------"
		echo -e "$green例子：$white"
		echo ""
		echo -e "$green pt_key=jd_10086jd_10086jd_10086jd_10086jd_10086jd_10086jd_10086;pt_pin=jd_10086; //二狗子$white"
		echo ""
		echo -e "$yellow 请填写你要删除的cookie（// 备注 或者pt_pin 名都行）：$green二狗子 $white"
		echo -e "$yellow 请填写你要删除的cookie（// 备注 或者pt_pin 名都行）：$green jd_10086$white "
		echo "---------------------------------------------------------------------------"
		echo -e "$yellow你的cookie有$cookie_quantity个，具体如下：$white"
		cat $script_dir/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | sed -e "s/',//g" -e "s/'//g"
		echo "---------------------------------------------------------------------------"
		echo ""
		read -p "请填写你要删除的cookie（// 备注 或者pt_pin 名都行）：" you_cookie
		if [[ -z $you_cookie ]]; then
			echo -e "$red请不要输入空值。。。$white"
			exit 0
		fi
	
		sed -i "/$you_cookie/d" $script_dir/jdCookie.js
		clear
		echo "---------------------------------------------------------------------------"
		echo -e "$yellow你删除账号或者备注：$green${you_cookie}$white$yellow 现在cookie还有`cat $script_dir/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l`个，具体以下：$white"
		cat $script_dir/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | sed -e "s/',//g" -e "s/'//g"
		echo "---------------------------------------------------------------------------"
		echo ""
		read -p "是否需要删除cookie（1.需要  2.不需要 ）：" cookie_continue
		if [ "$cookie_continue" == "1" ];then
			echo "请稍等。。。"
			delcookie
		elif [ "$cookie_continue" == "2" ];then
			echo "退出脚本。。。"
			exit 0
		else
			echo "请不要乱输，退出脚本。。。"
			exit 0
		fi
	else
		echo -e "$yellow你的cookie空空如也，比地板都干净，你想删啥。。。。。$white"
	fi

}

checklog() {
	log1="checklog_jd.log" #用来查看tmp有多少jd log文件
	log2="checklog_jd_error.log" #筛选jd log 里面有几个是带错误的
	log3="checklog_jd_error_detailed.log" #将错误的都输出在这里

	cd /tmp
	rm -rf $log3

	#用来查看tmp有多少jd log文件
	ls ./ | grep -E "^j" | grep -v "jd_price.log" | sort >$log1

	#筛选jd log 里面有几个是带错误的
	echo -e "$line#### Model：$sys_model\n#### Wan+IP地址：+$wan_ip\n#### 系统版本:++$uname_version\n$line" >>$log3
	echo "#### $current_time+检测到错误日志的文件" >>$log3
	for i in `cat $log1`
	do
		grep -Elrn  "错误|失败" $i  >> $log2
		grep -Elrn  "错误|失败" $i  >> $log3
	done
	cat_log=$(cat $log2 | wc -l)
	if [ $cat_log -ge "1" ];then
		num="JD_Script发现有$cat_log个日志包含错误信息"
	else
		num="no_error"
	fi

	#将详细错误信息输出log3
	for i in `cat $log2`
	do
		echo "#### ${i}详细的错误" >> $log3
		grep -E  "错误|失败|module" $i | grep -v '京东天天\|京东商城\|京东拍拍\|京东现金\|京东秒杀\|京东日历\|京东金融\|京东金贴\|金融京豆\|检测\|参加团主\|参团失败\|node_modules\|sgmodule' | sort -u >> $log3
	done

	if [ $num = "no_error" ]; then
		echo "**********************************************"
		echo -e "$green log日志没有发现错误，一切风平浪静$white"
		echo "**********************************************"
	else
		if [ ! $SCKEY ];then
			echo "没找到Server酱key不做操作"
		else
			log_sort=$(cat ${log3} | sed "s/&//g" | sed "s/$/$wrap$wrap_tab$sort_log/g" |  sed ':t;N;s/\n//;b t' )
			log_sort1=$(echo "${log_sort}${by}" | sed "s/$wrap_tab####/####/g" )
			if [ ! $log_sort1 ];then
				echo -e "$red 推送失败$white，请检查 $log3是否存在"
			else
				echo "**********************************************"
				echo -e "$yellow检测$cat_log个包含错误的日志，已推送到你的接收设备$white"
				echo "**********************************************"
				curl -s "http://sc.ftqq.com/$SCKEY.send?text=$num" -d "&desp=${log_sort1}" >/dev/null 2>&1
				sleep 3
				echo -e "$green 推送完成$white"
			fi
		fi
	fi

	rm -rf $log1
	rm -rf $log2
}


#检测当天更新情况并推送
that_day() {
	cd $dir_file
	git fetch
	if [[ $? -eq 0 ]]; then
		echo ""
	else
		echo -e "$red>> 取回分支没有成功，重新执行代码$white"
		that_day
	fi
	clear
	git_branch=$(git branch -v | grep -o behind )
	if [[ "$git_branch" == "behind" ]]; then
		Script_status="建议更新"
	else
		Script_status="最新"
	fi

	if [ ! -d $dir_file/git_log ];then
		mkdir 	$dir_file/git_log
	fi

	echo > $dir_file/git_log/${current_time}.log


	git_log=$(git log --format=format:"%ai %an %s" --since="$current_time 00:00:00" --before="$current_time 23:59:59" | sed "s/+0800//g" | sed "s/$current_time //g" | sed "s/ /+/g")
	echo $git_log >/tmp/git_log_if.log
	git_log_if=$(grep -Eo "Zhang|ITdesk" /tmp/git_log_if.log | sort -u | wc -l )
	if [ $git_log_if -ge 1  ];then
		echo -e "$line#### Model：$sys_model\n#### Wan+IP地址：+$wan_ip\n#### 系统版本:++$uname_version\n$line#### $prompt\n#### $current_time+更新日志\n" >> $dir_file/git_log/${current_time}.log
		echo "  时间       +作者          +操作" >> $dir_file/git_log/${current_time}.log
		echo "$git_log" >> $dir_file/git_log/${current_time}.log
		echo "#### 当前脚本是否最新：$Script_status" >>$dir_file/git_log/${current_time}.log
	else
		echo -e "$line#### Model：$sys_model\n#### Wan+IP地址：+$wan_ip\n#### 系统版本:++$uname_version\n$line#### $prompt\n#### $current_time+更新日志\n" >> $dir_file/git_log/${current_time}.log
		echo "作者泡妹子或者干饭去了$wrap$wrap_tab今天没有任何更新$wrap$wrap_tab不要催佛系玩。。。" >>$dir_file/git_log/${current_time}.log
		echo "#### 当前脚本是否最新：$Script_status" >>$dir_file/git_log/${current_time}.log
	fi

	log_sort=$(cat  $dir_file/git_log/${current_time}.log |sed "s/$/$wrap$wrap_tab/" | sed ':t;N;s/\n//;b t' | sed "s/$wrap_tab####/####/g")
	log_sort1=$(echo "${log_sort}${by}" | sed "s/$wrap_tab####/####/g" )
	if [ ! $SCKEY ];then
			echo "没找到Server酱key不做操作"
	else
		if [ ! $log_sort1 ];then
			echo -e "$red 推送失败$white，请检查 $dir_file/git_log/${current_time}.log是否存在"
		else
			echo -e "$green开始推送JD_Script仓库状态$white"
			curl -s "http://sc.ftqq.com/$SCKEY.send?text=JD_Script仓库状态" -d "&desp=$log_sort1" >/dev/null 2>&1
			sleep 3
			echo -e "$green 推送完成$white"
		fi
	fi

}

backnas() {
	date_time=$(date +%Y-%m-%d-%H:%M | sed "s/:/_/")
	back_file_name="script_${date_time}.tar.gz"
	#判断所在文件夹
	if [ "$dir_file" == "$openwrt_script/JD_Script" ];then
		backnas_config_file="$openwrt_script_config/backnas_config.txt"
		back_file_patch="$openwrt_script"
		if [ ! -f "$openwrt_script_config/backnas_config.txt" ]; then
			backnas_config
		fi
	else
		backnas_config_file="$dir_file/config/backnas_config.txt"
		back_file_patch="$dir_file"
		if [ ! -f "$dir_file/config/backnas_config.txt" ]; then
			backnas_config
		fi
	fi

	#判断config文件
	backnas_config_version="1.0"
	if [ `grep -o "backnas_config版本$backnas_config_version" $backnas_config_file |wc -l` == "0" ]; then
		echo "backnas_config有变，开始更新"
		backnas_config
		echo "backnas计划任务设置完成"
	fi
	clear

	#判断依赖
	sshpass_if=$(opkg list-installed | grep 'sshpass' |awk '{print $1}')
	if [ ! $sshpass_if ];then
		echo "未检测到sshpass依赖，开始安装"
		opkg update
		opkg install sshpass
	fi

	#开始传递参数
	nas_user=$(grep "user" $backnas_config_file | awk -F "'" '{print $2}')
	nas_secret_key=$(grep "secret_key" $backnas_config_file | awk -F "'" '{print $2}')
	nas_pass=$(grep "password" $backnas_config_file | awk -F "'" '{print $2}')
	nas_ip=$(grep "nas_ip" $backnas_config_file | awk -F "'" '{print $2}')
	nas_file=$(grep "nas_file" $backnas_config_file | awk -F "'" '{print $2}')
	nas_prot=$(grep "port" $backnas_config_file | awk -F "'" '{print $2}')

	echo "#########################################"
	echo "       backnas $backnas_version版本"
	echo "#########################################"
	#判断用户名
	if [ ! $nas_user ];then
		echo -e "$yellow 用户名:$red    空 $white"
		echo "空" >/tmp/backnas_if.log
	else
		echo -e "$yellow 用户名：$green $nas_user $white"
		echo "正常" >/tmp/backnas_if.log
	fi

	#判断密码
	if [ ! $nas_pass ];then
		echo -e "$yellow 密码：$red     空 $white"
		echo "空" >>/tmp/backnas_if.log
	else
		echo -e "$yellow 密码：$green这是机密不显示给你看 $white"
		echo "正常" >>/tmp/backnas_if.log
	fi

	#判断密钥
	if [ ! $nas_secret_key ];then
		echo -e "$yellow NAS 密钥：$green 空(可以为空)$white"
	else
		echo -e "$yellow NAS 密钥：$green $nas_secret_key $white"
		echo "正常" >>/tmp/backnas_if.log
	fi

	#判断IP
	if [ ! $nas_ip ];then
		echo -e "$yellow NAS IP:$red    空 $white"
		echo "空" >>/tmp/backnas_if.log
	else
		echo -e "$yellow NAS IP：$green$nas_ip $white"
		echo "正常" >>/tmp/backnas_if.log
	fi

	#判断NAS文件夹
	if [ ! $nas_file ];then
		echo -e "$yellow NAS文件夹:$red 空 $white"
		echo "空" >>/tmp/backnas_if.log
	else
		echo -e "$yellow NAS备份目录：$green $nas_file $white"
		echo "正常" >>/tmp/backnas_if.log
	fi

	#判断端口
	if [ ! $nas_prot ];then
		echo -e "$yellow NAS 端口:$red   空 $white"
	else
		echo -e "$yellow NAS 端口：$green $nas_prot $white"
	fi

	echo -e "$yellow 使用协议：$green SCP$white"
	echo ""
	echo -e "$yellow 参数填写$green$backnas_config_file$white"
	echo "#########################################"

	back_if=$(cat /tmp/backnas_if.log | sort -u )
	if [ $back_if == "空" ];then
		echo ""
		echo -e "$red重要参数为空 不执行备份操作，需要备份的，把参数填好,$white填好以后运行$green sh \$jd backnas $white测试一下是否正常$white"
		exit 0
	fi

	echo -e "$green>> 开始备份到nas$white"
	sleep 5

	echo -e "$green>> 开始打包文件$white"
	tar -zcvf /tmp/$back_file_name $back_file_patch
	sleep 5

	clear
	echo -e "$green>> 开始上传文件 $white"
	echo -e "$yellow注意事项: 首次连接NAS的ssh会遇见$green Do you want to continue connecting?$white然后你输入y卡住不动"
	echo -e "$yellow解决办法:ctrl+c ，然后$green ssh -p $nas_prot $nas_user@$nas_ip $white连接成功以后输$green logout$white退出NAS，重新执行$green sh \$jd backnas$white"
	echo ""
	echo -e "$green>> 上传文件中，请稍等。。。。 $white"

	if [ ! $nas_secret_key ];then
		if [ ! $nas_pass ];then
			echo -e "$red 密码：为空 $white参数填写$green$backnas_config_file$white"
			read a
			backnas
		else
			sshpass -p "$nas_pass" scp -P $nas_prot -r /tmp/$back_file_name $nas_user@$nas_ip:$nas_file
		fi
	else
		scp -P $nas_prot -i $nas_secret_key -r /tmp/$back_file_name $nas_user@$nas_ip:$nas_file
	fi

	if [ $? -eq 0 ]; then
		sleep 5
		echo -e "$green>> 上传文件完成 $white"
		echo ""
		echo "#############################################################################"
		echo ""
		echo -e "$green $date_time将$back_file_name上传到$nas_ip 的$nas_file目录$white"
		echo ""
		echo "#############################################################################"
	else
		echo -e "$red>> 上传文件失败，请检查你的参数是否正确$white"
	fi
	echo ""
	echo -e "$green>> 清理tmp文件 $white"
	rm -rf /tmp/*.tar.gz
	sleep 5
}

backnas_config() {
cat >$backnas_config_file <<EOF
################################################################
                 backnas_config版本$backnas_config_version
用于备份JD_script 到NAS 采用scp传输，请确保你的nas，ssh端口有打开
################################################################
#填入你的nas账号(必填)
user=''

#填入你nas的密码(密码和密钥必须填一个)
password=''

#填入你nas的密钥位置(可以留空)(密钥 > 密码,有密钥的情况优先使用密钥而不是密码)
secret_key=''

#填入nas IP地址可以是域名(必填)
nas_ip=''

#填入nas保存路径(必填)
nas_file=''

#端口(默认即可，ssh端口有变填这里)
port='22'
EOF
}

script_black() {
	#不是很完美，但也能用，后面再想想办法，grep无法处理$node 这种这样我无法判断是否禁用了，只能删除掉一了百了
	black_version="黑名单版本1.1"
	#判断所在文件夹
	if [ "$dir_file" == "$openwrt_script/JD_Script" ];then
		script_black_file="$openwrt_script_config/Script_blacklist.txt"
		if [ ! -f "$script_black_file" ]; then
			script_black_Description
		fi
		#script_black用于升级以后恢复链接
		if [ ! -f "$dir_file/config/Script_blacklist.txt" ]; then
			ln -s $script_black_file $dir_file/config/Script_blacklist.txt
		fi
	else
		script_black_file="$dir_file/config/Script_blacklist.txt"
		if [ ! -f "$script_black_file" ]; then
			script_black_Description
		fi
	fi

	if_script_black=$(grep "$black_version" $script_black_file | wc -l)
	if [  $if_script_black == "0" ];then
		echo "更新一下黑名单"
		rm -rf $dir_file/config/Script_blacklist.txt
		sed -i '/*/d' $script_black_file >/dev/null 2>&1
		sed -i '/jd_ceshi/d' $script_black_file >/dev/null 2>&1
		sed -i "s/ //g"  $script_black_file >/dev/null 2>&1
		echo "" >> $script_black_file >/dev/null 2>&1
		ln -s $script_black_file $dir_file/config/Script_blacklist.txt
		script_black_Description
	fi

	script_list=$(cat $script_black_file | sed  "/*/d"  | sed "/jd_ceshi/d" | sed "s/ //g" | awk '{print $1}')
	if [ ! $script_list ];then
		echo -e "$green 黑名单没有任何需要禁用的脚本，不做任何处理$white"
	else
		for i in `echo "$script_list"`
		do
			if [ `grep "dir_file_js\/$i" $dir_file/jd.sh  | wc -l` -gt 0 ];then
				echo "开始删除关于$i脚本的代码，后面需要的话看黑名单描述处理"
				sed -i "/\$node \$dir_file_js\/$i/d" $dir_file/jd.sh
			elif [ `grep "$i" $dir_file/jd.sh  | wc -l` -gt 0 ];then
				echo "开始删除关于$i脚本的代码，后面需要的话看黑名单描述处理"
				sed -i "/$i/d" $dir_file/jd.sh
			else
				echo "黑名单脚本已经全部禁用了"
			fi
		done
	fi
	clear
}

script_black_Description() {
cat >> $script_black_file <<EOF
******************************不要删使用说明，$black_version*********************************************************************
*
*这是脚本黑名单功能，作用就是你跑脚本黑活动了，你只需要把脚本名字放底下，跑脚本的时候（全部账号）就不会跑这个脚本了
*但你可以通过node  脚本名字来单独跑（只是不会自动跑了而已）
*PS：（彻底解开的办法就是删除这里的脚本名称，然后更新脚本）
*例子
*
* 	jd_ceshi1.js #禁用的脚本1
* 	jd_ceshi2.js #禁用的脚本2
*
*注意事项：禁用JOY挂机需要这么写 jd_crazy_joy_coin.js &
*按这样排列下去（一行一个脚本名字）
*每个脚本应的文件可以用 sh \$jd script_name                    #显示所有JS脚本名称与作用
*
*
***********************要禁用的脚本不要写这里面，不要删除这里的任何字符，也不要动里面的，往下面写随便你********************************
EOF
}

stop_script() {
	echo -e "$green 删掉定时任务，这样就不会定时运行脚本了$white"
	task_delete
	sleep 3

	echo -e "$green kill JOY$white"
	kill_joy
	sleep 3
	echo -e "$green处理完成，需要重新启用，重新跑脚本sh \$jd 就会添加定时任务了$white"
}


help() {
	#检查脚本是否最新
	echo "稍等一下，正在取回远端脚本源码，用于比较现在脚本源码，速度看你网络"
	cd $dir_file
	git fetch
	if [[ $? -eq 0 ]]; then
		echo ""
	else
		echo -e "$red>> 取回分支没有成功，重新执行代码$white"
		system_variable
	fi
	clear
	git_branch=$(git branch -v | grep -o behind )
	if [[ "$git_branch" == "behind" ]]; then
		Script_status="$red建议更新$white (可以运行$green sh \$jd update_script && sh \$jd update && sh \$jd $white更新 )"
	else
		Script_status="$green最新$white"
	fi
	task
	clear
	echo ----------------------------------------------------
	echo "	     JD.sh $version 使用说明"
	echo ----------------------------------------------------
	echo -e "$yellow 1.文件说明$white"
	echo ""
	echo -e "$green  $script_dir/jdCookie.js $white 在此脚本内填写JD Cookie 脚本内有说明"
	echo -e "$green  $script_dir/sendNotify.js $white 在此脚本内填写推送服务的KEY，可以不填"
	echo -e "$green  $script_dir/USER_AGENTS.js $white 京东UA文件可以自定义也可以默认"
	echo -e "$green  $script_dir/JS_USER_AGENTS.js $white 京东极速版UA文件可以自定义也可以默认"
	echo -e "$green  $script_dir/config/Script_blacklist.txt $white 脚本黑名单，用法去看这个文件"
	echo ""
	echo -e "$yellow JS脚本活动列表：$green $dir_file/git_clone/lxk0301/README.md $white"
	echo -e "$yellow 浏览器获取京东cookie教程：$green $dir_file/git_clone/lxk0301/backUp/GetJdCookie.md $white"
	echo -e "$yellow 脚本获取京东cookie：$green sh \$jd getcookie $white"
	echo ""
	echo -e "$red 注意：$white请停掉你之前运行的其他jd脚本，然后把$green JS脚本活动列表$white的活动全部手动点开一次，不知活动入口的，$dir_file_js/你要的js脚本里有写"
	echo ""
	echo -e "$yellow 2.jd.sh脚本命令$white"
	echo ""
	echo -e "$green  sh \$jd run_0  run_07			#运行全部脚本(除个别脚本不运行)$white"
	echo ""
	echo -e "$yellow个别脚本有以下："
	echo ""
	echo -e "$green  sh \$jd npm_install $white  			#安装 npm 模块"
	echo ""
	echo -e "$green  sh \$jd jx $white 				#查询京喜商品生产使用时间"
	echo ""
	echo -e "$green  sh \$jd jd_sharecode $white 			#查询京东所有助力码"
	echo ""
	echo -e "$green  sh \$jd joy $white				#运行疯狂的JOY(两个号需要1G以上，sh \$jd kill_joy 杀掉进程，彻底关闭需要先杀进程再禁用定时任务的代码)"
	echo ""
	echo -e "$green  sh \$jd checklog $white  			#检测log日志是否有错误并推送"
	echo ""
	echo -e "$green  sh \$jd that_day $white  			#检测JD_script仓库今天更新了什么"
	echo ""
	echo -e "$green  sh \$jd script_name $white  			#显示所有JS脚本名称与作用"
	echo ""
	echo -e "$green  sh \$jd backnas $white  			#备份脚本到NAS存档"
	echo ""
	echo -e "$green  sh \$jd stop_script $white  			#删除定时任务停用所用脚本"
	echo ""
	echo -e "$green  sh \$jd kill_ccr $white  			#终止并发"
	echo ""
	echo -e "$green  sh \$jd checktool $white  			#检测后台进程，方便排除问题"
	echo ""
	echo -e " 如果不喜欢这样，你也可以直接$green cd \$jd_file/js$white,然后用$green node 脚本名字.js$white "
	echo ""
	echo -e "$yellow 3.检测定时任务:$white $cron_help"
	echo -e "$yellow   定时任务路径:$white$green/etc/crontabs/root$white"
	echo ""
	echo -e "$yellow 4.如何排错或者你想要的互助码:$white"
	echo ""
	echo "  答1：如何排错有种东西叫更新，如sh \$jd update_script 和sh \$jd update"
	echo "  答2：如何排错有种东西叫查日志，如/tmp/里面的jd开头.log结果的日志文件"
	echo "  答3：你想要的互助码 sh \$jd jd_sharecode"
	echo ""
	echo "  看不懂代码又想白嫖，你还是洗洗睡吧，梦里啥都有，当然你可以用钞能力解决多数问题（你可以忽略这句，继续做梦）"
	echo ""
	echo -e "$yellow 5.检测脚本是否最新:$white $Script_status "
	echo ""
	echo -e "$yellow 6.个性化配置：$white $jd_config_version"
	echo ""
	echo -e "$yellow 7.JD_Script报错你可以反馈到这里:$white$green https://github.com/ITdesk01/JD_Script/issues$white"
	echo ""
	echo ""
	echo -e "本脚本基于$green x86主机测试$white，一切正常，其他的机器自行测试，满足依赖一般问题不大"
	echo ----------------------------------------------------
	echo " 		by：ITdesk"
	echo ----------------------------------------------------

	time &
}


additional_settings() {

	for i in `cat $dir_file/config/collect_script.txt | awk '{print $1}'`
	do
		sed -i "s/$.isNode() ? 20 : 5/0/g" $dir_file_js/$i
	done

	for i in `cat $dir_file/config/collect_script.txt | awk '{print $1}'`
	do
		sed -i "s/helpAu = true/helpAu = false/g" $dir_file_js/$i
	done

	#京小超兑换豆子
	sed -i "s/|| 0/|| $jd_blueCoin/g" $dir_file_js/jd_blueCoin.js

	#取消店铺从20个改成50个(没有星推官先默认20吧)
	sed -i "s/|| 20/|| $jd_unsubscribe/g" $dir_file_js/jd_unsubscribe.js

	if [ `cat $openwrt_script_config/sendNotify.js | grep "采用lxk0301开源JS脚本" | wc -l` == "0" ];then
	sed -i "s/本脚本开源免费使用 By：https:\/\/gitee.com\/lxk0301\/jd_docker/#### 脚本仓库地址:https:\/\/github.com\/ITdesk01\/JD_Script\/tree\/main 核心JS采用lxk0301开源JS脚本/g" $openwrt_script_config/sendNotify.js
	sed -i "s/本脚本开源免费使用 By：https:\/\/github.com\/LXK9301\/jd_scripts/#### 脚本仓库地址:https:\/\/github.com\/ITdesk01\/JD_Script\/tree\/main 核心JS采用lxk0301开源JS脚本/g" $openwrt_script_config/sendNotify.js
	fi
	

	#东东农场
	new_fruit1="0763443f7d6f4f5ea5e54adc1c6112ed@e61135aa1963447fa136f293a9d161c1@f9e6a916ad634475b8e77a7704b5c3d8@713f6d7bd3084b4eb157375e119ef521@6632c8135d5c4e2c9ad7f4aa964d4d11@31a2097b10db48429013103077f2f037@5aa64e466c0e43a98cbfbbafcc3ecd02@bf0cbdb0083d443499a571796af20896@690009b0d5674e85b751838b2fa6241e@5f952ad609b1440b94599eaec41d853f"
	zuoyou_20190516_fr="367e024351fe49acaafec9ee705d3836@3040465d701c4a4d81347bc966725137@82c164278e934d5aaeb1cf19027a88a3@a2504cd52108495496460fc8624ae6d4"
	zuoyou_random_fr="44ba60178aa04b7895fe60c8f3b80a71@7fe23f78c77a47b0aba16b302eedbd3c@3e0769f3bb2042d993194db32513e1b9@dbd7dcdbb75940d3b81282d0f439673f@2c464c0f26c24daf84eb2e1e76a98d02@813e19ad60b049bcbb96d29d07f59847@b167fbe380124583a36458e5045ead57@5a1448c1a7944ed78bca2fa7bfeb8440"
	Javon_20201224_fr="926a1ec44ddd459ab2edc39005628bf4"
	Javon_random_fr="b2921984328744d7bc4302738235a4a8@8ac8cb7c9ded4a17b8057e27ed458104@e65a8b0cd1cc433a87bfd5925778fadc@669e5763877c4f97ab4ea64cd90c57fa@86ab77a88a574651827141e1e8c0b4c6@8ac8cb7c9ded4a17b8057e27ed458104@33b778b454a64b1e91add835e635256c@c9bb7ca2a80d4c8ab2cae6216d7a9fe6@dcfb05a919ff472680daca4584c832b8@0ce9d3a5f9cd40ccb9741e8f8cf5d801@54ac6b2343314f61bc4a6a24d7a2eba1@bad22aba416d4fffb18ad8534b56ea60@e5a87df07c914457b855cbb2f115d0a4@9a4370f99abb4eda8fa61d08be81c1d7@d535648ffa3b45d79ff66b997ec8b629@8b8b4872ab9d489896391cc5798a56e2"
	minty_20210114_fr="f6480e96df4e4ddb9629008af9932f8e@d6eabd292ec944de84d6de00aa6833cb"
	chiyu_fr="f227e8bb1ea3419e9253682b60e17ae5"
	ashou_20210516_fr="9046fbd8945f48cb8e36a17fff9b0983@72abb03ca91a4569933c6c8a62a5622c@5e567ba1b9bd4389ae19fa09ca276f33@82b1494663f9484baa176589298ca4b3@616382e94efa476c90f241c1897742f1@d4e3080b06ed47d884e4ef9852cad568@ed2b2d28151a482eae49dff2e5a588f8@a8b204ae2a7541a18e54f5bfb7dcb04b"
	xiaobandeng_fr="64304080a2714e1cac59af03b0009581@e9333dbf9c294ad6af2792dacc236fe7"
	xiaodengzi_20190516_fr="52dc669f77c54a26857c989c5b28221f@15cb130472c7494fbffec1758094a3e1@1db8e48de262417aaeaed456cadbc021"
	xiaodengzi_random_20190516_fr="8284c080686b45c89a6c6f7d1ea7baac@f69821dde34540d39f95315c5290eb88@5e753c671d0644c7bb418523d3452975@c6f859ec57d74dda9dafc6b3c2af0a0f@8dda5802f0d54f38af48c4059c591007"
	cainiao5_20190516_fr="2a9ccd7f32c245d7a4d6c0fe1cafdd4c"
	wjq_20190516_fr="9aac4df8839742b6abae13606ad696cc"
	whiteboy_20190711_fr="dfb6b5dcc9d24281acbfce5d649924c0@319239c7aed84c1a97092ddbf2564717@45e193df45704b8bb25e04ea86c650bf@49fefaa873c84b398882218588b0647a"
	jiu_20210110_fr="a413cb9823394d2d91eb8346d2fa4514@96721546e8fd429dbfa1351c907ea0f7"
	Oyeah_20200104_fr="5e54362c4a294f66853d14e777584598@efea4e3699804ffb87074c64d1e448bd"
	shisan_20200213_fr="cf13366e69d648ff9022e0fdce8c172a@cedfefd072434e57afcd95bed69a5f5c"
	JOSN_20200807_fr="2868e98772cb4fac9a04cd43e964f337"
	Jhone_Potte_20200824_fr="f6f58dc91bad4e24b9dd6f9a1ba19950@674922141a014f13bdd882e8b5c15916@4f53be3edea541268b1b948456d6ff4e"
	liandao_20201010_fr="1c6474a197af4b3c8d40c26ec7f11c9e@6f7a7cc42b9342e29163588bafc3782b"
	adong_20201108_fr="3d1985319106483ba83de3366d3716d5@9e9d99a4234d45cd966236d3cb3908cf"
	deng_20201120_fr="bc26d0bdc442421aa92cafcf26a1e148@57cf86ce18ca4f4987ce54fae6182bbd@521a558fcce44fbbb977c8eba4ba0d40@389f3bfe4bdc45e2b1c3e2f36e6be260@26c79946c7cc4477b56d94647d0959f2@26c79946c7cc4477b56d94647d0959f2"
	gomail_20201125_fr="31fee3cdb980491aad3b81d30d769655@0fe3938992cb49d78d4dfd6ce3d344fc"
	baijiezi_20201126_fr="09f7e5678ef44b9385eabde565c42715@ea35a3b050e64027be198e21df9eeece@62595da92a5140a3afc5bc22275bc26c@cb5af1a5db2b405fa8e9ec2e8aca8581"
	superbei666_20201124_fr="599451cd6e5843a4b8045ba8963171c5@8cce0e4cb54b433c9eebd251753088fd"
	yiji_20201125_fr="df3ae0b59ca74e7a8567cdfb8c383f02@e3ec63e3ba65424881469526d8964657"
	mjmdz_20201217_fr="9cd630e21bf44a1ea1512402827e4655"
	JDnailao_20201230_fr="daec421fb1d745148c0ae9bb298f1157@b659160dacc9457cadce4f1615d00b36"
	xo_20201229_fr="0ab77174e0a446ceaf075d2de507066b"
	xiaobai_20201204_fr="71807a3f6e38467d8e47ddee0b4609a4"
	wuming_20201225_fr="2942e50caa074daba96bdacc277a653f"
	511099189_20210101_fr="0d03ac05fdec4d729f81fb3d7bb54088@ddc79232c6e74725950ee42fde939483@61f21ef708c948568854ec50c3627085"
	JOSN_20210102_fr="3aaa13bec82041d59e566d35cebb3bc9"
	Lili_20210121_fr="48651377d7544f6bbf32cbd7ef50be30"
	tanherongyi_20210121_fr="24156b43b0664cff955e2bedea49e2b5"
	test_fr="0282b62c955349bc80c67dca4e85d6b5@b1e184275cc24382a606dada8df0a3b2@529972002f044c6ca466e8998ab5ba6b@10cae0f60a43485c9920943f22c44b3d@304b39f17d6c4dac87933882d4dec6bc@3e6f0b7a2d054331a0b5b956f36645a9@5e54362c4a294f66853d14e777584598@f0f5edad899947ac9195bf7319c18c7f@d2803739f777439db682549aa78aab9a@1a5ca20c959a4599b62a1c4ae8a8375c@52576b732d6c4b30aa77ff68b455b4a8@6974964b92d64fc18168fbc341b44133@659bc12c8b1343b9b2f4349570493254"
	dajiangyou20210116_fr="5a9c24fc64934cc69781870c9a7976fe@e9d6368fbf4748a6a6a547fc50e39183@890974ee297f46188bb7939bade578c0"
	luckies_20210121_fr="9c091f728d54497ba7bb814c0d9c241e@85f87f57794c4b4d8a427d3ddb7b52b6"
	soso_20210204_fr="fa804980c0034b1ebb2b66ca041b9d43"
	NanshanFox_20210303_fr="466c4a6b914f4639ac3b2f8b62473365"
	xo_20201229_fr="0ab77174e0a446ceaf075d2de507066b@16de7030778b41cc84b43bc96b0a67b2@a659afbab858490d8c713a43be26d447"
	random_fruit="$xo_20201229_fr@$zuoyou_random_fr@$511099189_20210101_fr@$Javon_random_fr@$test_fr@$xiaodengzi_random_20190516_fr@$xiaodengzi_20190516_fr@$cainiao5_20190516_fr@$wjq_20190516_fr@$whiteboy_20190711_fr@$jiu_20210110_fr@$Oyeah_20200104_fr@$shisan_20200213_fr@$JOSN_20200807_fr@$Jhone_Potte_20200824_fr@$liandao_20201010_fr@$adong_20201108_fr@$deng_20201120_fr@$gomail_20201125_fr@$baijiezi_20201126_fr@$superbei666_20201124_fr@$yiji_20201125_fr@$mjmdz_20201217_fr@$JDnailao_20201230_fr@$xo_20201229_fr@$xiaobai_20201204_fr@$wuming_20201225_fr@$JOSN_20210102_fr@$Lili_20210121_fr@$tanherongyi_20210121_fr@$dajiangyou20210116_fr@$luckies_20210121_fr@$soso_20210204_fr@$NanshanFox_20210303_fr"
	random="$random_fruit"
	random_array
	new_fruit_set="'$new_fruit1@$zuoyou_20190516_fr@$Javon_20201224_fr@$minty_20210114_fr@$ashou_20210516_fr@$xiaobandeng_fr@$chiyu_fr@$random_set',"

	fr_rows=$(grep -n "shareCodes =" $dir_file_js/jd_fruit.js | awk -F ":" '{print $1}')
	frcode_rows=$(grep -n "FruitShareCodes = \[" $dir_file_js/jdFruitShareCodes.js | awk -F ":" '{print $1}')

	sed -i "$fr_rows a \ $new_fruit_set\n$new_fruit_set\n$new_fruit_set\n$new_fruit_set\n$new_fruit_set\n$new_fruit_set\n$new_fruit_set\n$new_fruit_set" $dir_file_js/jd_fruit.js
	sed -i "$frcode_rows a  \ $new_fruit_set\n$new_fruit_set\n$new_fruit_set\n$new_fruit_set\n$new_fruit_set\n$new_fruit_set\n$new_fruit_set\n$new_fruit_set" $dir_file_js/jdFruitShareCodes.js

	sed -i "s/dFruitBeanCard = false/dFruitBeanCard = $jd_fruit/g" $dir_file_js/jd_fruit.js #农场不浇水开始换豆

	#萌宠
	new_pet1="MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzcwMDAwMDAwMzk1OTQ4Njk==@MTE1NDQ5OTUwMDAwMDAwMzk3NDgyMDE==@MTAxODEyOTI4MDAwMDAwMDQwMTIzMzcx@MTEzMzI0OTE0NTAwMDAwMDA0MzI3NzE3MQ==@MTE1NDQ5OTIwMDAwMDAwNDQzNjYzMTE=@MTE1NDUwMTI0MDAwMDAwMDQ0MzY2NDMx"
	zuoyou_20190516_pet="MTEzMzI0OTE0NTAwMDAwMDAzODYzNzU1NQ==@MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzgwMDAwMDAwMzg2Mzc1Nzc=@MTE1NDAxNzgwMDAwMDAwMzg4MzI1Njc=@MTE1NDQ5OTIwMDAwMDAwNDM3MTM3ODc="
	zuoyou_random_pet="MTAxODc2NTE0NzAwMDAwMDAyNDk1MDMwMQ==@MTAxODc2NTEzNTAwMDAwMDAyMjc1OTY1NQ==@MTEzMzI0OTE0NTAwMDAwMDA0MzQ1OTI1MQ==@MTE1NDQ5OTUwMDAwMDAwNDM3MDkyMDc=@MTE1NDQ5OTUwMDAwMDAwNDQxNDI2MzU=@MTE0MjI0NTE1MjAwMDAwMDA0NzY2OTgyMQ==@MTAxODc2NTEzNDAwMDAwMDAyNzAxMjc1NQ==@MTAxODc2NTEzMDAwMDAwMDAyMTIzNjU5Nw=="
	Javon_20201224_pet="MTE1NDUyMjEwMDAwMDAwNDE2NzYzNjc="
	Javon_random_pet="MTE0MDQ3MzIwMDAwMDAwNDczODQ2MTM=@MTAxODc2NTEzMDAwMDAwMDAxODU0NzI3Mw==@MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzgwMDAwMDAwNDI1MjkxMDU=@MTE1NDQ5OTIwMDAwMDAwNDIxMjgyNjM=@MTE1NDAxNzYwMDAwMDAwMzYwNjg0OTE=@MTE1NDQ5OTIwMDAwMDAwNDI4Nzk3NTE=@MTE1NDQ5OTUwMDAwMDAwNDMwMTIxMzc=@MTE1NDQ5MzYwMDAwMDAwNDQ0NTA5MzM=@MTEzMzI0OTE0NTAwMDAwMDA0NDQ1ODY4NQ=="
	minty_20210114_pet="MTE1NDQ5OTIwMDAwMDAwNDM2ODM4NDk=@MTE1NDQ5OTIwMDAwMDAwNDM2OTE3NDM="
	chiyu_pet="MTAxODEyOTI4MDAwMDAwMDQwNzYxOTUx"
	ashou_20210516_pet="MTAxODEyOTI4MDAwMDAwMDM5NzM3Mjk5@MTEzMzI0OTE0NTAwMDAwMDAzOTk5ODU1MQ==@MTE1NDQ5OTIwMDAwMDAwNDIxMDIzMzM=@MTAxODEyMjkxMDAwMDAwMDQwMzc4ODU1@MTAxODc2NTEzMDAwMDAwMDAxOTcyMTM3Mw==@MTAxODc2NTEzMzAwMDAwMDAxOTkzMzM1MQ==@MTAxODc2NTEzNDAwMDAwMDAxNjA0NzEwNw=="
	Jhone_Potte_20200824_pet="MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzcwMDAwMDAwNDE3MDkwNzE=@MTE1NDUyMjEwMDAwMDAwNDE3NDU2MjU="
	xiaodengzi_20190516_pet="MTE1NDUwMTI0MDAwMDAwMDM5NTc4ODQz@MTAxODExNDYxMTEwMDAwMDAwNDAxMzI0NTk="
	cainiao5_20190516_pet="MTAxODc2NTEzMzAwMDAwMDAyMTg1ODcwMQ=="
	wjq_20190516_pet="MTAxODc2NTEzMTAwMDAwMDAyNDM5MjI0Mw=="
	whiteboy_20190711_pet="MTAxODc2NTEzMzAwMDAwMDAwNjU4NDU4NQ==@MTAxODc2NTE0NzAwMDAwMDAwNDI4ODExMQ=="
	jiu_20210110_pet="MTE1NDUwMTI0MDAwMDAwMDQwODg1ODg3@MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzgwMDAwMDAwNDM1NjI2Mjk="
	Oyeah_20200104_pet="MTE1NDQ5OTUwMDAwMDAwNDAyNTYyMjM="
	shisan_20200213_pet="MTAxODc2NTEzMjAwMDAwMDAyMjc4OTI5OQ==@MTAxODExNTM5NDAwMDAwMDAzOTYzODY1Nw=="
	JOSN_20200807_pet="MTEzMzI0OTE0NTAwMDAwMDA0MTc2Njc2Nw=="
	liandao_20201010_pet="MTE1NDQ5MzYwMDAwMDAwNDA3Nzk0MTc=@MTE1NDQ5OTUwMDAwMDAwNDExNjIxMDc="
	adong_20201108_pet="MTAxODc2NTEzMTAwMDAwMDAyMTIwNTc3Nw==@MTEzMzI0OTE0NTAwMDAwMDA0MjE0MjUyNQ=="
	deng_20201120_pet="MTE1NDUwMTI0MDAwMDAwMDM4MzAwMTI5@MTE1NDQ5OTUwMDAwMDAwMzkxMTY3MTU=@MTE1NDQ5MzYwMDAwMDAwMzgzMzg3OTM=@MTAxODc2NTEzNTAwMDAwMDAyMzk1OTQ4OQ==@MTAxODExNDYxMTAwMDAwMDAwNDA2MjUzMTk=@MTE1NDUwMTI0MDAwMDAwMDM5MTg4MTAz"
	gomail_20201125_pet="MTE1NDQ5MzYwMDAwMDAwMzcyOTA4MDU=@MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzYwMDAwMDAwNDE0MzQ4MTE="
	baijiezi_20201126_pet="MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzgwMDAwMDAwNDE0NzQ3ODM=@MTE1NDUyMjEwMDAwMDAwNDA4MTg2NDE=@MTAxODc2NTEzNTAwMDAwMDAwNTI4ODM0NQ==@MTAxODc2NTEzMDAwMDAwMDAxMjM4ODExMw=="
	superbei666_20201124_pet="MTAxODcxOTI2NTAwMDAwMDAyNjc1MzUzMw==@MTE1NDQ5OTIwMDAwMDAwNDE4MDc3MzE="
	yiji_20201125_pet="MTE1NDUwMTI0MDAwMDAwMDQyODExMzU1@MTEzMzI0OTE0NTAwMDAwMDA0Mjg4NTczOQ=="
	mjmdz_20201217_pet="MTAxODc2NTEzMTAwMDAwMDAyNzI5OTU3MQ=="
	JDnailao_20201230_pet="MTEzMzI0OTE0NTAwMDAwMDA0MzEzMjkzNw==@MTEzMzI0OTE0NTAwMDAwMDA0MzI1ODU4MQ=="
	xo_20201229_pet="MTAxODc2NTEzNTAwMDAwMDAyMzYzODQzNw=="
	xiaobai_20201204_pet="MTE1NDQ5OTUwMDAwMDAwMzk5OTY4NjE="
	wuming_20201225_pet="MTE1NDUyMjEwMDAwMDAwNDQwMzM4NjE="
	511099189_20210101_pet="MTE1NDUyMjEwMDAwMDAwNDUyODcwOTM=@MTEzMzI0OTE0NTAwMDAwMDA0NTM1MTg4Nw==@MTEzMzI0OTE0NTAwMDAwMDA0NTIxOTk3MQ=="
	JOSN_20210102_pet="MTE1NDQ5MzYwMDAwMDAwNDI4MjM0OTE="
	Lili_20210121_pet="MTE1NDUyMjEwMDAwMDAwNDM4MjYyMDE="
	tanherongyi_20210121_pet="MTAxODc2NTEzNDAwMDAwMDAwNTgyNjI2Nw=="
	dajiangyou20210116_pet="MTE1NDQ5OTUwMDAwMDAwNDQ1NDcwODM=@MTEzMzI0OTE0NTAwMDAwMDA0MzM4Mzk2Mw==@MTEzMzI0OTE0NTAwMDAwMDA0NDU5MjM2OQ=="
	luckies_20210121_pet="MTE1NDUyMjEwMDAwMDAwNDQxMjY1MTM=@MTE1NDQ5OTIwMDAwMDAwNDQxNjM5Mjc="
	NanshanFox_20210303_pet="MTE1NDUwMTI0MDAwMDAwMDQ0OTY5Njcx"
	xo_20201229_pet="MTAxODc2NTEzNTAwMDAwMDAyMzYzODQzNw==@MTEzMzI0OTE0NTAwMDAwMDA0MjkzMDE1MQ==@MTE1NDUwMTI0MDAwMDAwMDQzNDY5Mzcx"
	soso_20210204_pet="MTAxODc2NTEzMjAwMDAwMDAyMTM2NzI5OQ=="
	test_pet="MTE1NDUwMTI0MDAwMDAwMDQ1MzAyNjI5@MTAxODc2NTEzMTAwMDAwMDAwNjQ4MzU4NQ==@MTE1NDQ5OTIwMDAwMDAwNDUzMDYzMDc=@MTE1NDQ5MzYwMDAwMDAwNDUzMDI4NjM=@MTE1NDQ5MzYwMDAwMDAwMzk2NTY2MTE==@MTE1NDQ5OTUwMDAwMDAwMzk2NTY2MTk==@MTE1NDQ5OTUwMDAwMDAwNDAyNTYyMjM==@MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzcwMDAwMDAwNDA4MzcyOTU==@MTEzMzI0OTE0NTAwMDAwMDA0NDE3MTQwOQ==@MTEzMzI0OTE0NTAwMDAwMDA0NDUyNzI4NQ=="
	

	random_pet="$xo_20201229_pet@$zuoyou_random_pet@$Javon_random_pet@$test_pet@$xiaodengzi_20190516_pet@$cainiao5_20190516_pet@$wjq_20190516_pet@$whiteboy_20190711_pet@$jiu_20210110_pet@$Oyeah_20200104_pet@$shisan_20200213_pet@$JOSN_20200807_pet@$liandao_20201010_pet@$adong_20201108_pet@$deng_20201120_pet@$gomail_20201125_pet@$baijiezi_20201126_pet@$superbei666_20201124_pet@$yiji_20201125_pet@$mjmdz_20201217_pet@$JDnailao_20201230_pet@$xo_20201229_pet@$xiaobai_20201204_pet@$wuming_20201225_pet@$511099189_20210101_pet@$JOSN_20210102_pet@$Lili_20210121_pet@$tanherongyi_20210121_pet@$dajiangyou20210116_pet@$luckies_20210121_pet@$NanshanFox_20210303_pet@$soso_20210204_pet"
	random="$random_pet"
	random_array
	new_pet_set="'$new_pet1@$zuoyou_20190516_pet@$Javon_20201224_pet@$minty_20210114_pet@$ashou_20210516_pet@$Jhone_Potte_20200824_pet@$chiyu_pet@$random_set',"

	pet_rows=$(grep -n "shareCodes =" $dir_file_js/jd_pet.js | awk -F ":" '{print $1}')
	petcode_rows=$(grep -n "PetShareCodes = \[" $dir_file_js/jdPetShareCodes.js | awk -F ":" '{print $1}')

	sed -i "$pet_rows a \ $new_pet_set\n$new_pet_set\n$new_pet_set\n$new_pet_set\n$new_pet_set\n$new_pet_set\n$new_pet_set\n$new_pet_set" $dir_file_js/jd_pet.js
	sed -i "$petcode_rows a  \ $new_pet_set\n$new_pet_set\n$new_pet_set\n$new_pet_set\n$new_pet_set\n$new_pet_set\n$new_pet_set\n$new_pet_set" $dir_file_js/jdPetShareCodes.js

	#宠汪汪积分兑换奖品改成兑换500豆子，个别人会兑换错误(350积分兑换20豆子，8000积分兑换500豆子要求等级16级，16000积分兑换1000京豆16级以后不能兑换)
	sed -i "s/let joyRewardName = 0/let joyRewardName = $jd_joy_reward/g" $dir_file_js/jd_joy_reward.js

	#宠汪汪喂食改成80
	sed -i "s/|| 10/|| $jd_joy_feedPets/g" $dir_file_js/jd_joy_feedPets.js

	#宠汪汪不给好友喂食
	sed -i "s/let jdJoyHelpFeed = true/let jdJoyHelpFeed = $jd_joy_steal/g" $dir_file_js/jd_joy_steal.js


	#种豆
	new_plantBean1="nuvfqviuwvnigxx65s7s77gbbvd4thrll7o63pq@fn5sjpg5zdejnypipngfhaudisqrfccakjuyaty@e7lhibzb3zek2xhmmypkf6ratimjeenqwvqvwjq@4npkonnsy7xi3n46rivf5vyrszud7yvj7hcdr5a@mlrdw3aw26j3xeqso5asaq6zechwcl76uojnpha@nkvdrkoit5o65lgaousaj4dqrfmnij2zyntizsa@u5lnx42k5ifivyrtqhfjikhl56zsnbmk6v66uzi@5sxiasthesobwa3lehotyqcrd4@b3q5tww6is42gzo3u67hjquj54@b3q5tww6is42gzo3u67hjquj54"
	zuoyou_20190516_pb="sz5infcskhz3woqbns6eertieu@mxskszygpa3kaouswi7rele2ji@nuvfqviuwvnigxx65s7s77gbbvd4thrll7o63pq@fn5sjpg5zdejnypipngfhaudisqrfccakjuyaty@e7lhibzb3zek2xhmmypkf6ratimjeenqwvqvwjq@4npkonnsy7xi3vk7khql3p7gkpodivnbwjoziga@cq7ylqusen234wdwxxbkf23g6y"
	zuoyou_random_pb="s7ete3o7zokpafftarfntyydni@advwde6ogv6oya4md5eieexlfi@ubn2ft6u6wnfxwt6eyxsbcvj44@nuvfqviuwvnigxx65s7s77gbbvd4thrll7o63pq@fn5sjpg5zdejnypipngfhaudisqrfccakjuyaty@e7lhibzb3zek2xhmmypkf6ratimjeenqwvqvwjq@4npkonnsy7xi3tqkdk2gmzv5vdq4xk4g3cuwp7y@qmnmamd3ukiwrtnx6sq7g3blplzmvfmfttdfgqa@yamkm32as4qqgkqymjwa2emtlmfcmoymverzcda@mlrdw3aw26j3xizu2u66lufwmtn37juiz4xzwmi@e7lhibzb3zek35xkfdysslqi4jy7prkhfvxryma"
	Javon_20201224_pb="wpwzvgf3cyawfvqim3tlebm3evajyxv67k5fsza"
	Javon_random_pb="g3ekvuxcunrery7ooivfylv2ci5ac3f4ijdgqji@wgkx2n7t2cr5oa6ro77edazro3kxfdgh6ixucea@qermg6jyrtndlahowraj6265fm@rug64eq6rdioosun4upct64uda5ac3f4ijdgqji@t4ahpnhib7i4hbcqqocijnecby@5a43e5atkvypfxat7paaht76zy@gdi2q3bsj3n4dgcs5lxnn2tyn4@mojrvk5gf5cfszku73tohtuwli@l4ex6vx6yynouzcgilo46gozezzpsoyqvp66rta@beda5sgrp3bnfrynnqutermxoe"
	minty_20210114_pb="lo3353pm4j5vuzw3ca6oyqfolm@pnmikaxn42by2bztpgvbfazmjc5rdijsmlk3oci"
	chiyu_pb="crydelzlvftgpeyuedndyctelq"
ashou_20210516_pb="3wmn5ktjfo7ukgaymbrakyuqry3h7wlwy7o5jii@chcdw36mwfu6bh72u7gtvev6em@mlrdw3aw26j3w2hy5trqwqmzn6ucqiz2ribf7na@olmijoxgmjutzdb4pf2fwevfnx4fxdmgld5xu2a@yaxz3zbedmnzhemvhmrbdc7xhq@olmijoxgmjutyy7u5s57pouxi5teo3r4r2mt36i@olmijoxgmjutzh77gykzjkyd6zwvkvm6oszb5ni@dixtq55kenw3ykejvsax6y3xrq"
	xiaobandeng_pb="olmijoxgmjutzcbkzw4njrhy3l3gwuh6g2qzsvi@olmijoxgmjuty4tpgnpbnzvu4pl6hyxp3sferqa"
	xiaodengzi_20190516_pb="kcpj4m5kmd4sfdp7ilsvvtkdvu@nuvfqviuwvnigxx65s7s77gbbvd4thrll7o63pq@fn5sjpg5zdejnypipngfhaudisqrfccakjuyaty@e7lhibzb3zek2xhmmypkf6ratimjeenqwvqvwjq@4npkonnsy7xi32mpzw3ekc36hh7feakdgbbfjky@j3yggpcyulgljlovo4pwsyi3xa@uvutkok52dcpuntu3gwko34qta@vu2gwcgpheqlm5vzyxutfzc774"
	cainiao5_20190516_pb="mlrdw3aw26j3wuxtla52mzrnywbtfqzw6bzyi3y"
	wjq_20190516_pb="sv3wbqzfbzbip22dluyg3kqa5a"
	whiteboy_20190711_pb="jfbrzo4erngfjdjlvmvpkpgbgie7i7c6gsw54yq@e7lhibzb3zek3uzcrgdebl2uyh3kuh7kap6cwaq"
	jiu_20210110_pb="e7lhibzb3zek3ng2hntfcceilic4hw26k24s3li@mlrdw3aw26j3wbley5cfqbdzsfdhusjessnlavi"
	Oyeah_20200104_pb="e7lhibzb3zek234ckc2fm2yvkj5cbsdpe7y6p2a@ro7272wkuunmcy35e4iwsw3572qi2njhs4kkzgq"
	shisan_20200213_pb="mlrdw3aw26j3xzd26qnacr3cfnm4zggngukbhny@okj5ibnh3onz7yqop3tum45jigtppsihwynzavy"
	JOSN_20200807_pb="pmvt25o5pxfjzcquanxwokbgvu3h7wlwy7o5jii"
	Jhone_Potte_20200824_pb="h3cggkcy6agkh4ozcp5idack3aupbxyuunf2oti@l4ex6vx6yynouz2vsrqlkogw4gvwf5sihbmchdq@wsr6thb5bd25kamxdqdkgw2m5zfiwo4o66p6saa"
	liandao_20201010_pb="nxawbkvqldtx4wdwxxbkf23g6y@l4ex6vx6yynouxxefa4hfq6z3in25fmktqqwtca"
	adong_20201108_pb="qhw4z5vauoy4gfkaybvpmxvjfi@olmijoxgmjuty6wu5iufrhoi6jmzzodszk6xgda"
	deng_20201120_pb="e7lhibzb3zek3knwnjhrbaadekphavflo22jqii@olmijoxgmjutzfvkt4iu7xobmplveczy2ogou3i@f3er4cqcqgwogenz3dwsg7owhy@eupxefvqt76x2ssddhd35aysfrchgqeijzo2wdi@3en43v3ev6tvx55oefp3vb2xure67mm3kwgsm6a@nkvdrkoit5o657wm7ui35qcu2dmtir7t5h7sema"
	gomail_20201125_pb="yzhv4vqminty2u2tan56h4a764rocbe@nuvfqviuwvnigxx65s7s77gbbvd4thrll7o63pq@fn5sjpg5zdejnypipngfhaudisqrfccakjuyaty@e7lhibzb3zek2xhmmypkf6ratimjeenqwvqvwjq@4npkonnsy7xi2rducm544znpdzi2gnyg5ygrqei"
	baijiezi_20201126_pb="m6brcm36t5fvxhxnhnjzssq3fauk3bdje2jbnra@mlkc4vnryrhbob7aruocema224@vv3gwhnjzvf5scyicvcrylwldjf2yqvagsa35cy@76gkpqn3nufwjfzgfcv2mxfeimcie5fxpwtraba"
	superbei666_20201124_pb="gcdr655xfdjq764agedg7f27knlvxw5krpeddfq@gcdr655xfdjq764agedg7f27ko37tplq475lryq"
	yiji_20201125_pb="qm7basnqm6wnqtoyefmgh65nby@mnuvelsb76r27b4ovdbtrrl2u5a53z543epg7hi"
	mjmdz_20201217_pb="olmijoxgmjutyscsyoot23r7uze7u6yf6pwytni"
	JDnailao_20201230_pb="nijojgywxnignilnryycfs6pau@wi2pnlhpuslajhsfsb4kjtqvee"
	xo_20201229_pb="rm4pdd5xupcmtvhrdwrn6luniardbktuo6umwtq"
	xiaobai_20201204_pb="winnewkfnxhluiwm7kx5k6efhm"
	wuming_20201225_pb="2a3vrgaa5owcwvondjoj5ldosu"
	JOSN_20210102_pb="pmvt25o5pxfjzjmrc7fubka5hu3h7wlwy7o5jii"
	Lili_20210121_pb="n24x4hzuumfuu3a26r2o45ydxe"
	tanherongyi_20210121_pb="pmxp2qr7mydqspc3tkg77sgvvq"
	dajiangyou20210116_pb="wrqpt6mmzjh2ymuihokh6rch26iphcfu6tg2dti@mlrdw3aw26j3xfvou7sfasnhuibk3tfgwzxznuq@e7lhibzb3zek3zlf7yqqsp7cpancjboji2vxaba"
	luckies_20210121_pb="5itdl72qrkd7lbepefbvkmopla@dp4p7knb5s3qqkzpv3pxsm4u7bdci76fivwlseq"
	NanshanFox_20210303_pb="ciue6ohtv7r3wcx6l7kb2trrc3l5vknx47277hi"
	xo_20201229_pb="rm4pdd5xupcmtvhrdwrn6luniardbktuo6umwtq@nuvfqviuwvnigxx65s7s77gbbvd4thrll7o63pq@fn5sjpg5zdejnypipngfhaudisqrfccakjuyaty@e7lhibzb3zek2xhmmypkf6ratimjeenqwvqvwjq@4npkonnsy7xi2ydq2lfsktlu4r2v6ydelzxbeqq"
	soso_20210204_pb="4a4p77hwqfa46vitvdjryxnokyexmx7dvyzyvsi"
	511099189_20210101_pb="42jxwmz7ybhbkqdsfn5gpb5kde@pfuw5smhkmxx4gbokvsi3yifr4@uwgpfl3hsfqp3b4zn67l245x6cosobnqtyrbvaa"
	test_pb="llc3cyki3azsjryv3ovhiqpxtut2lkuv6hpeepa@e7lhibzb3zek3giovoz45el7ymgcpt7ng5qq3ni@olmijoxgmjutzy3d472v6l6xqdtegx4v4dpjo7q@aogye6x4cnc3pjc7clkvzuymko5xo6gnii54lua@olmijoxgmjutyy7u5s57pouxi5teo3r4r2mt36i@chcdw36mwfu6bh72u7gtvev6em@olmijoxgmjutzh77gykzjkyd6zwvkvm6oszb5ni@nuvfqviuwvnigxx65s7s77gbbvd4thrll7o63pq@fn5sjpg5zdejnypipngfhaudisqrfccakjuyaty@e7lhibzb3zek2xhmmypkf6ratimjeenqwvqvwjq@4npkonnsy7xi3smz2qmjorpg6ldw5otnabrmlei@3wmn5ktjfo7ukgaymbrakyuqry3h7wlwy7o5jii@e7lhibzb3zek2zin4gnao3gynqwqgrzjyopvbua@e7lhibzb3zek234ckc2fm2yvkj5cbsdpe7y6p2a@u72q4vdn3zes24pmx6lh34pdcinjjexdfljybvi@mlrdw3aw26j3w2hy5trqwqmzn6ucqiz2ribf7na@7zslzn452hh7x7om4ajuw5qwwre47zqcvwx3esi@7qx2cngeekeqrzlgeuuuimqllq@e7lhibzb3zek3aujadhv7432zqsccexuw6asfua@5wl7asm5apdmptrt5felw5c6am5ac3f4ijdgqji@4npkonnsy7xi3lwrdh6u5xlbh2u6vsobzgnc2sa@t7obxmpebrxkcwywc7yvrxo2savf2goaiv53moa"

	
	random_plantBean="$xo_20201229_pb@$zuoyou_random_pb@$Javon_random_pb@$test_pb@$xiaodengzi_20190516_pb@$cainiao5_20190516_pb@$wjq_20190516_pb@$whiteboy_20190711_pb@$jiu_20210110_pb@$Oyeah_20200104_pb@$shisan_20200213_pb@$JOSN_20200807_pb@$Jhone_Potte_20200824_pb@$liandao_20201010_pb@$adong_20201108_pb@$deng_20201120_pb@$gomail_20201125_pb@$baijiezi_20201126_pb@$superbei666_20201124_pb@$yiji_20201125_pb@$mjmdz_20201217_pb@$JDnailao_20201230_pb@$xo_20201229_pb@$xiaobai_20201204_pb@$wuming_20201225_pb@$JOSN_20210102_pb@$Lili_20210121_pb@$tanherongyi_20210121_pb@$dajiangyou20210116_pb@$luckies_20210121_pb@$NanshanFox_20210303_pb@$soso_20210204_pb@$511099189_20210101_pb"
	random="$random_plantBean"
	random_array
	new_plantBean_set="'$new_plantBean1@$zuoyou_20190516_pb@$Javon_20201224_pb@$minty_20210114_pb@$ashou_20210516_pb@$xiaobandeng_pb@$chiyu_pb@$random_set',"

	pb_rows=$(grep -n "shareCodes =" $dir_file_js/jd_plantBean.js | awk -F ":" '{print $1}')
	pbcode_rows=$(grep -n "PlantBeanShareCodes = \[" $dir_file_js/jdPlantBeanShareCodes.js | awk -F ":" '{print $1}')

	sed -i "$pb_rows a \ $new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set" $dir_file_js/jd_plantBean.js
	sed -i "$pbcode_rows a  \ $new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set" $dir_file_js/jdPlantBeanShareCodes.js


	#京喜工厂
	new_dreamFactory="X2poJVLcLoygZX0TgGmkl8EiBIkQe_zrMAZqtgL24-M=@5MIEocu93aHBEq_1DLOFFA==@DAJklWSqv4HcjA35zvIPGA==@4HL35B_v85-TsEGQbQTfFg==@q3X6tiRYVGYuAO4OD1-Fcg==@Gkf3Upy3YwQn2K3kO1hFFg==@w8B9d4EVh3e3eskOT5PR1A==@jwk7hHoEWAsvQyBkNrBS1Q==@iqAUAWEQx86GvVthAu7-jQ=="
	zuoyou_20190516_df="oWcboKZa9XxTSWd28tCEPA==@sboe5PFeXgL2EWpxucrKYw==@rm-j1efPyFU50GBjacgEsw==@tZXnazfKhM0mZd2UGPWeCA=="
	zuoyou_random_df="BprHGWI9w04zUnZPbIzKgw==@9whmFTgMFw7ZfXcQdEJ3UA==@zVn3SNiwrEhxQEcbMZA27w==@k7iROwM2-Ha5EA59rRxBTg==@BeecV8Oe9FL6I13lDGgOgA==@cA7LmxYoXxJNLnS7j25dxA==@aAwyOK0kb9OSm2oq2JVYMQ=="
	Javon_20201224_df="P2nGgK6JgLtCqJBeQJ0f27XXLQwYAFHrKmA2siZTuj8=@LTyKtCPGU6v0uv-n1GSwfQ=="
	Javon_20201224_random_df="WnaDbsWYwImvOD1CpkeVWA==@y7KhVRopnOwB1qFo2vIefg==@Y4r32JTAKNBpMoCXvBf7oA=="
	minty_20210114_df="AuzMzT5lc_tztwp75jBCWQ==@0deOa5-nFGlfUhhWi-SDgg=="
	chiyu_df="us6se4fFC6cSjHDSS_ScMw=="
	superbei666_20201124_df="5_h5YOeKKB-7m3ejIBrkyg=="
	ashou_20210516_df="1rQLjMF_eWMiQ-RAWARW_w==@6h514zWW6JNRE_Kp-L4cjA==@2G-4uh8CqPAv48cQT7BbXQ==@cxWqqvvoGwDhojw6JDJzaA==@pvMjBwEJuWqNrupO6Pjn6w==@nNK5doo5rxvF1HjnP0Kwjw==@BoMD6oFV2DhQRRo_w-h83g==@PqXKBSk3K1QcHUS0QRsCBg=="
	Jhone_Potte_20200824_df="Q4Rij5_6085kuANMaAvBMA==@gTLa05neWl8UFTGKpFLeog=="
	wjq_20190516_df="43I0xnmtfBvt5qiFm6ftxA=="
	whiteboy_20190711_df="U_NgGvEUnbU6IblJUTMQV3F7G5ihingk9kVobx99yrY=@BXXbkqJN7sr-0Qkid6v27A=="
	adong_20201108_df="QBGc1MnsD3uSN5nGDMAl7A==@a8PK5kDEvblgKUUTLP0e2w=="
	cainiao5_20201209_df="LBoBCAhsmQGJdrWJilbWJQ=="
	wuming_20201225_df="w1LTb9UUAOsXbNHIwtnzCQ=="
	JOSN_20210102_df="Y1heEn9Iva97i-IjTtfI9Q=="
	Lili_20210121_df="HQTSebNAjuGe4igMSpHeog=="
	tanherongyi_20210121_df="6FDe4u9M6bpexYt56q3tkA=="
	test_df="WHYhQ1mFlqoFow2iuq06wg==@DQYKPYi5mD-dwO86UokUjg==@BsCgeeTl_H2x5JQKGte6ow==@P9BvfbIu2DKbqeKjbDT_AQ==@-q3gc8s9Vr5x17EPRwyB8w==@zS1ivJY43UFvaqOUiFijZQ==@BsCgeeTl_H2x5JQKGte6ow==@JuMHWNtZt4Ny_0ltvG6Ipg==@KDhTwFSjylKffc2V7dp5HQ==@RNpsm77e351Rmo_R3KwC-g==@oK5uN03nIPjodWxbtdxPPA==@7VHDTh1iDT3_YEtiZ1iRPA==@KPmB_yK4CEvytAyuVu1zpA==@@1s8ZZnxD6DVDyjdEUu-zXA==@FyYWfETygv_4XjGtnl2YSg==@oWcboKZa9XxTSWd28tCEPA==@sboe5PFeXgL2EWpxucrKYw==@rm-j1efPyFU50GBjacgEsw==@bHIVoTmS-fHA6G9ixqnOxfjRNGe1YfJzIbBoF-NEAOw=@WFlk160B_Byd-xNNEyRPJQ==@bxUPiWroac-c9PLIPSjnNQ==@bHIVoTmS-fHA6G9ixqnOxfjRNGe1YfJzIbBoF-NEAOw="
	dajiangyou20210116_df="zn0Xt-zkwkbostX3PpMmnQ==@0VVnk16dt_qwn4-I-dLaEA=="
	luckies_20210121_df="WOn8gTchH7qQwZU5_YaLfw=="
	NanshanFox_20210303_df="yPwJfzwijXtviR92IUzreA=="
	jdnailao_20201130_df="-8j_Yo7W90gMBlQHpEfAnQ=="
	xo_20201229_df="ef0tNsI1_iyEqhHjQ4KwJg==@45qgi8juNnNrG58FRAFfgA=="
	511099189_20210101_df="qCG9QOJTxIDm0m8RAzmj_A==@3mO9RC7oitABfebSxFZntg==@jxV8UW_ZoHgE7HYvdofwtA=="
	stayhere_20200104_df="oSsgRyF7zQgU5JfsS9A1dg=="
	soso_20210204_df="XSblCsoOhYj-2BIDn3nC3g=="
	
	random_dreamFactory="$xo_20201229_df@$zuoyou_random_df@$test_df@$wjq_20190516_df@$whiteboy_20190711_df@$adong_20201108_df@$cainiao5_20201209_df@$wuming_20201225_df@$JOSN_20210102_df@$Lili_20210121_df@$tanherongyi_20210121_df@$dajiangyou20210116_df@$luckies_20210121_df@$superbei666_20201124_df@$NanshanFox_20210303_df@$jdnailao_20201130_df@$Javon_20201224_random_df@$511099189_20210101_df@$stayhere_20200104_df@$soso_20210204_df"
	random="$random_dreamFactory"
	random_array
	new_dreamFactory_set="'$new_dreamFactory@$zuoyou_20190516_df@$Javon_20201224_df@$minty_20210114_df@$ashou_20210516_df@$Jhone_Potte_20200824_df@$chiyu_df@$random_set',"

	df_rows=$(grep -n "inviteCodes =" $dir_file_js/jd_dreamFactory.js | awk -F ":" '{print $1}')
	dfcode_rows=$(grep -n "shareCodes = \[" $dir_file_js/jdDreamFactoryShareCodes.js | awk -F ":" '{print $1}')

	sed -i "$df_rows a \ $new_dreamFactory_set\n$new_dreamFactory_set\n$new_dreamFactory_set\n$new_dreamFactory_set\n$new_dreamFactory_set\n$new_dreamFactory_set\n$new_dreamFactory_set\n$new_dreamFactory_set" $dir_file_js/jd_dreamFactory.js
	sed -i "$dfcode_rows a  \ $new_dreamFactory_set\n$new_dreamFactory_set\n$new_dreamFactory_set\n$new_dreamFactory_set\n$new_dreamFactory_set\n$new_dreamFactory_set\n$new_dreamFactory_set\n$new_dreamFactory_set" $dir_file_js/jdDreamFactoryShareCodes.js

	#京东赚赚长期活动
	new_jdzz="95OquUc_sFugJO5_E_2dAgm-@eU9YELv7P4thhw6utCVw@eU9YaOjnbvx1-Djdz3UUgw@S5KkcRx0b81fRIkigwKZccQ@AUWE5mKmQzGYKXGT8j38cwA@AUWE5mvvGzDFbAWTxjC0Ykw@AUWE5wPfRiVJ7SxKOuQY0@S5KkcJEZAjD2vYGGG4Ip0@S5KkcREsZ_QXWIx31wKJZcA@S5KkcRUwe81LRIR_3xaNedw@Suvp2RBcY_VHKKBn3k_MMdNw@SvPVyQRke_EnWJxj1nfE@S5KkcRBYbo1fXKUv2k_5ccQ@S5KkcRh0ZoVfQchP9wvQJdw@S5KkcJnlwogCDQ2G84qtI"
	zuoyou_20190516_jdzz="S4r90RQ@S9r43CBsZ@S5KkcR00boFzRKEvzlvYCcA@S47wgARoc@S4qQkFUBOsgG4fQ@S7KQtF1dc8lbX@S5rQ3EUBOtA2Ifk0@S5KkcR0scpgDUdBnxkaEPcg@S5KkcOUt-tA2xfVuXyo9R@S-akMAUNKozyMcl6e_L8@S5KkcRRtL_VeBckj1xaYNfA@S5KkcRB8d9FLRKU6nkPQOdw"
	jidiyangguang_20190516_jdzz="S5KkcRBpK8lbeIxr8wfRcdw@S5KkcR0wdpFCGcRvwxv4Jcg"
	chiyu_jdzz="S7aUqCVsc91U"
	ashou_20210516_jdzz="Sv_V1RRgf_VPSJhyb1A@Sa0DkmLenrwOA@S5KkcRRtN8wCBdUimlqVbJw@S5KkcRkoboVKEJRr3xvINdQ@S_aIzGEdFoAGJdw@S5KkcRhpI8VfXcR79wqVcIA@S5KkcRk1P8VTSdUmixvUIfQ@S-acrCh8Q_VE"
	xo_20201229_jdzz="Sv_h6QR0Z_F3XPRj1l_QMcQ@S5KkcRx8b8lfQJxOmx6NffA"
	stayhere_20200104_jdzz="S5KkcRBZM8FHfIk_zxvBZJg@Suf13Rhkd8FHKJB30l_AD"
	
	new_jdzz_set="'$xo_20201229_jdzz@$new_jdzz@$zuoyou_20190516_jdzz@$jidiyangguang_20190516_jdzz@$chiyu_jdzz@$ashou_20210516_jdzz@$xo_20201229_jdzz@$stayhere_20200104_jdzz',"

	jdzz_rows=$(grep -n "inviteCodes =" $dir_file_js/jd_jdzz.js | awk -F ":" '{print $1}')
	sed -i "$jdzz_rows a \ $new_jdzz_set\n$new_jdzz_set\n$new_jdzz_set\n$new_jdzz_set\n$new_jdzz_set\n$new_jdzz_set\n$new_jdzz_set\n$new_jdzz_set" $dir_file_js/jd_jdzz.js

	sed -i "s/helpAuthor=true/helpAuthor=false/g" $dir_file_js/jd_jdzz.js

	#crazyJoy任务
	new_crazyJoy="2wgkflmSL-eOLT3n1sPRIKGLdMmSR-i1@uahlHElOqVadmIuLt6yoeg==@wVO5hjOkRcsuqL_wHuhERqt9zd5YaBeE@rHYmFm9wQAUb1S9FJUrMB6t9zd5YaBeE@7P1a-YqssNzEUo2yzMjkKat9zd5YaBeE@5z24ds6URIn_QEyGetqaHg==@KgkXpuBiTwm918sV3j4cmA==@CCxsXuB_kLhf6HV1LsZZ3GXGvf5Si_Xe@2tkIpiDk0h5W4-QdQYV1Hw==@KERXjmCp23eGkqiL1HrNKKt9zd5YaBeE@AG0W7h-GcmIDy_e0bkMKyat9zd5YaBeE@_l4qGmr10IzOqi6IfXC7ZQ=="
	zuoyou_20190516_cj="4GfMxIH581M=@xIA07jnZuHg=@BxewpcJDIAwJqfAkvKwcwKt9zd5YaBeE@L5gPw7OnXf8=@Qx0ZX75ICJEEVf8fiwFZZA==@3iUbFNTLF6tnJA1ZYLpP-w==@gz45Nf_7rgKdlolf3aQDpg==@z3O-VNgrWFev3DPdeHIlOKt9zd5YaBeE@jF5bHEsOxjmab12UFJJDiw==@bzbj_8Lr9NAPL-92UEK1ng==@iMvFEnejNI36J92m_biwh6t9zd5YaBeE@1YdTjf0z-ejoT4C48SJDsat9zd5YaBeE"
	jidiyangguang_20190516_cj="YKcWnuVsQLhGGMGXoNagr6t9zd5YaBeE@bF34fM689WcBsccobrWCEKt9zd5YaBeE"
	Jhone_Potte_20200824_cj="R0_iwyMT_LeF5osbxYCNwKt9zd5YaBeE@LVKLzARN7ub-xqKdK_upZ6t9zd5YaBeE"
	chiyu_cj="C5vbyHg-mOmrfc3eWGgXhA=="
	ashou_20210516_crazyJoy="olsw8XVa7wR0FkRUtBfFHA==@g1JWtxlX4qIozEmNryQipA==@kFXkccdosJUs2woo9v1i66t9zd5YaBeE@aM93O_bjCuJBkBWZB1ALPat9zd5YaBeE@JbQ7JvEWx7Fab-MBk27Njg==@Opw_ywaQzHoZAjvtslBb-qt9zd5YaBeE@lrfiS0THw-PihqcgEdchY6t9zd5YaBeE@_6SDheC97JWrfc3eWGgXhA=="
	xo_20201229_crazyJoy="BrZxuN-FogjZKJXTJqXFOat9zd5YaBeE"
	stayhere_20200104_crazyJoy="JYMB0M2DG_OE-H_RYgP99qt9zd5YaBeE@MDIQhVK-LG_PlEmOfPSLwQ=="
	
	new_crazyJoy_set="'$xo_20201229_crazyJoy@$new_crazyJoy@$zuoyou_20190516_cj@$jidiyangguang_20190516_cj@$Jhone_Potte_20200824_cj@$chiyu_cj@$ashou_20210516_crazyJoy@$xo_20201229_crazyJoy@$stayhere_20200104_crazyJoy',"

	crazyJoy_rows=$(grep -n "inviteCodes =" $dir_file_js/jd_crazy_joy.js | awk -F ":" '{print $1}')
	sed -i "$crazyJoy_rows a \ $new_crazyJoy_set\n$new_crazyJoy_set\n$new_crazyJoy_set\n$new_crazyJoy_set\n$new_crazyJoy_set\n$new_crazyJoy_set\n$new_crazyJoy_set\n$new_crazyJoy_set" $dir_file_js/jd_crazy_joy.js

	sed -i "s/$.isNode() ? 10 : 5/0/g" $dir_file_js/jd_crazy_joy.js
	sed -i "s/applyJdBean = 2000/applyJdBean = $jd_crazy_joy/g" $dir_file_js/jd_crazy_joy.js #JOY兑换2000豆子


	#签到领现金
	new_jdcash="95OquUc_sFugJO5_E_2dAgm-@eU9YELv7P4thhw6utCVw@eU9YaOjnbvx1-Djdz3UUgw@eU9Yau_gMP4nombWynsU1w@eU9Ya--wYP8g8zyBnyJF0w@eU9Ya-iyZ68kpWrRmXBFgw@eU9YabrkZ_h1-GrcmiJB0A@eU9YM7bzIptVshyjrwlteU9YCLTrH5VesRWnvw5t@P2nGgK6JgLtCqJBeQJ0f27XXLQwYAFHrKmA2siZTuj8=@JuMHWNtZt4Ny_0ltvG6Ipg==@IRM2beu1b-En9mzUwnU@eU9YaOSwMP8m-D_XzHpF0w@eU9Yau-yMv8ho2fcnXAQ1Q@eU9YCovbMahykhWdvS9R@JxwyaOWzbvk7-W3WzHcV1mw"
	zuoyou_20190516_jdcash="f1kwaQ@a1hzJOmy@eU9Ya7-wM_Qg-T_SyXIb0g@flpkLei3@f0JgObLlIalJrA@cUJpO6X3Yf4m@e1JzPbLlJ6V5rzk@eU9Ya7m3NaglpW3QziUW0A@eU9YFbnVJ6VArC-2lQtI@ZE9ILbHhMJR9oyq_ozs@eU9Yaengbv9wozzUmiIU3g@eU9YaO22Z_og-DqGz3AX1Q"
	jidiyangguang_20190516_jdcash="eU9YaOjhYf4v8m7dnnBF1Q@eU9Ya762N_h3oG_RmXoQ0A"
	chiyu_jdcash="cENuJam3ZP0"
	Jhone_Potte_20200824_jdcash="eU9Yaum1N_4j82-EzCUSgw@eU9Yar-7Nf518GyBniIWhw"
	jidiyangguang_20190516_jdcash="eU9YaOjhYf4v8m7dnnBF1Q@eU9Ya762N_h3oG_RmXoQ0A"
	ashou_20210516_jdcash="IhMxaeq0bvsj92i6iw@9qagtEUMPKtx@eU9YaenmYKhwpDyHySFChQ@eU9YariwMvp19G7WmXYU1w@YER3NLXuM6l4pg@eU9YaujjYv8moGrcnSFFgg@eU9Yar_kYvwjpD2DmXER3w@ZEFvJu27bvk"
	test_jdcash="JxwyaOWzbvk7-W3WzHcV1mw@9ruRu2Aas2GG@9o-utEEMs2mlJsRi@a0JpJLXsCf0k8m8@9pm0u3sJvlya@YF5qMbnwCaB6rQ@aUJtNb7xLKV8qA@XM6P3Toyxw@ZnQyOL7hMv91-GfczSJC@Iho0aO6yZ_gm-QGI@dF5oO7nsMaF_rznXy3MQ@d0RpO7_qM6JxuSuL@ZEd2be26"
	xo_20201229_jdcash="Ih4-be-yb_Um7GzUyHAV0w@eU9Ya-2wYf8h9meHmCdG3g"
	stayhere_20200104_jdcash="eU9YaOTnY_ku8zvSmXRAhA@JBszauu2Y_k79WnVyHQa"

	new_jdcash_set="'$xo_20201229_jdcash@$new_jdcash@$zuoyou_20190516_jdcash@$jidiyangguang_20190516_jdcash@$chiyu_jdcash@$Jhone_Potte_20200824_jdcash@$jidiyangguang_20190516_jdcash@$ashou_20210516_jdcash@$test_jdcash@$stayhere_20200104_jdcash',"

	cash_rows=$(grep -n "inviteCodes =" $dir_file_js/jd_cash.js | awk -F ":" '{print $1}')
	sed -i "$cash_rows a \ $new_jdcash_set\n$new_jdcash_set\n$new_jdcash_set\n$new_jdcash_set\n$new_jdcash_set\n$new_jdcash_set\n$new_jdcash_set\n$new_jdcash_set" $dir_file_js/jd_cash.js

	sed -i "s/https:\/\/gitee.com\/shylocks\/updateTeam\/raw\/main\/jd_cash.json/https:\/\/raw.githubusercontent.com\/ITdesk01\/JD_Script\/main\/JSON\/jd_cash.json/g"  $dir_file_js/jd_cash.js

	#闪购盲盒
	new_jdsgmh="T024anXulbWUI_NR9ZpeTHmEoPlACjVWmIaW5kRrbA@T0205KkcPElQrCOQVnqP66FpCjVWmIaW5kRrbA@T0225KkcRBpM_VSEKUz8kPENIQCjVWmIaW5kRrbA@T0225KkcRxoZ9AfVdB7wxvRcIQCjVWmIaW5kRrbA@T0225KkcRUhP9FCEKR79xaZYcgCjVWmIaW5kRrbA@T0205KkcH0RYsTOkY2iC8I10CjVWmIaW5kRrbA@T0205KkcJEZAjD2vYGGG4Ip0CjVWmIaW5kRrbA@T019vPVyQRke_EnWJxj1nfECjVQmoaT5kRrbA@T0225KkcRBYbo1fXKUv2k_5ccQCjVQmoaT5kRrbA@T0225KkcRh0ZoVfQchP9wvQJdwCjVQmoaT5kRrbA@T0205KkcJnlwogCDQ2G84qtICjVQmoaT5kRrbA"
	zuoyou_20190516_jdsgmh="T0064r90RQCjVQmoaT5kRrbA@T0089r43CBsZCjVQmoaT5kRrbA@T0225KkcR00boFzRKEvzlvYCcACjVQmoaT5kRrbA@T00847wgARocCjVQmoaT5kRrbA@T0144qQkFUBOsgG4fQCjVQmoaT5kRrbA@T0127KQtF1dc8lbXCjVQmoaT5kRrbA@T0155rQ3EUBOtA2Ifk0CjVQmoaT5kRrbA@T0225KkcR0scpgDUdBnxkaEPcgCjVQmoaT5kRrbA@T0205KkcOUt-tA2xfVuXyo9RCjVQmoaT5kRrbA@T019-akMAUNKozyMcl6e_L8CjVQmoaT5kRrbA@T0225KkcRRtL_VeBckj1xaYNfACjVQmoaT5kRrbA@T0225KkcRB8d9FLRKU6nkPQOdwCjVQmoaT5kRrbA"
	jidiyangguang_20190516_jdsgmh="T0225KkcR0wdpFCGcRvwxv4JcgCjVWmIaW5kRrbA@T0225KkcRBpK8lbeIxr8wfRcdwCjVWmIaW5kRrbA"
	chiyu_jdsgmh="T0117aUqCVsc91UCjVWmIaW5kRrbA"
	Javon_20201224_jdsgmh="T023uvp2RBcY_VHKKBn3k_MMdNwCjVQmoaT5kRrbA"
	Jhone_Potte_20200824_jdsgmh="T0225KkcRhsepFbSIhulk6ELIQCjVWmIaW5kRrbA@T0225KkcRk0QplaEIRigwaYPJQCjVWmIaW5kRrbA"
	jidiyangguang_20190516_jdsgmh="T0225KkcRBpK8lbeIxr8wfRcdwCjVQmoaT5kRrbA@T0225KkcR0wdpFCGcRvwxv4JcgCjVQmoaT5kRrbA"
	chiyu_jdsgmh="T0117aUqCVsc91UCjVQmoaT5kRrbA"
	ashou_20210516_jdsgmh="T018v_V1RRgf_VPSJhyb1ACjVQmoaT5kRrbA@T012a0DkmLenrwOACjVQmoaT5kRrbA@T0225KkcRRtN8wCBdUimlqVbJwCjVQmoaT5kRrbA@T0225KkcRkoboVKEJRr3xvINdQCjVQmoaT5kRrbA@T014_aIzGEdFoAGJdwCjVQmoaT5kRrbA@T0225KkcRhpI8VfXcR79wqVcIACjVQmoaT5kRrbA@T0225KkcRk1P8VTSdUmixvUIfQCjVQmoaT5kRrbA@T011-acrCh8Q_VECjVQmoaT5kRrbA"
	xo_20201229_jdsgmh="T022v_h6QR0Z_F3XPRj1l_QMcQCjVQmoaT5kRrbA@T0225KkcRx8b8lfQJxOmx6NffACjVQmoaT5kRrbA"
	stayhere_20200104_jdsgmh="T0225KkcRBZM8FHfIk_zxvBZJgCjVQmoaT5kRrbA@T020uf13Rhkd8FHKJB30l_ADCjVQmoaT5kRrbA"
	
	new_jdsgmh_set="'$xo_20201229_jdsgmh@$new_jdsgmh@$zuoyou_20190516_jdsgmh@$jidiyangguang_20190516_jdsgmh@$chiyu_jdsgmh@$Javon_20201224_jdsgmh@$Jhone_Potte_20200824_jdsgmh@$jidiyangguang_20190516_jdsgmh@$chiyu_jdsgmh@$ashou_20210516_jdsgmh@$xo_20201229_jdsgmh@$stayhere_20200104_jdsgmh',"

	sgmh_rows=$(grep -n "inviteCodes =" $dir_file_js/jd_sgmh.js | awk -F ":" '{print $1}')
	sed -i "$sgmh_rows a \ $new_jdsgmh_set\n$new_jdsgmh_set\n$new_jdsgmh_set\n$new_jdsgmh_set\n$new_jdsgmh_set\n$new_jdsgmh_set\n$new_jdsgmh_set\n$new_jdsgmh_set" $dir_file_js/jd_sgmh.js

	#财富岛
	new_cfd="698098B001CF38EEEBCF66F9746EAFC73C36297A95A48C90B928863583FC13E3@2F37BEBF8BFCDF8BEE92C1C2923706A411D77D02290C12A6E2CB6D6085D019F0@74368D6374341F98E02515D2661AA24D21A71F3D430C4C3CB7102A904AF54F55@161F722B03A9D0D88957B3A10D1993F05269434FB7E0C21EAB50C8D80F8BAE37"
	test_cfd="1A91CB7D423B0797C8FCB56F427D8DBE17FC2BC3429518690AE267598024A64F@D2B2DC26C59CE6F9D40087876C5E1365B167EC29D2F4A5A1E466AD6DC908FF13@5B674A6E0E797CF70F2D784210E24D19875694C418C215CB732C90C8534DE908@30267C61BC24DCF80B89925CCCB5B4C3900AAE08116E9F7EC18A0ACF8371482D@EC1EE0B8E9D14A159CB3ED96274FE27FAD7BC87B7873159A8EE7F60C5FD7D681"
	zuoyou_20190516_cfd="FEDB2AF96850881075FA08A13F621BA2@492629151F9A4D58FD1396DF6A89283271310967BE165544D8C825F27C4A2BA3@B07EC6F47A9BBA48D730300D742021D4AB091E6E8BC38C6FC83951F090865B4D@5266AB2AB4A420E011FDE365CD3761DEA004AF26497E96FE787CEA61D3B9CC5D@E36DC4BBF3C37E38C7E986E8836ECA97D7CC19A31C9E2A1F98A102AEE7E4CCC2@BC11A30DDE0C69ACBA90C9374FB64AF6648270AC47BB30E4340A23CB0B286411@BE23B69794FF9225CA2A11A4FD324D9973306BE33A756B36D5DD201B2D661F69@0FD477A54177EE4FA6B4128DC6C4FE442B153AE2B4C40E1EEC9CA76696BC61CB@11F743A9D0C5D5ADFBBAA2DF0413382B53EC91F0510E9968157559A4B38F176C@02891BCA03C90A1927B0A6B7AEAF2C60255B1E1317B509B477793869356E8D81@9D3BBBB7C428ACF58C7380ACA3EBE0798CBD1466AFAF50B327F3168977EBAF5A@4258CC830AA9723630A626F5CD2CE5E39EB5941364F3A8C9E0E0A04CC41ABAC9"
	Javon_20201224_cfd="3108F77AE5B711A96FBEE78E952FDE2000683335CE0DBAB16894D48FD5B95815@859D1EACFE0FB0DE30DF970EC5DF56A6B0AA74FA8D1F91A5B04C143E84C4C033"
	stayhere_20200104_cfd="1AA809032AAFEAB44ADA354C0355DF303842B23067E05B05EB517F6E0D5926C7@BBF0047F731148F8EEE064EE3D5BF51889F9EE5A1FC3BEA1C046D5D7F12946DF"
	random_cfd="$test_cfd"
	random="$random_cfd"
	random_array
	new_cfd_set="$new_cfd@$Javon_20201224_cfd@$zuoyou_20190516_cfd@$random_set@$stayhere_20200104_cfd"
	sed -i '/JDCFD_SHARECODES/d' /etc/profile >/dev/null 2>&1
	echo "export JDCFD_SHARECODES=$new_cfd_set" >> /etc/profile
	source /etc/profile

	#手机狂欢城
	new_sj818="b10ff4fc-7465-45aa-b052-c5d3776685ca@61740c94-f9a4-4d16-bc47-b0f0e858663d@2003ee19-bb7d-405a-a018-3eb814704c13f9cbb5fb-3944-4cc1-8136-0d1321e90d47"
	test_sj818="733546f2-f282-4f82-86df-0f8fd3b367bd@27f61a94-7a32-4f6c-81a3-1de4e4b44a59@a0d94b9a-438f-47d7-8db4-17aa0da80f6f@9ed7b309-b7cd-483e-b6e3-4ea65e7d7fb3@8f0420f6-a601-4f54-af56-90d24434d5b6"
	random_sj818="$test_sj818"
	random="$random_sj818"
	random_array
	new_sj818_set="$new_sj818@$random_set"
	sed -i '/JD818_SHARECODES/d' /etc/profile >/dev/null 2>&1
	echo "export JD818_SHARECODES=$new_sj818_set" >> /etc/profile
	source /etc/profile

	#京东试用
	if [ "$jd_try" == "yes" ];then
		jd_try_if=$(grep "jd_try.js" $cron_file | wc -l)
		if [ "$jd_try_if" == "0" ];then
			echo "检测到试用开关开启，导入一下计划任务"
			echo "0 10 * * * $node $dir_file/js/jd_try.js >/tmp/jd_try.log" >>$cron_file
			/etc/init.d/cron restart
		else
			echo "京东试用计划任务已经导入"
		fi
	else
		jd_try_if=$(grep "jd_try.js" $cron_file | wc -l)
		if [ "$jd_try_if" == "1" ];then
			echo "检测到试用开关关闭，清理一下之前的导入"
			sed -i '/jd_try.js/d' /etc/crontabs/root >/dev/null 2>&1
			/etc/init.d/cron restart
		fi
		echo "京东试用计划任务不导入"
	fi

	#取消会员卡脚本修复路径
	sed -i "s/..\/jdCookie.js/.\/jdCookie.js/g" $dir_file_js/jd_unbind.js
	sed -i "s/..\/sendNotify/.\/sendNotify/g" $dir_file_js/jd_unbind.js
	sed -i "s/..\/USER_AGENTS/.\/USER_AGENTS/g" $dir_file_js/jd_unbind.js

	#脚本黑名单
	script_black

	#农场萌宠关闭通知
	close_notification
}

close_notification() {
	#农场和东东萌宠关闭通知
	if [ `date +%A` == "Monday" ];then
		echo -e "$green今天周一不关闭农场萌宠通知$white"
	else
		case `date +%H` in
		22|23|00|01|02|03)
			sed -i "s/jdNotify = true/jdNotify = false/g" $dir_file_js/jd_fruit.js
			sed -i "s/jdNotify = true/jdNotify = false/g" $dir_file_js/jd_pet.js
			if [ "$ccr_if" == "yes" ];then
				for i in `ls $ccr_js_file`
				do
					sed -i "s/jdNotify = true/jdNotify = false/g" $ccr_js_file/$i/jd_fruit.js
					sed -i "s/jdNotify = true/jdNotify = false/g" $ccr_js_file/$i/jd_pet.js
				done
			fi
			echo -e "$green暂时不关闭农场和萌宠通知$white"
		;;
		*)
			sed -i "s/jdNotify = false/jdNotify = true/g" $dir_file_js/jd_fruit.js
			sed -i "s/jdNotify = false/jdNotify = true/g" $dir_file_js/jd_pet.js
			if [ "$ccr_if" == "yes" ];then
				for i in `ls $ccr_js_file`
				do
					sed -i "s/jdNotify = false/jdNotify = true/g" $ccr_js_file/$i/jd_fruit.js
					sed -i "s/jdNotify = false/jdNotify = true/g" $ccr_js_file/$i/jd_pet.js
				done
			fi
			echo -e "$green时间大于凌晨三点开始关闭农场和萌宠通知$white"
		;;
		esac
	fi
}
random_array() {
	#彻底完善，感谢minty大力支援
	length=$(echo $random | awk -F '[@]' '{print NF}') #获取变量长度
	quantity_num=$(expr $length + 1)

	if [ "$length" -ge "20" ];then
		echo "random_array" > /tmp/random.txt
		random_num=$(python3 $dir_file/jd_random.py $quantity_num,$length  | sed "s/,/\n/g")
		for i in `echo $random_num`
		do
			echo $random | awk -va=$i -F '[@]' '{print $a}'  >>/tmp/random.txt
		done

		random_set=$(cat /tmp/random.txt | sed  "/random_array/d"| sed "s/$/@/" | sed ':t;N;s/\n//;b t' |sed 's/.$//g')
	else
		random_set="$random"
	fi
}

time() {
	if [ $script_read == "0" ];then
		echo ""
		echo -e  "$green你是第一次使用脚本，请好好阅读以上脚本说明$white"
		echo ""
		seconds_left=120
		while [[ ${seconds_left} -gt 0 ]]; do
			echo -ne "$green${seconds_left}秒以后才能正常使用脚本，不要想结束我。我无处不在。。。$white"
			sleep 1
			seconds_left=$(($seconds_left - 1))
			echo -ne "\r"
		done
		echo -e "$green恭喜你阅读完成，祝玩的愉快，我也不想搞这波，但太多小白不愿意看说明然后一大堆问题，请你也体谅一下$white"
		echo "我已经阅读脚本说明" > $dir_file/script_read.txt
		exit 0
	fi
}

npm_install() {
	echo -e "$green 开始安装npm模块$white"
	if [ "$dir_file" == "$openwrt_script/JD_Script" ];then
		cp $openwrt_script/JD_Script/git_clone/lxk0301/package.json $openwrt_script/package.json
		cd $openwrt_script && npm install && npm install -g request
	else
		cp $dir_file/git_clone/lxk0301/package.json $dir_file/package.json
		cd $dir_file && npm -g install && npm install -g request
	fi
}

system_variable() {
	source /etc/profile

	if [[ ! -d "$dir_file/config/tmp" ]]; then
		mkdir -p $dir_file/config/tmp
	fi
	
	if [[ ! -d "$dir_file/js" ]]; then
		mkdir  $dir_file/js
	fi

	if [[ ! -d "/tmp/jd_tmp" ]]; then
		mkdir  /tmp/jd_tmp
	fi

	if [[ ! -d "$ccr_js_file" ]]; then
		mkdir  $ccr_js_file
	fi

	#判断openssh
	openssh_if=$(opkg list-installed | grep "openssh-client" | awk '{print $1}')
	openssh_if1=$(opkg list-installed | grep "openssh-keygen" | awk '{print $1}')
	if [ ! $openssh_if ];then
		echo -e "缺少$green openssh-client$white依赖，请安装以后再使用本脚本"
		sleep 5
	fi
	
	if [ ! $openssh_if1 ];then
		echo -e "缺少$green openssh-keygen$white依赖，请安装以后再使用本脚本"
		sleep 5
	fi

	#判断python
	python_if=$(opkg list-installed | grep "python3" | awk 'NR==1 {print $1}')
	if [ ! $python_if ];then
		echo -e "缺少$green python3$white依赖，请安装以后再使用本脚本"
		sleep 5
	fi

	#判断参数
	if [ ! -f /root/.ssh/test ];then
		rm -rf /root/.ssh
		cp -r $dir_file/.ssh /root/.ssh
		chmod 600 /root/.ssh/lxk0301
		sed -i "s/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g" /etc/ssh/ssh_config
		echo > /root/.ssh/test
		update
	fi

	if [ "$dir_file" == "$openwrt_script/JD_Script" ];then
		#jdCookie.js
		if [ ! -f "$openwrt_script_config/jdCookie.js" ]; then
			cp  $dir_file/JSON/jdCookie.js  $openwrt_script_config/jdCookie.js
			rm -rf $dir_file_js/jdCookie.js #用于删除旧的链接
			ln -s $openwrt_script_config/jdCookie.js $dir_file_js/jdCookie.js
		fi

		#jdCookie.js用于升级以后恢复链接
		if [ ! -L "$dir_file_js/jdCookie.js" ]; then
			rm -rf $dir_file_js/jdCookie.js
			ln -s $openwrt_script_config/jdCookie.js $dir_file_js/jdCookie.js
		fi

		#sendNotify.js
		if [ ! -f "$openwrt_script_config/sendNotify.js" ]; then
			cp  $dir_file/JSON/sendNotify.js $openwrt_script_config/sendNotify.js
			rm -rf $dir_file_js/sendNotify.js  #用于删除旧的链接
			ln -s $openwrt_script_config/sendNotify.js $dir_file_js/sendNotify.js
		fi

		#sendNotify.js用于升级以后恢复链接
		if [ ! -L "$dir_file_js/sendNotify.js" ]; then
			rm -rf $dir_file_js/sendNotify.js  #临时删除，解决最近不推送问题
			ln -s $openwrt_script_config/sendNotify.js $dir_file_js/sendNotify.js
		fi

		#USER_AGENTS.js
		if [ ! -f "$openwrt_script_config/USER_AGENTS.js" ]; then
			cp  $dir_file/git_clone/lxk0301/USER_AGENTS.js $openwrt_script_config/USER_AGENTS.js
			rm -rf $dir_file_js/USER_AGENTS.js #用于删除旧的链接
			ln -s $openwrt_script_config/USER_AGENTS.js $dir_file_js/USER_AGENTS.js
		fi

		#USER_AGENTS.js用于升级以后恢复链接
		if [ ! -L "$dir_file_js/USER_AGENTS.js" ]; then
			rm -rf $dir_file_js/USER_AGENTS.js
			ln -s $openwrt_script_config/USER_AGENTS.js $dir_file_js/USER_AGENTS.js
		fi

		#JS_USER_AGENTS.js
		if [ ! -f "$openwrt_script_config/JS_USER_AGENTS.js" ]; then
			cp  $dir_file/git_clone/lxk0301/JS_USER_AGENTS.js $openwrt_script_config/JS_USER_AGENTS.js
			rm -rf $dir_file_js/JS_USER_AGENTS.js #用于删除旧的链接
			ln -s $openwrt_script_config/JS_USER_AGENTS.js $dir_file_js/JS_USER_AGENTS.js
		fi

		#JS_USER_AGENTS.js用于升级以后恢复链接
		if [ ! -L "$dir_file_js/JS_USER_AGENTS.js" ]; then
			rm -rf $dir_file_js/JS_USER_AGENTS.js
			ln -s $openwrt_script_config/JS_USER_AGENTS.js $dir_file_js/JS_USER_AGENTS.js
		fi
	else
		if [ ! -f "$dir_file/jdCookie.js" ]; then
			cp  $dir_file/JSON/jdCookie.js $dir_file/jdCookie.js
			ln -s $dir_file/jdCookie.js $dir_file_js/jdCookie.js
		fi

		if [ ! -f "$dir_file/sendNotify.js" ]; then
			cp  $dir_file/JSON/sendNotify.js $dir_file/sendNotify.js
			ln -s $dir_file/sendNotify.js $dir_file_js/sendNotify.js
		fi

		if [ ! -f "$dir_file/USER_AGENTS.js" ]; then
			cp  $dir_file/git_clone/lxk0301/USER_AGENTS.js $dir_file/USER_AGENTS.js
			ln -s $dir_file/USER_AGENTS.js $dir_file_js/USER_AGENTS.js
		fi

		if [ ! -f "$dir_file/JS_USER_AGENTS.js" ]; then
			cp  $dir_file/git_clone/lxk0301/JS_USER_AGENTS.js $dir_file/JS_USER_AGENTS.js
			ln -s $dir_file/JS_USER_AGENTS.js $dir_file_js/JS_USER_AGENTS.js
		fi
	fi

	jd_openwrt_config_version="1.2"
	if [ "$dir_file" == "$openwrt_script/JD_Script" ];then
		jd_openwrt_config="$openwrt_script_config/jd_openwrt_script_config.txt"
		if [ ! -f "$jd_openwrt_config" ]; then
			jd_openwrt_config_description
		fi
		#jd_openwrt_script_config用于升级以后恢复链接
		if [ ! -L "$dir_file/config/jd_openwrt_script_config.txt" ]; then
			rm rf $dir_file/config/jd_openwrt_script_config.txt
			ln -s $jd_openwrt_config $dir_file/config/jd_openwrt_script_config.txt
		fi
	else
		jd_openwrt_config="$dir_file/config/jd_openwrt_script_config.txt"
		if [ ! -f "$jd_openwrt_config" ]; then
			jd_openwrt_config_description
		fi
	fi

	if [ `grep "jd_openwrt_config $jd_openwrt_config_version" $jd_openwrt_config |wc -l` == "1"  ];then
		jd_config_version="$green jd_config最新 $yellow$jd_openwrt_config$white"
	else
		jd_config_version="$red jd_config与新版不一致，请手动更新，更新办法，删除$green rm -rf $jd_openwrt_config$white然后更新一下脚本,再进去重新设置一下"
	fi

	ccr_if=$(grep "concurrent" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_try=$(grep "jd_try" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_fruit=$(grep "jd_fruit" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_blueCoin=$(grep "jd_blueCoin" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_joy_reward=$(grep "jd_joy_reward" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_joy_feedPets=$(grep "jd_joy_feedPets" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_joy_steal=$(grep "jd_joy_steal" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_crazy_joy=$(grep "jd_crazy_joy" $jd_openwrt_config | awk -F "'" '{print $2}')
	jd_unsubscribe=$(grep "jd_unsubscribe" $jd_openwrt_config | awk -F "'" '{print $2}')

	#判断node版本是大于10
	node_if=$(opkg list-installed | grep 'node -' | awk -F "." '{print $1}' | awk -F v '{print $2}')
	node_npm=$(opkg list-installed | grep 'node-npm' | awk -F "." '{print $1}' | awk -F v '{print $2}')
	if [ ! $node_if -ge "10" ];then
		echo "node 版本小于10，请升级以后再使用本脚本"
		exit 0
	fi

	if [ ! $node_if -ge "10" ];then
		echo "node-npm 版本小于10，请升级以后再使用本脚本"
		exit 0
	fi

	#添加系统变量
	jd_script_path=$(cat /etc/profile | grep -o jd.sh | wc -l)
	if [[ "$jd_script_path" == "0" ]]; then
		echo "export jd_file=$dir_file" >> /etc/profile
		echo "export jd=$dir_file/jd.sh" >> /etc/profile
		source /etc/profile
	fi

	blacklist=""
	if [ "黑名单" == "$blacklist" ];then
		echo ""
	fi

	#农场萌宠关闭通知
	close_notification

	script_black
}

jd_openwrt_config_description() {
cat > $jd_openwrt_config <<EOF
*****************jd_openwrt_config $jd_openwrt_config_version**************

这里主要定义一些脚本的个性化操作，如果你不需要微调，那么保持默认不理他就行了

这里的参数如果你看不懂或者想知道还有没有其他参数，你可以去$dir_file_js这里找相应的js脚本看说明

修改完参数如何生效：sh \$jd update && sh \$jd

*******************************************************
#是否启用账号并发功能（多账号考虑打开，黑了不管） yes开启 默认no
concurrent='no'

#京东试用 yes开启  默认no
jd_try='no'

#农场不浇水换豆 false关闭 ture打开
jd_fruit='false'


#京小超默认兑换20豆子(可以改成你要的1000豆子或者其他)
jd_blueCoin='20'


#宠汪汪积分兑换500豆子，(350积分兑换20豆子，8000积分兑换500豆子要求等级16级，16000积分兑换1000京豆16级以后不能兑换)
jd_joy_reward='500'


#宠汪汪喂食(更多参数自己去看js脚本描述)
jd_joy_feedPets='80'


#宠汪汪不给好友喂食 false不喂食 ture喂食
jd_joy_steal='false'


#JOY兑换豆子(满2000开始兑换)
jd_crazy_joy='2000'


#取消店铺200个(觉得太多你可以自己调整)
jd_unsubscribe='200'
EOF
}


system_variable
action1="$1"
action2="$2"
if [[ -z $action1 ]]; then
	help
else
	case "$action1" in
		run_0|run_01|run_06_18|run_10_15_20|run_02|run_03|run_045|run_08_12_16|run_07|run_030|run_020)
		concurrent_js_if
		;;
		system_variable|update|update_script|task|jx|additional_settings|joy|kill_joy|jd_sharecode|ds_setup|checklog|that_day|stop_script|script_black|script_name|backnas|npm_install|checktool|concurrent_js_clean|if_ps|getcookie|addcookie|delcookie)
		$action1
		;;
		kill_ccr)
			action="run_"
			kill_ccr
		;;
		*)
		help
		;;
	esac

	if [[ -z $action2 ]]; then
		echo ""
	else
		case "$action2" in
		run_0|run_01|run_06_18|run_10_15_20|run_02|run_03|run_045|run_08_12_16|run_07|run_030|run_020)
		concurrent_js_if
		;;
		system_variable|update|update_script|task|jx|additional_settings|joy|kill_joy|jd_sharecode|ds_setup|checklog|that_day|stop_script|script_black|script_name|backnas|npm_install|checktool|concurrent_js_clean|if_ps|getcookie|addcookie|delcookie)
		$action2
		;;
		kill_ccr)
			action="run_"
			kill_ccr
		;;
		*)
		help
		;;
	esac
	fi
fi


