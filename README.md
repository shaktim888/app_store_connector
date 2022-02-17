### 使用教程
#### 一、配置方式
##### config/output.json字段说明
 - "c" : 不用管，保持原值
 - "cn": 不用管，保持原值
 - "emailAddress" : 配置接收testFlight的邀请的邮箱地址
 - "issuer_id": 配置后台issueID
 - "key_id" : 配置后台key_id				
 - "private_key":将p8文件放到config目录。并配置好文件名
 - "fileName":用于自定义保存证书的文件目录明。可不修改
 - "bundleidentifier" : 设置要生产的证书bundleID。
      - "bundleidName": 自定义设置保存.mobileprovision的文件名。可以不配置。并不会设置到苹果后台。
      - "bundleId": 设置bundleId

#### 二、运行
首先，先cd到脚本所在的目录
##### 生成证书和mobileprovision
- sh cert.sh
##### 进行testFlight测试
- sh tf.sh
