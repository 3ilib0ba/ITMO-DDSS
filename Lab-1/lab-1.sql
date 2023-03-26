\prompt 'Ввведите название таблицы ' name_table
set myvars.tab to :name_table;

\prompt 'Ввведите имя пользователя ' name_user
set myvars.user_name to :name_user;


do
$$
    declare
        tmp_user_name   text;
        tmp_database_name text;
        tmp_table_name text;
--         tmp_schema_name text;
        table_exists    integer;
        column_record  record;
        table_id       oid;
        my_column_name text;
        column_number  text;
        column_type    text;
        column_type_id oid;
        result         text;
        constraint_name text;
        constraint_def  text;
        first_constraint boolean;
    begin
        tmp_user_name := current_setting('myvars.user_name');
        tmp_database_name := current_database();
        tmp_table_name := current_setting('myvars.tab');

--         select schema_name into tmp_schema_name
--         from information_schema.schemata
--         where catalog_name = tmp_database_name
--         and schema_owner = tmp_user_name;

        select COUNT(*) into table_exists
        from pg_tables
        where tablename = tmp_table_name
          and tableowner = tmp_user_name;

        if table_exists > 0 then

            raise notice '|Пользователь: %', tmp_user_name;
            raise notice '|Таблица: %', tmp_table_name;
            raise notice '|No  Имя столбца    Атрибуты';
            raise notice '|--- -------------- ------------------------------------------';
            select "oid" into table_id from pg_catalog.pg_class where "relname" = tmp_table_name;
            for column_record in select * from pg_catalog.pg_attribute where attrelid = table_id
                loop
                first_constraint := true;
                if column_record.attnum > 0 then
                    column_number = column_record.attnum;
                    my_column_name = column_record.attname;
                    column_type_id = column_record.atttypid;
                    select typname into column_type from pg_catalog.pg_type where oid = column_type_id;

                    if column_record.attnotnull then
                        column_type = column_type || ' Not null';
                    end if;

                    select format('%-3s %-14s %-6s %-2s %s', column_number, my_column_name, 'Type', ':', column_type)
                    into result;
                    raise notice '%', '|' || result;

                    for constraint_name, constraint_def in select conname, pg_get_constraintdef(c.oid)
                                                           from pg_constraint c
                                                                    join pg_class t on c.conrelid = t.oid
                                                                    join pg_attribute a on a.attrelid = t.oid
                                                           where t.relname = tmp_table_name
                                                             and a.attname = my_column_name
                        loop
                            if first_constraint then
                                select format('%25s %-2s %s %s', 'Constr', ':', constraint_name, constraint_def) into result;
                                raise notice '%', '|' || result;
                                first_constraint := false;
                            else
                                select format('%49s %s',  constraint_name, constraint_def) into result;
                                raise notice '%', '|' || result;
                            end if;
                        end loop;
                end if;
            end loop;
        else
            raise notice 'Пользователь: %', tmp_user_name;
            raise notice 'не содержит таблицу: %', tmp_table_name;
        end if;
    end
$$ LANGUAGE plpgsql;
