export const errorHandler = (err, _req, res, _next) => {
    console.error('[API Error]:', err.stack || err.message);
    res.status(500).json({
        success: false,
        error: err.message || 'Internal Server Error'
    });
};
