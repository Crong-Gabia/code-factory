FROM node:20-bookworm-slim

WORKDIR /app

ARG CA_CERT_PEM_B64=

# Ensure Node respects system+custom CAs in corp networks.
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    default-mysql-client \
    bash \
  && rm -rf /var/lib/apt/lists/*

# Corporate CA support for Prisma engine downloads during build.
RUN if [ -n "$CA_CERT_PEM_B64" ]; then \
    echo "$CA_CERT_PEM_B64" | base64 -d >/usr/local/share/ca-certificates/corp.crt && \
    update-ca-certificates >/dev/null; \
  fi

COPY package.json package-lock.json* ./

RUN npm install

COPY . .

RUN npm run prisma:generate

EXPOSE 3000

CMD ["bash", "-lc", "./scripts/wait-mysql.sh && npm run prisma:migrate && npm run dev"]
