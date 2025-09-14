import express from 'express';
import {
  getAllViolations,
  getViolationById,
  createViolation,
  updateViolation,
  deleteViolation,
  searchViolations
} from '../controllers/violationController.js';

const router = express.Router();

router.get('/', getAllViolations);
router.get('/:id', getViolationById);
router.post('/', createViolation);
router.put('/:id', updateViolation);
router.delete('/:id', deleteViolation);
router.get('/search/term', searchViolations);

// Change this export to match the others
export default function violationRoute(app) {
  app.use('/violations', router);
}