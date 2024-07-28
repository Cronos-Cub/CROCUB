// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CronosCub is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 3_000_000 * 10**18;
    uint256 public constant DEV_RESERVE = 300_000 * 10**18;
    uint256 public constant LIQUIDITY = 600_000 * 10**18;

    uint256 public communityReserve = 2_100_000 * 10**18; // Mutable state variable for community tokens
    uint256 public devReleased;
    uint256 public startTime;
    uint256 public constant VESTING_DURATION = 24 * 30 days; // 24 months

    address public liquidityAddress;
    address public devAddress;

    constructor(address _liquidityAddress, address _devAddress) ERC20("CronosCub", "CROCUB") Ownable(_devAddress) {
        require(_liquidityAddress != address(0), "Liquidity address cannot be zero address");
        require(_devAddress != address(0), "Developer address cannot be zero address");
        
        liquidityAddress = _liquidityAddress;
        devAddress = _devAddress;
        startTime = block.timestamp;

        _mint(address(this), MAX_SUPPLY);
        _transfer(address(this), liquidityAddress, LIQUIDITY);
        _transfer(address(this), devAddress, DEV_RESERVE * 20 / 100); // 20% initial release for developers
        devReleased = DEV_RESERVE * 20 / 100;
    }

    function releaseDevTokens() external onlyOwner {
        uint256 elapsedTime = block.timestamp - startTime;
        uint256 releasableAmount = (DEV_RESERVE * elapsedTime / VESTING_DURATION) - devReleased;
        require(releasableAmount > 0, "No tokens available for release");
        require(devReleased + releasableAmount <= DEV_RESERVE, "Exceeds reserved amount");

        devReleased += releasableAmount;
        _transfer(address(this), devAddress, releasableAmount);
    }

    function distributeCommunityTokens(address recipient, uint256 amount) external onlyOwner {
        require(amount <= communityReserve, "Exceeds community distribution limit");
        communityReserve -= amount;
        _transfer(address(this), recipient, amount);
    }
}
