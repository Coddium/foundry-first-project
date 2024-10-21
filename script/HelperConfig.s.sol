// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetwordConfig {
        address priceFeed; // ETH/USD priceFeed address
    }

    NetwordConfig public activeNetworkConfig;

    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_PRICE = 2600e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = createAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetwordConfig memory) {
        NetwordConfig memory sepoliaConfig = NetwordConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetwordConfig memory) {
        NetwordConfig memory mainnetConfig = NetwordConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return mainnetConfig;
    }

    function createAnvilEthConfig() public returns (NetwordConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetwordConfig memory anvilConfig = NetwordConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }
}
