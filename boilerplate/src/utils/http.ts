import type { Request } from "express";

export function getUser(req: Request) {
  return (req as Request & { user?: unknown }).user;
}
