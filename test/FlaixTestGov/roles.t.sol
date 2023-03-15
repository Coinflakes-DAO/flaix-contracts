// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@src/FlaixTestGov.sol";
import {FlaixTestGovBase_Test} from "./FlaixTestGovBase.t.sol";

contract Roles_Test is FlaixTestGovBase_Test {
    function test_adminIsOwner() public {
        assertEq(flaixTestGov.owner(), users.admin);
    }

    function test_govContractIsAdmin() public {
        assertEq(vault.admin(), govAddr);
    }
}
