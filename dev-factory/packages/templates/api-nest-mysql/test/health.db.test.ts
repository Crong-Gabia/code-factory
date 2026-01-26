import { Test } from "@nestjs/testing";
import request from "supertest";
import { AppModule } from "../src/app.module";

describe("DB health", () => {
  const hasDb = Boolean(process.env.DATABASE_URL);

  (hasDb ? it : it.skip)("reports db: up when DB is reachable", async () => {
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
        db: "up",
      }),
    );

    await app.close();
  });
});
