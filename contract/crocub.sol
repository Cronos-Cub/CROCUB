// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CronosCubToken is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("Cronos Cub Token", "CROCUB") {
        _mint(msg.sender, 500_000_000_000 * 10 ** decimals());
    }

    // Overriding the _mint function to restrict further minting
    function _mint(address account, uint256 amount) internal override onlyOwner {
        require(totalSupply() == 0, "Minting can only occur during initial deployment");
        super._mint(account, amount);
    }

    // External mint function disabled to prevent any minting after deployment
    function mint(address to, uint256 amount) public onlyOwner {
        revert("Minting is not allowed after initial deployment");
    }

    function burn(uint256 amount) public override {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount) public override {
        super.burnFrom(account, amount);
    }
}
