##
# This is some code from google. The ruby fast introduction to the google
# scripts API. Will do for the one function call.
#
require 'google/apis/script_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Get color values from some sheets'
CLIENT_SECRETS_PATH = '/home/developer/.credentials/PT_client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials', "GC_credentials.yaml")
SCOPE = ['https://www.googleapis.com/auth/drive.scripts',
          'https://www.googleapis.com/auth/spreadsheets',
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/script.storage',
          'https://www.googleapis.com/auth/script.send_mail',
          'https://www.googleapis.com/auth/forms',
          'https://www.googleapis.com/auth/documents']

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
    client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(
      base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the " +
         "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

# Initialize the API
service = Google::Apis::ScriptV1::ScriptService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize
SCRIPT_ID = 'M9BEz7TKhFSreJFaUhoqlQzuvAMBXjVEc'

# Create an execution request object.
request = Google::Apis::ScriptV1::ExecutionRequest.new(
  function:		'get_color_matrix',
	devMode:		true,
	parameters: ['EinListe',],
)

begin
  # Make the API request.
  resp = service.run_script(SCRIPT_ID, request)

  if resp.error
    # The API executed, but the script returned an error.

    # Extract the first (and only) set of error details. The values of this
    # object are the script's 'errorMessage' and 'errorType', and an array of
    # stack trace elements.
    error = resp.error.details[0]

    puts "Script error message: #{error['errorMessage']}"

    if error['scriptStackTraceElements']
      # There may not be a stacktrace if the script didn't start executing.
      puts "Script error stacktrace:"
      error['scriptStackTraceElements'].each do |trace|
        puts "\t#{trace['function']}: #{trace['lineNumber']}"
      end
    end
  else
    # The structure of the result will depend upon what the Apps Script function
    # returns. 
    $COLORS = resp.response['result']
		$COLOR_D = {
			'#ffffff' => 'white',
			'#ff0000' => 'red',
			'#00ff00' => 'green',
			'#38761d' => 'dark green',
			'#00ffff' => 'turquois',
			'#b45f06' => 'brown',
			'#ff00ff' => 'pink',
			'#ead1dc' => 'light pink',
			'#ffff00' => 'yellow',
			'#fff2cc' => 'chamois',
		}
		puts $COLORS
  end
rescue Google::Apis::ClientError
  # The API encountered a problem before the script started executing.
  puts "Error calling API!"
end
