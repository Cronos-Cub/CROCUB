# Function/Feature Report for Cronos Cub $CROCUB Smart Contract

## Contract Overview
The CronosCubToken contract implements an ERC20 token with additional functionalities such as burning and vesting schedules. It leverages OpenZeppelin libraries for secure and efficient implementations.

## Features
1. **ERC20 Token Standard**: Implements the ERC20 standard for fungible tokens.
2. **Burnable Tokens**: Allows tokens to be burned, reducing the total supply.
3. **Ownership Control**: Uses Ownable for ownership management.
4. **Initial Supply**: Mints an initial supply of 500 billion tokens to the deployer's address.
5. **Vesting Schedule**: Implements vesting schedules for airdrop and development team tokens.

## Functions
### Constructor
- **constructor(address _initialOwner)**: Initializes the contract, mints the initial supply to `_initialOwner`, and sets `_initialOwner` as the contract owner.

### Minting
- **mint(address to, uint256 amount)**: Allows the owner to mint tokens only once during initial deployment.

### Burning
- **burn(uint256 amount)**: Allows token holders to burn their tokens.
- **burnFrom(address account, uint256 amount)**: Allows tokens to be burned from a specified address.

### Vesting
- **createVestingSchedule(address beneficiary, uint256 totalAmount, uint256 startTime, uint256 cliffDuration, uint256 duration)**: Creates a vesting schedule for a beneficiary.
- **releaseVestedTokens()**: Releases vested tokens according to the vesting schedule.
- **_vestedAmount(VestingSchedule memory schedule)**: Internal function to calculate vested tokens.

## Events
- **VestingScheduleCreated(address indexed beneficiary, uint256 totalAmount, uint256 startTime, uint256 cliffDuration, uint256 duration)**: Emitted when a vesting schedule is created.
- **TokensReleased(address indexed beneficiary, uint256 amount)**: Emitted when vested tokens are released.

## Summary
The Cronos Cub Token smart contract effectively integrates essential features such as burning, ownership control, and vesting schedules. The use of OpenZeppelin libraries enhances its security and reliability, making it suitable for production deployment.
