import Reparation from '../models/reparation.js';
import Vehicule from '../models/vehicule.js';
import Panne from '../models/panne.js';

export const getAllReparations = async (req, res) => {
    try {
        const reparations = await Reparation.find();
        res.status(200).json(reparations);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getReparationById = async (req, res) => {
    try {
        const reparation = await Reparation.findById(req.params.id);
        if (reparation) {
            res.status(200).json(reparation);
        } else {
            res.status(404).json({ message: 'Reparation not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const createReparation = async (req, res) => {
  try {
    // Handle field mapping from Flutter app
    const reparationData = {
      ...req.body,
      etat: req.body.statut || req.body.etat, // Map statut to etat
      priorite: req.body.priorite || 'MOYENNE'
    };
    
    const newReparation = new Reparation(reparationData);
    const savedReparation = await newReparation.save();
    
    // Update vehicle status based on repair state
    if (savedReparation.etat === 'TERMINEE') {
      await Vehicule.findByIdAndUpdate(
        savedReparation.vehicule, 
        { etat: 'DISPONIBLE' }
      );
    } else if (savedReparation.etat === 'EN_COURS') {
      await Vehicule.findByIdAndUpdate(
        savedReparation.vehicule, 
        { etat: 'EN_REPARATION' }
      );
    }
    
    const populatedReparation = await Reparation.findById(savedReparation._id)
      .populate('vehicule');
      
    res.status(201).json(populatedReparation);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const updateReparation = async (req, res) => {
  try {
    // Handle field mapping for updates
    const updateData = {
      ...req.body,
      etat: req.body.statut || req.body.etat,
      priorite: req.body.priorite || req.body.priorite
    };
    
    const updatedReparation = await Reparation.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    ).populate('vehicule');
    
    if (updatedReparation) {
      // Update vehicle state if reparation status changed
      if (req.body.etat || req.body.statut) {
        const newEtat = req.body.etat || req.body.statut;
        let newVehicleState = 'DISPONIBLE';
        
        if (newEtat === 'EN_COURS') {
          newVehicleState = 'EN_REPARATION';
        } else if (newEtat === 'EN_ATTENTE') {
          newVehicleState = 'EN_PANNE';
        }
        
        await Vehicule.findByIdAndUpdate(
          updatedReparation.vehicule, 
          { etat: newVehicleState }
        );
      }
      
      res.status(200).json(updatedReparation);
    } else {
      res.status(404).json({ message: 'Reparation not found' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const deleteReparation = async (req, res) => {
    try {
        const deletedReparation = await Reparation.findByIdAndDelete(req.params.id);
        if (deletedReparation) {
            res.status(200).json({ message: 'Reparation deleted successfully' });
        } else {
            res.status(404).json({ message: 'Reparation not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getReparationsByFilter = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const filter = req.query.filter ? JSON.parse(req.query.filter) : {};
        const skip = (page - 1) * limit;

        let query = {};
        for (const key in filter) {
            if (filter[key]) {
                query[key] = filter[key];
            }
        }

        const totalRecords = await Reparation.countDocuments(query);
        const reparationRecords = await Reparation.find(query)
            .populate('panne')
            .skip(skip)
            .limit(limit);

        const totalPages = Math.ceil(totalRecords / limit);
        res.status(200).json({
            data: reparationRecords,
            pagination: {
                page,
                limit,
                totalRecords,
                totalPages
            }
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getReparationsByVehicule = async (req, res) => {
    try {
        const { immatriculation } = req.params;
        const vehicule = await Vehicule.findOne({ immatriculation });
        
        if (!vehicule) {
            return res.status(404).json({ message: 'Vehicule not found' });
        }

        const pannes = await Panne.find({ vehicule: vehicule._id });
        const panneIds = pannes.map(panne => panne._id);
        
        const reparations = await Reparation.find({ panne: { $in: panneIds } })
            .populate('panne')
            .populate('garage');

        res.status(200).json(reparations);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getReparationsByPanne = async (req, res) => {
    try {
        const { panneId } = req.params;
        const reparations = await Reparation.find({ panne: panneId })
            .populate('panne')
            .populate('garage');

        res.status(200).json(reparations);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const searchReparations = async (req, res) => {
    try {
        const { term } = req.query;
        const regex = new RegExp(term, 'i');
        
        const reparations = await Reparation.find({
            $or: [
                { etat: { $regex: regex } }
            ]
        }).populate('panne').populate('garage');

        res.status(200).json(reparations);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};