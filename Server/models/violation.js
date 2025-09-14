import mongoose from 'mongoose';

const violationSchema = new mongoose.Schema({
  numero: {
    type: String,
    required: true
  },
  type: {
    type: String,
    required: true
  },
  date: {
    type: Date,
    required: true
  },
  montant: {
    type: Number,
    required: true
  },
  chauffeur: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Chauffeur',
    required: true
  },
  vehicule: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Vehicule',
    required: true
  }
}, {
  collection: 'violation',
  timestamps: false
});

export default mongoose.model('Violation', violationSchema);