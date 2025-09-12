const violationController = require('../controllers/violationController');
module.exports = (app) => {
    app.get('/violations', violationController.getAllViolations);
    app.get('/violations/:id', violationController.getViolationById);
    app.post('/violations', violationController.createViolation);
    app.put('/violations/:id', violationController.updateViolation);
    app.delete('/violations/:id', violationController.deleteViolation);
    app.get('/violations/search', violationController.searchViolations);
}