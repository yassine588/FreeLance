import mongoose from 'mongoose';

const permisSchema = new mongoose.Schema({
  numero: {
    type: String,
    required: true,
    maxlength: 50
  },
  type: {
    type: String,
    enum: ['A1', 'A', 'B', 'B+E', 'C', 'C+E', 'D', 'D+E', 'D1', 'H'],
    required: true
  },
  date: {
    type: Date,
    required: true
  },
  date_renouvellement: {
    type: Date,
    required: true
  },
  chauffeur: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  collection: 'permis',
  timestamps: false
});

export default mongoose.model('Permis', permisSchema);