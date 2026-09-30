### Debug API in Azure API Management
In this exercise, we will debug an API in Azure API Management. Debugging an API is an important part of the development process as it allows you to identify and fix issues in your API implementation.

#### Prerequisites
- Completed the previous exercises in this module.

#### Exercise 1: API tracing through the portal
In this exercise, we will debug an API operation in Azure API Management. We will use the **Trace** feature in the Azure portal to view the request and response details for the API operation.

1. In the Azure portal, go to your API Management instance and click on **APIs** in the left-hand menu.
2. Click on the **Festival Ticket Sales API xx** API.
3. Click on the **Test** tab.
4. Click on the **Initiates a new ticket purchase.** operation.
5. Enter a valid tiketId under **Template parameters** (e.g. '123' ) 
6. Enter a valid JSON object in the **Request body** section. It should be present already. In case it's missing  reuse the value used during the previous exercises.
7. Click on **Trace** to send the request with tracing enabled.
8. The "HTTP response" should display a 200 OK response.
9. Click on the **Trace** tab to view the request and response details.

  ![APIM Change backend](../../assets/images/apim-tracing.png)

9. The trace will show the request and response details, including the request headers, request body and response headers.

!!! **Remark**: if you receive an error that tracing is not enabled for your subscription, please enable tracing for your subscription:
1. In the Azure portal, go to your API Management instance and click on **Subscriptions** in the left-hand menu.
2. Click on the subscription you created earlier.
3. Set the **Allow tracing** option to **true**.   

### Excercise 2: API tracing through Postman
In this exercise, we will debug an API operation in Azure API Management using Postman. We will use Postman to send a request to the API operation and view the response.


#### Test the API operation using Postman
1. Open Postman.
2. Create a new request.
3. Set the request type to **POST**.
4. Enter the URL of the API operation. The URL should resemble `https://<your-apim-instance-name>.azure-api.net/festivalticketsales00/tickets/123/purchase`.
5. Go to the **Headers** tab and add a new header with the key `Ocp-Apim-Subscription-Key` and the value of the subscription key you copied earlier.
6. Add a new header with the key `Ocp-Apim-Trace` and the value of `true`.
7. Go to the **Body** tab and enter the following JSON object:

```json
{
  "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "quantity": 1,
  "ticketType": "normal"
}
```
8. Send the request.
9. You should receive a response with a status code of 200 OK and a JSON object containing the response from the backend service.
10. Inside the response headers, you should see the `ocp-apim-trace-location` header. Copy the value of this header and open it in your browser window.
 ![APIM trace location](../../assets/images/ocp-apim-trace-location.png)
11. Inspect the trace details in the browser window.