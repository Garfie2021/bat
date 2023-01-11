rem @echo off

rem --------------------------------------------------
rem DB�ڑ��p�����[�^
rem --------------------------------------------------
set PGPATH=C:\Tasks\reindexTask
set HOSTNAME=�i�z�X�g���j
set DBNAME=�i�f�[�^�x�[�X���j
set USERNAME=�i�f�[�^�x�[�X ���O�C�����[�U���j
set PGPASSWORD=�i�f�[�^�x�[�X ���O�C���p�X���[�h�j

rem --------------------------------------------------
rem �萔
rem --------------------------------------------------
rem �����̓��t
set YYYYMMDD=%DATE:/=%

rem ���sSQL�t�@�C����`
set SELECT_INDEX_FILE=sql\select_index.sql

rem SQL���s���ʃt�@�C����`
set SELECT_INDEX_OUTPUT_FILE=dat\select_index_output.txt

rem --------------------------------------------------
rem ���s
rem --------------------------------------------------
rem �����J�n
echo %date:/=-% %time:.=,%0 start >log\%YYYYMMDD%.log

cd %PGPATH%

if not exist "dat" (
  rem dat�t�H���_��������΍쐬
  mkdir dat\
)

if not exist "log" (
  rem log�t�H���_��������΍쐬
  mkdir log\
)

echo %date:/=-% %time:.=,%0 REINDEX�Ώے��o start >>log\%YYYYMMDD%.log
psql -h %HOSTNAME% -p 5432 -U %USERNAME% -f %SELECT_INDEX_FILE% -d %DBNAME% -o %SELECT_INDEX_OUTPUT_FILE% >> log\%YYYYMMDD%.log
echo %date:/=-% %time:.=,%0 REINDEX�Ώے��o end >>log\%YYYYMMDD%.log

rem REINDEX�Ώے��o���ʂ�1�s���ǂݍ��ށBIndex���ȊO�̓X�L�b�v����B
for /f "delims=" %%a in (%SELECT_INDEX_OUTPUT_FILE%) do (

  echo %%a | find "�s" 1>nul
  if not ERRORLEVEL 1 (
    echo %date:/=-% %time:.=,%0 : �X�L�b�v[%%a] >> log\%YYYYMMDD%.log
  ) else (

    echo %%a | find "--" 1>nul
    if not ERRORLEVEL 1 (
      echo %date:/=-% %time:.=,%0 : �X�L�b�v[%%a] >> log\%YYYYMMDD%.log
    ) else (

      echo %%a | find "indexrelname" 1>nul
      if not ERRORLEVEL 1 (
        echo %date:/=-% %time:.=,%0 : �X�L�b�v[%%a] >> log\%YYYYMMDD%.log
      ) else (

        rem Index���Ȃ̂� REINDEX���s���B
        echo %date:/=-% %time:.=,%0 : psql -h %HOSTNAME% -p 5432 -U %USERNAME% -c "REINDEX INDEX %%a;" -d %DBNAME% >> log\%YYYYMMDD%.log
        psql -h %HOSTNAME% -p 5432 -U %USERNAME% -c "REINDEX INDEX %%a;" -d %DBNAME%  >> log\%YYYYMMDD%.log
      )
    )
  )
)

rem �����I��
echo %date:/=-% %time:.=,%0 end >>log\%YYYYMMDD%.log