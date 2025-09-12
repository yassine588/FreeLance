import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import bodyParser from "body-parser";
import yahooFinance from "yahoo-finance2";
import dotenv from "dotenv";
import bcrypt from "bcryptjs";

// ES module route imports
import panneRoute from './config/routes/panne.route.js';
import reparationRoute from './config/routes/reparation.route.js';
import vehiculeRoute from './config/routes/vehicule.route.js';
import violationRoute from './config/routes/violation.route.js';
import permisRoute from './config/routes/permis.route.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI || "mongodb://127.0.0.1:27017/etapDB";
 const admin = {password:process.env.ADMIN_PASSWORD,email:process.env.ADMIN_EMAIL}; 

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Use route modules
panneRoute(app);
reparationRoute(app);
vehiculeRoute(app);
violationRoute(app);
permisRoute(app);

// Connect to MongoDB
mongoose.connect(MONGODB_URI)
  .then(() => console.log("✅ Connected to MongoDB"))
  .catch(err => console.error("❌ MongoDB connection error:", err));

// Tickers
const tickers = {
  brent: "BZ=F",
  naturalGas: "NG=F",
  gasoline: "RB=F",
};

// User Schema
const userSchema = new mongoose.Schema({
  name: String,
  post: String,
  email: { type: String, unique: true },
  password: String,
  createdAt: { type: Date, default: Date.now }
});

const User = mongoose.model("User", userSchema);

const priceSchema = new mongoose.Schema({
  commodity: String,
  price: Number,
  timestamp: { type: Date, default: Date.now }
});

const Price = mongoose.model("Price", priceSchema);

let historicalData = {
  brent: [],
  naturalGas: [],
  gasoline: []
};

// Signup endpoint
app.post("/signup", async (req, res) => {
  try {
    const { name, post, email, password } = req.body;
    if (!name || !email || !password || !post) {
      return res.status(400).json({ 
        success: false, 
        message: "Name, email, and password are required" 
      });
    }
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ 
        success: false, 
        message: "Email already exists" 
      });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({ name, post, email, password: hashedPassword });
    await newUser.save();
    res.status(201).json({ 
      success: true, 
      message: "User created successfully wait for admin approval" 
    });
  } catch (error) {
    console.error("Signup error:", error);
    res.status(500).json({ 
      success: false, 
      message: "Internal server error" 
    });
  }
});

// Check email endpoint
app.post("/checkEmail", async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ 
        error: "Email is required" 
      });
    }
    const user = await User.findOne({ email });
    res.json({ exists: !!user });
  } catch (err) {
    console.error("Check email error:", err);
    res.status(500).json({ 
      error: "Internal server error" 
    });
  }
});

// Prices endpoint
app.get("/prices", async (req, res) => {
  try {
    const results = {};
    for (const [key, symbol] of Object.entries(tickers)) {
      try {
        const quote = await yahooFinance.quote(symbol);
        const price = quote.regularMarketPrice;
        // Store historical data (keep last 100 entries)
        if (historicalData[key].length >= 100) {
          historicalData[key].shift();
        }
        historicalData[key].push({
          price,
          timestamp: new Date()
        });
        results[key] = {
          price,
          currency: quote.currency,
          time: quote.regularMarketTime,
          historical: historicalData[key]
        };
      } catch (error) {
        console.error(`Error fetching ${key}:`, error);
        // Return last known data if available
        if (historicalData[key].length > 0) {
          const lastPrice = historicalData[key][historicalData[key].length - 1];
          results[key] = {
            price: lastPrice.price,
            currency: "USD",
            time: lastPrice.timestamp,
            historical: historicalData[key],
            error: "Live data unavailable, showing cached data"
          };
        } else {
          results[key] = {
            error: `Failed to fetch data for ${key}`
          };
        }
      }
    }
    res.json(results);
  } catch (error) {
    console.error("Prices endpoint error:", error);
    res.status(500).json({ 
      error: "Failed to fetch data" 
    });
  }
});

// Historical data endpoint
app.get("/historical/:commodity", async (req, res) => {
  try {
    const { commodity } = req.params;
    if (!tickers[commodity]) {
      return res.status(404).json({ 
        error: "Commodity not found" 
      });
    }
    res.json(historicalData[commodity] || []);
  } catch (error) {
    console.error("Historical data error:", error);
    res.status(500).json({ 
      error: "Failed to fetch historical data" 
    });
  }
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({ 
    status: "OK", 
    timestamp: new Date().toISOString() 
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 HTTP Server running on http://localhost:${PORT}`);
});