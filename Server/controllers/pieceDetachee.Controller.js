import PieceDetachee from '../models/pieceDetachee.js';

// Get all piece détachée
export const getAllPieces = async (req, res) => {
  try {
    const pieces = await PieceDetachee.find()
      .populate('panne')
      .populate('societe');
    const totalRecords = await PieceDetachee.countDocuments();
    res.status(200).json({ pieces, totalRecords });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get piece détachée by ID
export const getPieceById = async (req, res) => {
  try {
    const piece = await PieceDetachee.findById(req.params.id)
      .populate('panne')
      .populate('societe');
    if (piece) {
      res.status(200).json(piece);
    } else {
      res.status(404).json({ message: 'Piece détachée not found' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Create new piece détachée
export const createPiece = async (req, res) => {
  try {
    const piece = new PieceDetachee(req.body);
    await piece.save();
    const savedPiece = await PieceDetachee.findById(piece._id)
      .populate('panne')
      .populate('societe');
    res.status(201).json(savedPiece);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Update piece détachée
export const updatePiece = async (req, res) => {
  try {
    const piece = await PieceDetachee.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    ).populate('panne').populate('societe');
    if (piece) {
      res.status(200).json(piece);
    } else {
      res.status(404).json({ message: 'Piece détachée not found' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Delete piece détachée
export const deletePiece = async (req, res) => {
  try {
    const piece = await PieceDetachee.findByIdAndDelete(req.params.id);
    if (piece) {
      res.status(200).json({ message: 'Piece détachée deleted successfully' });
    } else {
      res.status(404).json({ message: 'Piece détachée not found' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Search pieces by name, numero_serie, etat
export const searchPieces = async (req, res) => {
  try {
    const { term } = req.query;
    const regex = new RegExp(term, 'i');
    const pieces = await PieceDetachee.find({
      $or: [
        { nom: { $regex: regex } },
        { numero_serie: { $regex: regex } },
        { etat: { $regex: regex } }
      ]
    }).populate('panne').populate('societe');
    res.status(200).json(pieces);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};