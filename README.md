# Contextual Marketing and Data Capture using WIFI based access points

```
nodogsplash router 
name = 'root'
password= 'mitra'

```
![GitHub Logo](/docs/images/digram.png)

## Web
### Node
#### Setup

+ Add  `keys.js` under `config/keys.js`
example


```
module.exports={
  google:{
    clientID:xxxxxxxxxxxxx.....
    clientSecret:xxxxxxx..........
  }
}

```
+ `nds.js` is responsible for keep user informations
```
app.get('/', (req, res) => {
    ndsvaribles._authaction = req.query['authaction'];
    ndsvaribles._tok = req.query['tok'];
    ndsvaribles._gatewayname = req.query['gatewayname'];
    ndsvaribles._redir = req.query['redir'];
    res.render('home',);
})


```


![GitHub Logo](/docs/images/servicedigram.png)

## Mobile
### Flutter
+ Creaeate an SSH tunnel after connection to access point 
```

  Future<String> _getMACOfDevice() async {
    var client = new SSHClient(
      host: "192.168.1.1",
      port: 22,
      username: "root",
      passwordOrKey: "mitra",
    );
    String isConnet;
    isConnet = await client.connect();
    if (isConnet == "session_connected") {
      print(_clientMAC);
      client.disconnect();
    }
  }

```
+ check weather device's  `MAC` is already authenticated or not  , 
+ add `allow` or `deny` of `iptables` of access point ( using 
[`nodogsplash`](https://github.com/nodogsplash/nodogsplash "nodogsplash"))


