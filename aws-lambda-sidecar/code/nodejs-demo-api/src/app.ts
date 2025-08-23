import { Hono } from 'hono';
import { handle } from 'hono/aws-lambda';

const app = new Hono();
const TOKEN_URL = 'http://localhost:8000/my-token';

app.get('/', (c) => c.json({ message: 'Hello Hono!' }));
app.get('/get-auth-token', async (c) => {
    const response = await fetch(TOKEN_URL);
    const data = await response.text();
    return c.text(data);
});

export const handler = handle(app);
