local JsonSoapTransformer = {
  PRIORITY = 1000,
  VERSION = "0.0.1",
}


function JsonSoapTransformer:access(conf)
  kong.response.set_raw_body("Hello, world!")
end

return JsonSoapTransformer