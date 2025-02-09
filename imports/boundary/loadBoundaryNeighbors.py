import sys
import psycopg2

dbname = sys.argv[1]
connectionstring = "dbname=%s user=klp" % dbname
conn = psycopg2.connect(connectionstring)
cur = conn.cursor()
# This should be imported from a file, not hardcoded like this
neighbours = {
        413: [414,  415,  420, 421, 422],
        414: [413, 415, 418, 419, 420],
        415: [413, 414, 416, 418, 445],
        416: [415, 417, 445],
        417: [416],
        418: [414, 415, 419, 424, 445],
        419: [414.418, 420, 424],
        420: [414, 419, 421, 423, 424],
        421: [413, 420, 422, 423],
        422: [413, 421, 423, 427, 428],
        423: [420, 421, 422, 424, 426, 427],
        424: [418, 419, 420, 423, 426, 425],
        425: [424, 426, 429, 430],
        426: [423, 424, 425, 427, 429],
        427: [422, 423, 426, 428, 429],
        428: [422, 427, 429, 436],
        429: [425, 426, 427, 428, 430, 435, 436],
        430: [425, 429, 433, 434, 435, 441, 444],
        431: [433, 441, 9540, 9541],
        433: [430, 431, 444, 9540, 9541],
        434: [430, 435, 439, 444, 8878],
        435: [429, 430, 434, 436, 437, 8878],
        436: [428, 429, 435, 437],
        437: [435, 436, 8878],
        439: [434, 444, 8878],
        441: [430, 431, 433],
        442: [414, 415, 420, 421, 422],
        443: [425, 429, 433, 434, 435, 441, 444],
        444: [430, 433, 434, 439, 9540, 9541],
        445: [415, 416, 418],
        8878: [434, 435, 437, 439],
        9540: [431, 433, 444, 9541],
        9541: [431, 433, 444, 9540]
}
for i in neighbours:
    list = neighbours[i]
    for value in list:
        print(i, value)
        cur.execute("INSERT INTO boundary_boundaryneighbours(boundary_id,neighbour_id) VALUES(%s,%s)", (i, value,))
conn.commit()
cur.close()
conn.close()
