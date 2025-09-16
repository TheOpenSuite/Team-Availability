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
# Documentations used:
[Prettier](https://prettier.io/docs/configuration.html)
[ESlint](https://eslint.org/docs/latest/use/configure/)
[Jest](https://jestjs.io/docs/getting-started)
[Supertest](https://www.npmjs.com/package/supertest)
[npm1](https://docs.npmjs.com/cli/v11/commands)[npm2](https://docs.npmjs.com/packages-and-modules)
