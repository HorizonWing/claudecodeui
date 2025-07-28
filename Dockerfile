FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANTHROPIC_AUTH_TOKEN=sk-134

RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs

RUN npm install -g @anthropic-ai/claude-code

RUN npm config set registry https://registry.npmmirror.com && \
    npm config set fetch-retry-mintimeout 20000 && \
    npm config set fetch-retry-maxtimeout 120000 && \
    npm config set fetch-retries 3

RUN mkdir -p ~/.claude && echo '{\
  "env": {\
    "ANTHROPIC_AUTH_TOKEN": "'$ANTHROPIC_AUTH_TOKEN'",\
    "ANTHROPIC_BASE_URL": "https://api.aicodeditor.com",\
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "32000",\
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": 1\
  },\
  "permissions": {\
    "allow": [],\
    "deny": []\
  }\
}' > ~/.claude/settings.json

WORKDIR /code

EXPOSE 3008 3009

COPY . .

RUN npm install

RUN npm run build

CMD ["npm", "run", "server"]