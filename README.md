# Vizallas - Hungarian Water Level Monitoring App

Welcome to Vizallas, an app that provides real-time water level information for Hungarian lakes and rivers. This repository contains both the mobile app and the backend service, which work together to offer an intuitive and reliable experience for users.

## Features

- View real-time water level data for Hungarian lakes and rivers.
- Data is sourced from the local government portals, ensuring accuracy and reliability (https://www.vizugy.hu).
- Mobile app provides an intuitive and user-friendly interface to access the information.
- Backend service collects and processes data using Python scraper scripts.
- Data is served to the mobile app through a GraphQL API, written in Rust.
- Deployed on Google Cloud Platform (GCP) for scalability and performance.

## Getting Started

To get started with Vizallas, follow the steps below:

### Prerequisites

- SwiftUI framework (for the mobile app development).
- Rust and Cargo (for the backend GraphQL server).
- Python 3.x (for the scraper scripts).
- Google Cloud Platform account (for deploying the backend service).

### Installation

1. Clone this GitHub repository to your local machine:

   ```
   git clone https://github.com/your-username/vizallas.git
   ```

2. Set up the mobile app:

   - Open the `mobile-app` directory.
   - Install the necessary dependencies by running:

     ```
     # Instructions to install dependencies for SwiftUI-based app
     ```

   - Connect your device or simulator.
   - Launch the app using:

     ```
     # Instructions to run the SwiftUI app
     ```

3. Set up the backend service:

   - Open the `backend-service` directory.
   - Build the Rust project by running:

     ```
     cargo build
     ```

   - Start the backend service using:

     ```
     cargo run
     ```

   - The GraphQL server should now be running on `http://localhost:8000`.

### Configuration

1. Create a configuration file for the scraper scripts:

   - Copy the `backend-service/config.sample.ini` file to `backend-service/config.ini`.
   - Fill in the necessary details in `config.ini`, such as the URLs and selectors for the scraper scripts.

2. Set up Google Cloud Platform:

   - Create a new project on GCP.
   - Create a service user with Cloud SQL and Cloud App APIs

3. Configure the GraphQL server:

   - Update the necessary configuration parameters in `backend-service/.env` file, such as the GCP project ID, postgres credentials, etc.

### Deployment

- Deploy the mobile app to your preferred mobile platform (well, only iOS is supported) using the appropriate SwiftUI deployment process.
- Deploy the backend service using the Pulumi deployment scripts provided in the `deployment` directory.

## Contributing

We welcome contributions to Vizallas! If you have any suggestions, bug reports, or feature requests, please open an issue on this repository. For code contributions, please follow the standard GitHub workflow by forking the repository and creating a pull request.

Before making a contribution, please read our [Contributing Guidelines](CONTRIBUTING.md) for more information.

## License

Vizallas is open-source and released under the [MIT License](LICENSE). Feel free to modify, distribute, and use the codebase according to the terms of the license.

## Acknowledgements

We would like to thank the local water government portal for providing the water level data and the community for their valuable feedback and contributions.

Special thanks to the following technologies used in this project:

- SwiftUI: [https://developer.apple]

