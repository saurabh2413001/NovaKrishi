import { Request, Response } from 'express';
import { INITIAL_WEATHER } from '../utils/seedData.js';

export async function getWeather(req: Request, res: Response) {
  const apiKey = process.env.OPENWEATHER_API_KEY;
  const city = String(req.query.city || process.env.OPENWEATHER_DEFAULT_CITY || 'Gorakhpur,IN');

  if (!apiKey) {
    return res.json({
      success: true,
      live: false,
      source: 'NovaKrishi fallback',
      data: INITIAL_WEATHER,
      message: 'Set OPENWEATHER_API_KEY to enable live weather.'
    });
  }

  try {
    const url = new URL('https://api.openweathermap.org/data/2.5/weather');
    url.searchParams.set('q', city);
    url.searchParams.set('appid', apiKey);
    url.searchParams.set('units', 'metric');
    url.searchParams.set('lang', req.query.lang === 'hi' ? 'hi' : 'en');

    const response = await fetch(url, { headers: { Accept: 'application/json' } });
    const payload: any = await response.json();
    if (!response.ok) {
      return res.status(response.status).json({ success: false, message: payload?.message || 'Weather service failed.' });
    }

    const current = payload.weather?.[0] || {};
    return res.json({
      success: true,
      live: true,
      source: 'OpenWeather',
      data: {
        city: payload.name,
        country: payload.sys?.country,
        temperature: payload.main?.temp,
        feelsLike: payload.main?.feels_like,
        humidity: payload.main?.humidity,
        windSpeed: payload.wind?.speed,
        condition: current.description || current.main,
        icon: current.icon,
        rain1h: payload.rain?.['1h'] || 0,
        observedAt: payload.dt ? new Date(payload.dt * 1000).toISOString() : new Date().toISOString()
      }
    });
  } catch (error: any) {
    console.error('[weather] OpenWeather request failed:', error?.message || error);
    return res.json({ success: true, live: false, source: 'NovaKrishi fallback', data: INITIAL_WEATHER });
  }
}
