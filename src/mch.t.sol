pragma solidity 0.5.12;

import "ds-test/test.sol";

import "./mch.sol";

contract MCHTest is DSTest {
    MCH mch;

    function setUp() public {
        mch = new MCH();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
