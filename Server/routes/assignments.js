import express from "express";
import { addAssignment, getAssignments, getAssignmentsByDriver} from "../controllers/assignmentController.js";

const router = express.Router();

router.post("/", addAssignment);
router.get("/", getAssignments);
router.get("/driver/:driverId", getAssignmentsByDriver);
export default router;
