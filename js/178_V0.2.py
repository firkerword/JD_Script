#!/usr/bin/python
# -*- coding: utf-8 -*-
# 原作者不知道
"""
运行环境为python3
脚本自动安装模块，如果安装失败请手动pip3 install telethon pysocks httpx 或者 py -3 -m pip install telethon pysocks httpx

使用方法：
1.修改47、48、50三行变量
2.正常运行的话会要求输入手机号登录，记得+86，然后输入tg发的验证码
3.开始监控频道并领取京豆

测试方法：
1.取消83行群的注释
2.往群里发送(https://api.m.jd.com)或者，要带上括号发，或者复制频道的信息往群里发，正则匹配api.m.jd的域名，怕被群里钓ck可以修改chats=[id]里面的id，id可以在运行时屏幕上打印的信息查找，可以改成机器人的id
3.查看返回信息，有{xxxx}这样的信息一般就可以了，如果ck有问题可以取消65行注释查看ck

"""
import os
count = 3
while count:
    try:
        from telethon import TelegramClient, events, sync
        break
    except:
        print('开始安装telethon')
        os.system('pip install telethon')
        count -= 1
        continue
count = 3
while count:
    try:
        import httpx
        break
    except:
        print('开始安装httpx')
        os.system('pip install httpx')
        count -= 1
        continue
import time
import json
import re
import asyncio

# ========================下面要改===========================
# 前两个变量请打开https://my.telegram.org，在API development tools里面获取，记得api_id不带引号
api_id = ''
api_hash = ''
# cookie，多个cookie请用&隔开，如pt_key=111;pt_pin=111;&pt_key=222;pt_pin=222;
cookies = ""

# 使用代理proxy，请自行pip install pysocks安装pysocks
#client = TelegramClient('test', api_id, api_hash, proxy=("socks5", '127.0.01', 7890))
# 不使用代理
client = TelegramClient('test', api_id, api_hash)
client.start()
# ========================上面要改===========================

async def send_live(cookies, url):
    if len(cookies) > 0:
        str_ck = cookies.split('&')
        for i in range(1, len(str_ck) + 1):
            if len(str_ck[i - 1]) > 0:
                # ck有问题的请取消注释下面一行，查看输出的ck对不对
                # print(str_ck[i-1])
                header = {
                    "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.104 Safari/537.36",
                    "Cookie": str_ck[i - 1],
                }
                async with httpx.AsyncClient() as client:
                    r = await client.get(url=url, headers=header)
                # r = await httpx.get(url=url, headers=header)
                print(r.text)
                await asyncio.sleep(0.5)

async def main():
    me = await client.get_me()
    async for dialog in client.iter_dialogs():
        print(dialog.name, 'has ID', dialog.id)

p1 = re.compile(r'[(](https://api\.m\.jd\.com.*?)[)]', re.S)

# @client.on(events.NewMessage(chats=[-1001479368440]))# 群
@client.on(events.NewMessage(chats=[-1001197524983]))# 频道

async def my_event_handler(event):
        print(event.message.sender_id,event.message.text)
        sec = re.findall(p1, event.message.text)
        if sec!=[]:
            await send_live(cookies,sec[0])

with client:
    client.loop.run_until_complete(main())
    client.loop.run_forever()
