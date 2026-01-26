import request from "supertest";
import { createApp } from "../src/app";

function isRecord(v: unknown): v is Record<string, unknown> {
  return typeof v === "object" && v !== null;
}

describe("GET /health", () => {
  it("returns 200 with status+db", async () => {
    const app = createApp();
    const res = await request(app).get("/health");

    expect(res.status).toBe(200);

    const body: unknown = res.body;
    expect(isRecord(body)).toBe(true);
    if (!isRecord(body)) return;

    expect(body.status).toBe("up");
    expect(typeof body.db).toBe("string");
  });
});
