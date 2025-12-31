const express = require('express');
const os = require('os');

const axios = require('axios');
const app = express();
const port = 3000;

const BAR_SERVICE_URL = process.env.BAR_SERVICE_URL || 'http://localhost:5150';

app.get('/', async (req, res) => {
  try {
    const barResponse = await axios.get(`${BAR_SERVICE_URL}/api/message`);
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

    res.send(`
<!DOCTYPE html>
<html>
<head>

<title>2025-12 Foo Service</title>
<style>
    body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
</style>

</head>

<body>

<h3>TRACER :: 2025-12-30 Foo Service</h3>

<pre>
foo-ip: ${ipAddress}
foo-timestamp: ${currentDate}
</pre>
<hr/>
<pre>
bar-response: ${JSON.stringify(barResponse.data)}
</pre>

</body>
</html>

`);
  } catch (error) {
    res.send(`<h3>Foo Service</h3><p>Error: ${error.message}</p>`);
  }
});

app.listen(port, () => {
  console.log(`Foo running at http://localhost:${port} with BAR_SERVICE_URL=${BAR_SERVICE_URL}`);
});

