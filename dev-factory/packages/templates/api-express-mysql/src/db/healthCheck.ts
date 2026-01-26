import { getPrisma } from "./prisma";

export async function checkDbHealth(): Promise<"up" | "down"> {
  const prisma = getPrisma();
  if (!prisma) return "down";
  try {
    await prisma.$queryRaw`SELECT 1`;
    return "up";
  } catch {
    return "down";
  }
}
