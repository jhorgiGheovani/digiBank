// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {SimpleBank} from "../src/SimpleBank.sol";

/**
 * @title DeploySimpleBank
 * @notice Script untuk deploy SimpleBank contract
 */
contract DeploySimpleBank is Script {
    function run() external returns (SimpleBank) {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy contract
        SimpleBank bank = new SimpleBank();

        console.log("SimpleBank deployed to:", address(bank));

        // Stop broadcasting
        vm.stopBroadcast();

        return bank;
    }
}