import mongoose from 'mongoose';

const reparationSchema = new mongoose.Schema({
    date_debut: {
        type: Date,
        required: true
    },
    date_fin: {
        type: Date,
        required: true
    },
    montant: {
        type: Number,
        required: true,
        min: 0
    },
    etat: {
        type: String,
        enum: ['EN_ATTENTE', 'EN_COURS', 'TERMINE'],
        required: true
    },
    panne: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Panne',
        required: true
    },
    garage: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Garage',
        required: true
    }
}, {
    collection: 'reparation',
    timestamps: false
});

export default mongoose.model('Reparation', reparationSchema);