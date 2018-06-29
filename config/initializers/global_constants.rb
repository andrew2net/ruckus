require Rails.root.join('config', 'initializers', 'app')

SERVER_IP = ruckus? ? '54.200.94.145' : '52.27.39.174'

US_STATES = [
    ['State', nil],
    ['Alabama', 'AL'],
    ['Alaska', 'AK'],
    ['Arizona', 'AZ'],
    ['Arkansas', 'AR'],
    ['California', 'CA'],
    ['Colorado', 'CO'],
    ['Connecticut', 'CT'],
    ['Delaware', 'DE'],
    ['District of Columbia', 'DC'],
    ['Florida', 'FL'],
    ['Georgia', 'GA'],
    ['Hawaii', 'HI'],
    ['Idaho', 'ID'],
    ['Illinois', 'IL'],
    ['Indiana', 'IN'],
    ['Iowa', 'IA'],
    ['Kansas', 'KS'],
    ['Kentucky', 'KY'],
    ['Louisiana', 'LA'],
    ['Maine', 'ME'],
    ['Maryland', 'MD'],
    ['Massachusetts', 'MA'],
    ['Michigan', 'MI'],
    ['Minnesota', 'MN'],
    ['Mississippi', 'MS'],
    ['Missouri', 'MO'],
    ['Montana', 'MT'],
    ['Nebraska', 'NE'],
    ['Nevada', 'NV'],
    ['New Hampshire', 'NH'],
    ['New Jersey', 'NJ'],
    ['New Mexico', 'NM'],
    ['New York', 'NY'],
    ['North Carolina', 'NC'],
    ['North Dakota', 'ND'],
    ['Ohio', 'OH'],
    ['Oklahoma', 'OK'],
    ['Oregon', 'OR'],
    ['Pennsylvania', 'PA'],
    ['Puerto Rico', 'PR'],
    ['Rhode Island', 'RI'],
    ['South Carolina', 'SC'],
    ['South Dakota', 'SD'],
    ['Tennessee', 'TN'],
    ['Texas', 'TX'],
    ['Utah', 'UT'],
    ['Vermont', 'VT'],
    ['Virginia', 'VA'],
    ['Washington', 'WA'],
    ['West Virginia', 'WV'],
    ['Wisconsin', 'WI'],
    ['Wyoming', 'WY']
]

US_STATES_HASH = {}
US_STATES.collect{ |fullname, abbr| US_STATES_HASH[abbr] = fullname }

US_STATES_ABBREVIATIONS = US_STATES_HASH.keys.compact

DEMOCRACYENGINE_CREDENTIALS = YAML.load_file("#{Rails.root}/config/democracy_engine_credentials.yml")
GOOGLE_MAP_KEY = YAML.load_file("#{Rails.root}/config/google_map_key.yml")
ANALYTICS = YAML.load_file("#{Rails.root}/config/analytics.yml")

MONTHS = %w(01 02 03 04 05 06 07 08 09 10 11 12)
YEARS = (Time.now.year..2025).collect(&:to_s)

DE_ACCOUNT_TYPES = [
  ['Federal Candidate', 'federal_candidate'],
  ['Federal Party',     'federal_party'],
  ['Federal PAC',       'federal_pac'],
  ['State Candidate',   'state_candidate'],
  ['State Party',       'state_party'],
  ['State PAC',         'state_pac'],
  ['Local Candidate',   'local_candidate'],
  ['Local Party',       'local_party'],
  ['Local PAC',         'local_pac'],
  ['Nonprofit',         'nonprofit'],
  ['Charity',           'charity'],
  ['For Profit',        'for_profit']
]

# todo: remove for production
VIDEOS = {
  youtube: {
    url:            'https://www.youtube.com/watch?v=WyMpZTba5Tc',
    embed_url:      '//www.youtube.com/embed/WyMpZTba5Tc',
    thumbnail_name: 'default.jpg'
  },
  vimeo:   {
    url:            'https://vimeo.com/50655103',
    embed_url:      '//player.vimeo.com/video/50655103',
    thumbnail_name: '348979922_640.jpg'
  }
}

REQUEST_METHODS = %i(ignore_accept_header auth_type gateway_interface path_translated remote_host
                     remote_ident remote_user remote_addr server_name server_protocol accept
                     accept_charset accept_encoding accept_language cache_control from negotiate
                     pragma request_method request_method_symbol method_symbol headers
                     original_fullpath fullpath original_url media_type content_length ip
                     remote_ip uuid server_software raw_post body body_stream reset_session
                     query_parameters request_parameters authorization
                     cookie_jar flash tld_length url protocol raw_host_with_port host
                     host_with_port port standard_port optional_port port_string server_port
                     domain subdomains subdomain filtered_parameters filtered_env filtered_path
                     parameter_filter env_filter filtered_query_string parameters
                     params symbolized_path_parameters path_parameters reset_parameters
                     content_mime_type content_type accepts format
                     formats valid_accept_header use_accept_header
                     script_name path_info query_string session session_options
                     media_type_params content_charset scheme referer referrer user_agent
                     cookies base_url path)

TIME_ZONES = {
  'HST' => 'Hawaii',
  'AKDT' => 'Alaska',
  'PDT' => 'Pacific Time (US & Canada)',
  'MST' => 'Arizona',
  'MDT' => 'Mountain Time (US & Canada)',
  'CDT' => 'Central Time (US & Canada)',
  'EST' => 'Eastern Time (US & Canada)',
  'EDT' => 'Indiana (East)',
  'UTC' => 'UTC'
}
