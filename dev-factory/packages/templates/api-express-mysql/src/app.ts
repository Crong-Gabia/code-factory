import express from "express";
import { healthRouter } from "./routes/health";
import { meRouter } from "./routes/me";
import { errorHandler } from "./middlewares/errorHandler";
import { logger } from "./middlewares/logger";
import { requestId } from "./middlewares/requestId";
import { userContext } from "./middlewares/userContext";

export function createApp() {
  const app = express();

  app.use(express.json({ limit: "1mb" }));
  app.use(requestId);
  app.use(logger);
  app.use(userContext);

  app.use(healthRouter);
  app.use(meRouter);

  app.use((_req, res) => {
    res.status(404).json({
      error: {
        code: "not_found",
        message: "Not Found",
        trace_id: undefined,
      },
    });
  });

  app.use(errorHandler);
  return app;
}
