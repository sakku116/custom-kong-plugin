-- -- config input validation scripts


-- plugin configuration


local typedefs = require "kong.db.schema.typedefs"

return {
  name = "my_plugin", -- Replace 'my_plugin' with your plugin's name
  fields = {
    { config = {
        type = "record",
        fields = {
          -- Define plugin-specific configuration options here
          { ignore_content_type = { type = "boolean", default = false } },
        },
      },
    },
    -- This line explicitly defines where the plugin can be applied
    { consumer = typedefs.no_consumer },  -- This is correct if your plugin should not apply to consumers
  },
}