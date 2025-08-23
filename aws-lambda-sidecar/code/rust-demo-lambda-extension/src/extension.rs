

use hyper::{Body, Error, Request, Response};
use log::info;
use once_cell::sync::OnceCell;

/// Send a request through a {hyper::Client}
pub async fn send_request(request: Request<Body>) -> Result<Response<Body>, Error> {
    hyper::Client::new().request(request).await
}


/// Lambda Extensions API version
const EXTENSION_API_VERSION: &str = "2020-01-01";
static LAMBDA_EXTENSION_IDENTIFIER: OnceCell<String> = OnceCell::new();

fn find_extension_name() -> String {
    crate::EXTENSION_NAME.to_owned()
}

pub(super) fn extension_id() -> &'static String {
    LAMBDA_EXTENSION_IDENTIFIER
        .get()
        .expect("[LRAP:Extension] Lambda Extension Identifier not set!")
}

/// Build the Lambda Extensions API endpoint URL
fn make_uri(path: &str) -> hyper::Uri {
    hyper::Uri::builder()
        .scheme("http")
        .authority(crate::env::sandbox_runtime_api())
        .path_and_query(format!("/{}/extension{}", EXTENSION_API_VERSION, path))
        .build()
        .expect("[LRAP:Extension] Error building Lambda Extensions API endpoint URL")
}

/// Register the extension with the Lambda Extensions API
///
/// This is the first step in the extension lifecycle.
///
/// It registers the extension with the Lambda Extensions API and
///
pub async fn register() {
    info!("Registering extension");
    let uri = make_uri("/register");

    let body = hyper::Body::from(r#"{"events":["INVOKE"]}"#);
    let mut request = hyper::Request::builder()
        .method("POST")
        .uri(uri)
        .body(body)
        .expect("[LRAP:Extension] Cannot create Lambda Extensions API request");

    // Set Lambda Extension Name header
    request.headers_mut().append(
        "Lambda-Extension-Name",
        find_extension_name().try_into().unwrap(),
    );

    let response = send_request(request)
        .await
        .expect("[LRAP:Extension] Cannot send Lambda Extensions API request to register");

    info!("Extension registered");

    let extension_identifier = response
        .headers()
        .get("lambda-extension-identifier")
        .expect("[LRAP:Extension] Lambda Extensions API response missing 'lambda-extension-identifier' header in Lambda Extensions API POST:register response")
        .to_str()
        .unwrap();

    LAMBDA_EXTENSION_IDENTIFIER
        .set(extension_identifier.to_owned())
        .expect("[LRAP:Extension] Error setting Lambda Extensions API request ID");
}


/// Get the next event from the Lambda Extensions API
///
/// This is the second step in the extension lifecycle.
///
/// It gets the next event from the Lambda Extensions API and
///
pub async fn get_next() {
    let uri = make_uri("/event/next");

    let mut request = hyper::Request::builder()
        .method("GET")
        .uri(uri)
        .body(Body::empty())
        .expect("[LRAP:Extension] Cannot create Lambda Extensions API request");

    request.headers_mut().insert(
        "Lambda-Extension-Identifier",
        extension_id().try_into().unwrap(),
    );

    // do not care about result because we get next payload through the Runtime API Proxy
    let _result = send_request(request).await;
}

