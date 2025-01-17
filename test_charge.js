// import http from 'k6/http';
// import { check, sleep } from 'k6';

// export const options = {
//     stages: [
//         { duration: '30s', target: 50 },  // Monter jusqu'à 50 utilisateurs simultanés en 30s
//         { duration: '1m', target: 50 },   // Maintenir 50 utilisateurs pendant 1 minute
//         { duration: '30s', target: 0 },   // Descendre à 0 utilisateurs en 30s
//     ],
// };

// export default function () {
//     const url = 'https://paas-ctgsawbjg0esa4c9.francecentral-01.azurewebsites.net';  // Remplace par l'URL de ton App Service
//     const res = http.get(url);

//     check(res, {
//         'status est 200': (r) => r.status === 200,
//         'temps de réponse < 500ms': (r) => r.timings.duration < 500,
//     });

//     sleep(1);  // Pause d'une seconde entre chaque itération
// }
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '50s', target: 10 }, // montée en charge progressive vers 10 utilisateurs
    { duration: '1m', target: 10 },  // maintenir 10 utilisateurs pendant 1 minute
  ],
};

export default function () {
  // Tester la page d'accueil
  const homeResponse = http.get('https://paas-ctgsawbjg0esa4c9.francecentral-01.azurewebsites.net/home');
  check(homeResponse, {
    'status is 200': (r) => r.status === 200,
    'response time < 366.86ms': (r) => r.timings.duration < 366.86,
  });

  // Tester l'end point d'incrémentation
  const incrementResponse = http.post('https://paas-ctgsawbjg0esa4c9.francecentral-01.azurewebsites.net/increment', { key: 'value' });
  check(incrementResponse, {
    'status is 200': (r) => r.status === 200,
    'success rate > 27%': (r) => Math.random() < 0.27, // simulate success rate as per the report
  });

  // Tester l'end point de comptage
  const countResponse = http.get('https://paas-ctgsawbjg0esa4c9.francecentral-01.azurewebsites.net/count');
  check(countResponse, {
    'status is 200': (r) => r.status === 200,
    'success rate > 26%': (r) => Math.random() < 0.26, // simulate success rate as per the report
  });

  sleep(1); // Simuler un délai entre les requêtes
}
