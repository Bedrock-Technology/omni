// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {omniBTC} from "../contracts/omniBTC.sol";
import {omniVault} from "../contracts/omniVault.sol";
import {WBTC} from "../contracts/mocks/WBTC.sol";

contract OmniVaultTest is Test {
    address private constant _PROXY_ADMIN = address(0x1);
    address private constant _DEFAULT_ADMIN = address(0x2);
    address private constant _DEFAULT_MINTER = address(0x3);

    omniBTC public omniBTCInstance;
    omniVault public omniVaultInstance;

    function setUp() public {
        setUpOmniBTC();
        setUpOmniVault();
    }

    function setUpOmniVault() public {
        omniVault impl = new omniVault();

        bytes memory initializeData =
            abi.encodeWithSelector(omniVault.initialize.selector, _DEFAULT_ADMIN, address(omniBTCInstance));
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(impl), _PROXY_ADMIN, initializeData);
        omniVaultInstance = omniVault(payable(address(proxy)));

        assert(omniVaultInstance.hasRole(omniVaultInstance.DEFAULT_ADMIN_ROLE(), _DEFAULT_ADMIN));
        assert(omniVaultInstance.hasRole(omniVaultInstance.PAUSER_ROLE(), _DEFAULT_ADMIN));

        // prank only works for the *next* call, so read role before pranking
        bytes32 operatorRole = omniVaultInstance.OPERATOR_ROLE();
        vm.prank(_DEFAULT_ADMIN);
        omniVaultInstance.grantRole(operatorRole, _DEFAULT_MINTER);
        assert(omniVaultInstance.hasRole(omniVaultInstance.OPERATOR_ROLE(), _DEFAULT_MINTER));

        bytes32 omniBTCMinterRole = omniBTCInstance.MINTER_ROLE();
        vm.prank(_DEFAULT_ADMIN);
        omniBTCInstance.grantRole(omniBTCMinterRole, address(omniVaultInstance));
        assert(omniBTCInstance.hasRole(omniBTCMinterRole, address(omniVaultInstance)));
    }

    function setUpOmniBTC() public {
        omniBTC impl = new omniBTC();

        bytes memory initializeData =
            abi.encodeWithSelector(omniBTC.initialize.selector, _DEFAULT_ADMIN, _DEFAULT_MINTER, new address[](0));
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(impl), _PROXY_ADMIN, initializeData);
        omniBTCInstance = omniBTC(address(proxy));

        assertEq(omniBTCInstance.name(), "omniBTC");
        assertEq(omniBTCInstance.decimals(), 8);
        assert(omniBTCInstance.hasRole(omniBTCInstance.DEFAULT_ADMIN_ROLE(), _DEFAULT_ADMIN));
        assert(omniBTCInstance.hasRole(omniBTCInstance.MINTER_ROLE(), _DEFAULT_MINTER));
    }

    function testMint() public {
        WBTC wbtc = new WBTC();
        IERC20 omniBTCToken = IERC20(omniVaultInstance.omniBTC());

        address[] memory allowedToken = new address[](1);
        allowedToken[0] = address(wbtc);

        vm.prank(_DEFAULT_ADMIN);
        omniVaultInstance.allowToken(allowedToken);

        vm.prank(_DEFAULT_ADMIN);
        omniVaultInstance.setCap(address(wbtc), 100 * 1e8);

        address _alice = address(0x123123);
        wbtc.mint(_alice, 1 * 1e8);
        assertEq(wbtc.balanceOf(_alice), 1 * 1e8);

        vm.prank(_alice);
        wbtc.approve(address(omniVaultInstance), 1 * 1e8);
        vm.prank(_alice);
        omniVaultInstance.mint(address(wbtc), 1 * 1e8);

        assertEq(wbtc.balanceOf(_alice), 0);
        assertEq(omniBTCToken.balanceOf(_alice), 1 * 1e8);
    }
}