\prompt 'Ввведите название таблицы ' name_table
\set tab_name :name_table
set myvars.tab to :tab_name;

do
$$
    declare
        column_record  record;
        table_id       oid;
        my_column_name text;
        column_number  text;
        column_type    text;
        column_type_id oid;
        column_comment text;
        column_index   text;
        result         text;
    begin
        raise notice 'Пользователь: Ivan Ivanov (s100000)';
        raise notice 'Таблица: %', current_setting('myvars.tab');
        raise notice 'No  Имя столбца    Атрибуты';
        raise notice '--- -------------- ------------------------------------------';
        select "oid" into table_id from ucheb.pg_catalog.pg_class where "relname" = current_setting('myvars.tab');
        for column_record in select * from ucheb.pg_catalog.pg_attribute where attrelid = table_id
            loop
            if column_record.attnum > 0 then
                column_number = column_record.attnum;
                my_column_name = column_record.attname;
                column_type_id = column_record.atttypid;
                select typname into column_type from ucheb.pg_catalog.pg_type where oid = column_type_id;

                if column_record.atttypmod != -1 then
                    column_type = column_type || ' (' || column_record.atttypmod || ')';
                    if column_type = 'int4' then
                        column_type = 'NUMBER';
                    end if;
                end if;

                if column_record.attnotnull then
                    column_type = column_type || ' Not null';
                end if;

                select description
                into column_comment
                from ucheb.pg_catalog.pg_description
                where objoid = table_id
                and objsubid = column_record.attnum;
                column_comment = '"' || column_comment || '"';

                select pg_catalog.pg_indexes.indexname
                from pg_indexes, information_schema.columns as inf
                where pg_indexes.tablename = current_setting('myvars.tab')
                and inf.column_name = my_column_name
                and indexdef ~ (my_column_name)
                into column_index;
                column_index = '"' || column_index || '"';

                select format('%-3s %-14s %-8s %-2s %s', column_number, my_column_name, 'Type', ':', column_type)
                into result;
                raise notice '%', result;

                if length(column_comment) > 0 then
                    select format('%-18s %-8s %-2s %s', '""', 'Constr', ':', column_comment) into result;
                    raise notice '%', result;
                end if;
            end if;
        end loop;
    end;
$$ LANGUAGE plpgsql;