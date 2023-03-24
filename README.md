<img src="https://uploads-ssl.webflow.com/63e41f305232fcaa8d352e16/63e5e642106e91fb54174c0a_Logo%20with%20Title.png" width="500">

---

# TYON

Tyrion is poised to revolutionize the crypto industry by providing volatility-safe, Regenerative finance (REFI) focused, utility driven services and products that help users build better, more secure portfolios that are protected from market fluctuations. We seek to make cryptocurrency a viable option for mainstream adoption by eliminating the need for users to understand complicated technical concepts or have tech-savvy skills. With a vibrant community of empowered individuals and with our community-driven mindset, we are committed to bringing the potential of blockchain and cryptocurrency to the masses and paving the way for a new era in digital finance. The safe-haven catalyst that we strive to be is a critical part of our mission – it is essential for us to provide ways to safeguard consumer's digital assets from market uncertainities, crashes, rugpulls and never ending winters.

## DEPLOYMENT INSTRUCTIONS

---

- Install truffle globally.

        $npm install -g truffle

- Clone the github repo.

        $git clone https://github.com/tyrion-solutions/token-launch.git

- Install all other packages.

        $cd token-launch
        $npm install

- Create a .env file with following variables.

        BSCSCAN_API_KEY=ABCDEFGHIJKLMNOPQRST

  ( NB: Never use the above value, Update the data )

- Create a .secret file and add your mnemonic.

        block chain developer photo scheme wild three attitude clip super man meat

  ( NB: Never use the above value, Update it with your mnemonic )

- Compile the contracts.

        $truffle compile

- Deploy the contract.

        $truffle migrate --network binance

  ( NB: change network accordingly. [*refer truffle-config.js*] )

- Verify the contract code.

        $truffle run verify TYON_V1 --network binance

## Test

---

Prerequisite : Truffle ( https://github.com/trufflesuite/truffle#readme ).

truffle netwok configuration

```
host: 127.0.0.1
port: 7545
network_id: 5777
```

---

### install

```
$npm install
```

### compile

```
$truffle compile
```

### migration

```
$truffle migrate
```

## Test

---

```
$truffle test
```

## Deployed Contract Details (BSC Test Network)

---

- TYON_V1 - https://testnet.bscscan.com/token/0xD748Bb49130D26c48d8e8B7817BbC40e552c0AEd
