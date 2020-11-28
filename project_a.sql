
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
    barcode int not null unique check ( length(barcode) in(7,15) ) ,
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
    isWriteable boolean not null default false,
--     isResigned bool default false not null ,
    signed_time timestamp default now() not null
);
-- 默认用户
create or replace function getDefaultUserKey() returns text as $$
    begin
        return query select key from signed_users where device_id == 'None_Master_';
    end;
    $$ language plpgsql;
insert into signed_users(key, device_id,isWriteable) values (md5(random()::text)::text,'None_Master_',true);
-- 检查写入权限 --
create or replace function isWriteable(kie text) returns Boolean as $$
declare
    writable boolean ;
begin
    select isWriteable into writable from signed_users where key==kie;
    return  (found and writable) ;
end;
$$ language plpgsql;


-- log专场 --

drop type if exists log_type;
create type log_type as ENUM ('insert','update','delete','login','didnt_tell_yet');
drop table if exists log;
create table log(
    id serial primary key ,
    user_key text references signed_users(key),
    target_name text not null ,
    content json not null ,
    action log_type not null
--         default 'didnt_tell_yet'
                ,
    log_time timestamp default now() not null
);
-- 日志生成

create or replace procedure login(
    in kie text ,in deviceID text , in deviceType device_type
)  language plpgsql  as $$
declare
    writable bool;
begin
    insert into log(user_key, target_name, content,action)  values (getDefaultUserKey(),'users', concat('{"key":"',kie,'"}') ,'login');
    select isWriteable into writable from signed_users where key == kie;
    -- 如果不存在插入 存在时判断是否可写入 选择更新
    if not found then
        insert into signed_users(key, device_id,device_type,isWriteable) values(kie,deviceID,deviceType,true);
    elseif not writable then
        update signed_users set isWriteable = true where key == kie;
    end if;
end $$;
create or replace procedure log(
    in key text, in targetName text,in contents json,in actions log_type
) as $$
    begin
        if isWriteable(key) then
            insert into log(user_key, target_name, content,action)
            values (key,targetName,contents,actions);
        else
            raise exception '操作不允许!该用户未经授权!';
        end if;
    end
$$ language plpgsql ;
-- 记录INIT事件
call log(getDefaultUserKey(),'all', '{"m":"init"}','didnt_tell_yet'::log_type);




-- TODO:view
--触发器 记录插入SIGNED_USER
-- create trigger AF_IN_SIGN after insert on signed_users for each row execute procedure ref()

--触发器
-- 在 父类型 插入前 执行
--触发器 AF_IN__P_TYPE
-- 在 父类型 插入后 执行
-- 逻辑大致: 插入,提交
--存储过程