const { Vehicule, Paiement, Dossier, DossierPaiement, Associer, User } = require('../config/models');
const { Op, col, literal } = require("sequelize");

exports.getAllVehicules = async (req, res) => {
    try {
        const vehicules = await Vehicule.findAll();
        const totalRecords = await Vehicule.count();

        res.status(200).json({ vehicules, totalRecords });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getVehiculeById = async (req, res) => {
    try {
        const vehicule = await Vehicule.findByPk(req.params.id);
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
        const newVehiculeId = await Vehicule.create({ ...req.body, societe: req.user.societe });
        res.status(201).json({ id: newVehiculeId, ...req.body });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.updateVehicule = async (req, res) => {
    try {
        console.log(req.params.id);
        console.log(req.body);
        const updatedRows = await Vehicule.update(req.body, {
            where: { id: req.params.id }
        });
        if (updatedRows > 0) {
            res.status(200).json({ message: 'Vehicule updated successfully' });
        } else {
            res.status(404).json({ message: 'Vehicule not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.deleteVehicule = async (req, res) => {
    try {
        const deletedRows = await Vehicule.destroy({
            where: { id: req.params.id }
        });
        if (deletedRows > 0) {
            res.status(200).json({ message: 'Vehicule deleted successfully' });
        } else {
            res.status(404).json({ message: 'Vehicule not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};


exports.getVehiculesByFilter = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const initFilter = JSON.parse(req.query.filter) || {};
        const offset = (page - 1) * limit;
        const { chauffeur, ...filter } = initFilter;
        const whereClause = {}
        if (req.user.societe) {
            whereClause.societe = req.user.societe; // Filter by societe
        }
        console.log('Filter:', filter);
        const associerClause = {
            active: true
        }
        if (chauffeur) {
            associerClause.chauffeur = chauffeur;
        }
        for (const key in filter) {
            if (key === 'immatriculation') {
                // Special handling for immatriculation to allow partial matches
                whereClause[key] = {
                    [Op.like]: `%${filter[key]}%`
                };
            }
            else if (filter[key]) {
                whereClause[key] = filter[key];
            }
        }
        // Date range for the current month
        const now = new Date();
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);

        // Handle the reglement filter
        const reglement = req.query.reglement;

        // Create the SQL condition for payments > 0 in the current month
        const positivePaymentCondition = `
            SELECT 1 
            FROM dossier_paiement dp 
            JOIN paiement p ON p.dossier_paiement = dp.id 
            WHERE dp.objet = 'VEHICULE' 
            AND dp.ref = \`Vehicule\`.\`id\` 
            AND p.dateApayer BETWEEN '${startOfMonth.toISOString()}' AND '${endOfMonth.toISOString()}'
            AND p.montant > 0.000
        `;

        // Create the SQL condition to check if a vehicle has any dossierPaiement
        const hasDossierCondition = `
            SELECT 1 
            FROM dossier_paiement dp 
            WHERE dp.objet = 'VEHICULE' 
            AND dp.ref = \`Vehicule\`.\`id\`
        `;

        // If reglement filter is specified, add it to the where clause
        if (reglement === "true") {
            // For reglement=true: Find vehicles with at least one payment > 0
            whereClause[Op.and] = whereClause[Op.and] || [];
            whereClause[Op.and].push(literal(`EXISTS (${positivePaymentCondition})`));
        } else if (reglement === "false") {
            // For reglement=false: Find vehicles with dossierPaiement but no payments > 0
            whereClause[Op.and] = whereClause[Op.and] || [];
            whereClause[Op.and].push(literal(`EXISTS (${hasDossierCondition})`)); // Must have dossierPaiement
            whereClause[Op.and].push(literal(`NOT EXISTS (${positivePaymentCondition})`)); // But no payments > 0
        }

        // Count total records
        const totalRecords = await Vehicule.count({
            where: whereClause,
            include: [{
                model: Associer,
                as: 'LatestAssocier',
                required: associerClause.chauffeur ? true : false,
                attributes: ['id', 'vehicule', 'chauffeur'],

                where: associerClause
            }],
            distinct: true
        });

        // Get the records with pagination
        const records = await Vehicule.findAll({
            where: whereClause,
            include: [
                {
                    model: DossierPaiement,
                    as: 'DossierPaiements',
                    required: false,
                    where: {
                        objet: 'VEHICULE',
                        ref: col('Vehicule.id')
                    },
                    attributes: ['id']
                }, {
                    model: Associer,
                    as: 'LatestAssocier',
                    required: associerClause.chauffeur ? true : false,
                    attributes: ['id', 'vehicule', 'chauffeur'],
                    include: [{
                        model: User,
                        as: 'Chauffeur',
                        attributes: ['id', 'nom', 'prenom']
                    }],
                    where: associerClause
                }
            ],
            attributes: {
                include: [
                    [
                        literal(`EXISTS (${positivePaymentCondition})`),
                        'reglement'
                    ]
                ]
            },
            limit: limit,
            offset: offset
        });

        // Calculate total pages for pagination
        const totalPages = Math.ceil(totalRecords / limit);

        // Return the data with pagination information
        res.status(200).json({
            data: records,
            pagination: {
                page,
                limit,
                totalRecords,
                totalPages
            }
        });
    } catch (error) {
        console.error("Error fetching vehicles:", error);
        res.status(500).json({ error: error.message });
    }
};
exports.getVehiculeByImmatriculation = async (req, res) => {
    try {
        const immatriculation = req.params.immatriculation;
        const vehicule = await Vehicule.findAll({
            where: {
                immatriculation: {
                    [Op.like]: `%${immatriculation}%`
                }
            }
        });
        if (vehicule) {
            res.status(200).json(vehicule);
        } else {
            res.status(404).json({ message: 'Vehicule not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}
exports.searchVehicules = async (req, res) => {
    try {
        const { term } = req.query;
        const whereClause = {
            [Op.or]: [
                { immatriculation: { [Op.like]: `%${term}%` } },
                { marque: { [Op.like]: `%${term}%` } },
                { modele: { [Op.like]: `%${term}%` } }
            ]
        };
        if (req.user.societe) {
            whereClause.societe = req.user.societe; // Filter by societe
        }
        const vehicules = await Vehicule.findAll({
            where: whereClause
        });

        res.status(200).json(vehicules);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}