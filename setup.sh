rm ./db/db_test.sqlite3

sqlite3 ./db/db_test.sqlite3 < ./db/schema.sql
echo "Schema successfully applied to DB!"


