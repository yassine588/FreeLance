const panneController = require('../controllers/panne.controller');
module.exports = (app) => {
    app.get('/pannes', panneController.getAllPannes);
    app.get('/pannes/:id', panneController.getPanneById);
    app.post('/pannes', panneController.createPanne);
    app.put('/pannes/:id', panneController.updatePanne);
    app.delete('/pannes/:id', panneController.deletePanne);
    app.get('/pannes/vehicule/:immatriculation', panneController.getPannesByVehicule);
}