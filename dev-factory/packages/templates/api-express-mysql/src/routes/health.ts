import { Router } from "express";
import { checkDbHealth } from "../db/healthCheck";

export const healthRouter = Router();

healthRouter.get("/health", (_req, res) => {
  void checkDbHealth().then((db) => {
    res.status(200).json({ status: "up", db });
  });
});
