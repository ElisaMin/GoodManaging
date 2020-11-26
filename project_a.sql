
-- 删除后创建
DROP TABLE IF EXISTS parent_types;
CREATE TABLE parent_types (
    id SMALLSERIAL PRIMARY KEY NOT NULL,
    name text NOT NULL UNIQUE
);
-- 删除后创建
DROP TABLE IF EXISTS sub_types;
CREATE TABLE sub_types (
    id   SMALLSERIAL NOT NULL PRIMARY KEY,
    name  TEXT NOT NULL UNIQUE,
    parent_id SMALLINT NOT NULL REFERENCES parent_types (id)
);
-- 删除后创建
DROP TABLE IF EXISTS makers;
CREATE TABLE makers (
    id   SERIAL NOT NULL PRIMARY KEY,
    name TEXT   NOT NULL UNIQUE
);

-- 删除后创建
--写你妈大小写 爬
DROP TABLE IF EXISTS products;
CREATE TABLE products(
    id serial primary key not null ,
    product_id int references makers(id),
    name text not null ,
    type_id smallint references sub_types(id)
);

drop table if exists commodities;
create table commodities (
    id serial not null primary key ,
    barcode int not null unique check ( length(barcode) > 9 and length(barcode) <17 ) ,
    product_id int references products(id),
    price money not null ,
    size text not null ,
    other text not null ,
    insert_time timestamp default now()
);

drop type if exists device_type;
create type device_type as ENUM (
    'android','testing',
    'web','iphone',
    'desktop-client',
    'shit'
);
drop table if exists signed_users;
create table signed_users(
    key text primary key not null ,
    device_id text unique not null ,
    device_type device_type not null default 'shit',
--     isResigned bool default false not null ,
    signed_time timestamp default now() not null
);
-- drop type if exists log_type;
-- create type log as ENUM ('insert','update','delete','login');

drop table if exists log;
create table log(
    id serial primary key ,
    log_time timestamp default  now() not null ,
    target_name text not null ,
    content jsonb not null ,
    user_key text references signed_users(key)
);

-- TODO:view
--触发器
-- 在 父类型 插入前 执行
--触发器 AF_IN__P_TYPE
-- 在 父类型 插入后 执行
-- 逻辑大致: 获取statement的key,插入,提交
--存储过程