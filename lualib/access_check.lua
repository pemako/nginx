local param = require("comm.param")
local args = ngx.req.get_uri_args()

if not args.a or args.b or not param.is_number(args.a, args.b) then
  ngx.exit(ngx.HTTP_FORBIDDEN)
end
