import kong_pdk.pdk.kong as kong
import json
import xmltodict

Schema = (
    { "message": { "type": "string" } },
)
version = '0.1.0'
priority = 0

class Plugin(object):
    def __init__(self, config):
        self.config = config

    def access(self, kong: kong.kong):
        body, err = kong.request.get_raw_body()
        if body:
            if self.config.request_format == "json":
                # transform json to soap
                json_body = json.loads(body)
                soap_body = self.config.soap_request_template
                for k, v in json_body.items():
                    soap_body = soap_body.replace("{{" + k + "}}", v)

                kong.response.exit(
                    200,
                    body=soap_body,
                    headers={"Content-Type": "text/xml"},
                )

            elif self.config.request_format == "soap":
                # transform soap to json
                # Parse the XML into a dictionary
                data_dict = xmltodict.parse(body)

                # Convert the dictionary to a JSON string
                json_data = json.dumps(data_dict)

                kong.response.exit(
                    200,
                    body=json_data,
                    headers={"Content-Type": "application/json"},
                )