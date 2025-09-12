const Violation = require('../models/violation');

exports.getAllViolations = async (req, res) => {
  try {
    const violations = await Violation.find().populate('chauffeur').populate('vehicule');
    const totalRecords = await Violation.countDocuments();
    res.status(200).json({ violations, totalRecords });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getViolationById = async (req, res) => {
  try {
    const violation = await Violation.findById(req.params.id).populate('chauffeur').populate('vehicule');
    if (violation) {
      res.status(200).json(violation);
    } else {
      res.status(404).json({ message: 'Violation not found' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.createViolation = async (req, res) => {
  try {
    const violation = new Violation(req.body);
    await violation.save();
    const savedViolation = await Violation.findById(violation._id).populate('chauffeur').populate('vehicule');
    res.status(201).json(savedViolation);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.updateViolation = async (req, res) => {
  try {
    const violation = await Violation.findByIdAndUpdate(req.params.id, req.body, { new: true }).populate('chauffeur').populate('vehicule');
    if (violation) {
      res.status(200).json(violation);
    } else {
      res.status(404).json({ message: 'Violation not found' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.deleteViolation = async (req, res) => {
  try {
    const violation = await Violation.findByIdAndDelete(req.params.id);
    if (violation) {
      res.status(200).json({ message: 'Violation deleted successfully' });
    } else {
      res.status(404).json({ message: 'Violation not found' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.searchViolations = async (req, res) => {
  try {
    const { term } = req.query;
    const regex = new RegExp(term, 'i');
    const violations = await Violation.find({
      $or: [
        { numero: { $regex: regex } },
        { type: { $regex: regex } }
      ]
    }).populate('chauffeur').populate('vehicule');
    res.status(200).json(violations);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};