use hyper::{Body, Request, Response, Server, Method, StatusCode};
use hyper::service::{make_service_fn, service_fn};
use jsonwebtoken::{encode, EncodingKey, Header};
use serde::{Serialize};
use std::convert::Infallible;
use log::info;
mod env;
mod extension;

#[derive(Serialize)]
struct Claims {
    sub: String,
    exp: usize,
}

#[derive(Serialize)]
struct TokenResponse {
    token: String,
    expires_at: usize,
    user_id: String,
    message: String,
}

pub const EXTENSION_NAME: &str = "rust-demo-lambda-extension";
pub static LAMBDA_RUNTIME_API_VERSION: &str = "2018-06-01";

/// Handle the request
///
/// This is the main function that handles the request.
///
/// It handles the request and returns the response.
///
async fn handle_request(req: Request<Body>) -> Result<Response<Body>, Infallible> {
    match (req.method(), req.uri().path()) {
        (&Method::GET, "/my-token") => {
            let claims = Claims {
                sub: "user123".to_string(),
                exp: 2000000000, // timestamp
            };

            let secret = std::env::var("JWT_SECRET").unwrap_or_else(|_| "super_secret".to_string());

            let token = encode(&Header::default(), &claims, &EncodingKey::from_secret(secret.as_ref())).unwrap();

            let response = TokenResponse {
                token,
                expires_at: claims.exp,
                user_id: claims.sub.clone(),
                message: "JWT token generated successfully".to_string(),
            };

            let json_response = serde_json::to_string(&response).unwrap();

            Ok(Response::builder()
                .status(StatusCode::OK)
                .header("Content-Type", "application/json")
                .body(Body::from(json_response))
                .unwrap())
        }
        _ => {
            let error_response = serde_json::json!({
                "error": "Endpoint not found",
                "message": "Use /token to get a JWT",
                "status": 404
            });

            Ok(Response::builder()
                .status(StatusCode::NOT_FOUND)
                .header("Content-Type", "application/json")
                .body(Body::from(error_response.to_string()))
                .unwrap())
        }
    }
}

#[tokio::main]
async fn main() {
    env_logger::init();

   

    let addr = ([127, 0, 0, 1], 8000).into(); // HTTP local

    let make_svc = make_service_fn(|_conn| async {
        Ok::<_, Infallible>(service_fn(handle_request))
    });

    let server = Server::bind(&addr).serve(make_svc);

    info!("Extension HTTP server running on http://{}", addr);

     tokio::spawn(async {
        extension::register().await;

        loop {
            // Lambda Extension API requires we wait for next extension event
            extension::get_next().await;
        }
    });

    if let Err(e) = server.await {
        eprintln!("server error: {}", e);
    }
}





 
