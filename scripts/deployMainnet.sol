// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "@src/FlaixVault.sol";
import "@mock-tokens/MockERC20.sol";

contract DeployMainnet is Script {
    function run() public {
        uint deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        FlaixVault vault = new FlaixVault("Coinflakes AI Vault", "FLAIX");
        console.log("FlaixVault deployed at: ", address(vault));

        address admin = address(0xeF0053Dc1469aDAb91134f53032aE5f142f6a146);
        vault.changeAdmin(address(admin));

        vm.stopBroadcast();
    }
}
