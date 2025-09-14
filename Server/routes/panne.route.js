import express from 'express';
import { 
  getAllPannes, 
  getPanneById, 
  createPanne, 
  updatePanne, 
  deletePanne, 
  searchPannes 
} from '../controllers/panne.Controller.js';

const router = express.Router();

router.get('/', getAllPannes);
router.get('/:id', getPanneById);
router.post('/', createPanne);
router.put('/:id', updatePanne);
router.delete('/:id', deletePanne);
router.get('/search/term', searchPannes);

export default function panneRoute(app) {
  app.use('/pannes', router);
}