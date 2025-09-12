const mongoose = require('mongoose');

const vehiculeSchema = new mongoose.Schema({
  marque: {
    type: String,
    required: true
  },
  modele: {
    type: String,
    required: true
  },
  photo: {
    type: String,
    default: null
  },
  etat: {
    type: String,
    enum: ['DISPONIBLE', 'EN_PANNE', 'EN_REPARATION', 'HORS_SERVICE'],
    required: true
  },
  societe: {
    type: mongoose.Schema.Types.ObjectId,  // reference to another model
    ref: 'Societe',
    default: null
  },
  immatriculation: {
    type: String,
    required: true,
    maxlength: 15
  }
}, {
  collection: 'vehicule',
  timestamps: false
});

module.exports = mongoose.model('Vehicule', vehiculeSchema);
