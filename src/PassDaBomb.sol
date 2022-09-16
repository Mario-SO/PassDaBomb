// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// TODO: Draw the state diagram for this contract


// Globals: BombId
/* Bomb Specific: 
    bombCountdown,
    currentHolder,
    previousHolders,
    previousExploders,
    bombDefusers
*/

// States: Transfer, Defuse, Exploded

/*  
    Transfer: 
        Update the bomb countdown,
        current holder,
        previous holder,
        previous holders list
    Defuse: 
        Update defusers list,
        find a way to create a new bomb,
        push last bomb to DaBombs list
    Exploded: 
        Update previous exploder,
        previous exploders list,
        find a way to create a new bomb,
        push last bomb to DaBombs list
*/

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PassDaBomb is Ownable, ReentrancyGuard {
    uint256 currentBombId = 0;

    struct DaBomb {
        uint256 bombCountdown;
        address currentHolder;
        address[] previousHolders;
        address previousExploder;
        address[] bombExploderAddresses;
        address[] bombDefuserAddresses;
    }

    DaBomb[] public daBombs;

    DaBomb daBomb =
        DaBomb({
            bombCountdown: block.timestamp,
            currentHolder: msg.sender,
            previousHolders: new address[](0),
            previousExploder: address(0),
            bombExploderAddresses: new address[](0),
            bombDefuserAddresses: new address[](0)
        });

    event BombTransferred(address indexed from, address indexed to);
    event BombDefused(address indexed from, address indexed to);
    event BombExploded(address indexed from, address indexed to);

    constructor() {
        daBombs.push(daBomb);
    }

    function transferDaBomb(address newHolder) public payable {
        if (msg.sender != owner()) {
            require(
                msg.value >= 0.01 ether,
                "You must pay 0.01 ether to get rid of da bomb"
            );
        }
        require(
            msg.sender == daBomb.currentHolder,
            "You are not the current holder"
        );
        require(
            block.timestamp < daBomb.bombCountdown,
            "The bomb has already exploded"
        );
        daBomb.currentHolder = newHolder;
        daBomb.previousHolders.push(msg.sender);
        daBomb.bombCountdown = block.timestamp + 1 days;
    }

    function defuseDaBomb(uint256 _currentBombId) public payable nonReentrant {
        require(
            msg.value >= 0.1 ether,
            "You need to pay 0.1 ether to defuse the bomb"
        );
        require(
            msg.sender == daBomb.currentHolder,
            "You are not the current holder"
        );
        require(
            block.timestamp > daBomb.bombCountdown,
            "The bomb has not exploded yet"
        );
        // TODO: add logic for a defused bomb
    }

    function bombExploded() public {
        daBomb.bombExploderAddresses.push(daBomb.currentHolder);
        daBomb.previousExploder = daBomb.currentHolder;

        daBombs[daBombs.length] = daBomb;
    }

    // OnlyOwner functions
    function withdraw() public payable onlyOwner nonReentrant {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }
}
