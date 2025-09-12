const Vehicule = require('../models/vehicule');

exports.getAllVehicules = async (req, res) => {
    try {
        const vehicules = await Vehicule.find();
        const totalRecords = await Vehicule.countDocuments();
        res.status(200).json({ vehicules, totalRecords });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.getVehiculeById = async (req, res) => {
    try {
        const vehicule = await Vehicule.findById(req.params.id);
        if (vehicule) {
            res.status(200).json(vehicule);
        } else {
            res.status(404).json({ message: 'Vehicule not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.createVehicule = async (req, res) => {
    try {
        const vehicule = new Vehicule(req.body);
        await vehicule.save();
        res.status(201).json(vehicule);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.updateVehicule = async (req, res) => {
    try {
        const vehicule = await Vehicule.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (vehicule) {
            res.status(200).json(vehicule);
        } else {
            res.status(404).json({ message: 'Vehicule not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.deleteVehicule = async (req, res) => {
    try {
        const vehicule = await Vehicule.findByIdAndDelete(req.params.id);
        if (vehicule) {
            res.status(200).json({ message: 'Vehicule deleted successfully' });
        } else {
            res.status(404).json({ message: 'Vehicule not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.searchVehicules = async (req, res) => {
    try {
        const { term } = req.query;
        const regex = new RegExp(term, 'i');
        const vehicules = await Vehicule.find({
            $or: [
                { immatriculation: { $regex: regex } },
                { marque: { $regex: regex } },
                { modele: { $regex: regex } }
            ]
        });
        res.status(200).json(vehicules);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};