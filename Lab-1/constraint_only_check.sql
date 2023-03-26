\prompt 'Ввведите название таблицы ' name_table
set myvars.tab to :name_table;

DO
$$
    DECLARE
        my_column_name     text;
        constraint_name text;
        constraint_def  text;
    BEGIN
        FOR my_column_name IN SELECT column_name
                           FROM information_schema.columns
                           WHERE table_name = current_setting('myvars.tab')
            LOOP
                RAISE NOTICE 'Constraints for column %:', my_column_name;
                FOR constraint_name, constraint_def IN SELECT conname, pg_get_constraintdef(c.oid)
                                                       FROM pg_constraint c
                                                                JOIN pg_class t ON c.conrelid = t.oid
                                                                JOIN pg_attribute a ON a.attrelid = t.oid
                                                       WHERE t.relname = current_setting('myvars.tab')
                                                         AND a.attname = my_column_name
                    LOOP
                        RAISE NOTICE '- %: %', constraint_name, constraint_def;
                    END LOOP;
            END LOOP;
    END;
$$ LANGUAGE plpgsql;