var ursa = require('ursa');
console.log(ursa.generatePrivateKey().toPublicPem('utf8'));
