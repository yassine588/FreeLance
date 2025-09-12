import mongoose from 'mongoose';

const pieceDetacheeSchema = new mongoose.Schema({
    nom: {
        type: String,
        required: true,
        maxlength: 50
    },
    prix: {
        type: Number,
        min: 0
    },
    numero_serie: {
        type: String,
        maxlength: 50
    },
    etat: {
        type: String,
        enum: ['NEUF', 'RECONDITIONNE', 'REBUT', 'RETOURNEE', 'UTILISE'],
        required: true
    },
    reglement: {
        type: Boolean,
        default: true
    },
    panne: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Panne',
        required: true
    },
    societe: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Societe'
    }
}, {
    collection: 'piece_detachee',
    timestamps: false
});

export default mongoose.model('PieceDetachee', pieceDetacheeSchema);