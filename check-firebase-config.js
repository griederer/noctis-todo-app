// Script para verificar tu configuración de Firebase
// Ejecuta con: node check-firebase-config.js

const fs = require('fs');
const path = require('path');

console.log('🔍 Verificando configuración de Firebase...\n');

// Check if .env.local exists
const envPath = path.join(__dirname, '.env.local');
if (!fs.existsSync(envPath)) {
  console.error('❌ No se encontró el archivo .env.local');
  console.log('📝 Crea el archivo .env.local con tus credenciales de Firebase');
  console.log('   Puedes usar: cp env.local.example .env.local\n');
  process.exit(1);
}

// Read and check .env.local
const envContent = fs.readFileSync(envPath, 'utf8');
const requiredVars = [
  'REACT_APP_FIREBASE_API_KEY',
  'REACT_APP_FIREBASE_AUTH_DOMAIN',
  'REACT_APP_FIREBASE_PROJECT_ID',
  'REACT_APP_FIREBASE_STORAGE_BUCKET',
  'REACT_APP_FIREBASE_MESSAGING_SENDER_ID',
  'REACT_APP_FIREBASE_APP_ID'
];

let allGood = true;

requiredVars.forEach(varName => {
  const regex = new RegExp(`^${varName}=(.+)$`, 'm');
  const match = envContent.match(regex);
  
  if (!match || !match[1] || match[1].includes('tu-') || match[1].includes('your-') || match[1].includes('YOUR_')) {
    console.error(`❌ ${varName} no está configurado correctamente`);
    allGood = false;
  } else {
    console.log(`✅ ${varName} está configurado`);
  }
});

if (allGood) {
  console.log('\n🎉 ¡Configuración completa! Tu app debería funcionar correctamente.');
  console.log('📝 Recuerda reiniciar el servidor con: npm start');
} else {
  console.log('\n⚠️  Faltan algunas configuraciones.');
  console.log('📝 Asegúrate de reemplazar todos los valores con los de tu proyecto de Firebase.');
}

console.log('\n💡 Tip: Si sigues teniendo problemas, verifica también:');
console.log('   - Que hayas habilitado Google Auth en Firebase');
console.log('   - Que hayas creado la base de datos Firestore');
console.log('   - Que hayas configurado las URLs de redirección en Google Cloud Console'); 