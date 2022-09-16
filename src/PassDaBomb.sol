// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// import reentrancy guard
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import onlyowner
import "@openzeppelin/contracts/access/Ownable.sol";

contract PassDaBomb is Ownable, ReentrancyGuard {
    uint256 BOMB_COUNTDOWN = block.timestamp + 24 hours;

    address public currentHolder;
    address[] public previousHolders;

    address previousExploder;
    address[] bombExploderAddresses;

    event BombExploded(
        address indexed exploder,
        address indexed previousHolder
    );
    event BombPassed(address indexed newHolder, address indexed previousHolder);
    event BombDefused(address indexed defuser);

    constructor() {
        currentHolder = msg.sender;
    }

    function transferDaBomb(address newHolder) public payable {
        require(
            msg.value >= 0.01 ether,
            "You must pay 0.01 ether to get rid of da bomb"
        );
        require(msg.sender == currentHolder, "You are not the current holder");
        require(
            block.timestamp < BOMB_COUNTDOWN,
            "The bomb has already exploded"
        );

        previousHolders.push(currentHolder);
        currentHolder = newHolder;
        emit BombPassed(newHolder, msg.sender);
    }

    function defuseDaBomb() public payable nonReentrant {
        require(
            msg.value >= 0.1 ether,
            "You need to pay 0.1 ether to defuse the bomb"
        );
        require(msg.sender == currentHolder, "You are not the current holder");
        require(
            block.timestamp > BOMB_COUNTDOWN,
            "The bomb has not exploded yet"
        );

        emit BombDefused(msg.sender);
    }

    function bombExploded() public {
        bombExploderAddresses.push(currentHolder);
        previousExploder = currentHolder;
        emit BombExploded(
            currentHolder,
            previousHolders[previousHolders.length - 1]
        );
    }

    // Getter functions
    function getPreviousHolders() public view returns (address[] memory) {
        return previousHolders;
    }

    function getCurrentHolder() public view returns (address) {
        return currentHolder;
    }

    function getPreviousHolder(uint256 index) public view returns (address) {
        return previousHolders[index];
    }

    function getPreviousHoldersCount() public view returns (uint256) {
        return previousHolders.length;
    }

    // OnlyOwner functions
    function withdraw() public payable onlyOwner nonReentrant {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

}