import { PrismaClient } from "@prisma/client";

let client: PrismaClient | undefined;

export function getPrisma(): PrismaClient | undefined {
  if (!process.env.DATABASE_URL) return undefined;
  if (!client) client = new PrismaClient();
  return client;
}
