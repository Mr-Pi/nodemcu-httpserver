-- httpserver-basicauth.lua
-- Part of nodemcu-httpserver, authenticates a user using http basic auth.
-- Author: Sam Dieck

basicAuth = {}

function basicAuth.authenticate(header)
   -- Parse basic auth http header.
   -- Returns the username if header contains valid credentials,
   -- nil otherwise.
   local credentials_enc = header:match("Authorization: Basic ([A-Za-z0-9+/=]+)")
   if not credentials_enc then
      return nil
   end
   local credentials = base64.dec(credentials_enc)
   local user, pwd = credentials:match("^(.*):(.*)$")
   if user ~= g.config.httpauth.user or pwd ~= g.config.httpauth.password then
      return nil
   end
   print("httpserver-basicauth: User \"" .. user .. "\" authenticated.")
   return user
end

function basicAuth.authErrorHeader()
   return "WWW-Authenticate: Basic realm=\"" .. tostring(g.config.httpauth.realm) .. "\""
end

return basicAuth
