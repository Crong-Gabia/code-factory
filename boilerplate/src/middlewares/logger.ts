import type { NextFunction, Request, Response } from "express";

function getRequestId(req: Request): string | undefined {
  return (req as Request & { requestId?: string }).requestId;
}

export function logger(req: Request, res: Response, next: NextFunction): void {
  const startedAt = Date.now();

  res.on("finish", () => {
    const ms = Date.now() - startedAt;
    const payload = {
      level: "info",
      msg: "request",
      method: req.method,
      path: req.originalUrl,
      status: res.statusCode,
      durationMs: ms,
      trace_id: getRequestId(req),
    };
    // eslint-disable-next-line no-console
    console.log(JSON.stringify(payload));
  });

  next();
}
