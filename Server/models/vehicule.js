import mongoose from 'mongoose';  

const vehiculeSchema = new mongoose.Schema({
  marque: {
    type: String,
    required: true
  },
  modele: {
    type: String,
    required: true
  },
  etat: {
    type: String,
    enum: ['DISPONIBLE', 'EN_PANNE', 'EN_REPARATION', 'HORS_SERVICE'],
    required: true
  },
  societe: {
    type: mongoose.Schema.Types.ObjectId,
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

export default mongoose.model('Vehicule', vehiculeSchema);