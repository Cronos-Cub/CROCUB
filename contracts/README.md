### Cronos Cub Token (CROCUB) Smart Contract: Features and Functions Summary

Below is a detailed summary of the features and functions of the Cronos Cub Token (CROCUB) smart contract:

#### Token Details
- **Name**: Cronos Cub Token
- **Symbol**: CROCUB
- **Total Supply**: 500 billion tokens (500,000,000,000)

#### Contract Variables
- **INITIAL_SUPPLY**: Constant defining the initial supply of tokens.
- **_owner**: Address of the contract owner.
- **feeCollector**: Address where the transaction fees are collected.
- **feePercent**: Percentage of transaction fees charged (initially set to 3%).

#### Modifiers
- **onlyOwner**: Ensures that only the owner can call certain functions.

#### Events
- **FeePercentUpdated**: Emitted when the fee percentage is updated.
- **FeeCollectorUpdated**: Emitted when the fee collector address is updated.
- **VestingScheduleCreated**: Emitted when a vesting schedule is created.
- **TokensReleased**: Emitted when vested tokens are released.

#### Constructor
- **constructor(address _feeCollector)**: Initializes the contract with the initial supply of tokens, sets the owner, and assigns the fee collector address.

```solidity
constructor(address _feeCollector) ERC20("Cronos Cub Token", "CROCUB") {
    _owner = msg.sender;
    _mint(msg.sender, INITIAL_SUPPLY);
    feeCollector = _feeCollector;
}
```

#### Functions

1. **Token Transfer Functions with Fees**
    - **transferWithFee(address recipient, uint256 amount)**: Transfers tokens with a fee deducted.
    - **transferFromWithFee(address sender, address recipient, uint256 amount)**: Transfers tokens on behalf of another address with a fee deducted.

    ```solidity
    function transferWithFee(address recipient, uint256 amount) public returns (bool) {
        address sender = _msgSender();
        uint256 fee = (amount * feePercent) / 100;
        uint256 amountAfterFee = amount - fee;

        _transfer(sender, feeCollector, fee);
        _transfer(sender, recipient, amountAfterFee);

        return true;
    }

    function transferFromWithFee(address sender, address recipient, uint256 amount) public returns (bool) {
        uint256 fee = (amount * feePercent) / 100;
        uint256 amountAfterFee = amount - fee;

        _transfer(sender, feeCollector, fee);
        _transfer(sender, recipient, amountAfterFee);

        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }
    ```

2. **Fee Management Functions**
    - **setFeePercent(uint256 _feePercent)**: Allows the owner to set the fee percentage.
    - **setFeeCollector(address _feeCollector)**: Allows the owner to set the fee collector address.

    ```solidity
    function setFeePercent(uint256 _feePercent) external onlyOwner {
        require(_feePercent <= 10, "Fee percent too high");
        feePercent = _feePercent;
        emit FeePercentUpdated(_feePercent);
    }

    function setFeeCollector(address _feeCollector) external onlyOwner {
        require(_feeCollector != address(0), "Invalid address");
        feeCollector = _feeCollector;
        emit FeeCollectorUpdated(_feeCollector);
    }
    ```

3. **Minting Function**
    - **mint(address to, uint256 amount)**: Allows the owner to mint new tokens only during the initial deployment.

    ```solidity
    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() == 0, "Minting can only occur during initial deployment");
        _mint(to, amount);
    }
    ```

4. **Burn Functionality**
    - **burn(uint256 amount)**: Allows token holders to burn their tokens, reducing the total supply.
    - **burnFrom(address account, uint256 amount)**: Allows burning tokens from a specific address.

    ```solidity
    function burn(uint256 amount) public override {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount) public override {
        super.burnFrom(account, amount);
    }
    ```

5. **Ownership Management Functions**
    - **owner() public view returns (address)**: Returns the address of the current owner.
    - **transferOwnership(address newOwner)**: Transfers ownership to a new address.

    ```solidity
    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        _owner = newOwner;
    }
    ```

6. **Vesting Functions**
    - **createVestingSchedule(address beneficiary, uint256 totalAmount, uint256 startTime, uint256 cliffDuration, uint256 duration)**: Creates a vesting schedule for a beneficiary.
    - **releaseVestedTokens() external**: Releases vested tokens according to the vesting schedule.
    - **_vestedAmount(VestingSchedule memory schedule) internal view returns (uint256)**: Calculates the amount of tokens that have vested but not yet been released.

    ```solidity
    function createVestingSchedule(
        address beneficiary,
        uint256 totalAmount,
        uint256 startTime,
        uint256 cliffDuration,
        uint256 duration
    ) external onlyOwner {
        require(beneficiary != address(0), "Invalid address");
        require(totalAmount > 0, "Amount must be greater than 0");
        require(duration > 0, "Duration must be greater than 0");
        require(startTime + duration > block.timestamp, "End time is before current time");

        vestingSchedules[beneficiary] = VestingSchedule({
            totalAmount: totalAmount,
            amountReleased: 0,
            startTime: startTime,
            cliffDuration: cliffDuration,
            duration: duration
        });

        _transfer(msg.sender, address(this), totalAmount);
        emit VestingScheduleCreated(beneficiary, totalAmount, startTime, cliffDuration, duration);
    }

    function releaseVestedTokens() external {
        VestingSchedule storage schedule = vestingSchedules[msg.sender];
        require(schedule.totalAmount > 0, "No vesting schedule found");

        uint256 vestedAmount = _vestedAmount(schedule);
        uint256 unreleasedAmount = vestedAmount - schedule.amountReleased;

        require(unreleasedAmount > 0, "No tokens are due");

        schedule.amountReleased += unreleasedAmount;
        _transfer(address(this), msg.sender, unreleasedAmount);
        emit TokensReleased(msg.sender, unreleasedAmount);
    }

    function _vestedAmount(VestingSchedule memory schedule) internal view returns (uint256) {
        if (block.timestamp < schedule.startTime + schedule.cliffDuration) {
            return 0;
        } else if (block.timestamp >= schedule.startTime + schedule.duration) {
            return schedule.totalAmount;
        } else {
            return (schedule.totalAmount * (block.timestamp - schedule.startTime)) / schedule.duration;
        }
    }
    ```

### Summary

The Cronos Cub Token (CROCUB) smart contract includes the following features:
- **Fixed Supply**: 500 billion tokens minted upon deployment.
- **Burnable**: Tokens can be burned to reduce the total supply.
- **Transaction Fees**: A percentage of each transaction is collected as a fee.
- **Ownership Management**: Functions to manage contract ownership.
- **Vesting**: Mechanism to create and release vesting schedules for tokens.
- **Events**: Emitting events for transparency and off-chain tracking.

This comprehensive structure ensures that the Cronos Cub Token contract supports essential features such as transaction fees, ownership transfer, and vesting for early investors, making it robust and secure for deployment.