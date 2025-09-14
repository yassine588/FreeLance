import express from 'express';
import { 
  getAllPermis, 
  getPermisById, 
  createPermis, 
  updatePermis, 
  deletePermis, 
  searchPermis 
} from '../controllers/permis.Controller.js';

const router = express.Router();

router.get('/', getAllPermis);
router.get('/:id', getPermisById);
router.post('/', createPermis);
router.put('/:id', updatePermis);
router.delete('/:id', deletePermis);
router.get('/search', searchPermis);

export default function permisRoute(app) {
  app.use('/permis', router);
}