import { Controller, Get } from "@nestjs/common";
import { checkDbHealth } from "../../db/healthCheck";

@Controller()
export class HealthController {
  @Get("/health")
  async health() {
    const db = await checkDbHealth();
    return { status: "up", db };
  }
}
