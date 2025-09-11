const mongoose = require('mongoose');

const assuranceSchema = new mongoose.Schema({
  nom: {
    type: String,
    required: true,
    maxlength: 20
  },
  telephone: {
    type: Number,
    required: true
  },
  email: {
    type: String,
    default: null
  },
  societe: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Societe',
    default: null
  }
}, {
  collection: 'assurance',
  timestamps: false
});

module.exports = mongoose.model('Assurance', assuranceSchema);
