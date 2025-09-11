/*const { DataTypes } = require('sequelize');
const bcrypt = require('bcryptjs');
const { auth } = require('googleapis/build/src/apis/abusiveexperiencereport');
const User = sequelize.define('User', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  nom: { type: DataTypes.STRING(20) },
  prenom: { type: DataTypes.STRING(30) },
  email: { type: DataTypes.STRING(50), allowNull: false, unique: true },
  password: { type: DataTypes.STRING, allowNull: false },
  role: {
    type: DataTypes.ENUM('SUPERADMIN', 'ADMIN', 'OPERATEUR', 'CHAUFFEUR', 'CHEF_PARK'),
    allowNull: false,
  },
  active: { type: DataTypes.BOOLEAN, defaultValue: true },
}, {
  tableName: 'user',
  timestamps: false,
  hooks: {
    beforeCreate: async (user) => {
      if (user.password) {
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(user.password, salt);
      }
    },
    beforeUpdate: async (user) => {
      if (user.changed('password')) {
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(user.password, salt);
      }
    },
  },
});

module.exports = User;
/*sequelize.sync({ alter: true })  
    .then(() => {
        console.log('Database & tables created!');
    })
    .catch((err) => {
        console.error('Error syncing the database:', err);
    });*/
const Abonnement = sequelize.define('Abonnement', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    societe: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Societe,
            key: 'id'
        }
    },
    type: {
        type: DataTypes.ENUM('PARC', 'SERVICE', 'FULL'),
        allowNull: false,
        defaultValue: 'PARC'
    },
    max_vehicules: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 5
    },
    prix: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false
    },
    prixMensuel: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false
    },
    date_debut: {
        type: DataTypes.DATEONLY,
        allowNull: false
    },
    date_fin: {
        type: DataTypes.DATEONLY,
        allowNull: false
    },
    nombreMois: {
        type: DataTypes.INTEGER,
        allowNull: false
    }
}, {
    tableName: 'abonnement',
    timestamps: false
});

const Vehicule = sequelize.define("Vehicule",
    {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        marque: {
            type: DataTypes.STRING(20),
            allowNull: false,
        },
        modele: {
            type: DataTypes.STRING(20),
            allowNull: false,
        },
        photo: {
            type: DataTypes.STRING(255),
            allowNull: true,
        },
        etat: {
            type: DataTypes.ENUM('DISPONIBLE', 'EN_REPARATION', 'EN_MISSION', 'EN_PANNE'),
            allowNull: false,
        },
        societe: {
            type: DataTypes.INTEGER,
            allowNull: true,
            references: {
                model: Societe,
                key: 'id'
            }
        },
        immatriculation: {
            type: DataTypes.STRING(15),
            allowNull: false,
        },
    },
    {
        tableName: 'vehicule',
        timestamps: false,
    }
);
const Abonne = sequelize.define('Abonne', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true, autoIncrement: true
    },
    cin: {
        type: DataTypes.STRING(8),
        allowNull: false
    },
    nom: {
        type: DataTypes.STRING(20),
        allowNull: true
    },
    prenom: {
        type: DataTypes.STRING(30),
        allowNull: true
    },
    immatriculation: {
        type: DataTypes.STRING(20),
        allowNull: false
    },
    marque: {
        type: DataTypes.STRING(20),
        allowNull: false
    },
    modele: {
        type: DataTypes.STRING(20),
        allowNull: false
    },
    adresse: {
        type: DataTypes.JSON,
        allowNull: true
    },
    assurance: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    n_assurance: {
        type: DataTypes.STRING(20),
        allowNull: true
    },
    date_debut: {
        type: DataTypes.DATEONLY,
        allowNull: true
    },
    date_fin: {
        type: DataTypes.DATEONLY,
        allowNull: true
    },
    telephone: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    societe: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Societe,
            key: 'id'
        }
    },
}, {
    tableName: 'abonne',
    timestamps: false
});

const User = sequelize.define("User",
    {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        nom: {
            type: DataTypes.STRING(20),
            allowNull: true,
        },
        prenom: {
            type: DataTypes.STRING(30),
            allowNull: true,
        },
        email: {
            type: DataTypes.STRING(50),
            allowNull: false,
        },
        password: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        photoProfile: {
            type: DataTypes.STRING(50),
            allowNull: true,
        },
        role: {
            type: DataTypes.ENUM('SUPERADMIN', 'ADMIN', 'OPERATEUR', 'CHAUFFEUR', 'CHEF_PARK'),
            allowNull: false,
        },
        cin: {
            type: DataTypes.STRING(8),
            allowNull: true,
        },
        telephone: {
            type: DataTypes.STRING(12),
            allowNull: true,
        },
        active: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: true,
        },
        verified: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: true,
        },
        email_token: {
            type: DataTypes.STRING(50),
            allowNull: true,
        },
        societe: {
            type: DataTypes.INTEGER,
            allowNull: true,
            references: {
                model: Societe,
                key: 'id'
            }
        },
    },
    {
        tableName: 'user',
        timestamps: false,

        hooks: {
            beforeCreate: async (user) => {
                if (user.password) {
                    const salt = await bcrypt.genSalt(10);  // Generate salt with cost factor of 10
                    user.password = await bcrypt.hash(user.password, salt);  // Hash password
                }
            },
            beforeUpdate: async (user) => {

                if (user.changed('password')) {  // Check if password is being updated
                    const salt = await bcrypt.genSalt(10);  // Generate salt with cost factor of 10
                    user.password = await bcrypt.hash(user.password, salt);  // Hash password
                }
            }
        },
    }
); User.associate = (models) => {
    User.hasMany(models.Pointage, { foreignKey: 'userId' });
};
/*
const Assurance = sequelize.define('Assurance', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true, autoIncrement: true
    },
    nom: {
        type: DataTypes.STRING(20),
        allowNull: false
    },
    telephone: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    email: {
        type: DataTypes.STRING
    },
    societe: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Societe,
            key: 'id'
        }
    },
}, {
    tableName: 'assurance',
    timestamps: false
});
const Client = sequelize.define('Client', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    nom: {
        type: DataTypes.STRING(20),
        allowNull: false
    },
    telephone: {
        type: DataTypes.STRING(12),
        allowNull: true
    },
    email: {
        type: DataTypes.STRING
    },
    societe: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Societe,
            key: 'id'
        }
    },
}, {
    tableName: 'client',
    timestamps: false
});


const Dossier = sequelize.define('Dossier', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    date_overture: {
        type: DataTypes.DATE,
        allowNull: false
    },
    date_fermeture: {
        type: DataTypes.DATE,
        allowNull: true
    },
    abonne: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: Abonne,
            key: 'id'
        }
    },
    client: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Client,
            key: 'id'
        },
    },
    associer: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: Associer,
            key: 'id'
        }
    },
    ref_assurance: {
        type: DataTypes.STRING(20),
        allowNull: true

    },
    operateur: {
        type: DataTypes.INTEGER,
        references: {
            model: User,
            key: 'id'
        }
    },
    operateur_fermeture: {
        type: DataTypes.INTEGER,
        references: {
            model: User,
            key: 'id'
        }
    },
    societe: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Societe,
            key: 'id'
        }
    },
}, {
    tableName: 'dossier',
    timestamps: false
});
const Log = sequelize.define("Log", {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    date: {
        type: DataTypes.DATE,
        allowNull: false
    },
    message: {
        type: DataTypes.STRING(50),
        allowNull: false
    },
    dossier: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: Dossier,
            key: 'id'
        }
    }
}, { tableName: 'log', timestamps: false }
);
const Intervention = sequelize.define('intervention', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    type: {
        type: DataTypes.ENUM("forfait", "combinaison", "fixe"),
        allowNull: false
    },
    nom: {
        type: DataTypes.STRING(50),
        allowNull: false
    },

    tarifs: {
        type: DataTypes.JSON,
        allowNull: false
    },
    active: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: true
    },
    prix: {
        type: DataTypes.DECIMAL(10, 3),
        allowNull: true
    },
    societe: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Societe,
            key: 'id'
        }
    },
    client: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Client,
            key: 'id'
        }
    },
    assurance: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Assurance,
            key: 'id'
        }
    }
}, {
    tableName: 'intervention',
    timestamps: false
});
const Prestation = sequelize.define("prestation", {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    panne: {
        type: DataTypes.STRING(5),
        allowNull: false
    },
    date: {
        type: DataTypes.DATE,
        allowNull: false
    },
    date_depart: {
        type: DataTypes.DATE,
        allowNull: false
    },
    lieu_depart: {
        type: DataTypes.JSON,
        allowNull: false
    },
    lieu_panne: {
        type: DataTypes.JSON,
        allowNull: false
    },
    destination: {
        type: DataTypes.JSON,
        allowNull: false
    },
    intervention: {
        type: DataTypes.INTEGER,
        references: {
            model: Intervention,
            key: 'id'
        },
        allowNull: false
    },
    montant: {
        type: DataTypes.DECIMAL(10, 0),
        allowNull: false
    },
    dossier: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: Dossier,
            key: 'id'
        }
    },
    paiement: {
        type: DataTypes.ENUM("ESPECE", "CREDIT"),
        allowNull: true,
    },
    societe: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Societe,
            key: 'id'
        }
    },
}, { tableName: 'prestation', timestamps: false });

const Rattache = sequelize.define("Rattache", {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    date: {
        type: DataTypes.DATE,
        allowNull: false
    },
    photo: {
        type: DataTypes.STRING(50),
        allowNull: false
    },
    dossier: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: Dossier,
            key: 'id'
        }
    }
}, {
    tableName: 'rattache',
    timestamps: false
});
const DossierPaiement = sequelize.define("DossierPaiement", {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    montantTotal: {
        type: DataTypes.DECIMAL(10, 3),
        allowNull: false,
    },
    montantRestant: {
        type: DataTypes.DECIMAL(10, 3),
        allowNull: false,
    },
    nbrEcheance: {
        type: DataTypes.INTEGER,
        allowNull: true,
    },
    montantEcheance: {
        type: DataTypes.DECIMAL(10, 3),
        allowNull: true,
    },
    dateDebut: {
        type: DataTypes.DATE,
        allowNull: false,
    },

    dateFin: {
        type: DataTypes.DATE,
        allowNull: true,
    },
    date: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: new Date(),
    },
    objet: {
        type: DataTypes.ENUM('ASSURANCE', 'CARBURANT', 'PIECE DETACHEE', 'REPARATION', 'VISITE TECHNIQUE', 'VIOLATION', 'DOSSIER', 'VEHICULE', 'AUTRE'),
        allowNull: false,
    },
    ref: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    societe: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Societe,
            key: 'id'
        }
    },
},
    {
        tableName: 'dossier_paiement',
        timestamps: false,
        hooks: {
            beforeValidate: async (dossier) => {
                if (!dossier.date) {
                    dossier.date = new Date()
                }
                if (!dossier.dateDebut) {
                    dossier.dateDebut = new Date()
                }

            },
        }
    },
);
const Paiement = sequelize.define("Paiement",
    {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        montant: {
            type: DataTypes.DECIMAL(10, 3),
            allowNull: false,
            defaultValue: 0,
        },
        montantApayer: {
            type: DataTypes.DECIMAL(10, 3),
            allowNull: false,
        },
        dateApayer: {
            type: DataTypes.DATE,
            allowNull: false,
        },
        date: {
            type: DataTypes.DATE,
            allowNull: true,
        },
        moyen: {
            type: DataTypes.ENUM('CHEQUE', 'ESPECE', 'VIREMENT'),
            allowNull: true,
        },
        source: {
            type: DataTypes.ENUM('BANQUE', 'CAISSE'),
            allowNull: true,
        },
        ref: {
            type: DataTypes.STRING(50),
            allowNull: true,
        },
        dossier_paiement: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: DossierPaiement,
                key: 'id',

            },
            unique: false,
            onDelete: 'CASCADE',
            onUpdate: 'CASCADE',
        },
    },
    {
        tableName: 'paiement',
        timestamps: false,
    })
const Pointage = sequelize.define('Pointage', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    date_debut: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
    },
    date_fin: {
        type: DataTypes.DATE,
        allowNull: true,
    },
    mission: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: 0,
    },
    userId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: User,
            key: 'id',
        },
    },
    note: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
}, {
    tableName: 'pointages',
    timestamps: false,
});



const Location = sequelize.define('Location', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    lat: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    lng: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    date: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW, // on stocke l’horodatage
    },
    pointageId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: Pointage,
            key: 'id',
        },
    },
}, {
    tableName: 'locations',
    timestamps: false, // on n’a pas besoin des colonnes createdAt/updatedAt
});

Location.belongsTo(Pointage, { foreignKey: 'pointageId', as: 'Pointage' });

const Notification = sequelize.define('Notification', {
    userId: DataTypes.INTEGER,
    title: DataTypes.STRING,
    message: DataTypes.TEXT,
    type: DataTypes.ENUM('INFO', 'WARNING', 'ERROR', 'SUCCESS', "PRIMARY"),
    read: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
    societe: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Societe,
            key: 'id'
        }
    },
}, {
    tableName: 'notification',
}
);
*/
const Demande = sequelize.define('Demande', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    date: {
        type: DataTypes.DATE,
        allowNull: false,
    },
    data: {
        type: DataTypes.JSON,
        allowNull: false,
    },
    societe: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Societe,
            key: 'id'
        }
    },
}, {
    tableName: 'demande',
    timestamps: false,
});
const DemandeResponse = sequelize.define('DemandeResponse', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    date: {
        type: DataTypes.DATE,
        allowNull: false,
    },
    response: {
        type: DataTypes.BOOLEAN,

    },
    demande: {
        type: DataTypes.INTEGER,
        references: {
            model: Demande,
            key: 'id',
        }
    },
    blocked: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
    chauffeur: {
        type: DataTypes.INTEGER,
        references: {
            model: User,
            key: 'id',
        }
    }
}, {
    tableName: 'demande_response',
    timestamps: false,
    updatedAt: true,
});

const Garage = sequelize.define('Garage', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    nom: {
        type: DataTypes.STRING(50),
        allowNull: false
    },
    adresse: {
        type: DataTypes.JSON,
        allowNull: false
    },
    telephone: {
        type: DataTypes.STRING(12),
        allowNull: false
    },
    email: {
        type: DataTypes.STRING(50),
        allowNull: false
    },
    responsable: {
        type: DataTypes.STRING(50),
        allowNull: false,
    },
    numero_fiscale: {
        type: DataTypes.STRING(20),
        allowNull: false
    },
    societe: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Societe,
            key: 'id'
        }
    },
}, {
    tableName: 'garage',
    timestamps: false,

});
const Reparation = sequelize.define("Reparation",
    {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        panne: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: Panne,
                key: 'id',
            }
        },
        date_debut: {
            type: DataTypes.DATE,
            allowNull: false,
        },
        date_fin: {
            type: DataTypes.DATE,
            allowNull: false,
        },
        montant: {
            type: DataTypes.DECIMAL(10, 0),
            allowNull: false,
        },
        etat: {
            type: DataTypes.ENUM('EN_ATTENTE', 'EN_COURS', 'TERMINE'),
            allowNull: false,
        },
        garage: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: Garage,
                key: 'id',
            }
        },
    },
    {
        tableName: 'reparation',
        timestamps: false,
    }
);

const PieceDetachee = sequelize.define("PieceDetachee",
    {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        nom: {
            type: DataTypes.STRING(50),
            allowNull: false,
        },
        prix: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: true,
        },
        numero_serie: {
            type: DataTypes.STRING(50),
            allowNull: true,
        },
        etat: {
            type: DataTypes.ENUM('NEUF', 'RECONDITIONNE', 'REBUT', 'RETOURNEE', 'UTILISE'),
            allowNull: false,
        },
        reglement: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: true,
        },
        panne: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: Panne,
                key: 'id',
            }
        },
        societe: {
            type: DataTypes.INTEGER,
            allowNull: true,
            references: {
                model: Societe,
                key: 'id'
            }
        },
    },
    {
        tableName: 'piece_detachee',
        timestamps: false,
    }
);
const Salarie = sequelize.define("Salarie",
    {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        employe: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: User,
                key: 'id',
            }
        },
        cnss: {
            type: DataTypes.STRING(11),
            allowNull: false,
        },
        salaire: {
            type: DataTypes.DECIMAL(9, 3),
            allowNull: false,
        },
        situation: {
            type: DataTypes.ENUM('C', 'M', 'D', 'V'),
            allowNull: false,
        },
        nbr_enfant: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        emploi: {
            type: DataTypes.STRING(50),
            allowNull: false,
        },
        categorie: {
            type: DataTypes.STRING(3),
            allowNull: false,
        },
        echelon: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        date_embauche: {
            type: DataTypes.DATEONLY,
            allowNull: false,
        },
        createdAt: {
            type: DataTypes.DATE,
            allowNull: false,
            defaultValue: DataTypes.NOW,
        },
        compte_bancaire: {
            type: DataTypes.STRING(20),
            allowNull: true,
        },
    },
    {
        tableName: 'salarie',
        timestamps: true,
    }
);
const FicheParametre = sequelize.define("FicheParametre",
    {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        taux_heure_supp: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
        },
        taux_heure_nuit: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
        },
        taux_cnss: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
        },
        taux_css: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
        },
        taux_accidents: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
        },
        taux_contribution: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
        },
        taux_pro: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
        },
        createdAt: {
            type: DataTypes.DATE,
            allowNull: false,
            defaultValue: DataTypes.NOW,
        },
        societe: {
            type: DataTypes.INTEGER,
            allowNull: true,
            references: {
                model: Societe,
                key: 'id'
            }
        },
    }, {
    tableName: 'fiche_parametre',
    timestamps: false,
});
const FichePaie = sequelize.define("FichePaie",
    {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        mois: {
            type: DataTypes.STRING(20),
            allowNull: false,
        },
        salarie: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: Salarie,
                key: 'id',
            }
        },
        avance: {
            type: DataTypes.DECIMAL(9, 3),
            allowNull: false,
        },
        nbr_heure: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        nbr_heure_nuit: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        nbr_heure_supp: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        parametres: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: FicheParametre,
                key: 'id',
            }
        },
        date_paiement: {
            type: DataTypes.DATE,
            allowNull: true,
        },
        salaire_net: {
            type: DataTypes.DECIMAL(9, 3),
            allowNull: false,
        },
    }, {
    tableName: 'fiche_paie',
    timestamps: false,
});
const Prime = sequelize.define("Prime",
    {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        nom: {
            type: DataTypes.STRING(50),
            allowNull: false,
        },
        montant: {
            type: DataTypes.DECIMAL(9, 3),
            allowNull: false,
        },
        nbr: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        fichePaie: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: FichePaie,
                key: 'id',
            }
        }
    }, {
    tableName: 'prime',
    timestamps: false,
}
);
const Document = sequelize.define('Document', {
    id: {
        type: DataTypes.INTEGER, primaryKey: true,
        autoIncrement: true
    },
    type: {
        type: DataTypes.STRING,
        allowNull: false
    },
    nom: {
        type: DataTypes.STRING,
        allowNull: false
    },
    vehicule: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Vehicule,
            key: 'id'
        }
    },
    user: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: User,
            key: 'id'
        }
    },
    violation: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Violation,
            key: 'id'
        }
    },
    assurance: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Assurance,
            key: 'id'
        }
    },
    client: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Client,
            key: 'id'
        }
    },
    paiement: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Paiement,
            key: 'id'
        }
    },
    dossierPaiement: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: DossierPaiement,
            key: 'id'
        }
    },
    pieceDetachee: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: PieceDetachee,
            key: 'id'
        }
    },
    reparation: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Reparation,
            key: 'id'
        }
    },
    date: {
        type: DataTypes.DATEONLY,
        allowNull: false,
        defaultValue: DataTypes.NOW
    },
    fichiers: {
        type: DataTypes.JSON,
        allowNull: false,
        defaultValue: []
    },
    societe: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Societe,
            key: 'id'
        }
    }
}, {
    tableName: 'document',
    timestamps: false
});

Document.belongsTo(Vehicule, { foreignKey: 'vehicule', as: 'Vehicule', constraints: false });
Document.belongsTo(User, { foreignKey: 'user', as: 'User', constraints: false });
Document.belongsTo(Violation, { foreignKey: 'violation', as: 'Violation', constraints: false });
Document.belongsTo(Assurance, { foreignKey: 'assurance', as: 'Assurance', constraints: false });
Document.belongsTo(Client, { foreignKey: 'client', as: 'Client', constraints: false });
Document.belongsTo(Paiement, { foreignKey: 'paiement', as: 'Paiement', constraints: false });
Document.belongsTo(DossierPaiement, { foreignKey: 'dossierPaiement', as: 'DossierPaiement', constraints: false });
Document.belongsTo(PieceDetachee, { foreignKey: 'pieceDetachee', as: 'PieceDetachee', constraints: false });
Document.belongsTo(Reparation, { foreignKey: 'reparation', as: 'Reparation', constraints: false });
Document.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe', constraints: false });

FichePaie.belongsTo(Salarie, { foreignKey: 'salarie', as: 'Salarie' });
Salarie.hasMany(FichePaie, { foreignKey: 'salarie', sourceKey: 'id', as: 'FichesPaie' });

Prime.belongsTo(FichePaie, { foreignKey: 'fichePaie', as: 'FichePaie' });
FichePaie.hasMany(Prime, { foreignKey: 'fichePaie', sourceKey: 'id', as: 'Primes' });

FichePaie.belongsTo(FicheParametre, { foreignKey: 'parametres', as: 'Parametres' });
FicheParametre.hasMany(FichePaie, { foreignKey: 'parametres', sourceKey: 'id', as: 'FichesPaie' });

Salarie.belongsTo(User, { foreignKey: 'employe', as: 'Employe' });
User.hasMany(Salarie, { foreignKey: 'employe', sourceKey: 'id', as: 'Salaries' });

Prestation.belongsTo(Dossier, { foreignKey: 'dossier', as: 'Dossier' });
Dossier.hasMany(Prestation, { foreignKey: 'dossier', as: 'Prestations' });

Dossier.belongsTo(Abonne, { foreignKey: 'abonne', as: 'Abonne' });

Intervention.hasMany(Prestation, { foreignKey: 'intervention', as: 'Prestations' });
Prestation.belongsTo(Intervention, { foreignKey: 'intervention', as: 'Intervention' });

Panne.hasMany(PieceDetachee, { foreignKey: 'panne', as: 'PieceDetachees' });
PieceDetachee.belongsTo(Panne, { foreignKey: 'panne', as: 'Panne' });
Panne.hasMany(PieceDetachee, { foreignKey: 'panne', as: 'PieceRetournees' });

Garage.hasMany(Reparation, { foreignKey: 'garage', as: 'Reparations' });
Reparation.belongsTo(Garage, { foreignKey: 'garage', as: 'Garage' });

Panne.hasOne(Reparation, { foreignKey: 'panne', as: 'Reparation' });
Reparation.belongsTo(Panne, { foreignKey: 'panne', as: 'Panne' });

Vehicule.hasMany(Panne, { foreignKey: 'vehicule', as: 'Pannes' });
Panne.belongsTo(Vehicule, { foreignKey: 'vehicule', as: 'Vehicule' });

Vehicule.hasMany(DossierPaiement, { foreignKey: 'ref', as: 'DossierPaiements', constraints: false });
DossierPaiement.belongsTo(Vehicule, { foreignKey: 'ref', targetKey: 'id', constraints: false, as: 'Vehicule' });


DossierPaiement.hasMany(Paiement, { foreignKey: 'dossier_paiement', as: 'Paiements' });
Paiement.belongsTo(DossierPaiement, { foreignKey: 'dossier_paiement', as: 'DossierPaiement' });

Vehicule.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe' });
Societe.hasMany(Vehicule, { foreignKey: 'societe', sourceKey: 'id', as: 'Vehicules' });

// User -> Associer
User.hasMany(Associer, { foreignKey: 'chauffeur', sourceKey: 'id', as: 'Associers' });
User.hasOne(Associer, {
    as: 'LatestAssocier',
    foreignKey: 'chauffeur',

    sourceKey: 'id',

    constraints: false // because it's a pseudo relation
});
// Vehicule -> Associer
Vehicule.hasMany(Associer, { foreignKey: 'vehicule', sourceKey: 'id', as: 'VehiculeAssociers' });
Vehicule.hasOne(Associer, { foreignKey: 'vehicule', as: 'LatestAssocier', constraints: false })
Associer.belongsTo(Vehicule, { foreignKey: 'vehicule', as: 'Vehicule' });
Associer.belongsTo(User, { foreignKey: 'chauffeur', as: 'Chauffeur' });


Client.hasMany(Dossier, { foreignKey: 'client', as: 'Dossiers' });
Dossier.belongsTo(Client, { foreignKey: 'client', as: 'Client' });

Associer.hasMany(Dossier, { foreignKey: 'associer', as: 'Dossiers' });
Dossier.belongsTo(Associer, { foreignKey: 'associer', as: 'Associer' });

Abonne.hasMany(Dossier, { foreignKey: 'abonne', as: 'Dossiers' });

Demande.hasMany(DemandeResponse, { foreignKey: 'demande', as: 'DemandeResponses' });
DemandeResponse.belongsTo(Demande, { foreignKey: 'demande', as: 'Demande' });


Violation.belongsTo(User, { foreignKey: 'chauffeur', as: 'Chauffeur' });
Violation.belongsTo(Vehicule, { foreignKey: 'vehicule', as: 'Vehicule' });

User.hasMany(Violation, { foreignKey: 'chauffeur', sourceKey: 'id', as: 'Violations' });
Vehicule.hasMany(Violation, { foreignKey: 'vehicule', sourceKey: 'id', as: 'Violations' });
Societe.hasMany(Abonnement, { foreignKey: 'societe', as: 'Abonnements' });

Societe.hasOne(User, { foreignKey: 'societe', as: 'Admin' });

Societe.hasMany(User, { foreignKey: 'societe', as: 'Users' });

Assurance.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe' });

Client.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe' });

Dossier.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe' });

Garage.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe' });

Intervention.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe' });

User.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe' });

Abonnement.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe' });

Abonne.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe' });

Prestation.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe' });

DossierPaiement.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe' });

Notification.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe' });

Demande.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe' });

PieceDetachee.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe' });

FicheParametre.belongsTo(Societe, { foreignKey: 'societe', as: 'Societe' });

Pointage.belongsTo(User, { foreignKey: 'userId', as: 'User' });
User.hasMany(Pointage, { foreignKey: 'userId', sourceKey: 'id', as: 'Pointages' });
User.hasOne(Pointage, { foreignKey: 'userId', sourceKey: 'id', as: 'LatestPointage', constraints: false });
Pointage.hasOne(Location, { foreignKey: 'pointageId', as: 'Location' });

Intervention.belongsTo(Assurance, { foreignKey: 'assurance', as: 'Assurance' });
Intervention.belongsTo(Client, { foreignKey: 'client', as: 'Client' });
Assurance.hasMany(Intervention, { foreignKey: 'assurance', sourceKey: 'id', as: 'Interventions' });
Client.hasMany(Intervention, { foreignKey: 'client', sourceKey: 'id', as: 'Interventions' });


module.exports = { sequelize, Societe, Abonnement, FicheParametre, FichePaie, Prime, Salarie, PieceDetachee, Garage, Intervention, Demande, DemandeResponse, Notification, Pointage, Location, Paiement, DossierPaiement, Rattache, Prestation, Permis, Panne, Log, Abonne, Associer, Assurance, Client, Document, Dossier, Reparation, User, Vehicule, Violation };