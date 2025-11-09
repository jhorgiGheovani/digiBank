// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title SimpleBank
 * @author Ethereum Jakarta
 * @notice Bank sederhana untuk deposit, withdraw, dan transfer ETH
 * @dev Demo contract untuk Kelas Rutin Batch IV
 */
contract SimpleBank {
    // Custom Errors (lebih gas efficient!)
    error InsufficientBalance(uint256 requested, uint256 available);
    error ZeroAmount();
    error TransferFailed();

    // State variables
    mapping(address => uint256) public balances;

    // Events
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Transferred(address indexed from, address indexed to, uint256 amount);

    // Constructor
    constructor() {
        // Empty constructor - no initialization needed
    }

    function deposit() public payable {
        // Validasi: amount harus > 0
        if (msg.value == 0) revert ZeroAmount();

        // Update balance
        balances[msg.sender] += msg.value;

        // Emit event
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        // Validasi: amount harus > 0
        if (amount == 0) revert ZeroAmount();

        // Validasi: balance cukup?
        uint256 currentBalance = balances[msg.sender];
        if (currentBalance < amount) {
            revert InsufficientBalance(amount, currentBalance);
        }

        // Update balance SEBELUM transfer (CEI pattern!)
        balances[msg.sender] -= amount;

        // Transfer ETH ke user
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();

        // Emit event
        emit Withdrawn(msg.sender, amount);
    }

    function transfer(address to, uint256 amount) public {
        // Validasi: amount harus > 0
        if (amount == 0) revert ZeroAmount();

        // Validasi: balance cukup?
        uint256 currentBalance = balances[msg.sender];
        if (currentBalance < amount) {
            revert InsufficientBalance(amount, currentBalance);
        }

        // Update balances (CEI pattern)
        balances[msg.sender] -= amount;
        balances[to] += amount;

        // Emit event
        emit Transferred(msg.sender, to, amount);
    }

    function getBalance(address account) public view returns (uint256) {
        return balances[account];
    }

    function getTotalDeposits() public view returns (uint256) {
        return address(this).balance;
    }
}
