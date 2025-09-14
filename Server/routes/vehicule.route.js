import express from 'express';
import { 
  getAllVehicules, 
  getVehiculeById, 
  createVehicule, 
  updateVehicule, 
  deleteVehicule, 
  filterVehicules, 
  getVehiculesByChauffeur, 
  getAvailableVehicules 
} from '../controllers/vehiculeController.js';

const router = express.Router();

// Specific routes first
router.get('/', getAllVehicules);
router.get('/chauffeur/:chauffeurId', getVehiculesByChauffeur);
router.get('/available/:date', getAvailableVehicules);
router.post('/filter', filterVehicules);

// Generic routes last
router.get('/:id', getVehiculeById); 
router.post('/', createVehicule);
router.put('/id/:id', updateVehicule);   
router.delete('/id/:id', deleteVehicule); 

export default function vehiculeRoute(app) {
  app.use('/vehicules', router);
}