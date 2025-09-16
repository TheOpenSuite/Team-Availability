This project is based on [TeamavailTest](https://github.com/ge0rgeK/TeamavailTest), and will be split into 2 sections, original and edited. The original skips the lint, formatting and testing sections as the original package.json doesn't include them and the project itself doesn't include them. The edited will edit the package.json, in turn will edit server.js and create multiple files for lint, formatting and testing.

---
# Prerequisites
- Docker
- node.js & npm
- Jest (for edited version)

---
# Original
### `Dockerfile`

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### `docker-compose.yml`

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: teamavail:latest
    ports:
      - "${APP_PORT:-3000}:3000"
    environment:
      - NODE_ENV=development
      - PORT=3000
    depends_on:
      - db
    volumes:
      - ./:/usr/src/app:cached
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/ || exit 1"]
      interval: 10s
      timeout: 3s
      retries: 3

  db:
    image: postgres:latest
    restart: unless-stopped
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: teamavail
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:

```

### `ci.sh`

```bash
#!/bin/bash
set -euo pipefail

IMAGE_NAME="teamavail:local"
COMPOSE_FILE="docker-compose.yml"
NPM_CMD="npm"

echo "### CI START"

# Checks
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Download Docker as Docker isn't installed" >&2
  exit 1
fi

if ! command -v "$NPM_CMD" >/dev/null 2>&1; then
  echo "ERROR: Install Node.js/npm as it isn't installed" >&2
  exit 1
fi

# Installing Dependencies
if [ -f package.json ]; then
  echo "### Installing Node.js dependencies"
  "$NPM_CMD" ci
else
  echo "No package.json found. Skipping npm steps."
  exit 0
fi

# Lint
echo "### Running lint"
if "$NPM_CMD" run -s lint &>/dev/null; then
  "$NPM_CMD" run lint
else
  echo "No script found, skipping this step"
fi

# Formatting
echo "### Running format"
if "$NPM_CMD" run -s format &>/dev/null; then
  "$NPM_CMD" run format
else
  echo "No script found, skipping this step"
fi

# Testing
echo "### Running tests"
if "$NPM_CMD" run -s test &>/dev/null; then
  "$NPM_CMD" run test
else
  echo "No script found, skipping this step"
fi

# Docker
echo "### Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" .

if [ -f "$COMPOSE_FILE" ]; then
  echo "### Starting with docker compose"
  docker compose -f "$COMPOSE_FILE" up -d --build
  echo "### Status:"
  docker ps --filter "ancestor=$IMAGE_NAME" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
else
  echo "No docker-compose.yml found. Built image is available as $IMAGE_NAME"
fi

echo "### CI COMPLETE"
```

Make executable:

```bash
chmod +x ci.sh
```

---
## Script behavior:
1. **Prerequisite Checks**: The script first checks if Docker and npm are installed. If either one is missing, it will print an error message and exit.
2. **Dependency Installation**: It checks for a *package.json* file, and If found, it runs *npm ci* to install project dependencies. This command ensures a clean build by using the *package-lock.json* file.
3. **Code Quality Checks**: The script runs some npm commands to validate the codebase. It checks for and runs the scripts, if they exist in *package.json*:
    1. **Linting**: Runs the lint script to check code for stylistic issues and errors.        
    2. **Formatting**: Runs the format script to automatically format the code.
    3. **Testing**: Runs the test script.
4. **Docker Build and compose**: It builds a Docker image from the project's Dockerfile and tags with "local". It then runs docker compose to start the service and displays the status to check for the running container.
### Steps:
1. Clone repo
2. Create Dockerfile
3. Create docker-compose.yml
4. Create ci.sh
5. Make the shell script executable
6. Run the script
7. Open the app at: `http://localhost:3000`
---
# Edited
### `Dockerfile`

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### `docker-compose.yml`

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: teamavail:latest
    ports:
      - "${APP_PORT:-3000}:3000"
    environment:
      - NODE_ENV=development
      - PORT=3000
    depends_on:
      - db
    volumes:
      - ./:/usr/src/app:cached
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/ || exit 1"]
      interval: 10s
      timeout: 3s
      retries: 3

  db:
    image: postgres:latest
    restart: unless-stopped
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: teamavail
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:

```

### `ci.sh`

```bash
#!/bin/bash
set -euo pipefail

IMAGE_NAME="teamavail:local"
COMPOSE_FILE="docker-compose.yml"
NPM_CMD="npm"

echo "### CI START"

# Checks
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Download Docker as Docker isn't installed" >&2
  exit 1
fi

if ! command -v "$NPM_CMD" >/dev/null 2>&1; then
  echo "ERROR: Install Node.js/npm as it isn't installed" >&2
  exit 1
fi

# Installing Dependencies
if [ -f package.json ]; then
  echo "### Installing Node.js dependencies"
  "$NPM_CMD" ci
else
  echo "No package.json found. Skipping npm steps."
  exit 0
fi

# Lint
echo "### Running lint"
if "$NPM_CMD" run -s lint &>/dev/null; then
  "$NPM_CMD" run lint
else
  echo "No script found, skipping this step"
fi

# Formatting
echo "### Running format"
if "$NPM_CMD" run -s format &>/dev/null; then
  "$NPM_CMD" run format
else
  echo "No script found, skipping this step"
fi

# Testing
echo "### Running tests"
if "$NPM_CMD" run -s test &>/dev/null; then
  "$NPM_CMD" run test
else
  echo "No script found, skipping this step"
fi

# Docker
echo "### Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" .

if [ -f "$COMPOSE_FILE" ]; then
  echo "### Starting with docker compose"
  docker compose -f "$COMPOSE_FILE" up -d --build
  echo "### Status:"
  docker ps --filter "ancestor=$IMAGE_NAME" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
else
  echo "No docker-compose.yml found. Built image is available as $IMAGE_NAME"
fi

echo "### CI COMPLETE"
```

Make executable:

```bash
chmod +x ci.sh
```

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
6. Run the script
7. Open the app at: `http://localhost:3000`
*Manual installation of certain plugins if needed:*
- *sudo apt install jest*
- *npm install supertest --save-dev*
- *npm install --save-dev eslint prettier*

---
# Documentations used:
[Prettier](https://prettier.io/docs/configuration.html)
[ESlint](https://eslint.org/docs/latest/use/configure/)
[Jest](https://jestjs.io/docs/getting-started)
[Supertest](https://www.npmjs.com/package/supertest)
[npm1](https://docs.npmjs.com/cli/v11/commands)[npm2](https://docs.npmjs.com/packages-and-modules)