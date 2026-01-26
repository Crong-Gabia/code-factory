import { Controller, Get, Req } from "@nestjs/common";
import type { Request } from "express";
import { getUser } from "../../utils/http";

@Controller()
export class MeController {
  @Get("/me")
  me(@Req() req: Request) {
    return { user: getUser(req) ?? null };
  }
}
