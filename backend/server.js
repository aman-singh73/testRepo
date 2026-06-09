require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// 1. Connect to MongoDB
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("✅ MongoDB Connected"))
  .catch((err) => console.error("❌ MongoDB Connection Error:", err));

// 2. Define Database Schema
const CalculationSchema = new mongoose.Schema({
  num1: Number,
  num2: Number,
  operation: String,
  result: Number,
  timestamp: { type: Date, default: Date.now },
});

const Calculation = mongoose.model("Calculation", CalculationSchema);

// 3. API Routes

// GET: Fetch last 10 calculations
app.get("/api/history", async (req, res) => {
  try {
    const history = await Calculation.find().sort({ timestamp: -1 }).limit(10);
    res.json(history);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch history" });
  }
});

// POST: Perform calculation and save to DB
app.post("/api/calculate", async (req, res) => {
  const { num1, num2, operation } = req.body;
  const n1 = parseFloat(num1);
  const n2 = parseFloat(num2);

  if (isNaN(n1) || isNaN(n2)) {
    return res.status(400).json({ error: "Invalid numbers" });
  }

  let result;
  switch (operation) {
    case "add":
      result = n1 + n2;
      break;
    case "subtract":
      result = n1 - n2;
      break;
    case "multiply":
      result = n1 * n2;
      break;
    case "divide":
      if (n2 === 0)
        return res.status(400).json({ error: "Cannot divide by zero" });
      result = n1 / n2;
      break;
    default:
      return res.status(400).json({ error: "Invalid operation" });
  }

  // Save to Database
  try {
    const newCalc = new Calculation({ num1: n1, num2: n2, operation, result });
    await newCalc.save();
    res.json(newCalc); // Return the saved object
  } catch (err) {
    res.status(500).json({ error: "Failed to save calculation" });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
