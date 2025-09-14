import Vehicule from '../models/vehicule.js';

export const getAllVehicules = async (req, res) => {
    try {
        const vehicules = await Vehicule.find();
        const totalRecords = await Vehicule.countDocuments();
        res.status(200).json({ vehicules, totalRecords });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getVehiculeById = async (req, res) => {
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

export const createVehicule = async (req, res) => {
    try {
        const vehicule = new Vehicule(req.body);
        await vehicule.save();
        res.status(201).json(vehicule);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const updateVehicule = async (req, res) => {
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

export const deleteVehicule = async (req, res) => {
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

export const searchVehicules = async (req, res) => {
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

// Add the missing functions that are imported in the route file
export const filterVehicules = async (req, res) => {
    // Implement your filtering logic here
    res.status(200).json({ message: 'Filter endpoint' });
};

export const getVehiculesByChauffeur = async (req, res) => {
    // Implement logic to get vehicles by chauffeur
    res.status(200).json({ message: 'Chauffeur endpoint' });
};

export const getAvailableVehicules = async (req, res) => {
    // Implement logic to get available vehicles
    res.status(200).json({ message: 'Available vehicles endpoint' });
};