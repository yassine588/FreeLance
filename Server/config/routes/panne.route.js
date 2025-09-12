import express from 'express';
import panneController from '../controllers/panne.Controller.js';

const router = express.Router();

router.get('/', panneController.getAllPannes);
router.get('/:id', panneController.getPanneById);
router.post('/', panneController.createPanne);
router.put('/:id', panneController.updatePanne);
router.delete('/:id', panneController.deletePanne);
router.get('/search/term', panneController.searchPannes);

export default (app) => {
  app.use('/pannes', router);
};