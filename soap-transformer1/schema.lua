local typedefs = require "kong.db.schema.typedefs"

return {
  name = "soap-transform",
  fields = {
    { config = {
        type = "record",
        fields = {
          { request_format = { type = "string", required = true, one_of = { "json", "soap" } } },
          { response_format = { type = "string", required = true, one_of = { "json", "soap" } } },
          { soap_request_template = { type = "string", required = false } },
          { soap_response_template = { type = "string", required = false } },
          { json_request_mapping = { type = "map", keys = { type = "string" }, values = { type = "string" }, required = false } },
          { json_response_mapping = { type = "map", keys = { type = "string" }, values = { type = "string" }, required = false } }
        }
      }
    }
  }
}
