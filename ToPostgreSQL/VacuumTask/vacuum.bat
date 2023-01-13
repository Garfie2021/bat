rem @echo off

rem --------------------------------------------------
rem DB接続パラメータ
rem --------------------------------------------------
set PGPATH=C:\Tasks\VacuumTask
set HOSTNAME=（ホスト名）
set DBNAME=（データベース名）
set USERNAME=（データベース ログインユーザ名）
set PGPASSWORD=（データベース ログインパスワード）

rem --------------------------------------------------
rem 定数
rem --------------------------------------------------
rem 今日の日付
set YYYYMMDD=%DATE:/=%

rem 実行SQLファイル定義
set SELECT_TABLE_FILE=sql\select_table.sql

rem SQL実行結果ファイル定義
set SELECT_TABLE_OUTPUT_FILE=dat\select_table_output.txt

rem --------------------------------------------------
rem 実行
rem --------------------------------------------------
rem 処理開始
echo %date:/=-% %time:.=,%0 : start >log\%YYYYMMDD%.log

cd %PGPATH%

if not exist "dat" (
  rem datフォルダが無ければ作成
  mkdir dat\
)

if not exist "log" (
  rem logフォルダが無ければ作成
  mkdir log\
)

echo %date:/=-% %time:.=,%0 : VACUUM対象抽出 start >>log\%YYYYMMDD%.log
psql -h %HOSTNAME% -p 5432 -U %USERNAME% -f %SELECT_TABLE_FILE% -d %DBNAME% -o %SELECT_TABLE_OUTPUT_FILE% >> log\%YYYYMMDD%.log
echo %date:/=-% %time:.=,%0 : VACUUM対象抽出 end >>log\%YYYYMMDD%.log

rem VACUUM対象抽出結果を1行ずつ読み込む。Table名以外はスキップする。
for /f "delims=" %%a in (%SELECT_TABLE_OUTPUT_FILE%) do (

  echo %%a | find "行" 1>nul
  if not ERRORLEVEL 1 (
    echo %date:/=-% %time:.=,%0 : スキップ[%%a] >> log\%YYYYMMDD%.log
  ) else (

    echo %%a | find "--" 1>nul
    if not ERRORLEVEL 1 (
      echo %date:/=-% %time:.=,%0 : スキップ[%%a] >> log\%YYYYMMDD%.log
    ) else (

      echo %%a | find "relname" 1>nul
      if not ERRORLEVEL 1 (
        echo %date:/=-% %time:.=,%0 : スキップ[%%a] >> log\%YYYYMMDD%.log
      ) else (

        rem Table名なので VACUUMを行う。
        echo %date:/=-% %time:.=,%0 : psql -h %HOSTNAME% -p 5432 -U %USERNAME% -d %DBNAME% -c "VACUUM %%a;" >> log\%YYYYMMDD%.log
        psql -h %HOSTNAME% -p 5432 -U %USERNAME% -d %DBNAME% -c "VACUUM %%a;"  >> log\%YYYYMMDD%.log
      )
    )
  )
)

rem 処理終了
echo %date:/=-% %time:.=,%0 : end >>log\%YYYYMMDD%.log