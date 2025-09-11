const { Op } = require('sequelize');
const { Panne, Vehicule, Reparation, PieceDetachee } = require('../config/models');

exports.getAllPannes = async (req, res) => {
    try {
        const pannes = await Panne.findAll();
        res.status(200).json(pannes);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getPanneById = async (req, res) => {
    try {
        const panne = await Panne.findByPk(req.params.id);
        if (panne) {
            res.status(200).json(panne);
        } else {
            res.status(404).json({ message: 'Panne not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.createPanne = async (req, res) => {
    try {
        const vehicule = await Vehicule.findOne({ where: { immatriculation: req.body.immatriculation } });
        await Vehicule.update({ etat: 'EN_PANNE' }, { where: { immatriculation: req.body.immatriculation } });
        const newPanneId = await Panne.create({ ...req.body, vehicule: vehicule.id });
        res.status(201).json({ id: newPanneId, ...req.body });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.updatePanne = async (req, res) => {
    try {
        const vehicule = await Vehicule.findOne({ where: { immatriculation: req.body.immatriculation } });
        req.body = { ...req.body, vehicule: vehicule.id };
        console.log(req.body);
        console.log(req.params.id);
        req.body.immatriculation = undefined
        const updatedRows = await Panne.update(req.body, {
            where: { id: req.params.id }
        });
        console.log(updatedRows);
        res.status(200).json({ message: 'Panne updated successfully' });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.deletePanne = async (req, res) => {
    try {
        const deletedRows = await Panne.destroy({ where: { id: req.params.id } });
        if (deletedRows > 0) {
            res.status(200).json({ message: 'Panne deleted successfully' });
        } else {
            res.status(404).json({ message: 'Panne not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.getPannesByFilter = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const filter = JSON.parse(req.query.filter) || {};
        const offset = (page - 1) * limit;
        const whereClause = {};
        if (filter.typePanne) {
            whereClause.type_panne = filter.typePanne;
        }
        if (filter.date) {
            whereClause.date = filter.date;
        }

        const whereClauseReparation = {};
        if (filter.date_debut) {
            whereClauseReparation.date_debut = filter.date_debut;
        }
        if (filter.date_fin) {
            whereClauseReparation.date_fin = filter.date_fin;
        }
        if (filter.etat) {
            whereClauseReparation.etat = filter.etat;
        }

        const vehiculeWhereClause = {};
        if (filter.immatriculation) {
            vehiculeWhereClause.immatriculation = filter.immatriculation;
        }


        const totalRecords = await Panne.count({
            include: [
                {
                    model: Reparation,
                    as: 'Reparation',
                    required: false,
                    where: whereClauseReparation,
                },
                {
                    model: Vehicule,
                    as: 'Vehicule',
                    required: false,
                    where: vehiculeWhereClause
                },

            ],
            where: whereClause,
        });
        const panneRecords = await Panne.findAll({
            include: [
                {
                    model: Reparation,
                    as: 'Reparation',
                    required: false,
                    where: whereClauseReparation,
                },
                {
                    model: Vehicule,
                    as: 'Vehicule',
                    required: true,
                    where: vehiculeWhereClause
                },
                {
                    model: PieceDetachee,
                    as: 'PieceDetachees',
                    required: false,
                    where: {
                        etat: {
                            [Op.eq]: 'NEUF' // Exclude records where prix is null
                        }
                    }
                },
                {
                    model: PieceDetachee,
                    as: 'PieceRetournees',
                    required: false,
                    where: {
                        etat: {
                            [Op.ne]: 'NEUF' // Exclude records where prix is null
                        }
                    }
                }

            ],
            where: whereClause,
            order: [['date', 'DESC']],
            limit,
            offset
        });
        const totalPages = Math.ceil(totalRecords / limit);
        res.status(200).json({
            data: panneRecords,
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
}