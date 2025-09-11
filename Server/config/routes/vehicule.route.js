const vehiculeController = require('../controllers/vehiculeController');
module.exports = (app) => {
    app.get('/vehicules', vehiculeController.getAllVehicules);
    app.get('/vehicules/:id', vehiculeController.getVehiculeById);
    app.post('/vehicules', vehiculeController.createVehicule);
    app.put('/vehicules/:id', vehiculeController.updateVehicule);
    app.delete('/vehicules/:id', vehiculeController.deleteVehicule);
    app.post('/vehicules/filter', vehiculeController.filterVehicules);
    app.get('/vehicules/chauffeur/:chauffeurId', vehiculeController.getVehiculesByChauffeur);
    app.get('/vehicules/available/:date', vehiculeController.getAvailableVehicules);
}