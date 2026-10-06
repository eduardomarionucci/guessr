import { readFile } from 'node:fs/promises';
import { initializeApp, applicationDefault, deleteApp } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

const config = JSON.parse((await readFile(new URL('../../firebase-config.json', import.meta.url), 'utf8')).replace(/^\uFEFF/, ''));
const projectId = config.FIREBASE_PROJECT_ID;
if (!projectId || projectId.startsWith('YOUR_')) throw new Error('Configure FIREBASE_PROJECT_ID primeiro.');
const capitals = JSON.parse((await readFile(new URL('capitals.json', import.meta.url), 'utf8')).replace(/^\uFEFF/, ''));
const response = await fetch('https://servicodados.ibge.gov.br/api/v1/localidades/estados?orderBy=nome', {
  signal: AbortSignal.timeout(20000),
});
if (!response.ok) throw new Error(`IBGE retornou HTTP ${response.status}`);
const rows = await response.json();
const states = Object.fromEntries(rows.map(row => [row.sigla, row.nome]));
if (Object.keys(states).length !== 27 || Object.keys(capitals).length !== 27 ||
    Object.keys(states).some(uf => typeof capitals[uf] !== 'string' || !capitals[uf].trim())) {
  throw new Error('São necessárias 27 UFs e suas respectivas capitais.');
}
const app = initializeApp({ credential: applicationDefault(), projectId });
try {
  const ref = getFirestore(app).collection('quiz_catalog').doc('capitais-do-brasil');
  // create() falha se o documento já existir, preservando edições no banco.
  await ref.create({
    title: 'Capitais do Brasil',
    description: 'Encontre as 27 capitais pelas pistas de cada UF.',
    hint: 'Digite uma capital...', duration: 900, capitals, states,
    source: 'UFs: IBGE Localidades; capitais: cadastro editorial',
    createdAt: FieldValue.serverTimestamp(),
  });
  console.log('Documento quiz_catalog/capitais-do-brasil criado.');
} finally {
  await deleteApp(app);
}
