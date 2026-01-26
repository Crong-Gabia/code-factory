import "reflect-metadata";
import { NestFactory } from "@nestjs/core";
import express from "express";
import { AppModule } from "./app.module";
import { env } from "./config/env";
import { ErrorHandlerFilter } from "./middlewares/errorHandler";
import { logger } from "./middlewares/logger";
import { requestId } from "./middlewares/requestId";
import { userContext } from "./middlewares/userContext";

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: true });

  app.use(express.json({ limit: "1mb" }));
  app.use(requestId);
  app.use(logger);
  app.use(userContext);
  app.useGlobalFilters(new ErrorHandlerFilter());

  await app.listen(env.port);
}

bootstrap().catch((err) => {
  // eslint-disable-next-line no-console
  console.error(err);
  process.exit(1);
});
