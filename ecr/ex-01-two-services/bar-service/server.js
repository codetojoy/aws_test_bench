const express = require('express');
const os = require('os');

const app = express();
const port = 5150;

app.get('/api/message', async (req, res) => {
    const currentDate = new Date();
    
    let ipAddress = 'Unknown';
    const interfaces = os.networkInterfaces();
    for (const iface of Object.values(interfaces)) {
        for (const details of iface) {
            if (details.family === 'IPv4' && !details.internal) {
                ipAddress = details.address;
                break;
            }
        }
    }

    await delayedResponse(res, ipAddress, currentDate);
});

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function delayedResponse(res, ipAddress, currentDate) {
  await sleep(1000); 
  res.json({ bar_message: `TRACER BAR OK`, 
             bar_ip: ipAddress,
             bar_timestamp: currentDate });
}


app.listen(port, () => {
  console.log(`Bar running at http://localhost:${port}`);
});

