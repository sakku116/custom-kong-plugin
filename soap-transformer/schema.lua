return {
  name = "json-soap-transformer",
  fields = {
    { config = {
        type = "record",
        fields = {
          { transform_on = { type = "string", default = "response", one_of = {"request", "response"}, }, },
        },
      },
    },
  },
}