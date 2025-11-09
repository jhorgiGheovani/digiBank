// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title SimpleBankOptimized
 * @notice Gas-optimized version of SimpleBank
 */
contract SimpleBankOptimized {
    // ============ Custom Errors (Already optimized!) ============

    error InsufficientBalance(uint256 requested, uint256 available);
    error ZeroAmount();
    error TransferFailed();

    // ============ State Variables ============

    mapping(address => uint256) public balances;

    // ============ Events (Already optimized!) ============

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Transferred(address indexed from, address indexed to, uint256 amount);

    // ============ Functions ============

    function deposit() external payable {
        // Optimization: Use external instead of public
        // External = cheaper for external calls (calldata instead of memory)

        if (msg.value == 0) revert ZeroAmount();

        balances[msg.sender] += msg.value;

        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        // Optimization: Cache storage variable
        uint256 userBalance = balances[msg.sender]; // 1x SLOAD

        if (amount == 0) revert ZeroAmount();

        if (userBalance < amount) {
            revert InsufficientBalance(amount, userBalance);
        }

        // CEI Pattern: Update state before transfer
        unchecked {
            // Safe: we checked userBalance >= amount above
            balances[msg.sender] = userBalance - amount;
        }

        // Transfer ETH
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();

        emit Withdrawn(msg.sender, amount);
    }

    function transfer(address to, uint256 amount) external {
        // Optimization: Cache storage variable
        uint256 senderBalance = balances[msg.sender]; // 1x SLOAD

        if (amount == 0) revert ZeroAmount();

        if (senderBalance < amount) {
            revert InsufficientBalance(amount, senderBalance);
        }

        // Update balances
        unchecked {
            // Safe: we checked senderBalance >= amount above
            balances[msg.sender] = senderBalance - amount;
        }
        balances[to] += amount; // 1x SLOAD, 1x SSTORE

        emit Transferred(msg.sender, to, amount);
    }

    function getBalance(address account) external view returns (uint256) {
        return balances[account];
    }

    function getTotalDeposits() external view returns (uint256) {
        return address(this).balance;
    }
}