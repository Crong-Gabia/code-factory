import type { NextFunction, Request, Response } from "express";

export interface UserContext {
  id?: string;
  email?: string;
  roles: string[];
}

export function userContext(req: Request, _res: Response, next: NextFunction): void {
  const id = req.header("x-user-id")?.trim();
  const email = req.header("x-user-email")?.trim();
  const rolesHeader = req.header("x-user-roles") ?? "";
  const roles = rolesHeader
    .split(",")
    .map((r) => r.trim())
    .filter(Boolean);

  (req as Request & { user?: UserContext }).user = { id, email, roles };
  next();
}
