import Panne from '../models/panne.js';
import Vehicule from '../models/vehicule.js';
import Reparation from '../models/reparation.js';
import PieceDetachee from '../models/pieceDetachee.js';

export const getAllPannes = async (req, res) => {
    try {
        const pannes = await Panne.find().populate('vehicule');
        res.status(200).json(pannes);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getPanneById = async (req, res) => {
    try {
        const panne = await Panne.findById(req.params.id).populate('vehicule');
        if (panne) {
            res.status(200).json(panne);
        } else {
            res.status(404).json({ message: 'Panne not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const createPanne = async (req, res) => {
    try {
        const vehicule = await Vehicule.findOne({ immatriculation: req.body.immatriculation });
        if (!vehicule) {
            return res.status(404).json({ message: 'Vehicule not found' });
        }

        // Update vehicle state to "EN_PANNE"
        await Vehicule.findByIdAndUpdate(vehicule._id, { etat: 'EN_PANNE' });

        // Create new panne
        const newPanne = new Panne({
            date: req.body.date,
            description: req.body.description,
            type_panne: req.body.type_panne,
            vehicule: vehicule._id
        });

        const savedPanne = await newPanne.save();
        res.status(201).json(savedPanne);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const updatePanne = async (req, res) => {
    try {
        let updateData = { ...req.body };
        
        if (req.body.immatriculation) {
            const vehicule = await Vehicule.findOne({ immatriculation: req.body.immatriculation });
            if (!vehicule) {
                return res.status(404).json({ message: 'Vehicule not found' });
            }
            updateData.vehicule = vehicule._id;
            delete updateData.immatriculation;
        }

        const updatedPanne = await Panne.findByIdAndUpdate(
            req.params.id,
            updateData,
            { new: true, runValidators: true }
        ).populate('vehicule');

        if (!updatedPanne) {
            return res.status(404).json({ message: 'Panne not found' });
        }

        res.status(200).json(updatedPanne);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const deletePanne = async (req, res) => {
    try {
        const deletedPanne = await Panne.findByIdAndDelete(req.params.id);
        if (deletedPanne) {
            res.status(200).json({ message: 'Panne deleted successfully' });
        } else {
            res.status(404).json({ message: 'Panne not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const searchPannes = async (req, res) => {
    try {
        const { term } = req.query;
        const regex = new RegExp(term, 'i');
        
        const pannes = await Panne.find({
            $or: [
                { description: { $regex: regex } },
                { type_panne: { $regex: regex } }
            ]
        }).populate('vehicule');

        res.status(200).json(pannes);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getPannesByFilter = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const filter = req.query.filter ? JSON.parse(req.query.filter) : {};
        const skip = (page - 1) * limit;

        // Build main filter for Panne
        let panneFilter = {};
        if (filter.typePanne) {
            panneFilter.type_panne = filter.typePanne;
        }
        if (filter.date) {
            panneFilter.date = new Date(filter.date);
        }

        // Build vehicle filter
        let vehiculeFilter = {};
        if (filter.immatriculation) {
            vehiculeFilter['vehicule.immatriculation'] = filter.immatriculation;
        }

        // Build reparation filter
        let reparationFilter = {};
        if (filter.date_debut) {
            reparationFilter['reparation.date_debut'] = new Date(filter.date_debut);
        }
        if (filter.date_fin) {
            reparationFilter['reparation.date_fin'] = new Date(filter.date_fin);
        }
        if (filter.etat) {
            reparationFilter['reparation.etat'] = filter.etat;
        }

        const aggregationPipeline = [
            // Populate vehicule
            {
                $lookup: {
                    from: 'vehicules',
                    localField: 'vehicule',
                    foreignField: '_id',
                    as: 'vehicule'
                }
            },
            { $unwind: { path: '$vehicule', preserveNullAndEmptyArrays: true } },
            
            {
                $lookup: {
                    from: 'reparations',
                    localField: '_id',
                    foreignField: 'panne',
                    as: 'reparation'
                }
            },
            { $unwind: { path: '$reparation', preserveNullAndEmptyArrays: true } },

            {
                $lookup: {
                    from: 'piece_detachee',
                    localField: '_id',
                    foreignField: 'panne',
                    as: 'pieceDetachees'
                }
            },
            {
                $match: {
                    ...panneFilter,
                    ...vehiculeFilter,
                    ...reparationFilter
                }
            },
            
            {
                $addFields: {
                    pieceDetachees: {
                        $filter: {
                            input: '$pieceDetachees',
                            as: 'piece',
                            cond: { $eq: ['$$piece.etat', 'NEUF'] }
                        }
                    },
                    pieceRetournees: {
                        $filter: {
                            input: '$pieceDetachees',
                            as: 'piece',
                            cond: { $ne: ['$$piece.etat', 'NEUF'] }
                        }
                    }
                }
            },
            
            { $sort: { date: -1 } },
            
            {
                $facet: {
                    metadata: [{ $count: 'totalRecords' }],
                    data: [{ $skip: skip }, { $limit: limit }]
                }
            }
        ];

        const result = await Panne.aggregate(aggregationPipeline);
        
        const totalRecords = result[0].metadata.length > 0 ? result[0].metadata[0].totalRecords : 0;
        const totalPages = Math.ceil(totalRecords / limit);
        const data = result[0].data;

        res.status(200).json({
            data,
            pagination: {
                page,
                limit,
                totalRecords,
                totalPages
            }
        });
    } catch (error) {
        console.error('Error in getPannesByFilter:', error);
        res.status(500).json({ error: error.message });
    }
};