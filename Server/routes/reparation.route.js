import express from 'express';

import { 
  getAllReparations, 
  getReparationById, 
  createReparation, 
  updateReparation, 
  deleteReparation, 
  getReparationsByVehicule, 
  getReparationsByPanne 
} from '../controllers/reparationController.js';

const router = express.Router();

router.get('/', getAllReparations);
router.get('/:id', getReparationById);
router.post('/', createReparation);
router.put('/:id', updateReparation);
router.delete('/:id', deleteReparation);
router.get('/vehicule/:immatriculation', getReparationsByVehicule);
router.get('/panne/:panneId', getReparationsByPanne);

export default function reparationRoute(app) {
  app.use('/reparations', router);
}