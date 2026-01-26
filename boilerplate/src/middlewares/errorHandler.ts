import type { NextFunction, Request, Response } from "express";

function getRequestId(req: Request): string | undefined {
  return (req as Request & { requestId?: string }).requestId;
}

export function errorHandler(err: unknown, req: Request, res: Response, _next: NextFunction): void {
  const message = err instanceof Error ? err.message : "Internal Server Error";
  res.status(500).json({
    error: {
      code: "internal_error",
      message,
      trace_id: getRequestId(req),
    },
  });
}
