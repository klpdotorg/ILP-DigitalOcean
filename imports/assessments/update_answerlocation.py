from os import system, sys
import os
import inspect

if len(sys.argv) != 3:
    print("Please give database names as arguments. USAGE: python update_answerlocation.py dubdubdub ilp")
    sys.exit()

fromdatabase = sys.argv[1]

todatabase = sys.argv[2]

basename = "updatelocation"
scriptdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))

inputsqlfile = scriptdir+"/"+basename+"_getdata.sql"
loadsqlfile = scriptdir+"/"+basename+"_loaddata.sql"

tables = [
        {
            'name': 'assessments_answergroup_institution',
            'getquery': "\COPY (select id, group_id, location from stories_story where location is not null) TO 'replacefilename' NULL 'null' DELIMITER   ',' quote '\\\"' csv;",
            'tempquery': "CREATE TEMP TABLE temp_replacetablename(id integer, group_id integer, location geometry); \COPY temp_replacetablename(id, group_id, location) FROM 'replacefilename' with csv NULL 'null';",
            'updatequery': "UPDATE replacetablename set location=temp.location from  temp_replacetablename temp where replacetablename.id=temp.id and replacetablename.questiongroup_id=temp.group_id;"
        },
]


# Create directory and files
def init():
    if not os.path.exists(scriptdir+"/load"):
        os.makedirs(scriptdir+"/load")
    open(inputsqlfile, 'wb', 0)
    open(loadsqlfile, 'wb', 0)


# Create the getdata.sql and loaddata.sql files
# getdata.sql file has the "Copy to" commands for populating the various csv files
# loaddata.sql file has the "copy from" commands for loading the data into the db
def create_sqlfiles():
    # Loop through the tables
    for table in tables:
        filename = scriptdir+'/load/'+basename+'_'+table['name']+'.csv'
        open(filename, 'wb', 0)
        os.chmod(filename, 0o666)
        if 'getquery' in table:
            command = 'echo "'+table['getquery'].replace('replacetablename', table['name']).replace('replacefilename', filename)+'">>'+inputsqlfile
            system(command)
        if 'tempquery' in table:
            command = 'echo "'+table['tempquery'].replace('replacetablename', table['name']).replace('replacefilename', filename)+'">>'+loadsqlfile
            system(command)
        if 'updatequery' in table:
            command = 'echo "'+table['updatequery'].replace('replacetablename', table['name']).replace('replacefilename', filename)+'">>'+loadsqlfile
            system(command)


# Running the "copy to" commands to populate the csvs.
def getdata():
    system("psql -U klp -d "+fromdatabase+" -f "+inputsqlfile)


# Running the "copy from" commands for loading the db.
def loaddata():
    system('psql -U klp -d '+todatabase+' -f '+loadsqlfile)


# order in which function should be called.
init()
create_sqlfiles()
getdata()
loaddata()
