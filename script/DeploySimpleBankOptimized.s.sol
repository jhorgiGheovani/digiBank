// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {SimpleBankOptimized} from "../src/SimpleBankOptimized.sol";

/**
 * @title DeploySimpleBankOptimized
 * @notice Script untuk deploy SimpleBank contract
 */
contract DeploySimpleBankOptimized is Script {
    function run() external returns (SimpleBankOptimized) {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy contract
        SimpleBankOptimized bank = new SimpleBankOptimized();

        console.log("SimpleBank deployed to:", address(bank));

        // Stop broadcasting
        vm.stopBroadcast();

        return bank;
    }
}