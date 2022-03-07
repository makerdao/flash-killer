// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./FlashKiller.sol";

contract FlashKillerTest is DSTest {
    FlashKiller killer;

    function setUp() public {
        killer = new FlashKiller();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
