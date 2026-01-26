import request from "supertest";
import { createApp } from "../src/app";

describe("DB health", () => {
  const hasDb = Boolean(process.env.DATABASE_URL);

  (hasDb ? it : it.skip)("reports db: up when DB is reachable", async () => {
    const app = createApp();
    const res = await request(app).get("/health");

    expect(res.status).toBe(200);
    expect(res.body).toEqual(
      expect.objectContaining({
        status: "up",
        db: "up",
      }),
    );
  });
});
