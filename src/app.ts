
import express from 'express';
import http from 'http';
import bodyParser from 'body-parser';
import cors from 'cors';
import router from './infrastructure/routes/beverageRoutes'
import helmet from 'helmet'
import dotenv from "dotenv"

dotenv.config();
const app = express();

app.use(cors({
    credentials: true
}));

app.use(helmet());
app.use(bodyParser.json());

// Health check endpoint (responds with HTTP 200)
app.get('/health', (req, res) => {
    res.status(200).send('OK');
});

const server = http.createServer(app);

const PORT = 3000;
server.listen(PORT, () => console.log(`Server is running on http://localhost:${PORT}/`));

app.use('/', router());