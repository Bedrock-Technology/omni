// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console, Script} from "forge-std/Script.sol";

import {brBTCRate} from "../contracts/brBTCRate.sol";
import {brBTCRawBTCExchangeRateChainlinkAdapter} from "../contracts/brBTCRawBTCExchangeRateChainlinkAdapter.sol";

contract MyScript is Script {
    function run() external {
        address deployer = vm.envAddress("DEPLOYER_ADDRESS");

        vm.startBroadcast(deployer);
        brBTCRate _brRate = new brBTCRate();
        brBTCRawBTCExchangeRateChainlinkAdapter _adapter = new brBTCRawBTCExchangeRateChainlinkAdapter(address(_brRate));
        vm.stopBroadcast();

        console.log("[Contract] brBTCRate:", address(_brRate));
        console.log("[Contract] brBTCRawBTCExchangeRateChainlinkAdapter:", address(_adapter));
    }
}
