import Assignment from '../models/Assignment.js';

export const addAssignment = async (req, res) => {
  try {
    const { address, driverId, status, time } = req.body;
    const assignment = new Assignment({ address, driverId, status, time });
    await assignment.save();
    res.status(201).json({ success: true, assignment });
  } catch (error) {
    console.error("Error adding assignment:", error);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
};

export const getAssignments = async (req, res) => {
  try {
    const assignments = await Assignment.find().populate("driverId", "nom prenom email");
    res.json({ success: true, assignments });
  } catch (error) {
    console.error("Error fetching assignments:", error);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
};

export const getAssignmentsByDriver = async (req, res) => {
  try {
    const { driverId } = req.params;
    const assignments = await Assignment.find({ driverId }).populate("driverId", "nom prenom email");
    res.json({ success: true, assignments });
  } catch (error) {
    console.error("Error fetching assignments by driver:", error);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
};