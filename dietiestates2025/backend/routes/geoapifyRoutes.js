/*
    REMEMBER:
    When you update a JS file and create a new service, you need to restart the server
    Run 'node server.js' from terminal (kill the process if it's already running, otherwise it won't restart properly)
    Otherwise it will keep returning 404 - Resource not found
*/
const express = require('express');
const https = require('https');
const dotenv = require('dotenv');
const router = express.Router();

// Carica le variabili d'ambiente dal file .env
dotenv.config();

// Funzione per chiamare Geoapify e ottenere le coordinate
const getCoordinatesFromAddress = async (address) => {
  const apiKey = process.env.GEOAPIFY_API_KEY;
  const encodedAddress = encodeURIComponent(address);
  const url = `https://api.geoapify.com/v1/geocode/search?text=${encodedAddress}&apiKey=${apiKey}`;

  return new Promise((resolve, reject) => {
    https.get(url, (response) => {
      let data = '';

      response.on('data', (chunk) => {
        data += chunk;
      });

      response.on('end', () => {
        try {
          const parsedData = JSON.parse(data);

          if (parsedData.features && parsedData.features.length > 0) {
            const geometry = parsedData.features[0].geometry;
            const lat = geometry.coordinates[1];
            const lon = geometry.coordinates[0];
            resolve({ lat, lon });
          } else {
            resolve(null);
          }
        } catch (error) {
          reject(error);
        }
      });
    }).on('error', (error) => {
      reject(error);
    });
  });
};

// Funzione per ottenere i punti di interesse vicini
const getNearbyPlaces = async (lat, lon, categories = [], radius = 5000, limit = 20) => {
  const apiKey = process.env.GEOAPIFY_API_KEY;
  const categoriesStr = categories.join(',');
  const url = `https://api.geoapify.com/v2/places?categories=${categoriesStr}&filter=circle:${lon},${lat},${radius}&bias=proximity:${lon},${lat}&limit=${limit}&apiKey=${apiKey}`;

  return new Promise((resolve, reject) => {
    https.get(url, (response) => {
      let data = '';

      response.on('data', (chunk) => {
        data += chunk;
      });

      response.on('end', () => {
        try {
          const parsedData = JSON.parse(data);
          resolve(parsedData.features || []);
        } catch (error) {
          reject(error);
        }
      });
    }).on('error', (error) => {
      reject(error);
    });
  });
};

// Rotta per ottenere le coordinate
router.get('/get-coordinates', async (req, res) => {
  const { address } = req.query;

  if (!address) {
    return res.status(400).json({ error: 'Address is required' });
  }

  try {
    const coordinates = await getCoordinatesFromAddress(address);

    if (coordinates) {
      res.json({ lat: coordinates.lat, lon: coordinates.lon });
    } else {
      res.status(404).json({ error: 'Address not found' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Error fetching data from Geoapify', details: error.message });
  }
});

// Rotta per ottenere i punti di interesse vicini
router.get('/get-nearby-places', async (req, res) => {
  const { address, categories, radius, limit } = req.query;

  console.log('Parametri ricevuti:', req.query);


  if (!address) {
    return res.status(400).json({ error: 'Address is required' });
  }

  try {
    const coordinates = await getCoordinatesFromAddress(address);

    if (!coordinates) {
      return res.status(404).json({ error: 'Address not found' });
    }

    const categoriesArray = categories ? categories.split(',') : [];
    const radiusNumber = radius ? parseInt(radius) : 5000;
    const limitNumber = limit ? parseInt(limit) : 20;

    const places = await getNearbyPlaces(
      coordinates.lat,
      coordinates.lon,
      categoriesArray,
      radiusNumber,
      limitNumber
    );

    const formattedPlaces = places.map(place => ({
      name: place.properties.name,
      address: place.properties.formatted,
      categories: place.properties.categories,
      distance: place.properties.distance,
      lat: place.properties.lat,
      lon: place.properties.lon
    }));

    res.json({
      coordinates,
      places: formattedPlaces,
      count: formattedPlaces.length
    });
  } catch (error) {
    res.status(500).json({
      error: 'Error fetching nearby places from Geoapify',
      details: error.message
    });
  }
});

module.exports = router;