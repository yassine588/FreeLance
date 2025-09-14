import Permis from '../models/permis.js';

export const getAllPermis = async (req, res) => {
  try {
    const permis = await Permis.find().populate('chauffeur');
    const totalRecords = await Permis.countDocuments();
    res.status(200).json({ permis, totalRecords });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const getPermisById = async (req, res) => {
  try {
    const permis = await Permis.findById(req.params.id).populate('chauffeur');
    if (permis) {
      res.status(200).json(permis);
    } else {
      res.status(404).json({ message: 'Permis not found' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const createPermis = async (req, res) => {
  try {
    const permis = new Permis(req.body);
    await permis.save();
    const savedPermis = await Permis.findById(permis._id).populate('chauffeur');
    res.status(201).json(savedPermis);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const updatePermis = async (req, res) => {
  try {
    const permis = await Permis.findByIdAndUpdate(req.params.id, req.body, { new: true }).populate('chauffeur');
    if (permis) {
      res.status(200).json(permis);
    } else {
      res.status(404).json({ message: 'Permis not found' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const deletePermis = async (req, res) => {
  try {
    const permis = await Permis.findByIdAndDelete(req.params.id);
    if (permis) {
      res.status(200).json({ message: 'Permis deleted successfully' });
    } else {
      res.status(404).json({ message: 'Permis not found' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const searchPermis = async (req, res) => {
  try {
    const { term } = req.query;
    const regex = new RegExp(term, 'i');
    const permis = await Permis.find({
      $or: [
        { numero: { $regex: regex } },
        { type: { $regex: regex } }
      ]
    }).populate('chauffeur');
    res.status(200).json(permis);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};