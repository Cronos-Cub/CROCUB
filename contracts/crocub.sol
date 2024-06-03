// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract CronosCubToken is ERC20, ERC20Burnable {
    uint256 private constant INITIAL_SUPPLY = 500_000_000_000 * 10**18; // 500 billion tokens with 18 decimals
    address private _owner;

    uint256 public feePercent = 3; // 3% total transaction fee
    address public feeCollector;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    constructor(address _feeCollector) ERC20("Cronos Cub Token", "CROCUB") {
        _owner = msg.sender;
        _mint(msg.sender, INITIAL_SUPPLY);
        feeCollector = _feeCollector;
    }

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

    // Function to set the fee percentages
    function setFeePercent(uint256 _feePercent) external onlyOwner {
        feePercent = _feePercent;
    }

    // Function to set the fee collector address
    function setFeeCollector(address _feeCollector) external onlyOwner {
        feeCollector = _feeCollector;
    }

    // External mint function disabled to prevent any minting after deployment
    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() == 0, "Minting can only occur during initial deployment");
        _mint(to, amount);
    }

    // Function to burn tokens, reducing total supply
    function burn(uint256 amount) public override {
        super.burn(amount);
    }

    // Function to burn tokens from a specific address
    function burnFrom(address account, uint256 amount) public override {
        super.burnFrom(account, amount);
    }

    // Function to get the owner address
    function owner() public view returns (address) {
        return _owner;
    }

    // Function to transfer ownership to a new address
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        _owner = newOwner;
    }
}
