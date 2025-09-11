const mongoose = require('mongoose');

const violationSchema = new mongoose.Schema({
  numero: {
    type: String,
    required: true,
    unique: true,
    maxlength: 20
  },
  type: {
    type: String,
    required: true,
    maxlength: 20
  },
  montant: {
    type: Number,
    required: true
  },
  date_violation: {
    type: Date,
    required: true
  },
  date_paiement: {
    type: Date,
    required: true
  },
  chauffeur: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  vehicule: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Vehicule',
    default: null
  }
}, {
  collection: 'violation',
  timestamps: false
});

module.exports = mongoose.model('Violation', violationSchema);
