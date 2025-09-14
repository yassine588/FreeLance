import mongoose from 'mongoose';

const panneSchema = new mongoose.Schema({
  date: {
    type: Date,
    required: true
  },
  description: {
    type: String,
    required: true,
    maxlength: 50
  },
  type_panne: {
    type: String,
    required: true,
    maxlength: 50
  },
  vehicule: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Vehicule',
    required: true
  }
}, {
  collection: 'panne',
  timestamps: false
});

export default mongoose.model('Panne', panneSchema);