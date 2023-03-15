// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@mock-tokens/MockERC20.sol";

contract Base_Test is Test {
    struct Users {
        address deployer;
        address admin;
        address alice;
        address bob;
    }

    Users public users;

    struct Tokens {
        MockERC20 dai;
        MockERC20 usdc;
    }

    Tokens public tokens;

    function setUp() public virtual {
        setUp_users();
        setUp_tokens();
    }

    function setUp_users() public virtual {
        users = Users({
            deployer: makeAddr("deployer"),
            admin: makeAddr("admin"),
            alice: makeAddr("alice"),
            bob: makeAddr("bob")
        });
    }

    function setUp_tokens() public virtual {
        tokens = Tokens({dai: new MockERC20("Dai Stablecoin", "DAI", 18), usdc: new MockERC20("USD Coin", "USDC", 6)});
    }
}
