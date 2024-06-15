// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CronosCubToken is ERC20, ERC20Burnable, Ownable {
    uint256 private constant INITIAL_SUPPLY = 500_000_000_000 * 10**18; // 500 billion tokens with 18 decimals

    struct VestingSchedule {
        uint256 totalAmount;
        uint256 amountReleased;
        uint256 startTime;
        uint256 cliffDuration;
        uint256 duration;
    }

    mapping(address => VestingSchedule) private vestingSchedules;

    event VestingScheduleCreated(address indexed beneficiary, uint256 totalAmount, uint256 startTime, uint256 cliffDuration, uint256 duration);
    event TokensReleased(address indexed beneficiary, uint256 amount);

    constructor(address _initialOwner) ERC20("Cronos Cub", "CROCUB") Ownable(_initialOwner) {
        _mint(_initialOwner, INITIAL_SUPPLY);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() == 0, "Minting can only occur during initial deployment");
        _mint(to, amount);
    }

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
}
