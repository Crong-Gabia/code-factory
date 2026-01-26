import { Router } from "express";
import { getUser } from "../utils/http";

export const meRouter = Router();

meRouter.get("/me", (req, res) => {
  res.status(200).json({ user: getUser(req) ?? null });
});
