const reparationcontroller = require('../controllers/reparation.controller');
module.exports = (app) => {
    app.get('/reparations', reparationcontroller.getAllReparations);
    app.get('/reparations/:id', reparationcontroller.getReparationById);
    app.post('/reparations', reparationcontroller.createReparation);
    app.put('/reparations/:id', reparationcontroller.updateReparation);
    app.delete('/reparations/:id', reparationcontroller.deleteReparation);
    app.get('/reparations/vehicule/:immatriculation', reparationcontroller.getReparationsByVehicule);
    app.get('/reparations/panne/:panneId', reparationcontroller.getReparationsByPanne);
}