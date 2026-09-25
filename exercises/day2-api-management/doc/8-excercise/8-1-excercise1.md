## Additional Excercises
If you followed the steps from the previous exercises, you should have an API in Azure API Management that is connected to the backend service and protected with OAuth2.

Now it's up to you to enhance the current soltuion with the following features:

## Exercise 1: Check HTTP header
Check if the client is calling the API with a value inside the Authorization HTTP header. If the header is missing, return a 401 Unauthorized response. Hint: Use the 
`check-header` policy. (https://learn.microsoft.com/en-us/azure/api-management/check-header-policy)

## Exercise 2: Verify OAuth2 response
Update the OAuth2 policy that is used to request a token from the identity provider to check if the identityprovider returned a HTTP status code 200 and only add the token to the Authorization header in that case. If the status code is different then 200, return a 401 Unauthorized response. Hint: Use the `choose` policy to check the status code. (https://learn.microsoft.com/en-us/azure/api-management/choose-policy)

## Exercise 3: Reject request if ticket id has the value '1234'
Add logic within the policy to check if the ticket id has the value '1234'. If the value is '1234', return a 400 Bad Request. Hint: Inside a variable .NET code can be used to parse the JSON body to a JObject. After that, the value of the ticket id can be checked. ([https://learn.microsoft.com/en-us/azure/api-management/set-variable](https://learn.microsoft.com/en-us/azure/api-management/set-variable-policy))

