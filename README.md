# LP Zapper

Solidity contract to convert native gas tokens into some desired V2 LP token.

## How it works

The contract trades the native token for the desired ERC20 token and a wrapped native token (WETH, or i.e. WMATIC). 
Users can then "zap" their native gas tokens into an LP token via the `zap()` function.

Contract does not define the LP address, instead parses it from the factory.

Dev address recieves fees and leftover tokens.

## Development

The project is built with Hardhat & Ethers v5.

1. Install dependencies

```bash
pnpm install
```

2. Update the contract source code in `contracts/`

- [Zap.sol](contracts/Zap.sol) is The main contract that converts gas tokens into the target LP token.

**Change the addresses for the target...**:
- **DEX factory** (the contract that creates the LP tokens)
- **DEX router** (the contract that executes the trades)
- **WETH** (the wrapped native token)
- **ERC20** (the desired project token to pair with)

3. Compile the contracts

```bash
pnpm hardhat compile
```

4. Run tests

```bash
pnpm test
```

5. Deploy the contract

```bash
pnpm deploy
```

## License

MIT

