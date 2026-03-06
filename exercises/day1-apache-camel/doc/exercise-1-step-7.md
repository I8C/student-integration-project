# Exercise 1 step 7

> DO THIS ONLY DAY 2 WHEN YOU RECEIVE CREDENTIALS TO CREATE API TOKENS  

**Do this step only once you call your Camel route from the Azure API Manager the 2nd day of the training**  
OR  
**if you know how to get an access token on an Autorization server with client credentials**  

## secure you API with OAuth2
There is an Authorization Server configured for us on Azure.  
You can find the endpoints at https://sts.windows.net/168b3482-55fe-4cf6-bc29-bd8c9fbc9999/.well-known/openid-configuration.  

1. uncomment the `<!-- Quarkus security dependencies ... -->` block in the _pom.xml_.  
2. uncomment these configuration keys in the _application.properties_:
   - mp.jwt.verify.issuer=https://sts.windows.net/09385aae-477d-4c3c-bb3d-36f75a52cdc3/
   - mp.jwt.verify.publickey.location=https://login.windows.net/common/discovery/keys
   - quarkus.http.auth.permission.secured.paths=/v1/tickets/*,/v1/purchases/*
   - quarkus.http.auth.permission.secured.policy=authenticated
   - quarkus.http.auth.permission.public.paths=/q/*,/api-doc/*,/openapi/*,/openapi
   - quarkus.http.auth.permission.public.policy=permit
   
   The result is that your application will expect and validate OAuth2 tokens in any request to your Camel REST API on paths `/v1/tickets/,/v1/purchases/` and authorize access without token on the paths `/q/,/api-doc/,/openapi/*,/openapi`.  
   The validation will check that:
   * the claim 'iss' (=issuer) has the configured value
   * the signature of the token is valid against the JWK  downloaded from the configured URL.  
     JWK is part of the JOSE specification. It's a  Keys represented in the Json (Json Web Key) format.

3. verify that you cannot query you API anymore.
   You will now get an HTTP 401 unauthorized error response when you query it.
   
4. in Postman, on your query to you API, configure the client credentials OAuth flow on Postman and test your API again.  
   Ask your clientId and secrets to your APIM teacher.
   Follow these instructions to configure Postman:
     - in the 'Authorization' tab of your request, select OAuth2 'auth type'
	 - set 'Add authorization data' to 'Request Headers'
	 - leave 'Header Prefix' as 'Bearer'
	 - give a name to your token. Ex: myToken
	 - set 'Grant Type' to 'client credentials'
	 - set 'Access Token URL' to the value of 'token_endpoint' in the list of URLs of the Authorization Server
	 - set 'Client ID' and 'Client Secret' to their respective values that you have received
	 - set 'Scope' to 'api://7304faca-f8d6-44d5-b0e1-bb40fb1d53e6/.default'
	 - click the 'Get New Access Token' button. It will fill the current token above still in the Authorization tab.
	   You can check the content of the token by pasting it on https://jwt.io/. Do that only with non sensitive tokens like the one here for the training!