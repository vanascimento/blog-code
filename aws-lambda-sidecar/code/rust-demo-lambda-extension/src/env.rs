//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
//

//! Access the ENV for the Extension (and Proxy)
//!
//! Utilities and other helper functions for thread-safe access and lazy initializers
//!

use once_cell::sync::OnceCell;

/// Runtime API endpoint
static LAMBDA_RUNTIME_API: OnceCell<String> = OnceCell::new();

///Fetches the AWS_LAMBDA_RUNTIME_API environment variable
pub fn latch_runtime_env() {
    use std::env::var;

    let aws_lambda_runtime_api =
        match var("AWS_LAMBDA_RUNTIME_API") {
            Ok(v) => v,
            Err(_) => panic!("AWS_LAMBDA_RUNTIME_API not found"),
        };

    // Latch in the ORIGIN we should proxy to the application
    LAMBDA_RUNTIME_API.set(aws_lambda_runtime_api.clone())
        .expect("Expected that mutate_runtime_env() has not been called before, but AWS_LAMBDA_RUNTIME_API was already set");

    
}

/// Gets the original AWS_LAMBDA_RUNTIME_API.
pub fn sandbox_runtime_api() -> &'static str {
    match LAMBDA_RUNTIME_API.get() {
        Some(val) => val,
        None => {
            latch_runtime_env();
            LAMBDA_RUNTIME_API.get().expect(
                "Error in setting and mutating AWS_LAMBDA_RUNTIME_API environment variables.",
            )
        }
    }
}

