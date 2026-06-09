import { useState, useEffect } from "react";
import "./App.css";

function App() {
  const [num1, setNum1] = useState("");
  const [num2, setNum2] = useState("");
  const [history, setHistory] = useState([]); // Store history
  const [loading, setLoading] = useState(false);

  const BACKEND_URL = import.meta.env.VITE_API_URL || "http://localhost:5000";

  // Fetch history when the app loads
  useEffect(() => {
    fetchHistory();
  }, []);

  const fetchHistory = async () => {
    try {
      const res = await fetch(`${BACKEND_URL}/api/history`);
      const data = await res.json();
      setHistory(data);
    } catch (err) {
      console.error("Failed to fetch history:", err);
    }
  };

  const handleCalculate = async (operation) => {
    setLoading(true);
    try {
      const response = await fetch(`${BACKEND_URL}/api/calculate`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ num1, num2, operation }),
      });

      if (response.ok) {
        const data = await response.json();
        // Add new result to the top of the list immediately
        setHistory([data, ...history]);
        setNum1("");
        setNum2("");
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div
      style={{
        padding: "2rem",
        maxWidth: "600px",
        margin: "0 auto",
        fontFamily: "Arial",
      }}
    >
      <h1>Full-Stack Calculator</h1>

      {/* Inputs */}
      <div style={{ display: "flex", gap: "10px", marginBottom: "20px" }}>
        <input
          type="number"
          value={num1}
          onChange={(e) => setNum1(e.target.value)}
          placeholder="First Number"
          style={{ padding: "10px", flex: 1 }}
        />
        <input
          type="number"
          value={num2}
          onChange={(e) => setNum2(e.target.value)}
          placeholder="Second Number"
          style={{ padding: "10px", flex: 1 }}
        />
      </div>

      {/* Buttons */}
      <div style={{ display: "flex", gap: "10px", marginBottom: "20px" }}>
        <button onClick={() => handleCalculate("add")} disabled={loading}>
          +
        </button>
        <button onClick={() => handleCalculate("subtract")} disabled={loading}>
          -
        </button>
        <button onClick={() => handleCalculate("multiply")} disabled={loading}>
          ×
        </button>
        <button onClick={() => handleCalculate("divide")} disabled={loading}>
          ÷
        </button>
      </div>

      <hr />

      {/* History Section */}
      <h3>Calculation History (From DB)</h3>
      <ul style={{ listStyle: "none", padding: 0 }}>
        {history.map((item) => (
          <li
            key={item._id}
            style={{
              background: "#f4f4f4",
              margin: "5px 0",
              padding: "10px",
              borderRadius: "5px",
            }}
          >
            {item.num1} <strong>{item.operation}</strong> {item.num2} ={" "}
            <strong>{item.result}</strong>
            <span style={{ float: "right", fontSize: "12px", color: "#666" }}>
              {new Date(item.timestamp).toLocaleTimeString()}
            </span>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
