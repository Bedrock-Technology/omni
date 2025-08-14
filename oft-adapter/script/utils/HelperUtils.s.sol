// SPDX-License-Identifier: MIT
pragma solidity >=0.8.22;

import {stdJson} from "forge-std/StdJson.sol";
import {Vm} from "forge-std/Vm.sol";

library HelperUtils {
    using stdJson for string;

    struct ExecutorConfig {
        uint32 maxMessageSize;
        address executorAddress;
    }

    struct UlnConfig {
        uint64 confirmations;
        uint8 requiredDVNCount;
        uint8 optionalDVNCount;
        uint8 optionalDVNThreshold;
        address[] requiredDVNs;
        address[] optionalDVNs;
    }

    struct NetworkConfig {
        string chainName;
        uint256 chainId;
        uint32 eid;
        address endPoint;
        address brBTC;
        address sendUln302;
        address receiveUIn302;
        bool whitelist;
    }

    function getAllEids() public pure returns (uint32[8] memory) {
        uint32[8] memory allEids = [uint32(40161), 40217, 40346, 40231, 30101, 30102, 30362, 30377];
        return allEids;
    }

    function getNetworkConfig(uint256 chainIdorEid) internal pure returns (NetworkConfig memory) {
        if (chainIdorEid == 17000 || chainIdorEid == 40217) {
            return getEthereumHoleskyConfig();
        } else if (chainIdorEid == 11155111 || chainIdorEid == 40161) {
            return getEthereumSepoliaConfig();
        } else if (chainIdorEid == 80000 || chainIdorEid == 40346) {
            return getBeraCartioConfig();
        } else if (chainIdorEid == 421614 || chainIdorEid == 40231) {
            return getArbitrumSepoliaConfig();
            // } else if (chainId == 84532) {
            //     return helperConfig.getBaseSepoliaConfig();
        } else if (chainIdorEid == 1 || chainIdorEid == 30101) {
            return getEthereumMainnetConfig();
            // } else if (chainId == 42161) {
            //     return helperConfig.getArbConfig();
        } else if (chainIdorEid == 56 || chainIdorEid == 30102) {
            return getBscMainnetConfig();
            // } else if (chainId == 10) {
            //     return helperConfig.getOptConfig();
            // } else if (chainId == 34443) {
            //     return helperConfig.getModeConfig();
        } else if (chainIdorEid == 80094 || chainIdorEid == 30362) {
            return getBeraMainnetConfig();
        } else if (chainIdorEid == 239 || chainIdorEid == 30377) {
            return getTacMainnetConfig();
        } else {
            revert("Unsupported chain ID");
        }
    }

    function getEthereumMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethereumMainnet = NetworkConfig({
            chainName: "ethereumMainnet",
            chainId: 1,
            eid: 30101,
            endPoint: 0x1a44076050125825900e736c501f859c50fE728c,
            brBTC: 0x2eC37d45FCAE65D9787ECf71dc85a444968f6646,
            sendUln302: 0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1,
            receiveUIn302: 0xc02Ab410f0734EFa3F14628780e6e695156024C2,
            whitelist: false
        });

        return ethereumMainnet;
    }

    function getBscMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory BscMainnet = NetworkConfig({
            chainName: "bscMainnet",
            chainId: 56,
            eid: 30102,
            endPoint: 0x1a44076050125825900e736c501f859c50fE728c,
            brBTC: address(0),
            sendUln302: 0x9F8C645f2D0b2159767Bd6E0839DE4BE49e823DE,
            receiveUIn302: 0xB217266c3A98C8B2709Ee26836C98cf12f6cCEC1,
            whitelist: true
        });

        return BscMainnet;
    }

    function getBeraMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory BeraMainnet = NetworkConfig({
            chainName: "beraMainnet",
            chainId: 80094,
            eid: 30362,
            endPoint: 0x6F475642a6e85809B1c36Fa62763669b1b48DD5B,
            brBTC: address(0),
            sendUln302: 0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7,
            receiveUIn302: 0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043,
            whitelist: true
        });

        return BeraMainnet;
    }

    function getTacMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory TacMainnet = NetworkConfig({
            chainName: "tacMainnet",
            chainId: 239,
            eid: 30377,
            endPoint: 0x6F475642a6e85809B1c36Fa62763669b1b48DD5B,
            brBTC: 0x8a94866dF557Bb7FCe88EfF9917237286098e590,
            sendUln302: 0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7,
            receiveUIn302: 0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043,
            whitelist: false
        });

        return TacMainnet;
    }

    function getEthereumHoleskyConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethereumHolesky = NetworkConfig({
            chainName: "ethereumHolesky",
            chainId: 17000,
            eid: 40217,
            endPoint: 0x6EDCE65403992e310A62460808c4b910D972f10f,
            brBTC: address(0),
            sendUln302: 0x21F33EcF7F65D61f77e554B4B4380829908cD076,
            receiveUIn302: 0xbAe52D605770aD2f0D17533ce56D146c7C964A0d,
            whitelist: true
        });

        return ethereumHolesky;
    }

    function getEthereumSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethereumSepolia = NetworkConfig({
            chainName: "ethereumSepolia",
            chainId: 11155111,
            eid: 40161,
            endPoint: 0x6EDCE65403992e310A62460808c4b910D972f10f,
            brBTC: address(0),
            sendUln302: 0xcc1ae8Cf5D3904Cef3360A9532B477529b177cCE,
            receiveUIn302: 0xdAf00F5eE2158dD58E0d3857851c432E34A3A851,
            whitelist: false
        });

        return ethereumSepolia;
    }

    function getBeraCartioConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory beraCartio = NetworkConfig({
            chainName: "beraCartio",
            chainId: 80000,
            eid: 40346,
            endPoint: 0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff,
            brBTC: address(0),
            sendUln302: 0xd682ECF100f6F4284138AA925348633B0611Ae21,
            receiveUIn302: 0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C,
            whitelist: false
        });

        return beraCartio;
    }

    function getArbitrumSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory arbitrumSepolia = NetworkConfig({
            chainName: "arbitrumSepolia",
            chainId: 421614,
            eid: 40231,
            endPoint: 0x6EDCE65403992e310A62460808c4b910D972f10f,
            brBTC: address(0),
            sendUln302: 0x4f7cd4DA19ABB31b0eC98b9066B9e857B1bf9C0E,
            receiveUIn302: 0x75Db67CDab2824970131D5aa9CECfC9F69c69636,
            whitelist: false
        });

        return arbitrumSepolia;
    }

    function getAddressFromJson(Vm vm, string memory path, string memory key) internal view returns (address) {
        string memory json = vm.readFile(path);
        return json.readAddress(key);
    }

    function getBoolFromJson(Vm vm, string memory path, string memory key) internal view returns (bool) {
        string memory json = vm.readFile(path);
        return json.readBool(key);
    }

    function getStringFromJson(Vm vm, string memory path, string memory key) internal view returns (string memory) {
        string memory json = vm.readFile(path);
        return json.readString(key);
    }

    function getUintFromJson(Vm vm, string memory path, string memory key) internal view returns (uint256) {
        string memory json = vm.readFile(path);
        return json.readUint(key);
    }

    function bytes32ToHexString(bytes32 _bytes) internal pure returns (string memory) {
        bytes memory hexString = new bytes(64);
        bytes memory hexAlphabet = "0123456789abcdef";
        for (uint256 i = 0; i < 32; i++) {
            hexString[i * 2] = hexAlphabet[uint8(_bytes[i] >> 4)];
            hexString[i * 2 + 1] = hexAlphabet[uint8(_bytes[i] & 0x0f)];
        }
        return string(hexString);
    }

    function uintToStr(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        return string(bstr);
    }
}
