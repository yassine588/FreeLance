import mongoose from 'mongoose';

const reparationSchema = new mongoose.Schema({
  dateDebut: {
    type: Date,
    required: true
  },
  dateFin: {
    type: Date
  },
  cout: {
    type: Number,
    min: 0,
    default: 0
  },
  etat: {
    type: String,
    enum: ['EN_COURS', 'TERMINEE', 'ANNULEE'],
    required: true
  },
  priorite: {
    type: String,
    enum: ['FAIBLE', 'MOYENNE', 'ELEVEE', 'URGENTE'],
    required: true,
    default: 'MOYENNE'
  },
  description: {
    type: String,
    required: true,
    maxlength: 500
  },
  vehicule: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Vehicule',
    required: true
  },
}, {
  collection: 'reparations',
  timestamps: true
});

export default mongoose.model('Reparation', reparationSchema);