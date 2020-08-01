pragma solidity ^0.5.12;

import "ds-test/test.sol";

import "./Mch.sol";

contract MchTest is DSTest {
    Mch mch;

    function setUp() public {
        mch = new Mch();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
