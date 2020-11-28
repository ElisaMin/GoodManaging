# Project_a 商品管理系统
简介: 一个没什么卵用的系统,可以展示、搜索、添加商品。
## 理清思路
一个商品包含信息有 ``名称、价格、厂家、条形码、类型、图片、规格、其他信息``  
### 遇到问题
* 更新时的function设计
```
直觉目标:像kotlin一样实现fun foo(a:Text?=null)的方法调用时为foo() a无需填入
详细目标:调用一个更新函数时智能更新内容
接着解释:智能更新是指在传入参数时判断字段哪些更新哪些则不需要更新
问题出现:智能更新内容
   设想:判断为空则不更新
   设想:传入键值对 --残留 都好_不过如何判断类型
   设想:拆分无数的内容如 updateParentType updateSubType 
```
* 验证登入 
```
直觉目标:在SQL内部实现验证登入效果
详细目标:巧妙使用SQL内部过程语言设计带有key插入的log
接着解释:插入日志是指 在任何表插入数据时把当前操作的时间 登记过的用户 操作类型 操作内容记录到log表
接着解释:验证登入是指 在任何数据插入时判断该用户是否已经登记 , 登记则继续,否则拒绝更新
接着解释:判断登记是指 该用户的key是否存在于数据表
最终目标:在任何数据更新/插入时,判断key是否存在,如果不存在拒绝写入(可选:并记录此时),否则
写入并且记录当前操作的时间 登记过的用户 操作类型 操作内容记录到log表
问题出现:如何设计key的输入;触发器不可传入参数;
   设想:使用(类)全局变量存储Key --failed 频繁切换全局变量会有时序安全问题;
   设想:通过procedure传入key --maybe 待会再想
 待验证:会话参数????事务可以传入参数??????
   解决:函数或存储过程
     问题出现:判断是否成功
        解决:使用函数,并返回isSucess和message
     问题出现:判断错误message如何保证通过SQL\互联网\用户后判断正确的信息
        解决:改用errorCode即可
问题再现:如果日志里面要求有key,而key必须存在且在key插入被记录在日志表,绕晕了
   解决:首先插入一个用户再用用户去Init 
```
## 数据库设计
采用pgSql,插入接入API时全面使用function
### 表 
~~引入用户系统~~ 暂无打算   
#### 商品
![图解](docs_tmp/readme_database_entities_i.png)
* 父类型 parent_type
  * id
  * 名称
* 子型 sub_type
  * id
  * 父类型id
  * 类型名称
* 厂家 Maker
  * id 
  * 名称  
* 产品 products
  * id
  * 名称
  * 厂家ID
  * 子类ID
* 商品 commodity
  * 条形码
  * 价格
  * 产品ID
  * 规格
  * 图片路径
  * 其他信息
  * 插入时间
* 信任用户
  * key(文字类型)
  * 是否可写入
  * 设备类型
  * 设备id
  * 注册时间
* 修改日志
  * id自增
  * 时间
  * 类型 (添加 修改 删除)
  * 表
  * 内容 (不麻烦时可直接记录json信息)
  * 操作用户
### 视图
* 商品信息
  * 条形码
  * 价格
  * 厂家名称
  * 产品名称
  * 类型名称
  * 规格
  * 图片路径
  * 其他信息
### SQL函数
由于存储过程不支持返回值那就用函数来做吧,大部分会返回一个表,字段为:isSuccess,message
* 插入类型:key,父,子;父不存在则不插;
* 插入产品:key,厂家名,产品名,类型;厂家 类型不存在则阻止写入;
* 插入商品:key TODO 懒得写先
* 更新时:能写多少是多少吧我死了
* 选择页面:
* 批量写入: TODO 后面再想
### SQL程序
设计走向:全面存储过程化
#### 插入程序
* 记录:key,
* 登入:key,设备id,设备类型;插入log,判断存在时更新writable不存在时插入;
### TODOS
凌晨三点准时锁定用户写入权限
## Api设计
通过HTTP协议达到增加删除更新效果 以``/``作为域名根目录 如:  
```url
https://mygoods.fuwushang.top/get?id=111111111111
```
则简写成
```url
/get?id=111111111111
```  
返回类型往常为json
```json5
{
  key: 'value'
}
```
### 搜索场景
method get,返回值引用下方的[商品信息]
```json5 
[
    {商品信息},
    ........
    {商品信息}
]
```
#### 主页需要的固定值
> /t/a  
#### 分页需要的下一页 上一页
> /t/a?page=${page}
#### 按照条形码查询商品信息
type = barcode ; key = 690321562179
> /s?t=b&k=${id}
#### 按照厂家名称查询商品信息
type = maker ; key = 散装
> /s?t=m&k=${producer}
#### 按照类型查询商品信息
type=type;key=洗发水
> /s?t=t&k=${type}
#### ~~模糊查询 不会做~~
> /s?t=m&k=${keyword}&k=${keyword}&k=${keyword}
#### 查询所有厂家
> /t/m
#### 查询所有类型
> /t/t
#### 查询所有产品
> /t/p
### 可增加/更新场景有:
此操作为危险操作,需要key进行验证用户. method部分post
#### 添加/更新类型
get
> /u?t=t&k=${name}
> /u?t=t&k=${origin}&v=${changed}
#### 添加/更新图片
post
> /u?t=p&k=${barcode}
> body 为图片本身
#### 添加/更新厂家信息
get 
> /u?t=m&k=${origin}&v=${changed}
#### 添加/更新商品信息
post:type=info;if(update)key=target
> /u?t=i
```json5
{商品信息: "完整"}
```
> /u?t=i&k=${barcode}
```json5
{商品信息: "碎片化"}
```
#### 批量上传
## 返回规范
错误时会有相应的状态码,并把错误原因放在response body内,response type为文本。正确时响应json
### 状态码
* 参数有误 400
* 更新时不允许该用户 401
* 找不到项 404
* 响应正确 200
### 响应信息
* 子类型
```json5
['parent;type','parent;type','parent;type']
```
* 产品
```json5
[
  {
    id:-1,name:'name',maker:'producer',type:'parent;type'
  },{
    id:-2,name:'name',maker:'producer',type:'parent;type'
  }
]
```
* 商品信息
```json5
[{
  barcode:6901234123456,
  maker:'散装',name:'牛奶',
  price:'￥6.0',size:'斤',
  pic:'sh4g6sf2rg45f42h52jf3k45.jpg',
  type:'parent;type',other:',thins'
}]
```
## 效果
## 后端设计
## 前端设计
























