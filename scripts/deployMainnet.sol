// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "@src/FlaixVault.sol";
import "@src/FlaixCallOption.sol";
import "@src/FlaixPutOption.sol";
import "@src/FlaixOptionFactory.sol";
import "@src/FlaixTestGov.sol";
import "@mock-tokens/MockERC20.sol";

contract DeployMainnet is Script {
    function run() public {
        uint deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        FlaixCallOption callOption = new FlaixCallOption();
        FlaixPutOption putOption = new FlaixPutOption();
        FlaixOptionFactory optionFactory = new FlaixOptionFactory(address(callOption), address(putOption));

        FlaixVault vault = new FlaixVault(address(optionFactory));
        console.log("FlaixVault deployed at: ", address(vault));

        address admin = address(0xeF0053Dc1469aDAb91134f53032aE5f142f6a146);
        vault.changeAdmin(address(admin));

        vm.stopBroadcast();
    }
}
