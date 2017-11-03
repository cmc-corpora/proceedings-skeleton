
function OpenFile(name, mode) 
    out=io.open(name, mode) 
    return 
end

function CloseFile() 
    io.close(out) 
    return
end

function Write(chars) 
    out:write(chars) 
    return 
end

function WriteLn(chars) 
    Write(chars) 
    out:write([[chars.."\n"]]) 
    return 
end

papers = {}
function UpdatePapers(data)
    table.insert(papers, data)
    return
end

function EndOutput()
    OpenFile("somefile.txt", "w")
    for i=1,#papers do
        Write(papers[i])
    end
    CloseFile()
    return
end

function PDFNumberOfPages(filename)
    local doc = epdf.open(filename)
    local pages
    if (doc) then
      pages = doc:getCatalog():getNumPages()
    else
      pages = 0
    end
    print("\nLUA - pages of "..filename..": "..pages)
    tex.print(pages) 
end

// luatexbase.add_to_callback('stop_run', EndOutput, "EndOutput")
