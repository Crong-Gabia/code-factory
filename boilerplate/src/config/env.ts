import { config as loadDotenv } from "dotenv";

loadDotenv();

function requireEnv(name: string): string {
  const v = process.env[name];
  if (!v) {
    throw new Error(`Missing required env var: ${name}`);
  }
  return v;
}

export const env = {
  nodeEnv: process.env.NODE_ENV ?? "development",
  port: Number(process.env.PORT ?? "3000"),
  databaseUrl: requireEnv("DATABASE_URL"),
};
