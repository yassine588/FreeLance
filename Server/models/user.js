const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const userSchema = new mongoose.Schema({
  nom: {
    type: String,
    maxlength: 20,
    default: null
  },
  prenom: {
    type: String,
    maxlength: 30,
    default: null
  },
  email: {
    type: String,
    required: true,
    maxlength: 50,
    unique: true
  },
  password: {
    type: String,
    required: true
  },
  photoProfile: {
    type: String,
    maxlength: 50,
    default: null
  },
  role: {
    type: String,
    enum: ['ADMIN', 'OPERATEUR', 'CHAUFFEUR', 'CHEF_PARK'],
    required: true
  },
  cin: {
    type: String,
    maxlength: 8,
    default: null
  },
  telephone: {
    type: String,
    maxlength: 12,
    default: null
  },
  active: {
    type: Boolean,
    default: true,
    required: true
  },
  verified: {
    type: Boolean,
    default: true,
    required: true
  },
  email_token: {
    type: String,
    maxlength: 50,
    default: null
  },
  societe: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Societe',
    default: null
  }
}, {
  collection: 'user',
  timestamps: false
});

// 🔐 Hash password before saving
userSchema.pre('save', async function (next) {
  if (this.isModified('password')) {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
  }
  next();
});

// 🔐 Hash password before updating
userSchema.pre('findOneAndUpdate', async function (next) {
  if (this._update.password) {
    const salt = await bcrypt.genSalt(10);
    this._update.password = await bcrypt.hash(this._update.password, salt);
  }
  next();
});

// ✅ Method to compare passwords (login check)
userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
