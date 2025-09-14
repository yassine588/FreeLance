import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import bodyParser from "body-parser";
import yahooFinance from "yahoo-finance2";
import dotenv from "dotenv";
import bcrypt from "bcryptjs";


import panneRoute from './routes/panne.route.js';
import reparationRoute from './routes/reparation.route.js';
import vehiculeRoute from './routes/vehicule.route.js';
import violationRouter from './routes/violation.route.js';
import permisRoute from './routes/permis.route.js';
import assignmentRoutes from './routes/assignments.js';  

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI || "mongodb://127.0.0.1:27017/etapDB";
const admin = {password: process.env.ADMIN_PASSWORD, email: process.env.ADMIN_EMAIL}; 

app.use(cors());
app.use(bodyParser.json());

app.use('/assignments', assignmentRoutes);  // ← Add this line here
panneRoute(app);
reparationRoute(app);
vehiculeRoute(app);
app.use('/violations', violationRouter);
permisRoute(app);

mongoose.connect(MONGODB_URI)
  .then(() => console.log("✅ Connected to MongoDB"))
  .catch(err => console.error("❌ MongoDB connection error:", err));

// Tickers
const tickers = {
  brent: "BZ=F",
  naturalGas: "NG=F",
  gasoline: "RB=F",
};

const userSchema = new mongoose.Schema({
  name: String,
  post: String,
  email: { type: String, unique: true },
  password: String,
  isApproved: { type: Boolean, default: false },
  status: String,
  createdAt: { type: Date, default: Date.now }
});

const User = mongoose.model("User", userSchema);
app.get("/chauffeurs", async (req, res) => {
  try {
    const chauffeurs = await User.find({ 
      post: 'chauffeur',
      isApproved: true
    });
    res.json({ success: true, chauffeurs: chauffeurs });
  } catch (error) {
    console.error("Error fetching chauffeurs:", error);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});
app.get("/count-chauffeurs", async (req, res) => {
  try {
    const count = await User.countDocuments({ 
      post: 'chauffeur', 
      isApproved: true 
    });
    res.json({ success: true, count: count });
  } catch (error) {
    console.error("Error counting chauffeurs:", error);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});
app.put("/chauffeurs/status", async (req, res) => {
  try {
    const { chauffeurId, status } = req.body;
    
    const user = await User.findByIdAndUpdate(
      chauffeurId,
      { status: status },
      { new: true }
    );
    
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    
    res.json({ success: true, message: "Status updated successfully" });
  } catch (error) {
    console.error("Error updating status:", error);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});


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

// Get pending users for admin approval
app.get("/admin/pending-users", async (req, res) => {
  try {
    const pendingUsers = await User.find({ isApproved: false });
    res.json({ success: true, users: pendingUsers });
  } catch (error) {
    console.error("Error fetching pending users:", error);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

// Approve user endpoint
app.post("/admin/approve-user/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findByIdAndUpdate(
      userId,
      { isApproved: true },
      { new: true }
    );
    
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    
    res.json({ success: true, message: "User approved successfully" });
  } catch (error) {
    console.error("Error approving user:", error);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

// Reject user endpoint
app.delete("/admin/reject-user/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findByIdAndDelete(userId);
    
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    
    res.json({ success: true, message: "User rejected successfully" });
  } catch (error) {
    console.error("Error rejecting user:", error);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

// Fixed account access endpoint
app.get("/accountAccess/:email", async (req, res) => {
  try {
    const { email } = req.params;
    
    if (!email) {
      return res.status(400).json({ 
        error: "Email is required" 
      });
    }
    
    const user = await User.findOne({ email });
    
    if (!user) {
      return res.status(404).json({ 
        access: false,
        message: "User not found" 
      });
    }
    
    if (user.isApproved) {
      res.json({ 
        access: true,
        message: "Account is approved" 
      });
    } else {
      res.json({ 
        access: false,
        message: "Account pending admin approval" 
      });
    }
  } catch (error) {
    console.error("Account access check error:", error);
    res.status(500).json({ 
      error: "Failed to check account access" 
    });
  }
});

// Login endpoint
app.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ 
        success: false, 
        message: "Email and password are required" 
      });
    }
    
    // Find user by email
    const user = await User.findOne({ email });
    
    if (!user) {
      return res.status(401).json({ 
        success: false, 
        message: "Invalid credentials" 
      });
    }
    
    // Check if account is approved
    if (!user.isApproved) {
      return res.status(401).json({ 
        success: false, 
        message: "Account pending admin approval" 
      });
    }
    
    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    
    if (!isPasswordValid) {
      return res.status(401).json({ 
        success: false, 
        message: "Invalid credentials" 
      });
    }
    
    // Successful login
    res.json({ 
      success: true, 
      message: "Login successful",
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        post: user.post
      }
    });
    
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ 
      success: false, 
      message: "Internal server error" 
    });
  }
});

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
    const newUser = new User({ 
      name, 
      post, 
      email, 
      password: hashedPassword,
      isApproved: false // Set to false by default
    });
    await newUser.save();
    res.status(201).json({ 
      success: true, 
      message: "User created successfully. Waiting for admin approval." 
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