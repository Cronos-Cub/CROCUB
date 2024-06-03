---

# Cronos Cub Token (CROCUB)

Cronos Cub Token (CROCUB) is an ERC-20 token deployed on the Cronos blockchain. This token includes features such as a fixed initial supply, burnable tokens, transaction fees, and ownership control.

## Features

1. **Fixed Supply**: The total supply of CROCUB tokens is fixed at 500 billion tokens.
2. **Ownership Control**: The contract includes ownership control mechanisms allowing the current owner to transfer ownership to a new address.
3. **Burnable Tokens**: Tokens can be burned, reducing the total supply. Tokens can also be burned from an approved address.
4. **Transaction Fees**: A transaction fee is applied to token transfers, which is collected by a specified fee collector address.

## Functions

### Constructor
```solidity
constructor(address _feeCollector) ERC20("Cronos Cub Token", "CROCUB")
```
Initializes the contract, mints the initial supply to the deployer's address, and sets the fee collector address.

### Transfer with Fee
```solidity
function transferWithFee(address recipient, uint256 amount) public returns (bool)
```
Transfers tokens with a transaction fee. The fee is transferred to the fee collector address.

### Transfer From with Fee
```solidity
function transferFromWithFee(address sender, address recipient, uint256 amount) public returns (bool)
```
Transfers tokens on behalf of another address with a transaction fee. The fee is transferred to the fee collector address, and the sender's allowance is adjusted.

### Set Fee Percent
```solidity
function setFeePercent(uint256 _feePercent) external onlyOwner
```
Allows the owner to set the transaction fee percentage.

### Set Fee Collector
```solidity
function setFeeCollector(address _feeCollector) external onlyOwner
```
Allows the owner to set the fee collector address.

### Mint
```solidity
function mint(address to, uint256 amount) public onlyOwner
```
Allows the owner to mint tokens, but only during the initial deployment. Ensures no additional minting can occur after the initial supply is minted.

### Burn
```solidity
function burn(uint256 amount) public override
```
Allows token holders to burn their tokens, reducing the total supply.

### Burn From
```solidity
function burnFrom(address account, uint256 amount) public override
```
Allows tokens to be burned from a specific address, given that an allowance is set.

### Owner
```solidity
function owner() public view returns (address)
```
Returns the address of the contract owner.

### Transfer Ownership
```solidity
function transferOwnership(address newOwner) public onlyOwner
```
Allows the owner to transfer ownership to a new address. Ensures the new owner address is not the zero address.

## Modifiers

### Only Owner
```solidity
modifier onlyOwner()
```
Restricts the execution of certain functions to the contract owner.

---

This README provides an overview of the features, functions, and deployment steps for the Cronos Cub Token smart contract.
