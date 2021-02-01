#!/bin/sh
#
# Copyright (C) 2020 luci-app-jd-dailybonus <jerrykuku@qq.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#
#set -x

version="1.9"
cron_file="/etc/crontabs/root"
#url=https://raw.githubusercontent.com/lxk0301/jd_scripts/master
url=https://gitee.com/lxk0301/jd_scripts/raw/master

#url=https://raw.githubusercontent.com/zy2021/JD/master


#获取当前脚本目录copy脚本之家
Source="$0"
while [ -h "$Source"  ]; do
    dir_file="$( cd -P "$( dirname "$Source"  )" && pwd  )"
    Source="$(readlink "$Source")"
    [[ $Source != /*  ]] && Source="$dir_file/$Source"
done
dir_file="$( cd -P "$( dirname "$Source"  )" && pwd  )"
dir_file_js="$dir_file/js"

node="/usr/bin/node"
install_script="/usr/share/Install_script"
install_script_config="/usr/share/Install_script/script_config"
if [ "$dir_file" == "$install_script/JD_Script" ];then
	script_dir="$install_script_config"
else
	script_dir="$dir_file"
fi

wrap="%0D%0A%0D%0A" #Server酱换行
wrap_tab="     "
current_time=$(date +"%Y-%m-%d")
by="#### 脚本仓库地址:https://github.com/ITdesk01/JD_Script"
SCKEY=$(cat $script_dir/sendNotify.js | awk 'NR==12 {print $4}' | sed "s/'//g" | sed "s/;//g")

red="\033[31m"
green="\033[32m"
yellow="\033[33m"
white="\033[0m"

start_script="脚本开始运行，当前时间：`date "+%Y-%m-%d %H:%M"`"
stop_script="脚本结束，当前时间：`date "+%Y-%m-%d %H:%M"`"

script_read=$(cat $dir_file/script_read.txt | grep "我已经阅读脚本说明"  | wc -l)

task() {
	cron_version="2.62"
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
#**********这里是JD_Script的定时任务$cron_version版本**********#
0 0 * * * $dir_file/jd.sh run_0  >/tmp/jd_run_0.log 2>&1 #0点0分执行全部脚本
*/45 2-23 * * * $dir_file/jd.sh run_045 >/tmp/jd_run_045.log 2>&1 #两个工厂
0 7-23/1 * * * $dir_file/jd.sh run_01 >/tmp/jd_run_01.log 2>&1 #种豆得豆收瓶子
10 2-22/3 * * * $dir_file/jd.sh run_03 >/tmp/jd_run_03.log 2>&1 #天天加速 3小时运行一次，打卡时间间隔是6小时
40 6-18/6 * * * $dir_file/jd.sh run_06_18 >/tmp/jd_run_06_18.log 2>&1 #不是很重要的，错开运行
35 10,15,20 * * * $dir_file/jd.sh run_10_15_20 >/tmp/jd_run_10_15_20.log 2>&1 #不是很重要的，错开运行
10 8,12,16 * * * $dir_file/jd.sh run_08_12_16 >/tmp/jd_run_08_12_16.log 2>&1 #旺旺兑换礼品
00 22 * * * $dir_file/jd.sh update_script that_day >/tmp/jd_update_script.log 2>&1 #22点更新JD_Script脚本
5 22 * * * $dir_file/jd.sh update >/tmp/jd_update.log 2>&1 #22点05分更新lxk0301脚本
5 7 * * * $dir_file/jd.sh run_07 >/tmp/jd_run_07.log 2>&1 #不需要在零点运行的脚本
*/30 1-22 * * * $dir_file/jd.sh joy >/tmp/jd_joy.log 2>&1 #1-22,每半个小时kill joy并运行一次joy挂机
55 23 * * * $dir_file/jd.sh kill_joy >/tmp/jd_kill_joy.log 2>&1 #23点55分关掉joy挂机
20 * * * * $dir_file/jd.sh run_020 >/tmp/jd_run_020.log 2>&1 #京东炸年兽领爆竹
0 2-21/1 * * 0,2-6 $dir_file/jd.sh stop_notice >/tmp/jd_stop_notice.log 2>&1 #两点以后关闭农场推送，周一不关
59 23 * * * sleep 57; $dir_file/jd.sh ddcs >/tmp/jd_ddcs.log 2>&1 #东东超市兑换
0 9,12,16,20 * * * $dir_file/jd.sh baiyuan >/tmp/jd_baiyuan.log 2>&1 #京东抢百元卡
###########100##########请将其他定时任务放到底下###############
EOF

	/etc/init.d/cron restart
	cron_help="$yellow定时任务更新完成，记得看下你的定时任务$white"
}

task_delete() {
	sed -i '/JD_Script/d' /etc/crontabs/root >/dev/null 2>&1
	sed -i '/#100#/d' /etc/crontabs/root >/dev/null 2>&1
}

ds_setup() {
	echo "JD_Script删除定时任务设置"
	task_delete
	echo "JD_Script删除全局变量"
	sed -i '/JD_Script/d' /etc/profile >/dev/null 2>&1
	. /etc/profile
	echo "JD_Script定时任务和全局变量删除完成，脚本彻底不会自动运行了"
}

update() {
	echo -e "$green update$start_script $white"
	echo -e "$green开始下载JS脚本，请稍等$white"
#cat script_name.txt | awk '{print length, $0}' | sort -rn | sed 's/^[0-9]\+ //'按照文件名长度降序：
#cat script_name.txt | awk '{print length, $0}' | sort -n | sed 's/^[0-9]\+ //' 按照文件名长度升序

cat >$dir_file/config/lxk0301_script.txt <<EOF
	jd_bean_sign.js			#京东多合一签到
	jx_sign.js			#京喜app签到长期
	jd_fruit.js			#东东农场
	jdFruitShareCodes.js		#东东农场ShareCodes
	jd_jxnc.js			#京喜农场
	jdJxncTokens.js			#京喜农场token
	jdJxncShareCodes.js		#京喜农场ShareCodes
	jd_pet.js			#东东萌宠
	jdPetShareCodes.js		#东东萌宠ShareCodes
	jd_plantBean.js			#种豆得豆
	jdPlantBeanShareCodes.js	#种豆得豆ShareCodes
	jd_superMarket.js		#东东超市
	jd_blueCoin.js			#东东超市兑换奖品
	jd_dreamFactory.js		#京喜工厂
	jdDreamFactoryShareCodes.js	#京喜工厂ShareCodes
	jd_jdfactory.js			#东东工厂
	jdFactoryShareCodes.js		#东东工厂ShareCodes
	jd_joy_feedPets.js 		#宠汪汪单独喂食
	jd_joy.js			#宠汪汪
	jd_joy_reward.js 		#宠汪汪兑换奖品
	jd_joy_steal.js			#宠汪汪偷好友狗粮与积分
	jd_crazy_joy.js			#crazyJoy任务
	jd_crazy_joy_coin.js		#crazy joy挂机领金币/宝箱专用
	jd_car_exchange.js		#京东汽车兑换，500赛点兑换500京豆
	jd_car.js			#京东汽车，签到满500赛点可兑换500京豆，一天运行一次即可
	jd_redPacket.js			#全民开红包
	jd_club_lottery.js		#摇京豆
	jd_shop.js			#进店领豆
	jd_live.js			#直播抢京豆
	jd_bean_home.js			#领京豆额外奖励
	jd_rankingList.js		#京东排行榜签到得京豆
	jd_cash.js			#签到领现金，每日2毛～5毛长期
	jd_jdzz.js			#京东赚赚长期活动
	jd_lotteryMachine.js 		#京东抽奖机
	jd_necklace.js			#点点券
	jd_nian.js			#京东炸年兽
	jd_nianCollect.js		#炸年兽专门收集爆竹
	jd_nian_sign.js			#年兽签到
	jd_nian_ar.js			#年兽ar
	jd_nian_wechat.js		#京东炸年兽小程序
	jd_immortal.js			#京东神仙书院 2021-1-20至2021-2-5
	jd_immortal_answer.js		#京东书院自动答题
	jd_syj.js			#赚京豆
	jd_bookshop.js			#口袋书店
	jd_family.js			#京东家庭号
	jd_kd.js			#京东快递签到 一天运行一次即可
	jd_small_home.js		#东东小窝
	jd_speed.js			#天天加速
	jd_moneyTree.js 		#摇钱树
	jd_pigPet.js			#金融养猪
	jd_daily_egg.js 		#京东金融-天天提鹅
	jd_nh.js			#京东年货节2021年1月9日-2021年2月9日
	jd_sgmh.js			#闪购盲盒长期活动
	jd_super_box.js			#京东超级盒子
	jd_festival.js			#京东手机年终奖 2021年1月26日～2021年2月8日
	jd_mh.js			#京东盲盒
	jd_ms.js			#京东秒秒币
	jd_xg.js			#小鸽有礼 2021年1月15日至2021年2月19日
	jd_coupon.js			#源头好物红包
	jd_5g.js			#5G狂欢城
	jd_818.js			#京东手机狂欢城活动
	jd_xgyl.js			#小鸽有礼2 2021年1月28日～2021年2月28日
        jd_newYearMoney.js              #京东压岁钱
        jd_newYearMoney_lottery.js      ＃京东抢百元卡
	getJDCookie.js			#扫二维码获取cookie有效时间可以90天
	jd_get_share_code.js		#获取jd所有助力码脚本
	jd_bean_change.js		#京豆变动通知(长期)
	jd_unbind.js			#注销京东会员卡
	jd_unsubscribe.js		#取关京东店铺和商品
EOF

for script_name in `cat $dir_file/config/lxk0301_script.txt | awk '{print $1}'`
do
	wget $url/$script_name -O $dir_file_js/$script_name
done


url2="https://raw.githubusercontent.com/shylocks/Loon/main"
cat >$dir_file/config/shylocks_script.txt <<EOF
	jd_bj.js			#宝洁美发屋
	jd_super_coupon.js		#玩一玩-神券驾到,少于三个账号别玩
	jd_gyec.js			#工业爱消除
	jd_xxl.js			#东东爱消除
	jd_xxl_gh.js			#个护爱消除，完成所有任务+每日挑战
	jd_live_redrain2.js		#直播间红包雨 1月17日-2月5日，每天19点、20点、21点
	jd_live_redrain_nian.js		#年货直播雨 2021年1月20日-2021年1月30日、2月3日、2月5日每天0,9,11,13,15,17,19,20,21,23点可领
	jd_live_redrain_half.js		#半点红包雨 2021年1月20日-2021年2月5日每天12~23每个半点
	jd_live_redrain_offical.js	#官方号直播红包雨
	jd_vote.js			#京年团圆pick2021年1月11日至2021年1月20日 抽奖可获得京豆，白号100豆，黑号全是空气
	jd_sx.js			#海产新年抽奖，欧皇可中实物
	jd_opencard.js			#开卡活动，一次性活动，运行完脚本获得53京豆，进入入口还可以开卡领30都
	jd_friend.js			#JOY总动员 一期的活动
EOF

:<<'COMMENT'
for script_name in `cat $dir_file/config/shylocks_script.txt | awk '{print $1}'`
do
	wget $url2/$script_name -O $dir_file_js/$script_name
done
COMMENT
	cat $dir_file/config/lxk0301_script.txt > $dir_file/config/collect_script.txt
	cat $dir_file/config/shylocks_script.txt >> $dir_file/config/collect_script.txt

	wget https://raw.githubusercontent.com/799953468/Quantumult-X/master/Scripts/JD/jd_paopao.js -O $dir_file_js/jd_paopao.js
	wget https://raw.githubusercontent.com/whyour/hundun/master/quanx/jx_products_detail.js -O $dir_file_js/jx_products_detail.js


	if [ $? -eq 0 ]; then
		echo -e ">>$green脚本下载完成$white"
	else
		clear
		echo "脚本下载没有成功，重新执行代码"
		update
	fi
	chmod 755 $dir_file_js/*
	additional_settings
	echo -e "$green update$stop_script $white"

	task #更新完全部脚本顺便检查一下计划任务是否有变

}

update_script() {
	echo -e "$green update_script$start_script $white"
	cd $dir_file
	git fetch --all
	git reset --hard origin/main
	echo -e "$green update_script$stop_script $white"
}


run_0() {
	echo -e "$green run_0$start_script $white"
	#$node $dir_file_js/cfdtx.js #财富岛提取
	$node $dir_file_js/jd_car.js #京东汽车，签到满500赛点可兑换500京豆，一天运行一次即可
	$node $dir_file_js/jd_bean_sign.js #京东多合一签到
	$node $dir_file_js/jx_sign.js #京喜app签到长期
	$node $dir_file_js/jd_redPacket.js #京东全民开红包，没时间要求
	$node $dir_file_js/jd_lotteryMachine.js #京东抽奖机
	$node $dir_file_js/jd_cash.js #签到领现金，每日2毛～5毛长期
	$node $dir_file_js/jd_nh.js #京东年货节2021年1月9日-2021年2月9日
	$node $dir_file_js/jd_nian_sign.js #年兽签到
	$node $dir_file_js/jd_sgmh.js #闪购盲盒长期活动
	$node $dir_file_js/jd_jdzz.js #京东赚赚长期活动
	run_08_12_16
	$node $dir_file_js/jd_small_home.js #东东小窝
	run_06_18
	run_10_15_20
	run_01
	run_02
	run_03
	run_045
	$node $dir_file_js/jd_crazy_joy.js #crazyJoy任务
	echo -e "$green run_0$stop_script $white"
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
	pid=$(ps -ef ww | grep "jd_crazy_joy_coin.js" | grep -v grep | awk '{print $1}')
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

run_020() {
	echo -e "$green run_020$start_script $white"
	$node $dir_file_js/jd_nianCollect.js #京东炸年兽领爆竹
	echo -e "$green run_020$stop_script $white"
}

run_030() {
	echo -e "$green run_030$start_script $white"
	#$node $dir_file_js/jd_gyec.js #工业爱消除
	#$node $dir_file_js/jd_xxl.js #东东爱消除
	#$node $dir_file_js/jd_xxl_gh.js	#个护爱消除，完成所有任务+每日挑战
	echo -e "$green run_030$stop_script $white"
}

run_045() {
	echo -e "$green run_045$start_script $white"
	$node $dir_file_js/jd_dreamFactory.js #京喜工厂 45分钟运行一次
	$node $dir_file_js/jd_jdfactory.js #东东工厂，不是京喜工厂
	echo -e "$green run_045$stop_script $white"
}

run_01() {
	echo -e "$green run_01$start_script $white"
	$node $dir_file_js/jd_plantBean.js
	$node $dir_file_js/jd_joy_feedPets.js #种豆得豆，没时间要求，一个小时收一次瓶子 & #宠汪汪喂食一个小时喂一次
	#$node $dir_file_js/jd_family.js #京东家庭号
	echo -e "$green run_01$stop_script $white"
}

run_02() {
	echo -e "$green run_02$start_script $white"
	$node $dir_file_js/jd_moneyTree.js #京东摇钱树，7-9 11-13 18-20签到 每两小时收一次
	$node $dir_file_js/jd_bookshop.js #口袋书店
	echo -e "$green run_02$stop_script $white"
}

run_03() {
	echo -e "$green run_03$start_script $white"
	$node $dir_file_js/jd_speed.js #天天加速 3小时运行一次，打卡时间间隔是6小时
	echo -e "$green run_03$stop_script $white"
}


run_06_18() {
	echo -e "$green run_06_18$start_script $white"
	$node $dir_file_js/jd_blueCoin.js  #东东超市兑换，有次数限制，没时间要求
	$node $dir_file_js/jd_shop.js #进店领豆，早点领，一天也可以执行两次以上
	$node $dir_file_js/jd_fruit.js #东东水果，6-9点 11-14点 17-21点可以领水滴
	$node $dir_file_js/jd_joy.js #jd宠汪汪，零点开始，11.30-15:00 17-21点可以领狗粮
	$node $dir_file_js/jd_pet.js #东东萌宠，跟手机商城同一时间
	$node $dir_file_js/jd_joy_steal.js #可偷好友积分，零点开始，六点再偷一波狗粮
	$node $dir_file_js/jd_daily_egg.js #天天提鹅蛋，需要有金融app，没有顶多报错问题不大
	$node $dir_file_js/jd_pigPet.js #金融养猪，需要有金融app，没有顶多报错问题不大
	$node $dir_file_js/jd_superMarket.js #东东超市,6点 18点多加两场用于收金币
	echo -e "$green run_06_18$stop_script $white"
}

run_07() {
	echo -e "$green run_07$start_script $white"
	$node $dir_file_js/jd_bean_sign.js #京东多合一签到
	$node $dir_file_js/jx_sign.js #京喜app签到长期
	$node $dir_file_js/jd_rankingList.js #京东排行榜签到领京豆
	$node $dir_file_js/jd_syj.js #十元街签到,一天一次即可，一周30豆子
	$node $dir_file_js/jd_paopao.js #京东泡泡大战,一天一次
	$node $dir_file_js/jd_kd.js #京东快递签到 一天运行一次即可
	$node $dir_file_js/jd_bean_home.js #领京豆额外奖励
	$node $dir_file_js/jd_club_lottery.js #摇京豆，没时间要求
	$node $dir_file_js/jd_live.js #直播抢京豆 （需要执行三次，不然没有18豆子）
	$node $dir_file_js/jd_live.js #直播抢京豆
	$node $dir_file_js/jd_live.js #直播抢京豆
	$node $dir_file_js/jd_jdzz.js #京东赚赚长期活动
	#$node $dir_file_js/jd_jxnc.js #京喜农场
	$node $dir_file_js/jd_mh.js #京东盲盒
	$node $dir_file_js/jd_ms.js #京东秒秒币 一个号大概60秒
	$node $dir_file_js/jd_bj.js #宝洁美发屋
	$node $dir_file_js/jd_bj.js #宝洁美发屋
	$node $dir_file_js/jd_bj.js #宝洁美发屋
	$node $dir_file_js/jd_bj.js #宝洁美发屋
	$node $dir_file_js/jd_nian_ar.js #年兽ar
	$node $dir_file_js/jd_nian_wechat.js #京东炸年兽小程序
	$node $dir_file_js/jd_immortal.js #京东神仙书院 2021-1-20至2021-2-5
	#$node $dir_file_js/jd_sx.js #海产新年抽奖，欧皇可中实物
	rm -rf  $dir_file_js/jd_firecrackers.js	#集鞭炮赢京豆
	$node $dir_file_js/jd_super_box.js #京东超级盒子
	#$node $dir_file_js/jd_vote.js #京年团圆pick2021年1月11日至2021年1月20日 抽奖可获得京豆，白号100豆，黑号全是空气
	$node $dir_file_js/jd_super_coupon.js #玩一玩-神券驾到,少于三个账号别玩
	$node $dir_file_js/jd_xg.js #小鸽有礼 2021年1月15日至2021年2月19日
	$node $dir_file_js/jd_xgyl.js #小鸽有礼2 2021年1月28日～2021年2月28日
	$node $dir_file_js/jd_sgmh.js #闪购盲盒长期活动
	$node $dir_file_js/jd_festival.js #京东手机年终奖 2021年1月26日～2021年2月8日
	sy
	$node $dir_file_js/jd_unsubscribe.js #取关店铺，没时间要求
	#$node $dir_file_js/jd_unbind.js #注销京东会员卡
	$node $dir_file_js/jd_bean_change.js #京豆变更
	checklog #检测log日志是否有错误并推送
	echo -e "$green run_07$stop_script $white"
}

run_08_12_16() {
	echo -e "$green run_08_12_16$start_script $white"
	nian
	$node $dir_file_js/jd_joy_reward.js #宠汪汪积分兑换奖品，有次数限制，每日京豆库存会在0:00、8:00、16:00更新，经测试发现中午12:00也会有补发京豆
	$node $dir_file_js/jd_5g.js #5G狂欢城
	$node $dir_file_js/jd_818.js #京东手机狂欢城活动
        $node $dir_file_js/jd_newYearMoney.js #京东压岁钱
	echo -e "$green run_08_12_16$stop_script $white"
}

run_19_20_21() {
	echo -e "$green run_19_20_21$start_script $white"
	$node $dir_file_js/jd_live_redrain2.js #直播间红包雨 1月17日-2月5日，每天19点、20点、21点
	echo -e "$green run_19_20_21$stop_script $white"
}


run_10_15_20() {
	echo -e "$green run_10_15_20$start_script $white"
	$node $dir_file_js/jd_superMarket.js #东东超市,0 10 15 20四场补货加劵
	$node $dir_file_js/jd_necklace.js  #点点券 大佬0,20领一次先扔这里后面再改
	$node $dir_file_js/jx_cfd.js #京东财富岛 有一日三餐任务
	echo -e "$green run_10_15_20$stop_script $white"
}

baiyuan() {
        echo -e "$green百元卡$start_script $white"
	$node $dir_file_js/jd_newYearMoney_lottery.js
	echo -e "$green 百元卡$stop_script $white"
        
}
nian() {
	echo -e "$green炸年兽$start_script $white"
	$node $dir_file_js/jd_nian.js #京东炸年兽
	echo -e "$green 炸年兽$stop_script $white"
}

nian_live() {
	echo -e "$green年货直播雨$start_script $white"
	＃$node $dir_file_js/jd_live_redrain_nian.js		#年货直播雨 2021年1月20日-2021年1月30日、2月3日、2月5日每天0,9,11,13,15,17,19,20,21,23点可领
	echo -e "$green 年货直播雨$stop_script $white"
}

ddcs() {
	ddcs_left=15
	while [[ ${ddcs_left} -gt 0 ]]; do
		#$node $dir_file_js/jd_blueCoin.js  &	#东东超市兑换，有次数限制，没时间要求
		$node $dir_file_js/jd_coupon.js	&	#源头好物红包
		$node $dir_file_js/jd_car_exchange.js &  #京东汽车兑换，500赛点兑换500京豆
		sleep 1
		ddcs_left=$(($ddcs_left - 1))
	done
}

sy() {
	sy_left=15
	while [[ ${sy_left} -gt 0 ]]; do
		$node $dir_file_js/jd_immortal_answer.js
		sleep 10
		sy_left=$(($sy_left - 1))
	done
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
	echo -e "$green 查询完成$start_script $white"
}

stop_notice() {
	#农场和萌宠提示太多次了，所用每天提示一次即可
	sed -i "s/jdNotify = false/jdNotify = true/g" $dir_file_js/jd_fruit.js
	sed -i "s/jdNotify = false/jdNotify = true/g" $dir_file_js/jd_pet.js
	echo "时间大于两点开始关闭农场和萌宠提示请稍等"
	echo -e "$green农场和萌宠提示关闭成功$white"
}

checklog() {
	log1="checklog_jd.log" #用来查看tmp有多少jd log文件
	log2="checklog_jd_error.log" #筛选jd log 里面有几个是带错误的
	log3="checklog_jd_error_detailed.log" #将错误的都输出在这里

	cd /tmp
	rm -rf $log3

	#用来查看tmp有多少jd log文件
	ls ./ | grep -E "^j" | sort >$log1

	#筛选jd log 里面有几个是带错误的
	echo "#### 检测到错误日志的文件" >>$log3
	for i in `cat $log1`
	do
		grep -Elrn  "错误|失败|error|taskVos" $i >> $log2
		grep -Elrn  "错误|失败|error|taskVos" $i >> $log3
	done
	cat_log=$(cat $log2 | wc -l)
	if [ $cat_log -ge "1" ];then
		num="JD_Script发现有$cat_log个日志包含错误信息"
	else
		num="no_eeror"
	fi

	#将详细错误信息输出log3
	for i in `cat $log2`
	do
		echo "#### ${i}详细的错误" >> $log3
		grep -E  "错误|失败|taskVos" $i | grep -v '京东天天\|京东商城\|京东拍拍\|京东现金\|京东秒杀\|京东日历\|京东金融\|京东金贴\|金融京豆\|检测\|参加团主\|参团失败' | sort -u >> $log3
	done

	if [ $num = "no_eeror" ]; then
		echo "**********************************************"
		echo -e "$green log日志没有发现错误，一切风平浪静$white"
		echo "**********************************************"
	else
		if [ ! $SCKEY ];then
			echo "没找到Server酱key不做操作"
		else
			log_sort=$(cat ${log3} | sed "s/$/$wrap$wrap_tab$sort_log/g" |  sed ':t;N;s/\n//;b t' )
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

	if [ $(echo $git_log |wc -l) == "0"  ];then
		echo "#### JD_Script+$current_time" >>$dir_file/git_log/${current_time}.log
		echo "作者泡妹子或者干饭去了，今天没有任何更新，不要催佛系玩。。。" >>$dir_file/git_log/${current_time}.log
		echo "#### 当前脚本是否最新：$Script_status" >>$dir_file/git_log/${current_time}.log
	else
		echo "#### JD_Script+$current_time+更新日志" >> $dir_file/git_log/${current_time}.log
		echo "  时间       +作者          +操作" >> $dir_file/git_log/${current_time}.log
		echo "$git_log" >> $dir_file/git_log/${current_time}.log
		echo "#### 当前脚本是否最新：$Script_status" >>$dir_file/git_log/${current_time}.log
	fi



	log_sort=$(cat  $dir_file/git_log/${current_time}.log | sed "s/${current_time}//g" |sed "s/$/$wrap$wrap_tab/" | sed ':t;N;s/\n//;b t' | sed "s/$wrap_tab####/####/g")
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
	task
	clear
	echo ----------------------------------------------------
	echo "	     JD.sh $version 使用说明"
	echo ----------------------------------------------------
	echo -e "$yellow 1.文件说明$white"
	echo ""
	echo -e "$green  $script_dir/jdCookie.js $white 在此脚本内填写JD Cookie 脚本内有说明"
	echo -e "$green  $script_dir/sendNotify.js $white 在此脚本内填写推送服务的KEY，可以不填"
	echo -e "$green  $script_dir/USER_AGENTS.js $white UA文件可以自定义也可以默认 ，自定义需要抓包本机UA，然后修改删掉里面的UA，改成自己的"
	echo -e "$green  $script_dir/config/Script_blacklist.txt $white 脚本黑名单，用法去看这个文件"
	echo ""
	echo -e "$yellow JS脚本活动列表：$green https://gitee.com/lxk0301/jd_scripts/blob/master/README.md $white"
	echo -e "$yellow 浏览器获取京东cookie教程：$green https://gitee.com/lxk0301/jd_scripts/blob/master/backUp/GetJdCookie.md $white"
	echo -e "$yellow 脚本获取京东cookie：$green node $dir_file_js/getJDCookie.js $white"
	echo ""
	echo -e "$red 注意：$white请停掉你之前运行的其他jd脚本，然后把$green JS脚本活动列表$white的活动全部手动点开一次，不知活动入口的，作者js脚本里有写"
	echo ""
	echo -e "$yellow 2.jd.sh脚本命令$white"
	echo ""
	echo -e "$green  sh \$jd run_0  run_07			#运行全部脚本(除个别脚本不运行)$white"
	echo ""
	echo -e "$yellow个别脚本有以下："
	echo ""
	echo -e "$green  sh \$jd nian $white				#运行炸年兽"
	echo ""
	echo -e "$green  sh \$jd joy $white				#运行疯狂的JOY(两个号需要1G以上，sh \$jd kill_joy 杀掉进程，彻底关闭需要先杀进程再禁用定时任务的代码)"
	echo ""
	echo -e "$green  sh \$jd jx $white 				#查询京喜商品生产使用时间"
	echo ""
	echo -e "$green  sh \$jd jd_sharecode $white 			#查询京东所有助力码"
	echo ""
	echo -e "$green  sh \$jd stop_notice $white  			#关掉萌宠 农场  多次提醒"
	echo ""
	echo -e "$green  sh \$jd checklog $white  			#检测log日志是否有错误并推送"
	echo ""
	echo -e "$green  sh \$jd that_day $white  			#检测JD_script仓库今天更新了什么"
	echo ""
	echo -e "$green  sh \$jd script_name $white  			#显示所有JS脚本名称与作用"
	echo ""
	echo -e "$green  sh \$jd stop_script $white  			#删除定时任务停用所用脚本"
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
	echo -e "$yellow 6.JD_Script报错你可以反馈到这里:$white$green https://github.com/ITdesk01/JD_Script/issues$white"
	echo ""
	echo -e "本脚本基于$green x86主机测试$white，一切正常，其他的机器自行测试，满足依赖一般问题不大"
	echo ----------------------------------------------------
	echo " 		by：ITdesk"
	echo ----------------------------------------------------

	time &

}


additional_settings() {

	for i in `cat $dir_file/config/lxk0301_script.txt | awk '{print $1}'`
	do
		sed -i "s/$.isNode() ? 20 : 5/0/g" $dir_file_js/$i
	done

	for i in `cat $dir_file/config/shylocks_script.txt | awk '{print $1}'`
	do
		sed -i "s/$.isNode() ? 20 : 5/0/g" $dir_file_js/$i
	done


	#京小超默认兑换20豆子(JS已经默认兑换20了)
	#sed -i "s/|| 0/|| 20/g" $dir_file_js/jd_blueCoin.js

	#取消店铺从20个改成50个(没有星推官先默认20吧)
	sed -i "s/|| 20/|| 50/g" $dir_file_js/jd_unsubscribe.js

	#宠汪汪积分兑换奖品改成兑换500豆子，个别人会兑换错误(350积分兑换20豆子，8000积分兑换500豆子要求等级16级，16000积分兑换1000京豆16级以后不能兑换)
	#sed -i "s/let joyRewardName = 20/let joyRewardName = 500/g" $dir_file_js/jd_joy_reward.js

	#东东农场
	old_fruit1="'0a74407df5df4fa99672a037eec61f7e@dbb21614667246fabcfd9685b6f448f3@6fbd26cc27ac44d6a7fed34092453f77@61ff5c624949454aa88561f2cd721bf6@56db8e7bc5874668ba7d5195230d067a@b9d287c974cc498d94112f1b064cf934',"
	old_fruit2="'b1638a774d054a05a30a17d3b4d364b8@f92cb56c6a1349f5a35f0372aa041ea0@9c52670d52ad4e1a812f894563c746ea@8175509d82504e96828afc8b1bbb9cb3@2673c3777d4443829b2a635059953a28',"
	old_fruit3="'0a74407df5df4fa99672a037eec61f7e@dbb21614667246fabcfd9685b6f448f3@6fbd26cc27ac44d6a7fed34092453f77@61ff5c624949454aa88561f2cd721bf6@56db8e7bc5874668ba7d5195230d067a',"
	old_fruit4="'6fbd26cc27ac44d6a7fed34092453f77@61ff5c624949454aa88561f2cd721bf6@9c52670d52ad4e1a812f894563c746ea@8175509d82504e96828afc8b1bbb9cb3',"

	new_fruit1="0763443f7d6f4f5ea5e54adc1c6112ed@e61135aa1963447fa136f293a9d161c1@f9e6a916ad634475b8e77a7704b5c3d8@6632c8135d5c4e2c9ad7f4aa964d4d11@31a2097b10db48429013103077f2f037@5aa64e466c0e43a98cbfbbafcc3ecd02@bf0cbdb0083d443499a571796af20896@9046fbd8945f48cb8e36a17fff9b0983"
	new_fruit2="d4e3080b06ed47d884e4ef9852cad568@72abb03ca91a4569933c6c8a62a5622c@ed2b2d28151a482eae49dff2e5a588f8@304b39f17d6c4dac87933882d4dec6bc"
	new_fruit3="3e6f0b7a2d054331a0b5b956f36645a9@5e54362c4a294f66853d14e777584598@f227e8bb1ea3419e9253682b60e17ae5@f0f5edad899947ac9195bf7319c18c7f@5e567ba1b9bd4389ae19fa09ca276f33"
	zuoyou_20190516_fr="367e024351fe49acaafec9ee705d3836@3040465d701c4a4d81347bc966725137@82c164278e934d5aaeb1cf19027a88a3@b167fbe380124583a36458e5045ead57@5a1448c1a7944ed78bca2fa7bfeb8440@44ba60178aa04b7895fe60c8f3b80a71@a2504cd52108495496460fc8624ae6d4@7fe23f78c77a47b0aba16b302eedbd3c@3e0769f3bb2042d993194db32513e1b9@dbd7dcdbb75940d3b81282d0f439673f"
	Javon_20201224_fr="926a1ec44ddd459ab2edc39005628bf4@dcfb05a919ff472680daca4584c832b8@0ce9d3a5f9cd40ccb9741e8f8cf5d801@54ac6b2343314f61bc4a6a24d7a2eba1@bad22aba416d4fffb18ad8534b56ea60"
	cainiao5_20190516_fr="2a9ccd7f32c245d7a4d6c0fe1cafdd4c"
	whiteboy__20190711_fr="dfb6b5dcc9d24281acbfce5d649924c0@319239c7aed84c1a97092ddbf2564717@45e193df45704b8bb25e04ea86c650bf@49fefaa873c84b398882218588b0647a"
	jiu_20210110_fr="a413cb9823394d2d91eb8346d2fa4514@96721546e8fd429dbfa1351c907ea0f7"
	Oyeah_20200104_fr="5e54362c4a294f66853d14e777584598"
	shisan_20200213_fr="cf13366e69d648ff9022e0fdce8c172a"
	JOSN_20200807_fr="2868e98772cb4fac9a04cd43e964f337"
	Jhone_Potte_20200824_fr="64304080a2714e1cac59af03b0009581@e9333dbf9c294ad6af2792dacc236fe7"
	liandao_20201010_fr="1c6474a197af4b3c8d40c26ec7f11c9e@6f7a7cc42b9342e29163588bafc3782b"
	adong_20201108_fr="3d1985319106483ba83de3366d3716d5@9e9d99a4234d45cd966236d3cb3908cf"
	deng_20201120_fr="bc26d0bdc442421aa92cafcf26a1e148@57cf86ce18ca4f4987ce54fae6182bbd@521a558fcce44fbbb977c8eba4ba0d40@389f3bfe4bdc45e2b1c3e2f36e6be260@26c79946c7cc4477b56d94647d0959f2@26c79946c7cc4477b56d94647d0959f2"
	gomail_20201125_fr="31fee3cdb980491aad3b81d30d769655@0fe3938992cb49d78d4dfd6ce3d344fc"
	baijiezi_20201126_fr="09f7e5678ef44b9385eabde565c42715@ea35a3b050e64027be198e21df9eeece@62595da92a5140a3afc5bc22275bc26c@cb5af1a5db2b405fa8e9ec2e8aca8581"
	superbei666_20201124_fr="599451cd6e5843a4b8045ba8963171c5"
	yiji_20201125_fr="df3ae0b59ca74e7a8567cdfb8c383f02@e3ec63e3ba65424881469526d8964657"
	mjmdz_20201217_fr="9cd630e21bf44a1ea1512402827e4655"
	JDnailao_20201230_fr="daec421fb1d745148c0ae9bb298f1157"
	xo_20201229_fr= "0ab77174e0a446ceaf075d2de507066b"
	
	new_fruit_set="'$new_fruit1@$new_fruit2@$new_fruit3@$zuoyou_20190516_fr@$Javon_20201224_fr@$cainiao5_20190516_fr@$whiteboy__20190711_fr@$jiu_20210110_fr@$Oyeah_20200104_fr@$shisan_20200213_fr@$JOSN_20200807_fr@$Jhone_Potte_20200824_fr@$liandao_20201010_fr@$adong_20201108_fr@$deng_20201120_fr@$gomail_20201125_fr@$baijiezi_20201126_fr@$superbei666_20201124_fr@$yiji_20201125_fr@$mjmdz_20201217_fr@$JDnailao_20201230_fr@$xo_20201229_fr',"
	sed -i "s/$old_fruit1/$new_fruit_set/g" $dir_file_js/jd_fruit.js
	sed -i "s/$old_fruit2/$new_fruit_set/g" $dir_file_js/jd_fruit.js
	sed -i "34a $new_fruit_set\n$new_fruit_set\n$new_fruit_set\n$new_fruit_set" $dir_file_js/jd_fruit.js
	sed -i "s/dFruitBeanCard = false/dFruitBeanCard = true/g" $dir_file_js/jd_fruit.js #年底不浇水开始换豆

	sed -i "s/$old_fruit3/$new_fruit_set/g" $dir_file_js/jdFruitShareCodes.js
	sed -i "s/$old_fruit4/$new_fruit_set/g" $dir_file_js/jdFruitShareCodes.js
	sed -i "11a $new_fruit_set\n$new_fruit_set\n$new_fruit_set\n$new_fruit_set" $dir_file_js/jdFruitShareCodes.js.

	#萌宠
	old_pet1="'MTAxODc2NTEzNTAwMDAwMDAwMjg3MDg2MA==@MTAxODc2NTEzMzAwMDAwMDAyNzUwMDA4MQ==@MTAxODc2NTEzMjAwMDAwMDAzMDI3MTMyOQ==@MTAxODc2NTEzNDAwMDAwMDAzMDI2MDI4MQ==@MTAxODcxOTI2NTAwMDAwMDAxOTQ3MjkzMw==',"
	old_pet2="'MTAxODc2NTEzMjAwMDAwMDAzMDI3MTMyOQ==@MTAxODcxOTI2NTAwMDAwMDAyNjA4ODQyMQ==@MTAxODc2NTEzOTAwMDAwMDAyNzE2MDY2NQ==@MTE1NDUyMjEwMDAwMDAwNDI0MDM2MDc=',"
	old_pet3="'MTAxODc2NTEzNTAwMDAwMDAwMjg3MDg2MA==@MTAxODc2NTEzMzAwMDAwMDAyNzUwMDA4MQ==@MTAxODc2NTEzMjAwMDAwMDAzMDI3MTMyOQ==@MTAxODc2NTEzNDAwMDAwMDAzMDI2MDI4MQ==',"
	old_pet4="'MTAxODc2NTEzMjAwMDAwMDAzMDI3MTMyOQ==@MTAxODcxOTI2NTAwMDAwMDAyNjA4ODQyMQ==@MTAxODc2NTEzOTAwMDAwMDAyNzE2MDY2NQ==',"

	new_pet1="MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzcwMDAwMDAwMzk1OTQ4Njk==@MTE1NDQ5OTUwMDAwMDAwMzk3NDgyMDE==@MTAxODEyOTI4MDAwMDAwMDQwMTIzMzcx@MTEzMzI0OTE0NTAwMDAwMDA0MzI3NzE3MQ==@MTEzMzI0OTE0NTAwMDAwMDAzOTk5ODU1MQ==@MTAxODc2NTEzMzAwMDAwMDAxOTkzMzM1MQ=="
	new_pet2="MTAxODEyOTI4MDAwMDAwMDM5NzM3Mjk5@MTAxODc2NTEzMDAwMDAwMDAxOTcyMTM3Mw==@MTE1NDQ5MzYwMDAwMDAwMzk2NTY2MTE==@MTE1NDQ5OTUwMDAwMDAwMzk2NTY2MTk==@MTE1NDQ5OTUwMDAwMDAwNDAyNTYyMjM=="
	new_pet3="MTAxODEyOTI4MDAwMDAwMDQwNzYxOTUx@MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzcwMDAwMDAwNDA4MzcyOTU==@MTE1NDQ5OTIwMDAwMDAwNDIxMDIzMzM="
	zuoyou_20190516_pet="MTEzMzI0OTE0NTAwMDAwMDAzODYzNzU1NQ==@MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzgwMDAwMDAwMzg2Mzc1Nzc=@MTE1NDAxNzgwMDAwMDAwMzg4MzI1Njc=@MTAxODc2NTEzNDAwMDAwMDAyNzAxMjc1NQ==@MTAxODc2NTEzMDAwMDAwMDAyMTIzNjU5Nw==@MTAxODc2NTE0NzAwMDAwMDAyNDk1MDMwMQ==@MTAxODc2NTEzNTAwMDAwMDAyMjc1OTY1NQ==@MTEzMzI0OTE0NTAwMDAwMDA0MzQ1OTI1MQ==@MTE1NDQ5OTUwMDAwMDAwNDM3MDkyMDc="
	Javon_20201224_pet="MTE1NDUyMjEwMDAwMDAwNDE2NzYzNjc=@MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzgwMDAwMDAwNDI1MjkxMDU=@MTE1NDQ5OTIwMDAwMDAwNDIxMjgyNjM=@MTE1NDAxNzYwMDAwMDAwMzYwNjg0OTE=@MTE1NDQ5OTIwMDAwMDAwNDI4Nzk3NTE="
	cainiao5_20190516_pet="MTAxODc2NTEzMzAwMDAwMDAyMTg1ODcwMQ=="
	whiteboy_20190711_pet="MTAxODc2NTEzMzAwMDAwMDAwNjU4NDU4NQ==@MTAxODc2NTE0NzAwMDAwMDAwNDI4ODExMQ=="
	jiu_20210110_pet="MTE1NDUwMTI0MDAwMDAwMDQwODg1ODg3@MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzgwMDAwMDAwNDM1NjI2Mjk="
	Oyeah_20200104_pet="MTE1NDQ5OTUwMDAwMDAwNDAyNTYyMjM="
	shisan_20200213_pet="MTAxODc2NTEzMjAwMDAwMDAyMjc4OTI5OQ=="
	JOSN_20200807_pet="MTEzMzI0OTE0NTAwMDAwMDA0MTc2Njc2Nw=="
	Jhone_Potte_20200824_pet="MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzcwMDAwMDAwNDE3MDkwNzE=@MTE1NDUyMjEwMDAwMDAwNDE3NDU2MjU="
	liandao_20201010_pet="MTE1NDQ5MzYwMDAwMDAwNDA3Nzk0MTc=@MTE1NDQ5OTUwMDAwMDAwNDExNjIxMDc="
	adong_20201108_pet="MTAxODc2NTEzMTAwMDAwMDAyMTIwNTc3Nw==@MTEzMzI0OTE0NTAwMDAwMDA0MjE0MjUyNQ=="
	deng_20201120_pet="MTE1NDUwMTI0MDAwMDAwMDM4MzAwMTI5@MTE1NDQ5OTUwMDAwMDAwMzkxMTY3MTU=@MTE1NDQ5MzYwMDAwMDAwMzgzMzg3OTM=@MTAxODc2NTEzNTAwMDAwMDAyMzk1OTQ4OQ==@MTAxODExNDYxMTAwMDAwMDAwNDA2MjUzMTk=@MTE1NDUwMTI0MDAwMDAwMDM5MTg4MTAz"
	gomail_20201125_pet="MTE1NDQ5MzYwMDAwMDAwMzcyOTA4MDU=@MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzYwMDAwMDAwNDE0MzQ4MTE="
	baijiezi_20201126_pet="MTE1NDUyMjEwMDAwMDAwNDI4ODA5NDU=@MTE1NDQ5OTUwMDAwMDAwNDI4ODA5NTE=@MTE1NDAxNzgwMDAwMDAwNDE0NzQ3ODM=@MTE1NDUyMjEwMDAwMDAwNDA4MTg2NDE=@MTAxODc2NTEzNTAwMDAwMDAwNTI4ODM0NQ==@MTAxODc2NTEzMDAwMDAwMDAxMjM4ODExMw=="
	superbei666_20201124_pet="MTAxODcxOTI2NTAwMDAwMDAyNjc1MzUzMw=="
	yiji_20201125_pet="MTE1NDUwMTI0MDAwMDAwMDQyODExMzU1@MTEzMzI0OTE0NTAwMDAwMDA0Mjg4NTczOQ=="
	mjmdz_20201217_pet="MTAxODc2NTEzMTAwMDAwMDAyNzI5OTU3MQ=="
	JDnailao_20201230_pet="MTEzMzI0OTE0NTAwMDAwMDA0MzEzMjkzNw=="
	xo_20201229_pet= "MTAxODc2NTEzNTAwMDAwMDAyMzYzODQzNw=="
	
	new_pet_set="'$new_pet1@$new_pet2@$new_pet3@$zuoyou_20190516_pet@$Javon_20201224_pet@$cainiao5_20190516_pet@$whiteboy_20190711_pet@$jiu_20210110_pet@$Oyeah_20200104_pet@$shisan_20200213_pet@$JOSN_20200807_pet@$Jhone_Potte_20200824_pet@$liandao_20201010_pet@$adong_20201108_pet@$deng_20201120_pet@$gomail_20201125_pet@$baijiezi_20201126_pet@$superbei666_20201124_pet@$yiji_20201125_pet@$mjmdz_20201217_pet@$JDnailao_20201230_pet@$xo_20201229_pet',"

	sed -i "s/$old_pet1/$new_pet_set/g" $dir_file_js/jd_pet.js
	sed -i "s/$old_pet2/$new_pet_set/g" $dir_file_js/jd_pet.js
	sed -i "35a $new_pet_set\n$new_pet_set\n$new_pet_set\n$new_pet_set" $dir_file_js/jd_pet.js

	sed -i "s/$old_pet3/$new_pet_set/g" $dir_file_js/jdPetShareCodes.js
	sed -i "s/$old_pet4/$new_pet_set/g" $dir_file_js/jdPetShareCodes.js
	sed -i "11a $new_pet_set\n$new_pet_set\n$new_pet_set\n$new_pet_set" $dir_file_js/jdPetShareCodes.js


	#种豆
	old_plantBean1="'66j4yt3ebl5ierjljoszp7e4izzbzaqhi5k2unz2afwlyqsgnasq@olmijoxgmjutyrsovl2xalt2tbtfmg6sqldcb3q@e7lhibzb3zek27amgsvywffxx7hxgtzstrk2lba@e7lhibzb3zek32e72n4xesxmgc2m76eju62zk3y',"
	old_plantBean2="'olmijoxgmjutyx55upqaqxrblt7f3h26dgj2riy@nuvfqviuwvnigxx65s7s77gbbvd4thrll7o63pq@fn5sjpg5zdejnypipngfhaudisqrfccakjuyaty@e7lhibzb3zek2xhmmypkf6ratimjeenqwvqvwjq@4npkonnsy7xi3p6pjfxg6ct5gll42gmvnz7zgoy@6dygkptofggtp6ffhbowku3xgu@mlrdw3aw26j3wgzjipsxgonaoyr2evrdsifsziy',"
	old_plantBean3="'66j4yt3ebl5ierjljoszp7e4izzbzaqhi5k2unz2afwlyqsgnasq@olmijoxgmjutyrsovl2xalt2tbtfmg6sqldcb3q@e7lhibzb3zek27amgsvywffxx7hxgtzstrk2lba@olmijoxgmjutyx55upqaqxrblt7f3h26dgj2riy',"
	old_plantBean4="'nuvfqviuwvnigxx65s7s77gbbvd4thrll7o63pq@fn5sjpg5zdejnypipngfhaudisqrfccakjuyaty@e7lhibzb3zek2xhmmypkf6ratimjeenqwvqvwjq@4npkonnsy7xi3p6pjfxg6ct5gll42gmvnz7zgoy@6dygkptofggtp6ffhbowku3xgu@mlrdw3aw26j3wgzjipsxgonaoyr2evrdsifsziy@mlrdw3aw26j3wgzjipsxgonaoyr2evrdsifsziy',"

	new_plantBean1="nuvfqviuwvnigxx65s7s77gbbvd4thrll7o63pq@fn5sjpg5zdejnypipngfhaudisqrfccakjuyaty@e7lhibzb3zek2xhmmypkf6ratimjeenqwvqvwjq@4npkonnsy7xi3n46rivf5vyrszud7yvj7hcdr5a@mlrdw3aw26j3xeqso5asaq6zechwcl76uojnpha@nkvdrkoit5o65lgaousaj4dqrfmnij2zyntizsa@u5lnx42k5ifivyrtqhfjikhl56zsnbmk6v66uzi@3wmn5ktjfo7ukgaymbrakyuqry3h7wlwy7o5jii"
	new_plantBean2="olmijoxgmjutyy7u5s57pouxi5teo3r4r2mt36i@chcdw36mwfu6bh72u7gtvev6em@olmijoxgmjutzh77gykzjkyd6zwvkvm6oszb5ni@nuvfqviuwvnigxx65s7s77gbbvd4thrll7o63pq@fn5sjpg5zdejnypipngfhaudisqrfccakjuyaty@e7lhibzb3zek2xhmmypkf6ratimjeenqwvqvwjq@4npkonnsy7xi3smz2qmjorpg6ldw5otnabrmlei"
	new_plantBean3="e7lhibzb3zek2zin4gnao3gynqwqgrzjyopvbua@e7lhibzb3zek234ckc2fm2yvkj5cbsdpe7y6p2a@crydelzlvftgpeyuedndyctelq@u72q4vdn3zes24pmx6lh34pdcinjjexdfljybvi@mlrdw3aw26j3w2hy5trqwqmzn6ucqiz2ribf7na"
	zuoyou_20190516_pb="sz5infcskhz3woqbns6eertieu@mxskszygpa3kaouswi7rele2ji@nuvfqviuwvnigxx65s7s77gbbvd4thrll7o63pq@fn5sjpg5zdejnypipngfhaudisqrfccakjuyaty@e7lhibzb3zek2xhmmypkf6ratimjeenqwvqvwjq@4npkonnsy7xi3vk7khql3p7gkpodivnbwjoziga@mlrdw3aw26j3xizu2u66lufwmtn37juiz4xzwmi@e7lhibzb3zek35xkfdysslqi4jy7prkhfvxryma@s7ete3o7zokpafftarfntyydni@cq7ylqusen234wdwxxbkf23g6y@advwde6ogv6oya4md5eieexlfi@ubn2ft6u6wnfxwt6eyxsbcvj44@4npkonnsy7xi3tqkdk2gmzv5vdq4xk4g3cuwp7y"
	Javon_20201224_pb="wpwzvgf3cyawfvqim3tlebm3evajyxv67k5fsza@qermg6jyrtndlahowraj6265fm@rug64eq6rdioosun4upct64uda5ac3f4ijdgqji@t4ahpnhib7i4hbcqqocijnecby@5a43e5atkvypfxat7paaht76zy"
	cainiao5_20190516_pb="mlrdw3aw26j3wuxtla52mzrnywbtfqzw6bzyi3y"
	whiteboy_20190711_pb="jfbrzo4erngfjdjlvmvpkpgbgie7i7c6gsw54yq@e7lhibzb3zek3uzcrgdebl2uyh3kuh7kap6cwaq"
	jiu_20210110_pb="e7lhibzb3zek3ng2hntfcceilic4hw26k24s3li@mlrdw3aw26j3wbley5cfqbdzsfdhusjessnlavi"
	Oyeah_20200104_pb="e7lhibzb3zek234ckc2fm2yvkj5cbsdpe7y6p2a"
	shisan_20200213_pb="mlrdw3aw26j3xzd26qnacr3cfnm4zggngukbhny"
	JOSN_20200807_pb="pmvt25o5pxfjzcquanxwokbgvu3h7wlwy7o5jii"
	Jhone_Potte_20200824_pb="olmijoxgmjutzcbkzw4njrhy3l3gwuh6g2qzsvi@olmijoxgmjuty4tpgnpbnzvu4pl6hyxp3sferqa"
	liandao_20201010_pb="nxawbkvqldtx4wdwxxbkf23g6y@l4ex6vx6yynouxxefa4hfq6z3in25fmktqqwtca"
	adong_20201108_pb="qhw4z5vauoy4gfkaybvpmxvjfi@olmijoxgmjuty6wu5iufrhoi6jmzzodszk6xgda"
	deng_20201120_pb="e7lhibzb3zek3knwnjhrbaadekphavflo22jqii@olmijoxgmjutzfvkt4iu7xobmplveczy2ogou3i@f3er4cqcqgwogenz3dwsg7owhy@eupxefvqt76x2ssddhd35aysfrchgqeijzo2wdi@3en43v3ev6tvx55oefp3vb2xure67mm3kwgsm6a@nkvdrkoit5o657wm7ui35qcu2dmtir7t5h7sema"
	gomail_20201125_pb="yzhv4vq2u2tan56h4a764rocbe@nuvfqviuwvnigxx65s7s77gbbvd4thrll7o63pq@fn5sjpg5zdejnypipngfhaudisqrfccakjuyaty@e7lhibzb3zek2xhmmypkf6ratimjeenqwvqvwjq@4npkonnsy7xi2rducm544znpdzi2gnyg5ygrqei"
	baijiezi_20201126_pb="m6brcm36t5fvxhxnhnjzssq3fauk3bdje2jbnra@mlkc4vnryrhbob7aruocema224@vv3gwhnjzvf5scyicvcrylwldjf2yqvagsa35cy@76gkpqn3nufwjfzgfcv2mxfeimcie5fxpwtraba"
	superbei666_20201124_pb="gcdr655xfdjq764agedg7f27knlvxw5krpeddfq"
	yiji_20201125_pb="qm7basnqm6wnqtoyefmgh65nby@mnuvelsb76r27b4ovdbtrrl2u5a53z543epg7hi"
	mjmdz_20201217_pb="olmijoxgmjutyscsyoot23r7uze7u6yf6pwytni"
	JDnailao_20201230_pb="nijojgywxnignilnryycfs6pau"
	xo_20201229_pb="rm4pdd5xupcmtvhrdwrn6luniardbktuo6umwtq"
	
	new_plantBean_set="'$new_plantBean1@$new_plantBean2@$new_plantBean3@$zuoyou_20190516_pb@$Javon_20201224_pb@$cainiao5_20190516_pb@$whiteboy_20190711_pb@$jiu_20210110_pb@$Oyeah_20200104_pb@$shisan_20200213_pb@$JOSN_20200807_pb@$Jhone_Potte_20200824_pb@$@$liandao_20201010_pb@$adong_20201108_pb@$deng_20201120_pb@$gomail_20201125_pb@$baijiezi_20201126_pb@$superbei666_20201124_pb@$yiji_20201125_pb@$mjmdz_20201217_pb@$JDnailao_20201230_pb@$xo_20201229_pb',"
	sed -i "s/$old_plantBean1/$new_plantBean_set/g" $dir_file_js/jd_plantBean.js
	sed -i "s/$old_plantBean2/$new_plantBean_set/g" $dir_file_js/jd_plantBean.js
	sed -i "39a $new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set" $dir_file_js/jd_plantBean.js

	sed -i "s/$old_plantBean3/$new_plantBean_set/g" $dir_file_js/jdPlantBeanShareCodes.js
	sed -i "s/$old_plantBean4/$new_plantBean_set/g" $dir_file_js/jdPlantBeanShareCodes.js
	sed -i "11a $new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set\n$new_plantBean_set" $dir_file_js/jdPlantBeanShareCodes.js


	#京喜工厂
	old_dreamFactory="'V5LkjP4WRyjeCKR9VRwcRX0bBuTz7MEK0-E99EJ7u0k=@Bo-jnVs_m9uBvbRzraXcSA==@-OvElMzqeyeGBWazWYjI1Q==',"
	old_dreamFactory1="'1uzRU5HkaUgvy0AB5Q9VUg==@PDPM257r_KuQhil2Y7koNw==@-OvElMzqeyeGBWazWYjI1Q==',"
	new_dreamFactory="X2poJVLcLoygZX0TgGmkl8EiBIkQe_zrMAZqtgL24-M=@5MIEocu93aHBEq_1DLOFFA==@4HL35B_v85-TsEGQbQTfFg==@q3X6tiRYVGYuAO4OD1-Fcg==@Gkf3Upy3YwQn2K3kO1hFFg==@w8B9d4EVh3e3eskOT5PR1A==@1s8ZZnxD6DVDyjdEUu-zXA==@FyYWfETygv_4XjGtnl2YSg==@us6se4fFC6cSjHDSS_ScMw==@oWcboKZa9XxTSWd28tCEPA==@sboe5PFeXgL2EWpxucrKYw==@rm-j1efPyFU50GBjacgEsw==@1rQLjMF_eWMiQ-RAWARW_w==@bHIVoTmS-fHA6G9ixqnOxfjRNGe1YfJzIbBoF-NEAOw=@6h514zWW6JNRE_Kp-L4cjA==@WFlk160B_Byd-xNNEyRPJQ==@bxUPiWroac-c9PLIPSjnNQ==@P2nGgK6JgLtCqJBeQJ0f27XXLQwYAFHrKmA2siZTuj8=@LTyKtCPGU6v0uv-n1GSwfQ==@y7KhVRopnOwB1qFo2vIefg==@WnaDbsWYwImvOD1CpkeVWA==@Y4r32JTAKNBpMoCXvBf7oA=="
	zuoyou_20190516_df="oWcboKZa9XxTSWd28tCEPA==@sboe5PFeXgL2EWpxucrKYw==@rm-j1efPyFU50GBjacgEsw==@cA7LmxYoXxJNLnS7j25dxA==@aAwyOK0kb9OSm2oq2JVYMQ==@BprHGWI9w04zUnZPbIzKgw==@9whmFTgMFw7ZfXcQdEJ3UA==@zVn3SNiwrEhxQEcbMZA27w==@k7iROwM2-Ha5EA59rRxBTg=="
	Jhone_Potte_20200824_df="Q4Rij5_6085kuANMaAvBMA==@gTLa05neWl8UFTGKpFLeog=="
	whiteboy_20190711_df="U_NgGvEUnbU6IblJUTMQV3F7G5ihingk9kVobx99yrY=@BXXbkqJN7sr-0Qkid6v27A=="
	
	new_dreamFactory_set="'$new_dreamFactory@$zuoyou_20190516_df@$Jhone_Potte_20200824_df@$whiteboy_20190711_df',"
	sed -i "s/6S9y4sJUfA2vPQP6TLdVIQ==/X2poJVLcLoygZX0TgGmkl8EiBIkQe_zrMAZqtgL24-M=@5MIEocu93aHBEq_1DLOFFA==@4HL35B_v85-TsEGQbQTfFg==/g" $dir_file_js/jd_dreamFactory.js
	sed -i "s/"gB99tYLjvPcEFloDgamoBw==",/'gB99tYLjvPcEFloDgamoBw==',/g" $dir_file_js/jd_dreamFactory.js
	sed -i "s/'V5LkjP4WRyjeCKR9VRwcRX0bBuTz7MEK0-E99EJ7u0k=@0WtCMPNq7jekehT6d3AbFw==', 'PDPM257r_KuQhil2Y7koNw==', 'gB99tYLjvPcEFloDgamoBw==', '-OvElMzqeyeGBWazWYjI1Q==', 'GFwo6PntxDHH95ZRzZ5uAg=='/$new_dreamFactory/g" $dir_file_js/jd_dreamFactory.js
	sed -i "s/$old_dreamFactory/$new_dreamFactory_set/g" $dir_file_js/jdDreamFactoryShareCodes.js
	sed -i "s/$old_dreamFactory1/$new_dreamFactory_set/g" $dir_file_js/jdDreamFactoryShareCodes.js
	sed -i "11a $new_dreamFactory_set\n$new_dreamFactory_set\n$new_dreamFactory_set\n$new_dreamFactory_set" $dir_file_js/jdDreamFactoryShareCodes.js

:<<'COMMENT'
	#东东工厂
	old_jdfactory="\`P04z54XCjVWnYaS5u2ak7ZCdan1Bdd2GGiWvC6_uERj\`, 'P04z54XCjVWnYaS5m9cZ2ariXVJwHf0bgkG7Uo'"
	#new_jdfactory="'T024anXulbWUI_NR9ZpeTHmEoPlACjVWnYaS5kRrbA@P04z54XCjVWnYaS5m9cZ2f83X0Zl_Dd8CqABxo', 'P04z54XCjVWnYaS5m9cZ2Wui31Oxg3QPwI97G0', 'P04z54XCjVWnYaS5m9cZz-inDgt5gUTV9zVCg', 'P04z54XCjVWnYaS5m9cZ2T8jntInKkhvhlkIu4', 'P04z54XCjVWnYaS5m9cZ2eq2S1OxAqmz-x3vbg',"
	new_jdfactory1="'T024anXulbWUI_NR9ZpeTHmEoPlACjVWnYaS5kRrbA@P04z54XCjVWnYaS5m9cZ2f83X0Zl_Dd8CqABxo@P04z54XCjVWnYaS5m9cZ2Wui31Oxg3QPwI97G0@P04z54XCjVWnYaS5m9cZz-inDgt5gUTV9zVCg@T0205KkcJEZAjD2vYGGG4Ip0CjVWnYaS5kRrbA@P04z54XCjVWnYaS5m9cZ2T8jntInKkhvhlkIu4@P04z54XCjVWnYaS5m9cZ2eq2S1OxAqmz-x3vbg@P04z54XCjVWnYaS5mZQUSm92H5L@P04z54XCjVWnYaS5mlKD2U@P04z54XCjVWnYaS5n1LTCj93Q@P04z54XCjVWnYaS5m9cZ2er3ylCk-4HZadagsg@T023uvp2RBcY_VHKKBn3k_MMdNwCjVWnYaS5kRrbA',"
	sed -i "s/'',/$new_jdfactory1 $new_jdfactory1 $new_jdfactory1/g" $dir_file_js/jdFactoryShareCodes.js
	sed -i "s/$old_jdfactory/$new_jdfactory1/g" $dir_file_js/jd_jdfactory.js

	if [[ -f "$dir_file/1.txt" ]]; then
		sed -i "s/let wantProduct = \`\`/let wantProduct = \`灵蛇机械键盘\`/g" $dir_file_js/jd_jdfactory.js
	elif [[ -f "$dir_file/2.txt" ]]; then
		sed -i "s/let wantProduct = \`\`/let wantProduct = \`电视\`/g" $dir_file_js/jd_jdfactory.js
	else
		echo ""
	fi


	#京喜农场
	old_jxnc="'22bd6fbbabbaa770a45ab2607e7a1e8a@197c6094e965fdf3d33621b47719e0b1'"
	new_jxnc="6210b7cb41e01b14d92b2d91eed78384@9455922013cf0f704ee6fc9416ec05df@df0165aa52755c3a5337bc789552d9a8@019cffd91086ab563e91abf469634395@48f4c24ea3d01be32359cc61ba43ae7e@87c34293058a8644f73be7731a91a293@16b73e9a958c3f4636a51a17fcba28df@6cdc3a49111b7b57153a633eb6c1b1e3"
	zuoyou_20190516_jxnc="8476543ed84f16c6446d48bbe8f769d4@ed92326cbc2013dfc769c5e813599b7c@74e57e9c14b59e8f11baa46d83f5f145@a782af3074ea9a1d0c72be5f04e324d4@e7ccd6363a8d84109b6ea5b6d2d7d355@48117805cf3c3f67371467c7b598964b@203c9e8921ec34ad159c301df8a3874c@c8a49d0b56a702a252d5ec3feea1c31e@f162cc02054a5be81ac30f9557bfd97b"
	jidiyangguang_20190516_jxnc="ba177c5a5cbfdf43ea517cd21c0c6250@01a09a00572befec4edb60e9d39f7ba1"
	chiyu_jxnc="6a1d2f560c746e4175d9c5bfc1f30ca1"

	new_jxnc_set="'$new_jxnc@$zuoyou_20190516_jxnc@$jidiyangguang_20190516_jxnc@$chiyu_jxnc',"
	sed -i "s/$old_jxnc/'6210b7cb41e01b14d92b2d91eed78384@9455922013cf0f704ee6fc9416ec05df@df0165aa52755c3a5337bc789552d9a8@019cffd91086ab563e91abf469634395@48f4c24ea3d01be32359cc61ba43ae7e@87c34293058a8644f73be7731a91a293@16b73e9a958c3f4636a51a17fcba28df@6cdc3a49111b7b57153a633eb6c1b1e3'/g" $dir_file_js/jd_jxnc.js
	sed -i "s/'',/$new_jxnc_set/g" $dir_file_js/jdJxncShareCodes.js
	sed -i "12a $new_jxnc_set\n$new_jxnc_set\n$new_jxnc_set\n$new_jxnc_set" $dir_file_js/jdJxncShareCodes.js

	#工业爱消除
	old_jdgyec="'840266@2583822@2585219@2586018@1556311@2583822@2585256@2586023@2728968',"
	new_jdgyec="'1900455@2771801@2771913@743359@2753077@2759122@2759259@2337978',"

	new_jdgyec_set="'$new_jdgyec',"
	sed -i "s/$old_jdgyec,/$new_jdgyec_set/g" $dir_file_js/jd_gyec.js
	sed -i "s/$old_jdgyec/$new_jdgyec_set/g" $dir_file_js/jd_gyec.js
	sed -i "35a $new_jdgyec_set\n$new_jdgyec_set\n$new_jdgyec_set\n$new_jdgyec_set" $dir_file_js/jd_gyec.js

	#东东爱消除
	old_jdxxl="'840266@2585219@2586018@1556311@2583822@2585256',"
	new_jdxxl="1900455@2771801@2771913@743359@2753077@2759122@2759259@2337978"

	new_jdxxl_set="'$new_jdxxl',"
	sed -i "s/$old_jdxxl/$new_jdxxl_set/g" $dir_file_js/jd_xxl.js
	sed -i "37a $new_jdxxl_set\n$new_jdxxl_set\n$new_jdxxl_set\n$new_jdxxl_set" $dir_file_js/jd_xxl.js

	#个护爱消除
	old_jdxxlgh="'840266@2585219@2586018@1556311@2583822@2585256',"
	new_jdxxlgh="1900455@2771801@2771913@743359@2753077@2759122@2759259@2337978"

	new_jdxxlgh_set="'$new_jdxxlgh',"
	sed -i "s/$old_jdxxlgh/$new_jdxxlgh_set/g" $dir_file_js/jd_xxl_gh.js
	sed -i "39a $new_jdxxlgh_set\n$new_jdxxlgh_set\n$new_jdxxlgh_set\n$new_jdxxlgh_set" $dir_file_js/jd_xxl_gh.js

COMMENT

	#京东赚赚长期活动
	old_jdzz="\`ATGEC3-fsrn13aiaEqiM@AUWE5maSSnzFeDmH4iH0elA@ATGEC3-fsrn13aiaEqiM@AUWE5m6WUmDdZC2mr1XhJlQ@AUWE5m_jEzjJZDTKr3nwfkg@A06fNSRc4GIqY38pMBeLKQE2InZA@AUWE5mf7ExDZdDmH7j3wfkA@AUWE5m6jBy2cNAWX7j31Pxw@AUWE5mK2UnDddDTX61S1Mkw@AUWE5mavGyGZdWzP5iCoZwQ\`,"
	old_jdzz1="\`ATGEC3-fsrn13aiaEqiM@AUWE5maSSnzFeDmH4iH0elA@ATGEC3-fsrn13aiaEqiM@AUWE5m6WUmDdZC2mr1XhJlQ@AUWE5m_jEzjJZDTKr3nwfkg@A06fNSRc4GIqY38pMBeLKQE2InZA@AUWE5m6_BmTUPAGH42SpOkg@AUWE53NTIs3V8YBqthQMI\`"
	new_jdzz="95OquUc_sFugJO5_E_2dAgm-@eU9YELv7P4thhw6utCVw@eU9YaOjnbvx1-Djdz3UUgw@AUWE5mKmQzGYKXGT8j38cwA@AUWE5mvvGzDFbAWTxjC0Ykw@AUWE5wPfRiVJ7SxKOuQY0@S5KkcJEZAjD2vYGGG4Ip0@S7aUqCVsc91U@S5KkcREsZ_QXWIx31wKJZcA@S5KkcRUwe81LRIR_3xaNedw@Suvp2RBcY_VHKKBn3k_MMdNw"

	new_jdzz_set="'$new_jdzz',"
	sed -i "s/$old_jdzz/$new_jdzz_set/g" $dir_file_js/jd_jdzz.js
	sed -i "s/$old_jdzz1/$new_jdzz_set/g" $dir_file_js/jd_jdzz.js
	sed -i "48a $new_jdzz_set\n$new_jdzz_set\n$new_jdzz_set\n$new_jdzz_set" $dir_file_js/jd_jdzz.js
	sed -i "s/const randomCount = 5/const randomCount = 0/g" $dir_file_js/jd_jdzz.js
	sed -i "s/helpAuthor=true/helpAuthor=false/g" $dir_file_js/jd_jdzz.js

	#crazyJoy任务
	old_crazyJoy="'EdLPh8A6X5G1iWXu-uPYfA==@0gUO7F7N-4HVDh9mdQC2hg==@fUJTgR9z26fXdQgTvt_bgqt9zd5YaBeE@nCQQXQHKGjPCb7jkd8q2U-aCTjZMxL3s@2boGLV7TonMex8-nrT6EGat9zd5YaBeE@KTZmB4gV4zirfc3eWGgXhA==@dtTXFsCQ3tCWnXkLY8gyL6t9zd5YaBeE@-c4jG-fMiNon5YWAJsFHL6t9zd5YaBeE@hxG_ozzxvNjPuPCbly1WtA==',"
	old_crazyJoy1="'EdLPh8A6X5G1iWXu-uPYfA==@0gUO7F7N-4HVDh9mdQC2hg==@fUJTgR9z26fXdQgTvt_bgqt9zd5YaBeE@nCQQXQHKGjPCb7jkd8q2U-aCTjZMxL3s@2boGLV7TonMex8-nrT6EGat9zd5YaBeE@EyZA15nkwWscm7frOkjZTat9zd5YaBeE@-c4jG-fMiNon5YWAJsFHL6t9zd5YaBeE'"
	new_crazyJoy="2wgkflmSL-eOLT3n1sPRIKGLdMmSR-i1@uahlHElOqVadmIuLt6yoeg==@wVO5hjOkRcsuqL_wHuhERqt9zd5YaBeE@rHYmFm9wQAUb1S9FJUrMB6t9zd5YaBeE@7P1a-YqssNzEUo2yzMjkKat9zd5YaBeE@5z24ds6URIn_QEyGetqaHg==@C5vbyHg-mOmrfc3eWGgXhA==@KgkXpuBiTwm918sV3j4cmA==@CCxsXuB_kLhf6HV1LsZZ3GXGvf5Si_Xe"
	zuoyou_20190516_cj="4GfMxIH581M=@xIA07jnZuHg=@BxewpcJDIAwJqfAkvKwcwKt9zd5YaBeE@adfaee62b5fb8168db108432e138dc3f@1YdTjf0z-ejoT4C48SJDsat9zd5YaBeE@Qx0ZX75ICJEEVf8fiwFZZA==@L5gPw7OnXf8=@3iUbFNTLF6tnJA1ZYLpP-w==@gz45Nf_7rgKdlolf3aQDpg==@z3O-VNgrWFev3DPdeHIlOKt9zd5YaBeE"
	jidiyangguang_20190516_cj="YKcWnuVsQLhGGMGXoNagr6t9zd5YaBeE@bF34fM689WcBsccobrWCEKt9zd5YaBeE"
	Jhone_Potte_20200824_cj="R0_iwyMT_LeF5osbxYCNwKt9zd5YaBeE@LVKLzARN7ub-xqKdK_upZ6t9zd5YaBeE"

	new_crazyJoy_set="'$new_crazyJoy@$zuoyou_20190516_cj@$jidiyangguang_20190516_cj@$Jhone_Potte_20200824_cj',"
	sed -i "s/$old_crazyJoy/$new_crazyJoy_set/g" $dir_file_js/jd_crazy_joy.js
	sed -i "s/$old_crazyJoy1/$new_crazyJoy_set/g" $dir_file_js/jd_crazy_joy.js
	sed -i "37a $new_crazyJoy_set\n$new_crazyJoy_set\n$new_crazyJoy_set\n$new_crazyJoy_set" $dir_file_js/jd_crazy_joy.js
	sed -i "s/$.isNode() ? 10 : 5/0/g" $dir_file_js/jd_crazy_joy.js
	sed -i "s/applyJdBean = 0/applyJdBean = 2000/g" $dir_file_js/jd_crazy_joy.js #默认兑换2000豆子


	#口袋书店
	old_jdbook="'28a699ac78d74aa3b31f7103597f8927@2f14ee9c92954cf79829320dd482bf49@fdf827db272543d88dbb51a505c2e869@ce2536153a8742fb9e8754a9a7d361da@38ba4e7ba8074b78851e928af2b4f6b2',"
	old_jdbook1="'28a699ac78d74aa3b31f7103597f8927@2f14ee9c92954cf79829320dd482bf49@fdf827db272543d88dbb51a505c2e869'"
	new_jdbook="2c25276cb61741d98f767884856ebcd4@f68cdec737564d929946ff64c76374cb@1ebabd3990a3499daab4397d09cd723b@d6d73edddaa64cbda1ec42dd496591d0@e50f362dbf8e4e8891c18d0a6fc9d04d@40cb5da84f0448a695dd5b9643592cfa@3ef061eb9b244b3cbdc9904a0297c3f5@99f8c73daa9f488b8cb7a2ed585aa34d"
	zuoyou_20190516_jdbook="6b1c75eb1cb94a798430419d910b72af@2bcf369644394ffda20b07abbd300957@dbd5fbf1ffde4f99b74fd5b9d5aba901@ccb016eff33147fc96b2b0cfa781965a@ab887a95729a4cc590fbb4161c19f57f@fa96f480e49b464e893bf18ac96a2772@eae4a6a81da5430688ed02c909d5ed75"
	jidiyangguang_20190516_jdbook="a3ad79593cdb41bd8ab31dab7e19cf06@90660442a37f473b98bf57774e9825fe"
	chiyu_jdbook="dfae57a9a2654667b0b5e7298d2ad137"

	new_jdbook_set="'$new_jdbook@$zuoyou_20190516_jdbook@$jidiyangguang_20190516_jdbook@$chiyu_jdbook',"
	sed -i "s/$old_jdbook/$new_jdbook_set/g" $dir_file_js/jd_bookshop.js
	sed -i "s/$old_jdbook1/$new_jdbook_set/g" $dir_file_js/jd_bookshop.js
	sed -i "34a $new_jdbook_set\n$new_jdbook_set\n$new_jdbook_set\n$new_jdbook_set" $dir_file_js/jd_bookshop.js
	
	#签到领现金
	old_jdcash="\`-4msulYas0O2JsRhE-2TA5XZmBQ@eU9Yar_mb_9z92_WmXNG0w@eU9YaO7jMvwh-W_VzyUX0Q@eU9YaurkY69zoj3UniVAgg@eU9YaOnjYK4j-GvWmXIWhA\`,"
	old_jdcash1="\`-4msulYas0O2JsRhE-2TA5XZmBQ@eU9Yar_mb_9z92_WmXNG0w@eU9YaO7jMvwh-W_VzyUX0Q@eU9YaurkY69zoj3UniVAgg@eU9YaOnjYK4j-GvWmXIWhA\`"
	new_jdcash="95OquUc_sFugJO5_E_2dAgm-@eU9YELv7P4thhw6utCVw@eU9YaOjnbvx1-Djdz3UUgw@eU9Ya-iyZ68kpWrRmXBFgw@eU9YabrkZ_h1-GrcmiJB0A@eU9YM7bzIptVshyjrwlteU9YCLTrH5VesRWnvw5t@P2nGgK6JgLtCqJBeQJ0f27XXLQwYAFHrKmA2siZTuj8=@LTyKtCPGU6v0uv-n1GSwfQ==@y7KhVRopnOwB1qFo2vIefg==@WnaDbsWYwImvOD1CpkeVWA==@Y4r32JTAKNBpMoCXvBf7oA==@JuMHWNtZt4Ny_0ltvG6Ipg=="
	zuoyou_20190516_jdcash="f1kwaQ@a1hzJOmy@eU9Ya7-wM_Qg-T_SyXIb0g@eU9Yaengbv9wozzUmiIU3g@eU9YaO22Z_og-DqGz3AX1Q@f0JgObLlIalJrA@flpkLei3@cUJpO6X3Yf4m@e1JzPbLlJ6V5rzk@eU9Ya7m3NaglpW3QziUW0A"
	jidiyangguang_20190516_jdcash="eU9YaOjhYf4v8m7dnnBF1Q@eU9Ya762N_h3oG_RmXoQ0A"
	chiyu_jdcash="cENuJam3ZP0"

	new_jdcash_set="'$new_jdcash@$zuoyou_20190516_jdcash@$jidiyangguang_20190516_jdcash@$chiyu_jdcash',"
	sed -i "s/$old_jdcash/$new_jdcash_set/g" $dir_file_js/jd_cash.js
	sed -i "s/$old_jdcash1/$new_jdcash_set/g" $dir_file_js/jd_cash.js
	sed -i "33a $new_jdcash_set\n$new_jdcash_set\n$new_jdcash_set\n$new_jdcash_set" $dir_file_js/jd_cash.js

	#京东炸年兽
	old_jdnian="\`cgxZaDXWZPCmiUa2akPVmFMI27K6antJzucULQPYNim_BPEW1Dwd@cgxZdTXtIrPYuAqfDgSpusxr97nagU6hwFa3TXxnqM95u3ib-xt4nWqZdz8@cgxZdTXtIO-O6QmYDVf67KCEJ19JcybuMB2_hYu8NSNQg0oS2Z_FpMce45g@cgxZdTXtILiLvg7OAASp61meehou4OeZvqbjghsZlc3rI5SBk7b3InUqSQ0@cgxZ9_MZ8gByP7FZ368dN8oTZBwGieaH5HvtnvXuK1Epn_KK8yol8OYGw7h3M2j_PxSZvYA\`,"
	old_jdnian1=" \`cgxZaDXWZPCmiUa2akPVmFMI27K6antJzucULQPYNim_BPEW1Dwd@cgxZdTXtIrPYuAqfDgSpusxr97nagU6hwFa3TXxnqM95u3ib-xt4nWqZdz8@cgxZdTXtIO-O6QmYDVf67KCEJ19JcybuMB2_hYu8NSNQg0oS2Z_FpMce45g@cgxZdTXtILiLvg7OAASp61meehou4OeZvqbjghsZlc3rI5SBk7b3InUqSQ0@cgxZdTXtIumO4w2cDgSqvYcqHwjaAzLxu0S371Dh_fctFJtN0tXYzdR7JaY\`"
	new_jdnian="cgxZ--kf8RFXPKlP3YUDN9N7qbopP-VtOxRA57Cp3GReD-a9yJi3ezZDqwBUqZz5@cgxZdTXtWO2Ts3mOfmXSkLTAnQUGuJKjSoHMwahkfs9SUuxc0x0N4sU@cgxZdTXtIL6P4g6aAVOh6xbLlZJoC29uIGgW846gj3vFI7ZqODDgGU6gAwA@cgxZdTXtI77a613LXAGtvfpsw8rraLgBTtRR8gtVXzz6qQixKVxvi1jGQt4@cgxZdTXtIeyM6wqaAQGgvhd59Mwz4nvxYSLgIRFrXHtC9Ij-x8O-uY98Rmc@cgxZdTXte-Cbrmm6S3ffi4dB6WNg_mNfNBNnMI122s8KkpZ8PS2o7cM@cgxZdTXtQOKDk2exSH7bm1yqE9lH3OVjhKsFb1yndmZ5KgUbv7F2-X8@cgxZfDnbbf_f6A-FRGauvmGGso1xqGtgAg@cgxZLmmEIbzc4gnMDgPGr2LOJQOfYtSzbdQggbo_ZBZvg1w-tA@cgxZ-twV_BNksFmeREnKvs1gJGa3wzPX6AQP@cgxZdTXtIr6L7g3JWQGguQl0fv8raw1YoF7_nbo39oCIWqSoltmEM42UVdM@cgxZdTXtIumM7g7MXVb_vf5sKfV37FuksxazeYcqfB4lV7yYY6SNJf1K9qo"
	zuoyou_20190516_jdnian="cgxZcyOFIfaWiQqLAQXLjg@cgxZZyLGbL_apkKqAUet7CfElE0@cgxZdTXtI-nYvwbPAFSu7cfA8L-fTfRluVPeR9kXvOpzr7T1OB7z_vf53pY@cgxZdTXtIb-I4g2fWleovuuIRUaojOVYyqCW2tQE47NH2e5FdQdTPzqVq60@cgxZdTXtILve6wjPAVH6637oFStz2n55oDLBd31Gx1wuFVZtARbf7Apdz2k@cgxZczjVceSNrVumVUnljJGWK910VVlBaWrIryfH@cgxZciDRZb7fpkKqDALuuFHFNhA@cgxZfTjcc_Of7QzJREnK6JpEyVYO3l7cfElq@cgxZdyjGdeSNq1eWVlLlox-BNG_CcXjZTeAN16NgVbs@cgxZdTXtI-_fuVrKXAas6hLMvq8JwrWzJDKWMn5lPVfsd8XKc2XkCY6g0Rw"
	jidiyangguang_20190516_jdnian="cgxZdTXtIL6J7QzACwWhunFByvPM_ltcuRhq9MwhLp6jp0TOnV3aPkhq-dY@cgxZdTXtI-jeuwqYWQStvcR9psTc5SAZg5CwlSr9fmHCeDi1lNzhztEP3zE"
	chiyu_jdnian="IgNWdiLGaPaJsleATQCr7iyCWzrGQyVnjFgGJ24sd94"

	new_jdnian_set="'$new_jdnian@$zuoyou_20190516_jdnian@$jidiyangguang_20190516_jdnian@$chiyu_jdnian',"
	sed -i "s/$old_jdnian/$new_jdnian_set/g" $dir_file_js/jd_nian.js
	sed -i "s/$old_jdnian1/$new_jdnian_set/g" $dir_file_js/jd_nian.js
	sed -i "50a $new_jdnian_set\n$new_jdnian_set\n$new_jdnian_set\n$new_jdnian_set" $dir_file_js/jd_nian.js

	#京东炸年兽AR
	sed -i "s/$old_jdnian/$new_jdnian_set/g" $dir_file_js/jd_nian_ar.js
	sed -i "s/$old_jdnian1/$new_jdnian_set/g" $dir_file_js/jd_nian_ar.js
	sed -i "50a $new_jdnian_set\n$new_jdnian_set\n$new_jdnian_set\n$new_jdnian_set" $dir_file_js/jd_nian_ar.js


	#京东神仙书院
		old_jdimmortal="\`39xIs4YwE5Z7CPQQ0baz9jNWO6PSZHsNWqfOwWyqScbJBGhg4v7HbuBg63TJ4@27xIs4YwE5Z7FGzJqrMmavC_vWKtbEaJxbz0Vahw@43xIs4YwE5Z7DsWOzDSP_N6WTDnbA0wBjjof6cA9FzcbHMcZB9wE1R3ToSluCgxAzEXQ@43xIs4YwE5Z7DsWOzDSEuRWEOROpnDjMx_VvSs5ikYQ8XgcZB9whEHjDmPKQoL16TZ8w@50xIs4YwE5Z7FTId9W-KibDgxxx6AEa7189V1zSxSf2HP6681IXPQ81aJEP77WoHXLcK7QzlxGqsGqfU@43xIs4YwE5Z7DsWOzDSPKFWdkRe2Ae6h0jAdlhuSmuwcfUcZB9wBcHhj0_zyZDNK4Rhg\`,"
	old_jdimmortal1="\`39xIs4YwE5Z7CPQQ0baz9jNWO6PSZHsNWqfOwWyqScbJBGhg4v7HbuBg63TJ4@27xIs4YwE5Z7FGzJqrMmavC_vWKtbEaJxbz0Vahw@43xIs4YwE5Z7DsWOzDSP_N6WTDnbA0wBjjof6cA9FzcbHMcZB9wE1R3ToSluCgxAzEXQ@43xIs4YwE5Z7DsWOzDSEuRWEOROpnDjMx_VvSs5ikYQ8XgcZB9whEHjDmPKQoL16TZ8w@43xIs4YwE5Z7DsWOzDSFehRRs_UaNcqkiU7BrrzDTKHScMcZB9wkYC2z6K-QOsQy1S3A@43xIs4YwE5Z7DsWOzDSFcl8RjNxfrQquzeGQQtkQOUbyqscZB9wkxX2jw2HhM7TczeqA\`"
	new_jdimmortal="46xIs4YwE5Z7G9g7VXXVQVAj1XaPuxnp42KWW3VHkbUCSyjZA_0yPE-_eWZkyLRGQewhtvF47@40xIs4YwE5Z7DsWOzDQEvxJW4_Gu_rEEGejqss1NHaWcZB9uhMa1knD7NF3t1DS@43xIs4YwE5Z7DsWOzDSFeBVdsn8wMSAqZUdmm4Ino9y4jMcZB9wkAGhz4L9-SqwpvWCg@43xIs4YwE5Z7DsWOzDSL_9CEGF8QjcKrGKFEUZqKB1WklAcZB9wUBTjm2pNOZkO1C8ew@43xIs4YwE5Z7DsWOzDSAvhIEJtWP7xzngvIUYtd1sw1JxIcZB9wxIFjjol6A2DOPxahQ@40xIs4YwE5Z7DsWOzDIZ8JBWj2nwoTJJBQQIYNpex1AcZB9mR4Sy1n0tWVpaoPC@40xIs4YwE5Z7DsWOzDKEspZQ0F-aIyW1stJDO2fu-9rcZB9ohwK9lcfpPTN0sBR"
	chiyu="28xIs4YwE5Z7Dm46PNfntL3F3pXbHtieJxLjwFWjT8"
	zuoyou_20190516_jdimmortal="22xIs4YwE5Z7DrE6AN9wfGxBQd4YVww@24xIs4YwE5Z7DdEYicm7x33rqDrY4dWjkFT@43xIs4YwE5Z7DsWOzDSZ6B6RrIMC4HFfxkSzf3jCbCFdHUcZB9wRdR2jb0-siyZL2Msw@43xIs4YwE5Z7DsWOzDSBeRUdmFA1baI1BuCTaeaNNRzhuIcZB9w0EBhz0OiBBprwWVKg@43xIs4YwE5Z7DsWOzDSFah8ENPhsZkB4O26BSbUl6LYstAcZB9wkVXjji_Rw4aYogBiw@32xIs4YwE5Z7DrHgFhpxYnERh2_hG_6b9vBd51FkxoEyGviag@24xIs4YwE5Z7DqBplRuwqToDxNydoVBh0BW@30xIs4YwE5Z7DmS7PZa-cX3FmkYs6Y8DAeZ1MkQ0WiDzP@34xIs4YwE5Z7DsvAWDFAtJXXa6aOvcyHgMcLAc41WlxoEzmeCYcI@43xIs4YwE5Z7DsWOzDSZ-N7WUyYAsdChzhnPpcvKkWX7u8cZB9wRFW3GrM09VTlnbADw"
	jidiyangguang_20190516_jdimmortal="43xIs4YwE5Z7DsWOzDSFeBTEW2yCionsUe6mEQoABstc0EcZB9wkAAiDzCkgQMVOwngA@43xIs4YwE5Z7DsWOzDSZ-d8WWsr_YlS1abHIWCEl1CuGf0cZB9wRZX3joyj0K_tfJ0XA"

	new_jdimmortal_set="'$new_jdimmortal@$chiyu@$zuoyou_20190516_jdimmortal@$jidiyangguang_20190516_jdimmortal',"
	sed -i "s/$old_jdimmortal/$new_jdimmortal_set/g" $dir_file_js/jd_immortal.js
	sed -i "s/$old_jdimmortal1/$new_jdimmortal_set/g" $dir_file_js/jd_immortal.js
	sed -i "56a $new_jdimmortal_set\n$new_jdimmortal_set\n$new_jdimmortal_set\n$new_jdimmortal_set" $dir_file_js/jd_immortal.js

	#闪购盲盒
	old_jdsgmh="'T019-aknAFRllhyoQlyI46gCjVWmIaW5kRrbA',"
	old_jdsgmh1="'T019-aknAFRllhyoQlyI46gCjVWmIaW5kRrbA'"
	new_jdsgmh="T024anXulbWUI_NR9ZpeTHmEoPlACjVWmIaW5kRrbA@T0205KkcPElQrCOQVnqP66FpCjVWmIaW5kRrbA@T0225KkcRBpM_VSEKUz8kPENIQCjVWmIaW5kRrbA@T0225KkcRxoZ9AfVdB7wxvRcIQCjVWmIaW5kRrbA@T0225KkcRUhP9FCEKR79xaZYcgCjVWmIaW5kRrbA@T0205KkcH0RYsTOkY2iC8I10CjVWmIaW5kRrbA@T0205KkcJEZAjD2vYGGG4Ip0CjVWmIaW5kRrbA"
	zuoyou_20190516_jdsgmh="T0064r90RQCjVWmIaW5kRrbA@T0089r43CBsZCjVWmIaW5kRrbA@T0225KkcR00boFzRKEvzlvYCcACjVWmIaW5kRrbA@T0225KkcRRtL_VeBckj1xaYNfACjVWmIaW5kRrbA@T0225KkcRB8d9FLRKU6nkPQOdwCjVWmIaW5kRrbA@T0144qQkFUBOsgG4fQCjVWmIaW5kRrbA@T0127KQtF1dc8lbXCjVWmIaW5kRrbA@T0155rQ3EUBOtA2Ifk0CjVWmIaW5kRrbA@T0225KkcR0scpgDUdBnxkaEPcgCjVWmIaW5kRrbA"
	jidiyangguang_20190516_jdsgmh="T0225KkcR0wdpFCGcRvwxv4JcgCjVWmIaW5kRrbA@T0225KkcRBpK8lbeIxr8wfRcdwCjVWmIaW5kRrbA"
	chiyu_jdsgmh="T0117aUqCVsc91UCjVWmIaW5kRrbA"

	new_jdsgmh_set="'$new_jdsgmh@$zuoyou_20190516_jdsgmh@$jidiyangguang_20190516_jdsgmh@$chiyu_jdsgmh',"
	sed -i "s/$old_jdsgmh/$new_jdsgmh_set/g" $dir_file_js/jd_sgmh.js
	sed -i "s/$old_jdsgmh1/$new_jdsgmh_set/g" $dir_file_js/jd_sgmh.js
	sed -i "32a $new_jdsgmh_set\n$new_jdsgmh_set\n$new_jdsgmh_set\n$new_jdsgmh_set" $dir_file_js/jd_sgmh.js

	#京东手机年终奖
	old_jdfestival="\`9b98eb88-80ed-40ac-920c-a63fc769e72b@94c2a4d4-b53b-454b-82a0-0b80828bfd37@e274c80b-82dd-470c-878c-0790f5bf6a5d@aae299fc-6854-4fa7-b3ef-a6dedc3771b7@91ae877b-c98b-484a-9143-22d3a70b4088\`,"
	old_jdfestival1="\`9b98eb88-80ed-40ac-920c-a63fc769e72b@94c2a4d4-b53b-454b-82a0-0b80828bfd37@e274c80b-82dd-470c-878c-0790f5bf6a5d@aae299fc-6854-4fa7-b3ef-a6dedc3771b7@91ae877b-c98b-484a-9143-22d3a70b4088\`"
	new_jdfestival="a1f4425f-8c39-471e-8689-0dd9af382045@a2538c1d-a045-4ea0-98ba-d8962796c097@753c15e6-ca43-4df0-99d2-08a3e8789bf3@11875cff-d5d6-4f17-af03-6a4cd00f94ec@5925b538-aa20-4417-b448-20f9a8c206b4"
	zuoyou_20190516_jdfestival="a8f2ca0c-536f-4535-871e-bf493652979a@fc9cc67f-5f6f-43b2-8d51-9e9d945bdb4f@0187b5a4-d78f-4d8a-9a48-3f5669befd57@2c194d51-57de-4612-b85e-4d98cfc5eece@b84c261b-854e-46c7-83b3-a84e6be91f77@9024588f-0e9e-4418-a2a8-00dc2f9533ae@79d5cd28-4930-47e6-acc4-87bbe1325b77@db202644-22c6-4e56-8c58-be5f6db4ebed@884ca6dd-db43-45b9-bf77-b009bed6350d"
	jidiyangguang_20190516_jdfestival="82b9b70b-a503-45fc-a9b4-04978d767f20@3ce171cf-df49-42eb-99de-1fdd306ca9e6"
	chiyu_jdfestival="1212d4c9-31e1-41af-b6ba-61c119940db2"

	new_jdfestival_set="'$new_jdfestival@$zuoyou_20190516_jdfestival@$jidiyangguang_20190516_jdfestival@$chiyu_jdfestival',"
	sed -i "s/$old_jdfestival/$new_jdfestival_set/g" $dir_file_js/jd_festival.js
	sed -i "s/$old_jdfestival1/$new_jdfestival_set/g" $dir_file_js/jd_festival.js
	sed -i "34a $new_jdfestival_set\n$new_jdfestival_set\n$new_jdfestival_set\n$new_jdfestival_set" $dir_file_js/jd_festival.js

	#京东超级盒子
	old_jdsuperbox="\`O3eI2LwEpHNofuF6LxjNqw@Hvm2Tg0jWloh4bnPOa9wuA@RY7V2DbS5uInv_GGD7JuoQij_0m9TAUe-t_mpE-BHB4@dZGLTyomKT0ZmOYaa4FSu0Ch0ywXFSW7gXwe_z6nUFc@UHW6hnmrpOABeMMKc5kpng\`,"
	old_jdsuperbox1="\`O3eI2LwEpHNofuF6LxjNqw@Hvm2Tg0jWloh4bnPOa9wuA@RY7V2DbS5uInv_GGD7JuoQij_0m9TAUe-t_mpE-BHB4@dZGLTyomKT0ZmOYaa4FSu0Ch0ywXFSW7gXwe_z6nUFc@UHW6hnmrpOABeMMKc5kpng\`,"
	new_jdsuperbox="AdK-E_nAYUm7Nif1o_P9Kz1_IjelEIX3XMR9kLhjkUo@kRUZgiHAG6MH3MbxEmHu7A@Wlnddn9-EST-tViwpRvedoseTzAkJjfBHBqsVhkxBiQ@paajDEtwEBWELjmcQ70f_PEh-JCPmgvF2XktOJIVKk8@NLQlCreLH6IcZX7xXmOy7JVKCiTveYfjCxRBHB1x7U8@TZOHaJd9uoCWSBGjTpvHtq4ESISc_JVtAz15HMVR0Xc@31AEesBSjRfF0nbzA0iTHw@GRTM4onTMM4_xLPwAgg2Lw"
	zuoyou_20190516_jdsuperbox="hpuuBn_DHIEEtGtO_l1v0g@PTvY82VjS4iyzD6m439G7A@Rhj2389A14HTWpJWakBoh2UcBVQY_4dhCiYnRz-lEdU@fNyyP5hpC8DMme-rHVK4Yw1Wug5CNiD8tBOlK6eDW8o@CbKCRFJOWsdVUJ3UNsnPeAhxGPo1ImbWUCfFnn9t2zI@IeevO_l_9DqDflSG728SPQ@Ulx6tsCj5ebNVpCbDIglSA@8m0NXmTc8I_kwRXxeOTJug@zSH2ixbQdrlZU-5VQwR5Pg@QDD9t-9smLC8GRIipCFU66-ur7VYRlvzT-rWSf8ZzC0"
	chiyu_jdsuperbox="u1Ev8KHVdp_hmy0nLDHRWQ"

	new_jdsuperbox_set="'$new_jdsuperbox@$zuoyou_20190516_jdsuperbox@$chiyu_jdsuperbox',"
	sed -i "s/$old_jdsuperbox/$new_jdsuperbox_set/g" $dir_file_js/jd_super_box.js
	sed -i "s/$old_jdsuperbox1/$new_jdsuperbox_set/g" $dir_file_js/jd_super_box.js
	sed -i "40a $new_jdsuperbox_set\n$new_jdsuperbox_set\n$new_jdsuperbox_set\n$new_jdsuperbox_set" $dir_file_js/jd_super_box.js

	#京东压岁钱
	old_jdnewYearMoney="\`ucp4UudBqMcbT-J9e_xx-UMQA96VZPICgwBY@oMZeX7Mco4wGBrBiNLAl-NqgPbNWoqjpA9BIHLl_7Z2uC4Bt@oMZeGJ8Q3ssja5hkb88ysz1myVkiBAsZmXvj1VVm0_HgAmA@udHn3lOfPCqCnVvmgzY8s7L3GtTvpSi9zyMcRoTjqfxLhw\`,"
	old_jdnewYearMoney1="\`ucp4UudBqMcbT-J9e_xx-UMQA96VZPMNgwJW@oMZeX7Mco4wGBrBiNLAl-NqgPbNWoqjpA9BIHLl_7Z2uC4Bt@oMZeGJ8Q3ssja5hkb88ysz1myVkiBAsZmXvj1VVm0_HgAmA@udHn3lOfPCqCnVvmgzY8s7L3GtTvpSi9zyMcRoTjqfxLhw\`,"
	new_jdnewYearMoney="Lhqsjk3FdizR1mKb7z7-K7Njx8Kx5kXkHhkgRBuL4oTCmFIWhfg@oMZeJ7EB-fwQdYJKSOYTs4Kn6PZYLirnNY34RGSlK_xwM2Q@oMZeX-IdqIsECrQ5M7Z3qtyub2RMkdQpvPkkptGu6dFpTWFk@oMZeXOJIodhVV-Y1ZbMmqmvPtKAlRyWSpZHXAsrGYwYZDHR0@oMZeXrAeoY8ECuY4ZuEi-bGnIR1K0yNnDNWDloaaDujkzEMW@oMZeBLwJ5OwkQJBHU8oOs6Lh-j1-tUN-likozedNAf1diJI@oMZeP74R2eIvQ5lDQ80OswPSAqISSuyC2ZZ8fZKY1yWb-KY"

	new_jdnewYearMoney_set="'$new_jdnewYearMoney',"
	sed -i "s/$old_jdnewYearMoney/$new_jdnewYearMoney_set/g" $dir_file_js/jd_newYearMoney.js
	sed -i "s/$old_jdnewYearMoney1/$new_jdnewYearMoney_set/g" $dir_file_js/jd_newYearMoney.js
	sed -i "53a $new_jdnewYearMoney_set\n$new_jdnewYearMoney_set\n$new_jdnewYearMoney_set\n$new_jdnewYearMoney_set" $dir_file_js/jd_newYearMoney.js

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
	fi
}

system_variable() {
	if [[ ! -d "$dir_file/config" ]]; then
		mkdir  $dir_file/config
	fi
	
	if [[ ! -d "$dir_file/js" ]]; then
		mkdir  $dir_file/js
		update
	fi


	if [ "$dir_file" == "$install_script/JD_Script" ];then
		#jdCookie.js
		if [ ! -f "$install_script_config/jdCookie.js" ]; then
			wget $url/jdCookie.js -O $install_script_config/jdCookie.js
			rm -rf $dir_file_js/jdCookie.js #用于删除旧的链接
			ln -s $install_script_config/jdCookie.js $dir_file_js/jdCookie.js
		fi
		
		#jdCookie.js用于升级以后恢复链接
		if [ ! -f "$dir_file_js/jdCookie.js" ]; then
			ln -s $install_script_config/jdCookie.js $dir_file_js/jdCookie.js
		fi

		#sendNotify.js
		if [ ! -f "$install_script_config/sendNotify.js" ]; then
			wget $url/sendNotify.js -O $install_script_config/sendNotify.js
			rm -rf $dir_file_js/sendNotify.js  #用于删除旧的链接
			ln -s $install_script_config/sendNotify.js $dir_file_js/sendNotify.js
		fi

		#sendNotify.js用于升级以后恢复链接
		if [ ! -f "$dir_file_js/sendNotify.js" ]; then
			ln -s $install_script_config/sendNotify.js $dir_file_js/sendNotify.js
		fi

		#USER_AGENTS.js
		if [ ! -f "$install_script_config/USER_AGENTS.js" ]; then
			wget $url/USER_AGENTS.js -O $install_script_config/USER_AGENTS.js
			rm -rf $dir_file_js/USER_AGENTS.js #用于删除旧的链接
			ln -s $install_script_config/USER_AGENTS.js $dir_file_js/USER_AGENTS.js
		fi

		#USER_AGENTS.js用于升级以后恢复链接
		if [ ! -f "$dir_file_js/USER_AGENTS.js" ]; then
			ln -s $install_script_config/USER_AGENTS.js $dir_file_js/USER_AGENTS.js
		fi

	else
		if [ ! -f "$dir_file/jdCookie.js" ]; then
			wget $url/jdCookie.js -O $dir_file/jdCookie.js
			ln -s $dir_file/jdCookie.js $dir_file_js/jdCookie.js
		fi

		if [ ! -f "$dir_file/sendNotify.js" ]; then
			wget $url/sendNotify.js -O $dir_file/sendNotify.js
			ln -s $dir_file/sendNotify.js $dir_file_js/sendNotify.js
		fi

		if [ ! -f "$dir_file/USER_AGENTS.js" ]; then
			wget $url/USER_AGENTS.js -O $dir_file/USER_AGENTS.js
			ln -s $dir_file/USER_AGENTS.js $dir_file_js/USER_AGENTS.js
		fi

	fi

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

	#判断JS文件夹是否为空
	if [ ! -f "$dir_file_js/Detect.txt" ]; then
		echo -e "$green js文件夹缺少一个Detect.txt，现在开始更新请稍等很快$white"
		sleep 3
		echo "我是作者写来应付检查的文件，不要理我，我很忙，老板加饭！！！再来半只白切鸡，不吃饱那里有力气应付检查。。。。。" > $dir_file_js/Detect.txt
		update_script
		update
		system_variable
	fi

	#添加系统变量
	jd_script_path=$(cat /etc/profile | grep -o jd.sh | wc -l)
	if [[ "$jd_script_path" == "0" ]]; then
		echo "export jd_file=$dir_file" >> /etc/profile
		echo "export jd=$dir_file/jd.sh" >> /etc/profile
		. /etc/profile
	fi

	script_black

	blacklist=""
	if [ "黑名单" == "$blacklist" ];then
		echo ""
	fi


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

	help
}

script_black_Description() {
cat >$dir_file/config/Script_blacklist.txt <<EOF
******************************不要删使用说明*********************************************************************

*这是脚本黑名单功能，作用就是你跑脚本黑活动了，你只需要把脚本名字放底下，跑脚本的时候（全部账号）就不会跑这个脚本了
*但你可以通过node  脚本名字来单独跑（只是不会自动跑了而已）
*PS：（彻底解开的办法就是删除这里的脚本名称，然后更新脚本）
*例子

jd_ceshi1.js #禁用的脚本1
jd_ceshi2.js #禁用的脚本2

*按这样排列下去（一行一个脚本名字）
*每个脚本应的文件可以参考jd.sh 的注释，ctrl+f输名字搜索即可

***********************要禁用的脚本往下写，不要删除这里的任何字符，也不要动上面的************************************
EOF
}

script_black() {
	#不是很完美，但也能用，后面再想想办法，grep无法处理$node 这种这样我无法判断是否禁用了，只能删除掉一了百了

	if [ ! -f "$dir_file/config/Script_blacklist.txt" ]; then
		echo > $dir_file/config/Script_blacklist.txt
	fi

	if_txt=$(grep "不要删使用说明" $dir_file/config/Script_blacklist.txt)
	if [ !  $if_txt ];then
		script_black_Description
	fi

	script_list=$(cat $dir_file/config/Script_blacklist.txt | sed  "/*/d"  | sed "/jd_ceshi/d" | sed "s/ //g" | awk '{print $1}')
	if [ ! $script_list ];then
		echo -e "$green 黑名单没有任何需要禁用的脚本，不做任何处理$white"
	else
		for i in `echo "$script_list"`
		do
			echo "开始删除关于$i脚本的代码，后面需要的话看黑名单描述处理"
			sed -i "s/\$node \$dir_file_js\/$i//g" $dir_file/jd.sh
		done
	fi
	clear
}


action1="$1"
action2="$2"
if [[ -z $action1 ]]; then
	system_variable
else
	case "$action1" in
		system_variable|update|update_script|run_0|run_01|run_06_18|run_10_15_20|run_02|run_03|run_045|task|run_08_12_16|jx|run_07|additional_settings|joy|kill_joy|jd_sharecode|ds_setup|run_030|run_19_20_21|run_020|stop_notice|nian|checklog|nian_live|that_day|stop_script|script_black|ddcs|sy|script_name|baiyuan)
		$action1
		;;
		*)
		help
		;;
	esac

	if [[ -z $action2 ]]; then
		echo ""
	else
		case "$action2" in
		system_variable|update|update_script|run_0|run_01|run_06_18|run_10_15_20|run_02|run_03|run_045|task|run_08_12_16|jx|run_07|additional_settings|joy|kill_joy|jd_sharecode|ds_setup|run_030|run_19_20_21|run_020|stop_notice|nian|checklog|nian_live|that_day|stop_script|script_black|ddcs|sy|script_name|baiyuan)
		$action2
		;;
		*)
		help
		;;
	esac
	fi
fi

