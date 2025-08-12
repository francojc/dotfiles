class CopilotTransformer {
  name = "copilot";

  transformRequestIn(request) {
    // Return both the request body and config with headers
    return {
      body: request,
      config: {
        headers: {
          'Editor-Version': 'vscode/1.89.0'
        }
      }
    };
  }

  async transformResponseOut(response) {
    // No response transformation needed for header injection
    return response;
  }
}

module.exports = CopilotTransformer;
