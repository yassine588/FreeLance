const { default: mongoose } = require("mongoose");

const Societe = mongoose.Schema('Societe', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    nom: {
        type: DataTypes.STRING(50),
        allowNull: false
    },
    numero_fiscale: {
        type: DataTypes.STRING(20),
        allowNull: false,
        unique: true
    },
    email: {
        type: DataTypes.STRING(50),
        allowNull: false,
        unique: true
    },
    adresse: {
        type: DataTypes.JSON,
        allowNull: true
    },
    telephone: {
        type: DataTypes.STRING(12),
        allowNull: true
    },
    cnss: {
        type: DataTypes.STRING(12),
        allowNull: true
    },
    logo: {
        type: DataTypes.STRING,
        allowNull: true,
    },
}, {
    tableName: 'societe',
    timestamps: false
});