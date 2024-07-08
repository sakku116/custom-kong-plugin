local typedefs = require "kong.db.schema.typedefs"

return {
  name = "soap-transform",
  fields = {
    { config = {
        type = "record",
        fields = {}
      }
    }
  }
}
