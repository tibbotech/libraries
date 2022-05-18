# HTTP Library

## Introduction<br />

The HTTP library simplifies the process of submitting Hypertext Transfer Protocol (HTTP) requests and dealing with the response on Tibbo's ARM-based programmable devices. This is an asynchronous and event-driven library that in most cases can be used to submit numerous concurrent requests up to a user-defined limit (the default is 10) — if that number is exceeded, additional requests will be ignored until a socket has been freed up to continue making HTTP requests. Connectivity is provided through the Ethernet (net.) and Wi-Fi (wln.) network interfaces.

Of the nine standard request methods for HTTP, this library facilitates the handling of the six most commonly used: 

1. ​	GET requests a representation of the specified resource.
2. ​	HEAD asks for the same as GET, only without the response body.
3. ​	POST is used to submit an entity to the specified resource.
4. ​	PUT replaces all current representations of the specified resource with the input.
5. ​	DELETE eliminates the specified resource.
6. ​	PATCH applies partial modifications to a resource.

When triggered by an event (e.g. a button press on the device or a scheduled activity), this library makes a Domain Name System (DNS) request for the specified target, establishes a connection to the provided Internet Protocol (IP) address and makes the desired HTTP requests. Once an HTTP request has been submitted, the library waits for a response, which is handled based on the user's predetermined needs — such as outputting returned data to a display — before the device is returned to an available state.

If the DNS request is unsuccessful, the process is terminated and the device returns to an available state.

## Library info<br />

Supported platforms: EM510, EM2000, EM2001, and second-generation Tibbo Project PCB (TPP) sizes 2 and 3. 

Dependencies: DHCP, DNS and SOCK libraries. The WLN library is highly recommended if using Wi-Fi.

API Procedures: 

http_start() — Starts the HTTP library.
 http_stop() — Stops the HTTP library.
 http_request() — Makes an HTTP request of up to 255 bytes with a specified remote server.
 http_request_with_buffers() — Same as http_request(), but with additional parameters to define the transmission (TX) and reception (RX) buffers.
 http_request_long() — Used when making HTTP POST, PUT or PATCH requests in which the total amount of content to be transmitted exceeds 255 bytes.
 http_request_long_with_buffers() — Same as http_request_long(), but with additional parameters to define the TX and RX buffers.


 

Event procedures:

http_proc_data() — Call it from on_sock_data_arrival().
 http_sock_state_update() — Call it from on_sock_event().
 http_on_sock_data_sent() — Call it from on_sock_data_event().
 
 

Callback procedures:

callback_http_send_post_data — Sends the next batch of content for an HTTP POST request. The amount of data sent corresponds with available capacity and the process keeps count by moving the cursor in the source material until the specified length has been reached. The location of the source material is defined within.
 callback_http_reponse_code_arrival() — Called when an HTTP code is received.
 callback_http_header_arrival() — Called when HTTP header data is received.
 callback_http_headers_complete() — Called when HTTP header data download is complete.
 callback_http_content_arrival() — Called when HTTP content is received.
 callback_http_post_data_sent_ok() — Provides notification that an http_request_long() function has been completed successfully.
 
 

Required buffer space: By default, each instance of the HTTP library requires 4 buffer pages — 2 for TX and 2 for RX. As there is a default maximum of 10 instances, buffer usage could go as high as 40 pages. 

However, if buffers are manually specified through http_request_with_buffers() or http_request_long_with_buffers(), then the required buffer space **per instance** would be the sum of the specified buffer values.

Due to the complexity of Transport Layer Security (TLS), its usage increases the required buffer space by an additional 64 pages.

## Step-by-step Usage Instructions<br />

### Minimal steps

1. ​	Make sure that you have included the DHCP, DNS and SOCK libraries in your project. This allows your project to use functions of those libraries, which are required. If you plan to use Wi-Fi functionality, including the WLN library is also recommended.
2. ​	Add the **http.tbs** and **http.tbh** files to your project (these are located at [location] included in platform version ##.##.## and later). These files contain the HTTP library.
3. ​	Add **#define HTTP_DEBUG_PRINT 1** to the defines section of the **global.tbh** file of your project. This allows you to "see what's going on" when debugging your project by allowing sys.debugprint messages to be sent to the Output pane in TIDE, but don't forget to remove it after you've made sure that the library operates as expected — such messages significantly slow down program execution.
4. ​	Add **include http.tbh** to the includes section of the **global.tbh** file. This lets TIDE know that your project will use the HTTP library.
5. ​	Call http_request() whenever you need to make an HTTP request of up to 255 bytes or http_request_long() when making HTTP POST, PUT or PATCH requests in which the total amount of content being transmitted exceeds 255 bytes. A detailed explanation of both functions' parameters can be found in the next section, Operation Details.  



## Operation Details

The HTTP library is called when either the http_request() or http_request_long() functions — or their variants when buffers need to be specified by the user — are used. It is capable of conducting several concurrent requests, as defined by the HTTP_NUM_OF_REQS variable in **global.tbh**.

### http_request()

The http_request() function is limited to performing HTTP requests of up to 255 bytes and takes five parameters: method, url, interface, data and content_type.

The method parameter identifies which of the six types of supported HTTP requests to perform: HTTP_GET, HTTP_HEAD, HTTP_POST, HTTP_PUT, HTTP_DELETE or HTTP_PATCH.

The GET method requests a representation of the requested resource from the remote system. HEAD asks for an identical response as GET, but without the response body. POST submits the entity included in the request as a new subordinate of the target resource. PUT requests that the enclosed entity be stored at a specific location, with any previous content being modified. DELETE, as the name implies, eliminates the target resource. PATCH applies partial modifications to a specified resource.

The url parameter specifies the Uniform Resource Locator (URL) — commonly known as a web address — of the system to which the request is being sent. The library parses the input and removes extraneous bits — such as "http://" and "www" — to ensure robust functionality while remaining user-friendly.

The interface parameter indicates which network interface on the device to use. There are two options: PL_SOCK_INTERFACE_NET for the Ethernet connection and PL_SOCK_INTERFACE_WLN for Wi-Fi (if available on the device).

The data parameter defines the data that is to be sent to the target server. As the HTTP_GET and HTTP_HEAD methods are intended to retrieve information from the target system, an empty string should be passed when they are used.

The content_type parameter specifies the string of text to be used in the "Content-Type" HTTP header of the request. If an empty string is passed, the default value of "text/plain" is used.

### http_request_long()

In cases where the total amount of content that is to be transmitted in an HTTP POST, PUT or PATCH requests exceeds 255 bytes, the http_request_long() function can be used. It shares the method, url, interface and content_type parameters with http_request(), but replaces the data parameter with request_length, which is measured in bytes. 

Prior to calling http_request_long(), the user must first calculate the size in bytes of the total content to be transmitted, which determines the value of request_length. This calculation can be achieved either manually, if the amount of content is to remain constant, or through a custom function. The value of request_length should not exceed the actual length in bytes of the total amount of content to transmit — doing so would leave the destination system waiting for data that will never be transmitted.

The http_request_long() function repeatedly triggers callback_http_send_post_data() until the user-defined amount of content in bytes (request_length) has been sent.

### Manually specifying buffer size

If buffer values other than the defaults (2,2) need to be specified, http_request_with_buffers() or http_request_long_with_buffers() should be used, as they have two additional parameters to manually specify the transmission (TX) and reception (RX) buffers.

### Working with the return value

The http_request() and http_request_long() functions provide a return value, which is the socket used for the operation. You can define byte-type variables that take the value of the return, allowing you to identify which sockets are being used for specific exchanges.

For example, you can define a variable and assign it the return value. This can provide valuable insight when debugging your code, such as identifying which sockets are being used when an event triggers multiple HTTP requests. 

### Transport Layer Security (Advanced)

The HTTP library provides support for issuing HTTP requests with TLS employing AES-256, SHA-3 and perfect forward secrecy. In your project code, implementation is as simple as changing “http” to “https” for the url parameter of the function being called to make the request.