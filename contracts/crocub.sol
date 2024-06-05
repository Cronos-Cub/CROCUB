// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract CronosCubToken is ERC20, ERC20Burnable {
    uint256 private constant INITIAL_SUPPLY = 500_000_000_000 * 10**18; // 500 billion tokens with 18 decimals
    address private _owner;

    uint256 public feePercent = 2; // 2% total transaction fee
    address public feeCollector;

    struct VestingSchedule {
        uint256 totalAmount;
        uint256 amountReleased;
        uint256 startTime;
        uint256 cliffDuration;
        uint256 duration;
    }

    mapping(address => VestingSchedule) private vestingSchedules;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    event FeePercentUpdated(uint256 newFeePercent);
    event FeeCollectorUpdated(address newFeeCollector);
    event VestingScheduleCreated(address indexed beneficiary, uint256 totalAmount, uint256 startTime, uint256 cliffDuration, uint256 duration);
    event TokensReleased(address indexed beneficiary, uint256 amount);

    constructor(address _feeCollector) ERC20("Cronos Cub Token", "CROCUB") {
        _owner = msg.sender;
        _mint(msg.sender, INITIAL_SUPPLY);
        feeCollector = _feeCollector;
    }

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

    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() == 0, "Minting can only occur during initial deployment");
        _mint(to, amount);
    }

    function burn(uint256 amount) public override {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount) public override {
        super.burnFrom(account, amount);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        _owner = newOwner;
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
