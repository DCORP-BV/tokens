Date.prototype.getUnixTime = function() { 
    return this.getTime()/1000|0;
};

module.exports = {
    now: parseInt(new Date().getTime() / 1000),
    hours: 3600,
    days: 86400,
    weeks: 604800,
    years: 31536000
}