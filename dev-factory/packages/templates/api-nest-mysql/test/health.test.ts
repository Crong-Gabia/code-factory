import { Test } from "@nestjs/testing";
import request from "supertest";
import { AppModule } from "../src/app.module";

describe("GET /health", () => {
  it("returns 200 with status+db", async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    const app = moduleRef.createNestApplication();
    await app.init();

    const res = await request(app.getHttpServer()).get("/health");
    expect(res.status).toBe(200);
    expect(res.body).toEqual(
      expect.objectContaining({
        status: "up",
        db: expect.any(String),
      }),
    );

    await app.close();
  });
});
