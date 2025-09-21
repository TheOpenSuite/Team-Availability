This project is based on [TeamavailTest](https://github.com/ge0rgeK/TeamavailTest), and will be split into 2 sections, original and edited. The original skips the lint, formatting and testing sections as the original package.json doesn't include them and the project itself doesn't include them. The edited will edit the package.json, in turn will edit server.js and create multiple files for lint, formatting and testing.

---
# Prerequisites
- Docker
- node.js & npm
- Jest (for edited version)

---
# Original
### Steps:
1. Clone repo
2. Create Dockerfile
3. Create docker-compose.yml
4. Create ci.sh
	1. Make executable: `chmod +x ci.sh`
5. Make the shell script executable
6. Run the script `./ci.sh`
7. Open the app at: `http://localhost:3000`

---
## Script behavior:
1. **Prerequisite Checks**: The script first checks if Docker and npm are installed. If either one is missing, it will print an error message and exit.
2. **Dependency Installation**: It checks for a *package.json* file, and If found, it runs *npm ci* to install project dependencies. This command ensures a clean build by using the *package-lock.json* file.
3. **Code Quality Checks**: The script runs some npm commands to validate the codebase. It checks for and runs the scripts, if they exist in *package.json*:
    1. **Linting**: Runs the lint script to check code for stylistic issues and errors.        
    2. **Formatting**: Runs the format script to automatically format the code.
    3. **Testing**: Runs the test script.
4. **Docker Build and compose**: It builds a Docker image from the project's Dockerfile and tags with "local". It then runs docker compose to start the service and displays the status to check for the running container.
---
# Edited
Same Dockerfile, docker-compose, and ci.sh

---
### `package.json`

```json
{
  "name": "version-1",
  "version": "1.0.0",
  "main": "script.js",
  "scripts": {
    "format": "prettier --write .",
    "lint": "eslint .",
    "test": "jest",
    "start": "node server.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "description": "",
  "dependencies": {
    "express": "^5.1.0"
  },
  "devDependencies": {
    "eslint": "9.35.0",
    "eslint-config-prettier": "9.1.0",
    "prettier": "3.3.3",
    "supertest": "^7.1.4"
  }
}
```

Made to add prettier, eslint, and jest

---
### `server.js`

```js
const express = require("express");
const fs = require("fs");
const path = require("path");
const bodyParser = require("body-parser");

const app = express();
const PORT = 3000;

// Middleware
app.use(bodyParser.json());

// Serve static frontend
app.use(express.static(path.join(__dirname, "public")));

// Serve input JSON files
app.use("/input", express.static(path.join(__dirname, "input")));

// Serve output folder (for history.json)
app.use("/output", express.static(path.join(__dirname, "output")));

// API to save history data
app.post("/save-history", (req, res) => {
  const historyPath = path.join(__dirname, "output", "history.json");
  const json = JSON.stringify(req.body, null, 2);

  fs.writeFile(historyPath, json, "utf8", (err) => {
    if (err) {
      console.error("Error saving history.json:", err);
      res.status(500).send("Failed to save history.json");
    } else {
      console.log("History successfully saved.");
      res.status(200).send("Saved");
    }
  });
});

// A basic route for testing
app.get("/", (req, res) => {
  res.send("Hello, World!");
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
  });
}

module.exports = app;
```

Added a simple route for testing purposes.

---
### `eslint.config.mjs`

```js
import globals from "globals";
import pluginJs from "@eslint/js";
import prettierConfig from "eslint-config-prettier";

export default [
  {
    files: ["**/*.js"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      globals: {
        ...globals.node,
        ...globals.browser,
        ...globals.jest,
      },
    },
  },
  pluginJs.configs.recommended,
  prettierConfig,
];
```

config file for lint and formatting.

---
### `server.test.js`

```js
const request = require("supertest");
const app = require("./server");

describe("API Endpoints", () => {
  it("should respond with the homepage HTML", async () => {
    const res = await request(app).get("/");
    expect(res.statusCode).toEqual(200);
    expect(res.text).toContain("<!doctype html>");
    expect(res.text).toContain("<title>Team Availability</title>");
  });
});
```

The basic testing file.

---
### Steps:
1. Clone repo
2. Create Dockerfile, docker-compose.yml, and ci.sh
3. Create eslint.config.mjs, and server.test.js
4. Change package.json and server.js
5. Make the shell script executable
6. Run the script `./ci.sh`
7. Open the app at: `http://localhost:3000`

*Manual installation of certain plugins if needed:*
- *sudo apt install jest*
- *npm install supertest --save-dev*
- *npm install --save-dev eslint prettier*
---
# Screenshots

Example shell run:

<img width="588" height="979" alt="Pasted image 20250917022040" src="https://github.com/user-attachments/assets/1f607295-d24d-4f82-bf19-1057c9b1da50" />

Website running:

<img width="968" height="579" alt="Pasted image 20250917022121" src="https://github.com/user-attachments/assets/0df12366-6af4-42a6-91de-720df373d098" />

---
# Jenkins CI/CD Pipeline

To automate the project's build, linting, formatting, and testing processes, a Jenkins CI/CD pipeline was set up. This pipeline integrates with GitHub to automatically trigger a build whenever changes are pushed to the repository.

## Steps for Jenkins Configuration:

1.  **Start Jenkins via Docker:** The Jenkins server was launched using Docker with the command:
```bash
sudo docker run -d -p 8080:8080 -p 50000:50000 \
-v jenkins_home:/var/jenkins_home \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $(which docker):/usr/bin/docker jenkins/jenkins:lts-jdk17
```
This command maps the necessary ports, persists the Jenkins data in a Docker volume (*jenkins_home*), and mounts the host's Docker socket to allow Jenkins to run Docker commands.

2.  **Access and Initial Setup:** I accessed Jenkins via `http://localhost:8080`, followed the initial setup wizard to install the needed plugins (nodejs, docker).

3.  **Create a New Pipeline:** I created a new pipeline job, configured it to connect to the GitHub repository, and added credentials (a GitHub token) to securely access the repository.

4.  **Configure the Pipeline Script:** The pipeline was set to use a *Jenkinsfile*. The pipeline's build step was configured to handle all the project's build logic, including dependency installation, linting, formatting, testing, and Docker operations.

5.  **Run the Build:** Upon running the pipeline, Jenkins cloned the repository and executed on the host machine. It ran all the defined stages: prerequisite checks, npm dependency installation, linting, formatting, testing, and the Docker build and compose process. The web application became accessible at `http://localhost:3000`.

## Problems Encountered and Solutions:

1.  **Docker Permissions Issue (Jenkins Container):** Initially, the Jenkins container couldn't access the Docker daemon on the host, leading to permission errors. This was resolved by entering the Jenkins container as the root user and granting the necessary permissions to the Docker socket.
```bash
sudo docker exec -u 0 -it <CONTAINER_NUM> bash
chmod 666 /var/run/docker.sock
```
This command temporarily fixes the issue by allowing all users inside the container to interact with the Docker socket.

2.  **Docker Pull Permission Issue:** I faced another permission issue when the Jenkins pipeline tried to pull a Docker image. The credentials or configuration inside the container were preventing the pull. I resolved this by accessing the container and removing the *config.json* file, which seemed to be causing the issue.
```bash
sudo docker exec -it <CONTAINER_NUM> bash
cd /var/jenkins_home/.docker
rm config.json
```
Afterward, I restarted the Jenkins container to apply the changes.

3.  **Node.js Versioning Issue:** The pipeline's npm commands failed due to an outdated Node.js version detected within the Jenkins environment. The npm dependencies, particularly for testing, required a newer version of Node.js. This was fixed by upgrading the Node.js installation within Jenkins's global tool configuration from `20.0.0` to `20.9.0`. This ensured that the *npm ci* and other scripts ran correctly.

---
# The Terraform Workflow

Using Terraform is a straightforward, three-step process that allows you to manage infrastructure as code. This approach ensures your infrastructure is reproducible and version-controlled. 

---
### Steps to run:
1. terraform init
2. terraform plan
3. terraform apply

The *main.tf* file I created defines the desired state of my infrastructure. When I run *terraform apply*, Terraform works to make the actual infrastructure match that desired state, creating a *local_file* and a *random_pet* resource.
### Explanation of the Terraform Files

* **`main.tf`**: This file contains the core of your configuration, the resources needed to create. In this case, it defines a *random_pet* resource to generate a unique name and a *local_file* resource to create a text file on the local machine, simulating a configuration file for a server.
* **`providers.tf`**: This file is used to declare and configure the providers that Terraform needs to use. It tells Terraform which providers to download and their required versions, keeping the resource definitions clean.
* **`output.tf`**: This file defines the outputs of the configuration. In this case, it outputs the generated server name and the content of the *local_file*, which are useful for verification and further automation.

---
# Documentations used:
[Prettier](https://prettier.io/docs/configuration.html)

[ESlint](https://eslint.org/docs/latest/use/configure/)

[Jest](https://jestjs.io/docs/getting-started)

[Supertest](https://www.npmjs.com/package/supertest)

[npm1](https://docs.npmjs.com/cli/v11/commands) [npm2](https://docs.npmjs.com/packages-and-modules)

[HashiCorp local](https://registry.terraform.io/providers/hashicorp/local/latest) / [GitHub](https://github.com/hashicorp/terraform-provider-local)

[HashiCorp random](registry.terraform.io/providers/hashicorp/random/latest/docs) / [GitHub](https://github.com/hashicorp/terraform-provider-random)
