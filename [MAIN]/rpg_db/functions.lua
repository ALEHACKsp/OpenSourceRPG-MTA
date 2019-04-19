local login, pass, host, dbname = "","","",""


local connection = nil

function connect()
    
    if not connection and not isElement(connection) then
        connection = dbConnect("mysql", "dbname="..dbname..";host="..host..";charset=utf8", login, pass, "share=1")
        
        if connection and isElement(connection) then
            outputDebugString("Połączono z mysql")
        else
            setTimer(connect, 5000, 1)
        end
    end  
        
end
addEventHandler("onResourceStart", resourceRoot, connect)


function query(...)
    if connection and isElement(connection) then
        
        if ... then -- kiedys to nei dzialalo w MTA XD potem zrobili ze dziala wow jak ty kozak
            local preparedString = dbPrepareString(connection, ...)
            if preparedString then
            
                local q = dbQuery(connection, preparedString)
                local r, aff, id = dbPoll(q, -1)
                if r or (type(r) == "table" and #r > 0) then -- ten warunek moze sie jebac, jak cos to sie naprawi
                    return r, aff, id
                end
                
            end
            
        end
    
    end
    return false
end

function exec(...) -- tu masz tylko dbExec do update głownie, bo insert wypadałoby przez query, bo cos moze zwrocic przydatnego

    if connection and isElement(connection) then
    
        if ... then
            
            local preparedString = dbPrepareString(connection, ...)
            if preparedString then
                
                local ex = dbExec(connection, preparedString)
                return ex or false
                
            end
            
        end
        
    end
    return false
end


