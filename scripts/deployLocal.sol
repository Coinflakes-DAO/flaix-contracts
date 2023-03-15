// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "@src/FlaixVault.sol";
import "@src/FlaixCallOption.sol";
import "@src/FlaixPutOption.sol";
import "@src/FlaixOptionFactory.sol";

contract DeployLocal is Script {
    function run() public {
        vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
        FlaixCallOption callOption = new FlaixCallOption();
        FlaixPutOption putOption = new FlaixPutOption();
        FlaixOptionFactory optionFactory = new FlaixOptionFactory(address(callOption), address(putOption));

        FlaixVault vault = new FlaixVault(address(optionFactory));
        console.log("FlaixVault deployed at: ", address(vault));
        vm.stopBroadcast();
    }
}
