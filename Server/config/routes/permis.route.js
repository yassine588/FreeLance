const permisController = require('../controllers/permis.Controller');
module.exports = (app) => {
    app.get('/permis', permisController.getAllPermis);
    app.get('/permis/:id', permisController.getPermisById);
    app.post('/permis', permisController.createPermis);
    app.put('/permis/:id', permisController.updatePermis);
    app.delete('/permis/:id', permisController.deletePermis);
    app.get('/permis/search', permisController.searchPermis);
}