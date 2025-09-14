import mongoose from "mongoose";

const assignmentSchema = new mongoose.Schema({
  address: { type: String, required: true },
  driverId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  status: { type: String, enum: ["Pending", "In Progress", "Completed"], default: "Pending" },
  time: { type: Date , required: true },
}, { timestamps: true });

const Assignment = mongoose.model("Assignment", assignmentSchema);

export default Assignment;
