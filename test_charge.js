import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    stages: [
        { duration: '30s', target: 50 },  // Monter jusqu'à 50 utilisateurs simultanés en 30s
        { duration: '1m', target: 50 },   // Maintenir 50 utilisateurs pendant 1 minute
        { duration: '30s', target: 0 },   // Descendre à 0 utilisateurs en 30s
    ],
};

export default function () {
    const url = 'https://paas-ctgsawbjg0esa4c9.francecentral-01.azurewebsites.net';  // Remplace par l'URL de ton App Service
    const res = http.get(url);

    check(res, {
        'status est 200': (r) => r.status === 200,
        'temps de réponse < 500ms': (r) => r.timings.duration < 500,
    });

    sleep(1);  // Pause d'une seconde entre chaque itération
}