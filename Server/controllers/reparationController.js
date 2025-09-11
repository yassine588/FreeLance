const { Op } = require('sequelize');
const { Reparation, Vehicule, Panne } = require('../config/models');

exports.getAllReparations = async (req, res) => {
    try {
        const reparations = await Reparation.findAll();
        res.status(200).json(reparations);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getReparationById = async (req, res) => {
    try {
        const reparation = await Reparation.findByPk(req.params.id);
        if (reparation) {
            res.status(200).json(reparation);
        } else {
            res.status(404).json({ message: 'Reparation not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.createReparation = async (req, res) => {
    try {
        const newReparation = await Reparation.create(req.body);
        if (newReparation.etat == 'TERMINE') {
            const panne = await Panne.findByPk(newReparation.panne);
            const vehicule = await Vehicule.findByPk(panne.vehicule);
            await Vehicule.update({ etat: 'DISPONIBLE' }, { where: { id: vehicule.id } });
        }
        else if (newReparation.etat == 'EN_COURS') {
            const panne = await Panne.findByPk(newReparation.panne);
            const vehicule = await Vehicule.findByPk(panne.vehicule);
            await Vehicule.update({ etat: 'EN_REPARATION' }, { where: { id: vehicule.id } });
        }
        res.status(201).json(newReparation);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.updateReparation = async (req, res) => {
    try {
        const updatedRows = await Reparation.update(req.body, {
            where: { id: req.params.id }
        });
        if (updatedRows > 0) {
            res.status(200).json({ message: 'Reparation updated successfully' });
        } else {
            res.status(404).json({ message: 'Reparation not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.deleteReparation = async (req, res) => {
    try {
        const deletedRows = await Reparation.destroy({ where: { id: req.params.id } });
        if (deletedRows > 0) {
            res.status(200).json({ message: 'Reparation deleted successfully' });
        } else {
            res.status(404).json({ message: 'Reparation not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.getReparationsByFilter = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const filter = JSON.parse(req.query.filter) || {};
        const offset = (page - 1) * limit;
        const whereClause = {};

        for (const key in filter) {
            if (filter[key]) {
                whereClause[key] = filter[key];
            }
        }
        const totalRecords = await Reparation.count({ where: whereClause });
        const reparationRecords = await Reparation.findAll({
            where: whereClause,
            limit: limit,
            offset: offset,
        });
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
}
exports.searchReparations = async (req, res) => {
    try {
        const { term } = req.query;
        const whereClause = {
            [Op.or]: [
                { id: { [Op.like]: `%${term}%` } },
            ]
        };
        if (req.user.societe) {
            whereClause.societe = req.user.societe; // Filter by societe
        }
        const reparations = await Reparation.findAll({
            where: whereClause
        });

        res.status(200).json(reparations);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};