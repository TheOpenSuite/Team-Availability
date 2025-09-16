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
