import { createServer } from "node:http";
import { env } from "./config/env";
import { createApp } from "./app";

const app = createApp();
const server = createServer(app);

server.listen(env.port, () => {
  // eslint-disable-next-line no-console
  console.log(`listening on :${env.port}`);
});
