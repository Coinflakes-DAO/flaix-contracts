// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@test/UniswapV3Position/UniswapV3PositionBase.t.sol";

contract PoolAddressDefaultValue is UniswapV3PositionBaseTest {
    function test_tokenId_defaultValue_is_0() public {
        assertEq(position.positionId(), 0);
    }

    function test_poolAddress_defaultValue() public {
        assertEq(address(position.pool()), 0x99ac8cA7087fA4A2A1FB6357269965A2014ABc35);
    }

    function test_positionManager_defaultValue() public {
        assertEq(address(position.positionManager()), 0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
    }

    function test_totalSupply_defaultValue_is_0() public {
        assertEq(position.totalSupply(), 0);
    }

    function test_token0_defaultValue() public {
        assertEq(position.pool().token0(), WBTC);
    }

    function test_token1_defaultValue() public {
        assertEq(position.pool().token1(), USDC);
    }

    function test_feeCollector_defaultValue() public {
        assertEq(address(position.feeCollector()), users.bob);
    }
}
