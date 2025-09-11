const mongoose = require('mongoose');

const associerSchema = new mongoose.Schema({
  date: {
    type: Date,
    required: true
  },
  chauffeur: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',   // reference to User model
    required: true
  },
  vehicule: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Vehicule',  // reference to Vehicule model
    required: true
  },
  active: {
    type: Boolean,
    required: true,
    default: true
  }
}, {
  collection: 'associer',
  timestamps: false
});

module.exports = mongoose.model('Associer', associerSchema);
