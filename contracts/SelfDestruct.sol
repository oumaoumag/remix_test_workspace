// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract SelfDestruct {
    constructor(address payable _target) payable {
        require(msg.value == 0.0005 ether, "Must send exactly 0.0005 ether");
        selfdestruct(_target);
    }
}