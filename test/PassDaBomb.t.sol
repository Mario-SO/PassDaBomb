// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PassDaBomb.sol";

contract PassDaBombTest is Test {
    PassDaBomb passDaBomb;

    function setUp() public {
        passDaBomb = new PassDaBomb();
    }

    function test_transferDaBomb() public {
        passDaBomb.transferDaBomb(address(this));
        assert.equal(
            passDaBomb.daBombs(0).currentHolder,
            address(this),
            "current holder should be this contract"
        );
    }

    function test_defuseDaBomb() public {
        passDaBomb.defuseDaBomb{value: 0.1 ether}();
        assert.equal(
            passDaBomb.daBombs(0).currentHolder,
            address(0),
            "current holder should be 0x0"
        );
    }

    // test bombexploded function by setting block timestamp to 1 day after bomb countdown
    function test_bombExploded() public {
        passDaBomb.transferDaBomb(address(this));
        block.timestamp = passDaBomb.daBombs(0).bombCountdown + 1 days;
        passDaBomb.defuseDaBomb{value: 0.1 ether}();
        assert.equal(
            passDaBomb.daBombs(0).currentHolder,
            address(0),
            "current holder should be 0x0"
        );
    }
}
