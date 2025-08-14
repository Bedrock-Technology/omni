// SPDX-License-Identifier: MIT

pragma solidity >=0.8.22;

import {Script, console} from "forge-std/Script.sol";
import {brBTCOFTAdapter} from "../contracts/brBTCOFTAdapter.sol";
import {HelperUtils} from "./utils/HelperUtils.s.sol";
import {OptionsBuilder} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";
import {SendParam} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";
import {MessagingFee, MessagingReceipt} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFTCore.sol";
import {brBTC} from "../contracts/mocks/brBTC.sol";

contract SetOFTAdapter is Script {
    using OptionsBuilder for bytes;

    function run() external {}

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
//forge script script/SendToken.s.sol --sig 'sendToken(address,uint256,uint256)' $RECIPIENT_ADDRESS $AMOUNT_IN_UNIT $DST_CHAIN_ID --rpc-url $RPC_ETH --account $SENDER_ACCOUNT_NAME --sender $SENDER_ACCOUNT_ADDRESS --broadcast
    function sendToken(address _recipient, uint256 _amount, uint256 _chainid) external {
        // Get the current chain name based on the chain ID
        string memory chainName = HelperUtils.getNetworkConfig(block.chainid).chainName;
        string memory peerChainName = HelperUtils.getNetworkConfig(_chainid).chainName;
        string memory localPoolPath =
            string.concat(vm.projectRoot(), "/script/output/deployedOFTAdapter_", chainName, ".json");
        // Extract addresses from the JSON files
        address oftAdapterAddress =
            HelperUtils.getAddressFromJson(vm, localPoolPath, string.concat(".deployedOFTAdapter_", chainName));
        brBTCOFTAdapter adapter = brBTCOFTAdapter(oftAdapterAddress);

        HelperUtils.NetworkConfig memory peerNetworkConfig = HelperUtils.getNetworkConfig(_chainid);
        HelperUtils.NetworkConfig memory networkConfig = HelperUtils.getNetworkConfig(block.chainid);

        SendParam memory sendParam = SendParam(
            peerNetworkConfig.eid,
            addressToBytes32(_recipient),
            _amount,
            _amount,
            OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0),
            "",
            ""
        );
        MessagingFee memory fee = adapter.quoteSend(sendParam, false);

	address fromAddress = msg.sender;
        vm.startBroadcast(fromAddress);
        uint256 allowance = brBTC(networkConfig.brBTC).allowance(fromAddress, oftAdapterAddress);
        if (allowance < _amount) {
            brBTC(networkConfig.brBTC).approve(oftAdapterAddress, _amount * 10);
        }
        console.log("SendParam:");
        console.log("  dstEid:", sendParam.dstEid);
        console.log("  to:");
        console.logBytes32(sendParam.to);
        console.log("  amountLD:", sendParam.amountLD);
        console.log("  minAmountLS:", sendParam.minAmountLD);
        console.log("  extraOptions:");
        console.logBytes(sendParam.extraOptions);
        console.log("  composeMsg:");
        console.logBytes(sendParam.composeMsg);
        console.log("  oftCmd:");
        console.logBytes(sendParam.oftCmd);
        console.log("Fee:");
        console.log("  nativeFee:", fee.nativeFee);
        console.log("  lzTokenFee:", fee.lzTokenFee);
        console.log("refundAddress:", fromAddress);
        adapter.send{value: fee.nativeFee}(sendParam, fee, payable(fromAddress));
        vm.stopBroadcast();
        console.log("send %s, to:", chainName, peerChainName);
        console.log("fee:", fee.nativeFee);
        console.log("recipient:%s, amount:", _recipient, _amount);
    }
}
