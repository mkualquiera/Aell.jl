
module DSL

@enum TokenizerState begin
    NORMAL
    STRING
    COMMENT
    ESCAPE
    LITERAL
end

"""
    tokenize(text)

Tokenize an Aell string into an array of tokens
"""
function tokenize(text::String)::Vector{NamedTuple{(:pos, :line, :col, :token),Tuple{Int64,Int64,Int64,String}}}
    tokens = []
    pos = 1
    line = 1
    col = 1
    mode = TokenizerState[NORMAL]
    buffer = ""
    function addtoken!()
        if buffer != ""
            push!(tokens, (pos=pos, line=line, col=col, token=buffer))
        end
        buffer = ""
    end
    while true
        if pos > length(text)
            addtoken!()
            break
        end
        char = text[pos]
        if mode[end] == ESCAPE
            buffer *= char
            pop!(mode)
        elseif mode[end] == STRING
            if char == '"'
                buffer *= char
                addtoken!()
                mode[end] = NORMAL
            elseif char == '\\'
                push!(mode, ESCAPE)
            else
                buffer *= char
            end
        elseif mode[end] == LITERAL
            buffer *= char
            if char == '{'
                push!(mode, LITERAL)
            elseif char == '}'
                pop!(mode)
                if mode[end] != LITERAL
                    addtoken!()
                end
            end
        elseif mode[end] == NORMAL
            if char == '"'
                buffer *= char
                mode[end] = STRING
            elseif char == '{'
                buffer *= char
                push!(mode, LITERAL)
            elseif char == '\\'
                push!(mode, ESCAPE)
            elseif char == '#'
                buffer *= char
                mode[end] = COMMENT
            elseif isspace(char)
                if buffer != ""
                    addtoken!()
                end
            else
                buffer *= char
            end
        elseif mode[end] == COMMENT
            if char == '\n'
                mode[end] = NORMAL
                addtoken!()
            else
                buffer *= char
            end
        end
        if char == '\n'
            line += 1
            col = 1
        else
            col += 1
        end
        pos += 1
    end
    return tokens
end

"""
    eval(text)

Evaluate an Aell string
"""
function eval(text::String)
    tokens = tokenize(text)
    eval(tokens)
end

"""
    eval(tokens)

Evaluate an array of tokens. Returns the value at the top of the stack.
"""
function eval(tokens::Vector{NamedTuple{(:pos, :line, :col, :token),Tuple{Int64,Int64,Int64,String}}})::Any
    for token in tokens
        println(token)
    end
end

end