// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "@src/FlaixVault.sol";
import "@mock-tokens/MockERC20.sol";

contract DeploySepolia is Script {
    function run() public {
        uint deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address mockErc20 = address(new MockERC20("Alpha AI", "alphaAI", 18));
        console.log("Alpha AI deployed at: ", mockErc20);
        mockErc20 = address(new MockERC20("Beta AI", "betaAI", 18));
        console.log("Beta AI deployed at: ", mockErc20);
        mockErc20 = address(new MockERC20("Gamma AI", "gammaAI", 18));
        console.log("Gamma AI deployed at: ", mockErc20);

        FlaixVault vault = new FlaixVault("Coinflakes AI Vault", "FLAIX");
        console.log("FlaixVault deployed at: ", address(vault));

        vm.stopBroadcast();
    }
}
