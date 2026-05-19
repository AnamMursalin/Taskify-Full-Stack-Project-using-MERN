import cookieParser from "cookie-parser";
import cors from "cors";
import dotenv from "dotenv";
import express from "express";
import morgan from "morgan";
import { errorHandler, routeNotFound } from "./middleware/errorMiddleware.js";
import routes from "./routes/index.js";
import dbConnection from "./utils/connectDB.js";

dotenv.config();

dbConnection();

const port = process.env.PORT || 5000;

const app = express();  

app.use(
  cors({
    origin: process.env.NODE_ENV === "production" ? "*" : ["http://localhost:3000", "http://localhost:3001","https://teamtaskify.netlify.app"],
    methods: ["GET", "POST", "DELETE", "PUT"],
    credentials: true,
  })
);
// Backend health endpoint for Azure verification
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: "UP", 
    message: "Backend health endpoint returns HTTP 200" 
  });
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(cookieParser());

app.use(morgan("dev"));
app.use("/api", routes);

app.use(routeNotFound);
app.use(errorHandler);

app.listen(port, () => console.log(`Server listening on ${port}`));

