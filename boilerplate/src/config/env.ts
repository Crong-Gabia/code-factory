import { config as loadDotenv } from "dotenv";

loadDotenv();

function optionalEnv(name: string): string | undefined {
  const v = process.env[name];
  if (!v) return undefined;
  return v;
}

export const env = {
  nodeEnv: process.env.NODE_ENV ?? "development",
  port: Number(process.env.PORT ?? "3000"),
  databaseUrl: optionalEnv("DATABASE_URL"),
};
