// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract TimedWithdrawal {
    struct User {
        uint256 balance;
        uint256 unlockTime;
    }

    mapping(address => User) public users;

    function deposit(uint256 _unlockTime) external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        require(_unlockTime > block.timestamp, "Invalid unlock time");

        users[msg.sender].balance += msg.value;
        users[msg.sender].unlockTime = _unlockTime;
    }

    function withdraw() external {
        require(block.timestamp >= users[msg.sender].unlockTime, "Funds are locked");
        require(users[msg.sender].balance > 0, "No funds to withdraw");

        uint256 amount = users[msg.sender].balance;
        users[msg.sender].balance = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function getBalance(address user) external view returns (uint256) {
        return users[user].balance;
    }
}