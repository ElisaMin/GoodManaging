# Project_a 商品管理系统
简介: 一个没什么卵用的系统,可以展示、搜索、添加商品。
## 理清思路
一个商品包含信息有 ``名称、价格、厂家、条形码、类型、图片、规格、其他信息``  
## 数据库设计
采用pgSql 
###　表
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
  * id(文字类型)
  * 设备名称
  * 注册时间
* 修改日志
  * id自增
  * 时间
  * 类型 (添加 修改 删除)
  * 表
  * 内容 (不麻烦时可直接记录json信息)
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
### 触发器
* 子父类型/厂家 修改后 插入日志
  * 类型 : 插入
  * 内容 : ${old.name} -> ${new.name}
  * 表 : ${table name}
* 子父类型/厂家 添加和删除后 插入日志
  * 内容: ${name}

### SQL程序
* 传入页数
* 

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
























