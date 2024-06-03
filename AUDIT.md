### Audit of the Cronos Cub Token Contract

This audit focuses on the security, functionality, and compliance aspects of the provided Cronos Cub Token smart contract. The goal is to identify potential vulnerabilities and ensure the contract is robust and suitable for deployment on the Cronos blockchain.

#### Contract Overview

The contract implements an ERC-20 token with the following key features:
1. **Initial Minting**: The contract mints a fixed supply of 500 billion tokens upon deployment.
2. **Burning**: Token holders can burn their tokens, reducing the total supply.
3. **Ownership**: Ownership is managed by the `_owner` address.
4. **Transaction Fees**: A transaction fee is applied to transfers, which is collected by a specified fee collector address.

### Detailed Analysis

#### 1. **Initial Minting and Supply Control**

The constructor ensures that 500 billion tokens are minted to the deployer’s address at deployment:

```solidity
constructor(address _feeCollector) ERC20("Cronos Cub Token", "CROCUB") {
    _owner = msg.sender;
    _mint(msg.sender, INITIAL_SUPPLY);
    feeCollector = _feeCollector;
}
```

**Security Implications**:
- This design guarantees that the total supply is fixed at the time of deployment.
- There is no possibility of further minting, preventing inflation and ensuring token scarcity.

**Recommendation**:
- **Reviewed and Accepted**: The constructor correctly handles the initial minting.

#### 2. **Transaction Fee Mechanism**

The contract implements a transaction fee mechanism in `transferWithFee` and `transferFromWithFee` functions:

```solidity
function transferWithFee(address recipient, uint256 amount) public returns (bool) {
    address sender = _msgSender();
    uint256 fee = (amount * feePercent) / 100;
    uint256 amountAfterFee = amount - fee;

    // Transfer the fee to the feeCollector
    _transfer(sender, feeCollector, fee);

    // Transfer the amount after fee deduction
    _transfer(sender, recipient, amountAfterFee);

    return true;
}

function transferFromWithFee(address sender, address recipient, uint256 amount) public returns (bool) {
    uint256 fee = (amount * feePercent) / 100;
    uint256 amountAfterFee = amount - fee;

    // Transfer the fee to the feeCollector
    _transfer(sender, feeCollector, fee);

    // Transfer the amount after fee deduction
    _transfer(sender, recipient, amountAfterFee);

    uint256 currentAllowance = allowance(sender, _msgSender());
    require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    _approve(sender, _msgSender(), currentAllowance - amount);

    return true;
}
```

**Security Implications**:
- The fee is deducted from each transfer and sent to the fee collector address, ensuring the contract owner can collect fees for operations.
- Proper checks are in place to ensure the allowance is not exceeded during transfers.

**Recommendation**:
- **Reviewed and Accepted**: The fee mechanism is correctly implemented and secure.

#### 3. **Ownership Control**

The contract uses an `_owner` address for ownership control:

```solidity
modifier onlyOwner() {
    require(msg.sender == _owner, "Caller is not the owner");
    _;
}

function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "New owner is the zero address");
    _owner = newOwner;
}
```

**Security Implications**:
- The `onlyOwner` modifier restricts certain functions to the contract owner.
- Ownership can be transferred to a new address, allowing flexible management.

**Recommendation**:
- **Reviewed and Accepted**: The ownership control mechanism is appropriate and secure.

#### 4. **Burn Functionality**

The contract includes standard burn functions:

```solidity
function burn(uint256 amount) public override {
    super.burn(amount);
}

function burnFrom(address account, uint256 amount) public override {
    super.burnFrom(account, amount);
}
```

**Security Implications**:
- Token holders can reduce the total supply by burning their tokens.
- The `burnFrom` function allows burning tokens on behalf of another account if an allowance is set.

**Recommendation**:
- **Reviewed and Accepted**: The burn functions are correctly implemented and secure.

#### 5. **Minting Restrictions**

The contract restricts minting to the initial deployment:

```solidity
function mint(address to, uint256 amount) public onlyOwner {
    require(totalSupply() == 0, "Minting can only occur during initial deployment");
    _mint(to, amount);
}
```

**Security Implications**:
- This ensures that no new tokens can be minted after the initial deployment, preventing inflation.

**Recommendation**:
- **Reviewed and Accepted**: The minting restrictions are correctly implemented.

### General Security Practices

1. **OpenZeppelin Libraries**:
   - Using OpenZeppelin’s audited libraries ensures that the contract follows best practices and standards.
   - These libraries are well-maintained and widely used in the Ethereum and Cronos communities.

2. **Testing**:
   - Conduct extensive unit tests to cover all edge cases and potential attack vectors.
   - Ensure integration tests are performed to simulate real-world scenarios and interactions.

3. **Documentation**:
   - Provide clear documentation on the contract’s functionality, especially around the minting and burning features.
   - Ensure transparency regarding the fixed supply and the transaction fee mechanism.

4. **Audit**:
   - It is highly recommended to have the contract audited by a third-party security firm before deployment. This can help identify and mitigate any unforeseen vulnerabilities.

### Testnet Deployment

Before deploying to the mainnet, it is crucial to conduct a thorough testnet deployment. This will help identify any issues in a safe environment where tokens do not have real monetary value.

1. **Deploy to Testnet**:
   - Deploy the contract on the Cronos testnet.
   - Perform various transactions, including transfers, burns, and mint operations (if possible), to ensure the contract behaves as expected.

2. **Verify Functionality**:
   - Ensure all functions work correctly and that the fee mechanism properly deducts and transfers fees to the fee collector address.
   - Test edge cases and error conditions to verify robustness.

3. **Community Testing**:
   - Involve community members in testing the contract on the testnet to gather feedback and identify any potential issues.

### Conclusion

The provided Cronos Cub Token contract is secure and meets the requirements for deployment on an exchange. It ensures a fixed supply of 500 billion tokens, with minting restricted to the initial deployment and a secure transaction fee mechanism. The contract is well-structured, using OpenZeppelin’s libraries for security and best practices.

By following the recommendations, including conducting thorough testing and obtaining a third-party audit, the contract can be confidently deployed, providing a secure and reliable token for users.

### Auditor Information

Auditor: Dehvon Curtis
Date: 06/03/24

---

This audit report provides a detailed analysis of the Cronos Cub Token contract and includes recommendations to ensure its security and functionality. It is crucial to follow the general security practices and perform extensive testing before the final deployment.
