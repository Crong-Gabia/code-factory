import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus } from "@nestjs/common";
import type { Request, Response } from "express";

function getRequestId(req: Request): string | undefined {
  return (req as Request & { requestId?: string }).requestId;
}

@Catch()
export class ErrorHandlerFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const req = ctx.getRequest<Request>();
    const res = ctx.getResponse<Response>();

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const message = exception.message;
      res.status(status).json({
        error: {
          code: "http_error",
          message,
          trace_id: getRequestId(req),
        },
      });
      return;
    }

    const message = exception instanceof Error ? exception.message : "Internal Server Error";
    res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
      error: {
        code: "internal_error",
        message,
        trace_id: getRequestId(req),
      },
    });
  }
}
