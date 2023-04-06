// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Conversions {

    function uint256ToAddress(uint256 input) public pure returns (address output) {
        return (address(uint160(input)));
    }

}