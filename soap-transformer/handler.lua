local xml2lua = require("xml2lua")
local handler = require("xmlhandler.tree")
local cjson = require "cjson"
local zlib = require("zlib")

function xml2json(xml)
    local parser = xml2lua.parser(handler)
    parser:parse(xml)

    a = cjson.encode(handler.root)
    return a

end

local TransformResponseHandler = {
    PRIORITY = 1000,
    VERSION = "1.0.0",
}

function TransformResponseHandler:header_filter(conf)
    -- Check if Content-Type is JSON-like or XML-like
    local content_type = ngx.header["Content-Type"]
    if content_type then
        if content_type:find("application/json", 1, true) or content_type:find("+json", 1, true) then
            ngx.ctx.is_json_response = true
            ngx.ctx.is_xml_response = false
            ngx.header["Content-Type"] = "application/xml"  -- Change content type to XML
            ngx.header["Accept-Encoding"] = nil
            ngx.header["Content-Encoding"] = nil
            kong.response.set_header("Accept-Encoding", "")
            kong.response.clear_header("Content-Length")
        elseif content_type:find("application/xml", 1, true) or content_type:find("+xml", 1, true) then
            ngx.ctx.is_json_response = false
            ngx.ctx.is_xml_response = true
            ngx.header["Content-Type"] = "application/json"  -- Change content type to JSON
            ngx.header["Accept-Encoding"] = nil
            ngx.header["Content-Encoding"] = nil
            kong.response.set_header("Accept-Encoding", "")
        else
            ngx.ctx.is_json_response = false
            ngx.ctx.is_xml_response = false
        end
    else
        ngx.ctx.is_json_response = false
        ngx.ctx.is_xml_response = false
    end
end

function TransformResponseHandler:body_filter(conf)
    local chunk, eof = ngx.arg[1], ngx.arg[2]
    local ctx = ngx.ctx

    if not ctx.buffer then
        ctx.buffer = {}
    end

    if chunk ~= "" then
        table.insert(ctx.buffer, chunk)
        ngx.arg[1] = nil
    end

    if eof then
        local response_body = table.concat(ctx.buffer)

        if ctx.is_xml_response then
        end

        if ctx.is_json_response then
            local jsonPay = cjson.decode(response_body)
            local soapXml = xml2lua.toXml(jsonPay, "Soap:Envelope")
            kong.response.set_raw_body(xml2lua.toXml(jsonPay, "Soap:Envelope"))
        end
        -- Clear buffer to prevent memory leaks
        ctx.buffer = nil
    end
end

--function TransformResponseHandler:access(conf)
--    kong.request.set_header("Accept-Encoding", "")
--end

return TransformResponseHandler

